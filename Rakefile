require 'rubygems'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'


task 'default' => 'test'

GEMSPEC = 'fileflags.gemspec'
LIBS    = FileList["lib/*.rb"]
TESTS   = FileList["test/test_*.rb"]
README  = "README_ja.org"

gemspec = Gem::Specification.new do |s|
  s.name              = "fileflags"
  s.version           = "0.0.1"
  s.authors           = ["arikui"]
  s.date              = "2011-03-14"
  s.rubyforge_project = "fileflags"
  s.description       = "A framework to process updated files."
  s.summary           = "A framework to process updated files which compiled at a directory."
  s.email             = "arikui.ruby@gmail.com"
  s.homepage          = "http://wiki.github.com/arikui1911/fileflags"

  etc = [README, "LICENSE"]

  s.test_files = TESTS
  s.extra_rdoc_files = etc
  s.files = LIBS + TESTS + etc

  s.rdoc_options = ["--title", "fileflags documentation",
                    "--opname", "index.html",
                    "--line-numbers",
                    "--main", README,
                    "--inline-source"]
end

gem_task = Rake::GemPackageTask.new(gemspec)
gem_task.define
gem_dest = "#{gem_task.package_dir}/#{gem_task.gem_file}"

desc "Upload the gem file #{gem_task.gem_file} to GemCutter"
task 'cutter' => 'gem' do |t|
  gem "push #{gem_dest}"
end

Rake::TestTask.new do |t|
  t.warning = true
end

task 'cov' do
  sh 'ruby-cov -Ilib test/test_*.rb'
end

Rake::RDocTask.new do |t|
  t.rdoc_dir = 'doc'
  t.rdoc_files = LIBS.include(README)
  t.options.push '-S', '-N'
end

desc "Update #{GEMSPEC}"
task "gemspec" do
  cp GEMSPEC, "#{GEMSPEC}~" if File.exist?(GEMSPEC)
  code = gemspec.to_ruby.sub(/\A#.*$/, '').strip  # remove utf8 magic encoding which hard-coded
  File.open(GEMSPEC, 'w'){|f| f.puts code }
end

