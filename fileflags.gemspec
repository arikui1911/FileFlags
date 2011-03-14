Gem::Specification.new do |s|
  s.name = %q{fileflags}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["arikui"]
  s.date = %q{2011-03-14}
  s.default_executable = %q{fileflags}
  s.description = %q{A framework to process updated files.}
  s.email = %q{arikui.ruby@gmail.com}
  s.executables = ["fileflags"]
  s.extra_rdoc_files = ["README_ja.org", "LICENSE"]
  s.files = ["bin/fileflags", "lib/fileflags.rb", "test/test_fileflags_entry.rb", "test/test_fileflags_suite.rb", "README_ja.org", "LICENSE"]
  s.homepage = %q{http://wiki.github.com/arikui1911/fileflags}
  s.rdoc_options = ["--title", "fileflags documentation", "--opname", "index.html", "--line-numbers", "--main", "README_ja.org", "--inline-source"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{fileflags}
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{A framework to process updated files which compiled at a directory.}
  s.test_files = ["test/test_fileflags_entry.rb", "test/test_fileflags_suite.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
