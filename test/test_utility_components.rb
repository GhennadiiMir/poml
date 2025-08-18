require_relative "test_helper"

class TestUtilityComponents < Minitest::Test
  include TestHelper

  def test_folder_component
    markup = '<folder src="lib" maxDepth="2">Folder listing</folder>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should list files in lib directory
    assert_includes result, 'poml.rb'
    assert_includes result, 'components/'
  end

  def test_folder_component_with_nonexistent_path
    markup = '<folder src="/nonexistent/path">Should handle gracefully</folder>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle error gracefully
    assert_includes result, 'directory not found'
  end

  def test_folder_component_without_src
    markup = '<folder>No source specified</folder>'
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_includes result, 'no src specified'
  end

  def test_tree_component_with_items
    markup = '<tree items="[{\"name\": \"root\", \"children\": [{\"name\": \"child1\"}, {\"name\": \"child2\"}]}]">Tree</tree>'
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_includes result, 'root'
    assert_includes result, 'child1'
    assert_includes result, 'child2'
  end

  def test_tree_component_without_items
    markup = '<tree>Empty tree</tree>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle empty gracefully
    assert_kind_of String, result
  end

  def test_conversation_component_with_messages
    markup = '<conversation messages="[{\"role\": \"user\", \"content\": \"Hello\"}, {\"role\": \"assistant\", \"content\": \"Hi there!\"}]">Conv</conversation>'
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_includes result, 'Hello'
    assert_includes result, 'Hi there!'
  end

  def test_conversation_component_without_messages
    markup = '<conversation>No messages</conversation>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle empty gracefully
    assert_kind_of String, result
  end

  def test_list_component
    markup = '<list><item>First item</item><item>Second item</item><item>Third item</item></list>'
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_includes result, '- First item'
    assert_includes result, '- Second item'
    assert_includes result, '- Third item'
  end

  def test_empty_list_component
    markup = '<list></list>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle empty list gracefully
    assert_kind_of String, result
  end

  def test_nested_list_items
    markup = '<list><item>Main item <b>with formatting</b></item><item>Another item</item></list>'
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_includes result, '- Main item **with formatting**'
    assert_includes result, '- Another item'
  end

  def test_utility_components_in_different_formats
    markup = '<list><item>Test item</item></list>'
    
    ['raw', 'dict', 'openai_chat'].each do |format|
      result = Poml.process(markup: markup, format: format)
      assert_kind_of(format == 'openai_chat' ? Array : (format == 'dict' ? Hash : String), result)
    end
  end

  def test_folder_component_with_filter
    markup = '<folder src="lib" filter="\.rb$">Ruby files only</folder>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should only show .rb files
    assert_includes result, 'poml.rb'
  end

  def test_tree_component_error_handling
    # Test with malformed JSON
    markup = '<tree items="[malformed">Invalid tree</tree>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should not crash
    assert_kind_of String, result
  end
end
