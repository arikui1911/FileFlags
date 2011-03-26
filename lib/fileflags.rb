require 'forwardable'
require 'date'
require 'yaml'
require 'singleton'

module FileFlags
  def self.suites
    @suites ||= []
  end

  class Suite
    TS_FILE = ".fileflag.timestamp"

    def initialize(directory, &block)
      @dir = File.expand_path(directory)
      raise ArgumentError, "no such directory - #{directory}" unless File.directory?(@dir)
      @startups  = []
      @shutdowns = []
      @matchers  = []
      @context   = create_context_class(&block)
    end

    def execute
      Dir.chdir(@dir) do
        load_timestamp
        context = @context.new
        @startups.each{|hook| context.instance_eval(&hook) }
        Entry.glob(@dir).each do |e|
          @matchers.each do |pattern, func|
            if updated?(e) && e.fnmatch(pattern)
              context.instance_exec(e, &func)
              break
            end
          end
        end
        @shutdowns.each{|hook| context.instance_eval(&hook) }
      end
    ensure
      update_timestamp
    end

    private

    def create_context_class(&body)
      table = {
        startup:  @startups,
        shutdown: @shutdowns,
        file:     @matchers,
      }
      Class.new{
        define_singleton_method(:startup){|&block| table[:startup] << block }
        define_singleton_method(:shutdown){|&block| table[:shutdown] << block }
        define_singleton_method(:file){|glob, &block| table[:file] << [glob, block] }
        class_eval(&body)
      }
    end

    def updated?(entry)
      @timestamp ? entry.updated?(@timestamp) : true
    end

    def load_timestamp
      @timestamp = YAML.load_file(File.join(@dir, TS_FILE))
    rescue Errno::ENOENT
      @timestamp = nil
    end

    def update_timestamp
      @timestamp = Time.now
      File.open(File.join(@dir, TS_FILE), 'w'){|f| YAML.dump @timestamp, f }
    end
  end

  class Entry
    include Comparable
    extend Forwardable

    DIARY_RE = /\A\d{4}-\d{2}-\d{2}\Z/

    def self.glob(dir)
      Dir.glob(File.join(File.expand_path(dir), "*.*")).map{|file|
        parse(file){ nil }
      }.compact
    end

    def self.parse(path)
      base = File.basename(path, '.*')
      case
      when DIARY_RE =~ base then new(path, Date.parse(base))
      when block_given?     then yield(path)
      else raise(ArgumentError, "invalid diary file name - #{path}")
      end
    end

    def initialize(path, date)
      @path  = path
      @date  = date
    end

    def open
      File.open(@path) do |f|
        f.flock File::LOCK_SH
        yield f
      end
    end

    def fnmatch(pattern)
      File.fnmatch(pattern, @path)
    end

    def_delegators :@date, :year, :month, :day

    def to_date
      @date
    end

    def <=>(other)
      @date <=> other.to_date
    rescue NoMethodError
      nil
    end

    def updated?(datum)
      File.mtime(@path) > datum
    end
  end
end

def FileFlags(*args, &block)
  FileFlags.suites << FileFlags::Suite.new(*args, &block)
end

