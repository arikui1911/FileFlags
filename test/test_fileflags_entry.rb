$LOAD_PATH.unshift File.expand_path("../lib")
require 'fileflags'
require 'test/unit'
require 'date'
require 'tmpdir'
require 'fileutils'

class TestFileFlagsEntry < Test::Unit::TestCase
  def with_temp_dir(&block)
    Dir.mktmpdir{|dir| Dir.chdir(&block) }
  end

  include FileUtils

  def setup
    @date = Date.today
  end

  def test_entry_glob
    with_temp_dir do |dir|
      touch "2010-05-07.txt"
      touch "#{__method__}.txt"
      list = FileFlags::Entry.glob(dir)
      assert_equal [Date.new(2010, 5, 7)], list.map(&:to_date)
    end
  end

  def test_entry_parse
    entry = FileFlags::Entry.parse("2000-05-07.txt")
    assert_equal Date.new(2000, 5, 7), entry.to_date
  end

  def test_entry_parse_failure
    assert_raises ArgumentError do
      FileFlags::Entry.parse("#{__method__}.txt")
    end
  end

  def test_entry_parse_failure_hooked
    tag = Object.new
    ret = FileFlags::Entry.parse("#{__method__}.txt"){ tag }
    assert_equal tag, ret
  end

  def context_test_open
    with_temp_dir do |dir|
      fname = "#{__method__}.txt"
      File.open(fname, 'w'){|f| f.write "Testing!" }
      entry = FileFlags::Entry.new(File.expand_path(fname), @date)
      entry.open{|f| yield f, fname }
    end
  end

  def test_open
    context_test_open do |f, fname|
      assert_equal File.expand_path(fname), f.path
    end
  end

  def test_open_written_content
    context_test_open do |f,|
      assert_equal "Testing!", f.read
    end
  end

  def context_test_fnmatch
    with_temp_dir do |dir|
      fname = "#{__method__}.txt"
      touch fname
      entry = FileFlags::Entry.new(File.expand_path(fname), @date)
      yield entry
    end
  end

  def test_fnmatch
    context_test_fnmatch do |entry|
      assert entry.fnmatch("*.txt")
    end
  end

  def test_fnmatch_nomatch
    context_test_fnmatch do |entry|
      assert !entry.fnmatch("*.rb")
    end
  end

  def test_to_date
    assert_equal @date, FileFlags::Entry.new('', @date).to_date
  end

  def test_cmp
    newer = @date + 1
    assert FileFlags::Entry.new('', newer) > FileFlags::Entry.new('', @date)
  end

  def test_cmp_typemismatch
    assert_raise(ArgumentError){ FileFlags::Entry.new('', @date) > Object.new }
  end

  def context_test_updated_p
    fname = "#{__method__}.txt"
    with_temp_dir do |dir|
      touch fname
      entry = FileFlags::Entry.new(File.expand_path(fname), @date)
      yield entry
    end
  end

  def test_updated_p
    datum = Time.now - 60
    context_test_updated_p do |entry|
      assert entry.updated?(datum)
    end
  end

  def test_update_p
    context_test_updated_p do |entry|
      assert !entry.updated?(Time.now)
    end
  end
end

