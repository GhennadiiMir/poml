#!/usr/bin/env ruby

# Test runner for POML - follows Ruby/Minitest conventions
# Usage: ruby test/run_tests.rb [options]
# Options:
#   --verbose, -v    Verbose output
#   --seed SEED      Set random seed for test order
#   --name PATTERN   Run only tests matching pattern

require 'minitest/autorun'
require 'minitest/reporters'

# Use progress reporter for better output
Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new]

# Set up load path
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

# Require all test files
test_files = Dir[File.join(__dir__, 'test_*.rb')]
test_files.each { |file| require file }

puts "Running POML test suite with #{test_files.length} test files..."
puts "Test files: #{test_files.map { |f| File.basename(f) }.join(', ')}"
