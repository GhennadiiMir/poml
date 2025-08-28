require_relative 'test_helper'

class TestMissingComponents < Minitest::Test
  include TestHelper

  def test_object_component
    # Test JSON object serialization
    content = '<poml><object data=\'{"name": "John", "age": 30}\' syntax="json"/></poml>'
    result = Poml.process(markup: content, format: 'raw')
    
    assert_includes result, '"name": "John"'
    assert_includes result, '"age": 30'
  end

  def test_object_component_yaml
    # Test YAML object serialization
    content = '<poml><object data=\'{"name": "John", "age": 30}\' syntax="yaml"/></poml>'
    result = Poml.process(markup: content, format: 'raw')
    
    assert_includes result, 'name: John'
    assert_includes result, 'age: 30'
  end

  def test_audio_component
    # Test audio component
    content = '<poml><audio src="test.mp3" alt="Test audio"/></poml>'
    result = Poml.process(markup: content, format: 'raw')
    
    assert_includes result, '[Audio: test.mp3]'
    assert_includes result, '(Test audio)'
  end

  def test_audio_component_xml_mode
    # Test audio component in XML mode
    content = '<poml syntax="xml"><audio src="test.mp3" alt="Test audio"/></poml>'
    result = Poml.process(markup: content, format: 'raw')
    
    assert_includes result, '<audio'
    assert_includes result, 'src="test.mp3"'
    assert_includes result, 'alt="Test audio"'
  end

  def test_role_component
    # Test role component
    content = '<poml><role>Assistant</role></poml>'
    result = Poml.process(markup: content, format: 'raw')
    
    assert_includes result, 'Role'
    assert_includes result, 'Assistant'
  end

  def test_task_component
    # Test task component
    content = '<poml><task>Help users</task></poml>'
    result = Poml.process(markup: content, format: 'raw')
    
    assert_includes result, 'Task'
    assert_includes result, 'Help users'
  end

  def test_include_component
    # Create a temporary include file
    temp_file = create_temp_poml_file('Hello from included file!')
    
    content = "<poml><include src=\"#{temp_file}\"/></poml>"
    result = Poml.process(markup: content, format: 'raw')
    
    assert_includes result, 'Hello from included file!'
    
    # Clean up
    File.delete(temp_file) if File.exist?(temp_file)
  end

  def test_include_component_with_variables
    # Create a temporary include file with template variables
    temp_file = create_temp_poml_file('Hello {{name}}!')
    
    content = "<poml><include src=\"#{temp_file}\"/></poml>"
    result = Poml.process(markup: content, context: {'name' => 'World'}, format: 'raw')
    
    assert_includes result, 'Hello World!'
    
    # Clean up
    File.delete(temp_file) if File.exist?(temp_file)
  end

  def test_tool_attribute_templates
    # Test tool definition with template variables in attributes
    content = '<poml>
      <tool-definition name="{{tool_name}}" description="{{tool_desc}}" parser="json">
      {
        "type": "function",
        "function": {
          "name": "test_function",
          "description": "Test function",
          "parameters": {
            "type": "object",
            "properties": {
              "input": {"type": "string"}
            }
          }
        }
      }
      </tool-definition>
    </poml>'
    
    context = {
      'tool_name' => 'my_tool',
      'tool_desc' => 'My awesome tool'
    }
    
    result = Poml.process(markup: content, context: context, format: 'dict')
    
    # Check that template variables were substituted
    assert_equal 'my_tool', result['metadata']['tools'][0]['name']
    assert_equal 'My awesome tool', result['metadata']['tools'][0]['description']
  end
end
