require 'rake/testtask'

# Test Tasks:
# - rake test         : Run stable tests (default, all should pass)
# - rake test_working : Same as rake test
# - rake test_all     : Run all tests including unimplemented features (many will fail)

# Stable tests - only tests that pass with current implementation
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList[
    'test/test_basic_functionality.rb',
    'test/test_implemented_features.rb',
    'test/test_real_implementation.rb',
    'test/test_formatting_components.rb',
    'test/test_table_component.rb',
    'test/test_file_components.rb',
    'test/test_utility_components.rb',
    'test/test_meta_component.rb',
    'test/test_template_engine.rb',
    'test/test_new_schema_components.rb',
    'test/test_schema_compatibility.rb'
  ]
  t.verbose = true
  t.ruby_opts = ['-w']
end

# All tests including failing ones (for development)
Rake::TestTask.new(:test_all) do |t|
  t.libs << "test"
  t.test_files = FileList['test/test_*.rb'].exclude('test/test_helper*.rb')
  t.verbose = true
  t.ruby_opts = ['-w']
end

# Legacy working tests (same as main test task)
Rake::TestTask.new(:test_working) do |t|
  t.libs << "test"
  t.test_files = FileList[
    'test/test_basic_functionality.rb',
    'test/test_implemented_features.rb',
    'test/test_real_implementation.rb',
    'test/test_formatting_components.rb',
    'test/test_table_component.rb',
    'test/test_file_components.rb',
    'test/test_utility_components.rb',
    'test/test_meta_component.rb',
    'test/test_template_engine.rb',
    'test/test_new_schema_components.rb',
    'test/test_schema_compatibility.rb'
  ]
  t.verbose = true
  t.ruby_opts = ['-w']
end

task default: :test
