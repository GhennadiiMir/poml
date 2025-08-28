require 'rake/testtask'

# Pre-process ARGV to handle test file arguments and create dynamic tasks
if ARGV.length > 1 && ARGV[0] == 'test'
  # Filter only valid test file arguments
  test_file_args = ARGV[1..-1].select do |arg| 
    arg.start_with?('test/') && arg.end_with?('.rb') && File.exist?(arg)
  end
  
  # Create dynamic no-op tasks for all arguments to prevent rake errors
  ARGV[1..-1].each do |arg|
    task arg.to_sym do
      # No-op task to prevent "Don't know how to build task" error
    end
  end
  
  # Store valid test files for later use
  $specific_test_files = test_file_args if test_file_args.any?
end

# Test task - run all tests or specific test files
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  
  # Use specific test files if they were provided and are valid
  if defined?($specific_test_files) && $specific_test_files && $specific_test_files.any?
    t.test_files = $specific_test_files
  else
    # Run all test files
    t.test_files = FileList['test/test_*.rb'].exclude('test/test_helper*.rb')
  end
  
  t.verbose = true
  t.ruby_opts = ['-w']
end

task default: :test
