require 'rake/testtask'

# Default test task - runs all tests (many will fail due to unimplemented features)
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test_*.rb'].exclude('test/test_helper*.rb')
  t.verbose = true
  t.ruby_opts = ['-w'] # Enable warnings
end

# Working tests only - tests that should pass with current implementation
Rake::TestTask.new(:test_working) do |t|
  t.libs << "test"
  t.test_files = FileList[
    'test/test_basic_functionality.rb',
    'test/test_implemented_features.rb'
  ]
  t.verbose = true
  t.ruby_opts = ['-w']
end

task default: :test_working
