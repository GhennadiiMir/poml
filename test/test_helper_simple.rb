require 'minitest/autorun'

# Add lib directory to load path
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require "poml"
require "json"
require "tempfile"
require "fileutils"

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
  
  def assert_poml_output(markup, expected_content, format: 'raw')
    result = Poml.process(markup: markup, format: format)
    assert_includes result, expected_content, "Expected POML output to contain '#{expected_content}'"
  end
  
  def assert_valid_openai_chat(result)
    assert_kind_of Array, result, "OpenAI chat format should return an Array"
    result.each do |message|
      assert_kind_of Hash, message, "Each message should be a Hash"
      assert_includes message.keys, 'role', "Message should have 'role' key"
      assert_includes message.keys, 'content', "Message should have 'content' key"
      assert_includes ['user', 'assistant', 'system'], message['role'], "Role should be valid"
    end
  end
  
  def assert_valid_dict_format(result)
    assert_kind_of Hash, result, "Dict format should return a Hash"
    assert_includes result.keys, 'content', "Dict should have 'content' key"
  end
end
