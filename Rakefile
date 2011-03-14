require 'rake/testtask'
require 'tempfile'

Rake::TestTask.new do |t|
  t.warning = true
end

task 'cov' do
  sh 'ruby-cov -Ilib test/test_*.rb'
end

