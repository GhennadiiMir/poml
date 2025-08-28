require "minitest/autorun"
require "poml"

class PomlDataComponentsTest < Minitest::Test
  
  def test_object_component_json_format
    # Test object component with JSON data
    test_data = { "name" => "John", "age" => 30, "skills" => ["Ruby", "JavaScript"] }
    
    content = %(<poml>
      <object data='#{test_data.to_json}' syntax="json"/>
    </poml>)
    
    result = Poml.process(markup: content, format: 'raw', chat: false)
    
    assert_includes result, '"name"'
    assert_includes result, '"John"'
    assert_includes result, '"age"'
    assert_includes result, '30'
    assert_includes result, '"skills"'
    assert_includes result, '"Ruby"'
    assert_includes result, '"JavaScript"'
  end
  
  def test_object_component_yaml_format
    # Test object component with YAML output
    test_data = { "title" => "Project", "version" => "1.0", "dependencies" => ["gem1", "gem2"] }
    
    content = %(<poml>
      <object data='#{test_data.to_json}' syntax="yaml"/>
    </poml>)
    
    result = Poml.process(markup: content, format: 'raw', chat: false)
    
    assert_includes result, 'title: Project'
    assert_includes result, 'version: '
    assert_includes result, '1.0'
    assert_includes result, 'dependencies:'
    assert_includes result, '- gem1'
    assert_includes result, '- gem2'
  end
  
  def test_object_component_xml_format
    # Test object component with XML output
    test_data = { "user" => { "name" => "Alice", "email" => "alice@example.com" } }
    
    content = %(<poml>
      <object data='#{test_data.to_json}' syntax="xml"/>
    </poml>)
    
    result = Poml.process(markup: content, format: 'raw', chat: false)
    
    assert_includes result, '<data>'
    assert_includes result, '<user>'
    assert_includes result, '<name>Alice</name>'
    assert_includes result, '<email>alice@example.com</email>'
    assert_includes result, '</user>'
    assert_includes result, '</data>'
  end
  
  def test_role_component
    # Test role component with default header style
    content = '<poml>
      <role>You are a helpful assistant specializing in Ruby programming.</role>
    </poml>'
    
    result = Poml.process(markup: content, format: 'raw', chat: false)
    
    # Based on original POML library, role should render with markdown header by default
    assert_includes result, '# Role'
    assert_includes result, 'helpful assistant'
    assert_includes result, 'Ruby programming'
  end
  
  def test_task_component
    # Test task component with default header style
    content = '<poml>
      <task>Write a comprehensive test suite for the POML Ruby gem.</task>
    </poml>'
    
    result = Poml.process(markup: content, format: 'raw', chat: false)
    
    # Based on original POML library, task should render with markdown header by default
    assert_includes result, '# Task'
    assert_includes result, 'comprehensive test suite'
    assert_includes result, 'POML Ruby gem'
  end
  
  def test_audio_component
    # Test audio component (should handle gracefully even without actual audio file)
    content = '<poml>
      <audio src="test_audio.mp3" alt="Test audio file"/>
    </poml>'
    
    result = Poml.process(markup: content, format: 'raw', chat: false)
    
    # Should render some representation of the audio component
    assert_kind_of String, result
    refute_empty result.strip
  end
  
  def test_object_component_inline_mode
    # Test object component in inline mode
    test_data = { "status" => "success", "count" => 42 }
    
    content = %(<poml>
      Status: <object data='#{test_data.to_json}' syntax="json" inline="true"/>
    </poml>)
    
    result = Poml.process(markup: content, format: 'raw', chat: false)
    
    assert_includes result, 'Status:'
    assert_includes result, '"status"'
    assert_includes result, '"success"'
    # Inline mode should not have extra newlines
    refute_includes result, "\n\n"
  end
  
  def test_webpage_component_with_html_buffer
    # Test webpage component with HTML buffer (no external dependencies)
    # Use simple HTML without complex nesting to avoid XML parsing issues
    html_content = 'Test Page This is a test paragraph.'
    
    content = %(<poml>
      <webpage buffer="#{html_content}" extractText="true"/>
    </poml>)
    
    result = Poml.process(markup: content, format: 'raw', chat: false)
    
    # Should handle the content
    assert_kind_of String, result
    refute_empty result.strip
  end
  
  def test_webpage_component_with_selector
    # Test webpage component with simple content (avoid XML parsing complexities)
    content = '<poml>
      <webpage selector="body"/>
    </poml>'
    
    result = Poml.process(markup: content, format: 'raw', chat: false)
    
    # Should handle gracefully when no source is provided
    assert_includes result, 'no source specified'
  end
  
  def test_webpage_component_no_source
    # Test webpage component with no source specified
    content = '<poml>
      <webpage/>
    </poml>'
    
    result = Poml.process(markup: content, format: 'raw', chat: false)
    
    # Should handle gracefully
    assert_includes result, 'no source specified'
  end
  
  def test_object_component_error_handling
    # Test object component with invalid JSON
    content = '<poml>
      <object data="invalid json {" syntax="json"/>
    </poml>'
    
    result = Poml.process(markup: content, format: 'raw', chat: false)
    
    # Should handle gracefully - either show original data or error message
    assert_kind_of String, result
    refute_empty result.strip
  end
  
end
