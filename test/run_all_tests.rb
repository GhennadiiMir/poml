#!/usr/bin/env ruby

# Minitest test runner for POML Ruby gem
# This simply loads all test files and lets Minitest handle the execution

require "minitest/autorun"

# Add lib directory to load path
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

# Load all test files
test_files = Dir[File.join(__dir__, "test_*.rb")]
test_files.each { |file| require file }
