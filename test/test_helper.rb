require 'minitest/autorun'

# Try to use minitest-reporters if available, but don't fail if not
begin
  require 'minitest/reporters'
  Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new]
rescue LoadError
  # Fall back to default Minitest output if minitest-reporters not available
  puts "Note: Install 'minitest-reporters' gem for better test output formatting"
end

require "poml"
require "json"
require "tempfile"

# Test helper methods
module TestHelper
  def fixture_path
    File.expand_path("fixtures", __dir__)
  end
  
  def load_fixture(filename)
    File.read(File.join(fixture_path, filename))
  end
  
  def create_temp_poml_file(content)
    file = Tempfile.new(['test_poml', '.poml'])
    file.write(content)
    file.close
    file.path
  end
  
  def assert_poml_output(markup, format, expected_content)
    result = Poml.process(markup: markup, format: format)
    case format
    when 'raw'
      assert_includes result, expected_content
    when 'dict'
      assert_includes result['content'], expected_content
    when 'openai_chat'
      assert result.any? { |msg| msg['content'].include?(expected_content) }
    end
  end
  
  def assert_valid_openai_chat(result)
    assert_kind_of Array, result
    result.each do |message|
      assert_kind_of Hash, message
      assert_includes ['user', 'assistant', 'system'], message['role']
      assert_kind_of String, message['content']
    end
  end
end
