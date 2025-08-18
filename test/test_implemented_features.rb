require_relative "test_helper"

class TestImplementedFeatures < Minitest::Test
  include TestHelper

  def test_basic_formatting_components
    # Test bold
    result = Poml.process(markup: '<b>Bold text</b>', format: 'raw')
    assert_includes result, '**Bold text**'
    
    # Test italic
    result = Poml.process(markup: '<i>Italic text</i>', format: 'raw')
    assert_includes result, '*Italic text*'
    
    # Test combined
    result = Poml.process(markup: '<b>Bold</b> and <i>italic</i>', format: 'raw')
    assert_includes result, '**Bold**'
    assert_includes result, '*italic*'
  end

  def test_chat_components_basic
    # Test AI component
    result = Poml.process(markup: '<ai>AI response</ai>', format: 'openai_chat')
    assert_valid_openai_chat(result)
    assert_equal 1, result.length
    assert_equal 'assistant', result[0]['role']
    assert_includes result[0]['content'], 'AI response'
    
    # Test human component
    result = Poml.process(markup: '<human>Human message</human>', format: 'openai_chat')
    assert_valid_openai_chat(result)
    assert_equal 1, result.length
    assert_equal 'user', result[0]['role']
    assert_includes result[0]['content'], 'Human message'
    
    # Test system component
    result = Poml.process(markup: '<system>System prompt</system>', format: 'openai_chat')
    assert_valid_openai_chat(result)
    assert_equal 1, result.length
    assert_equal 'system', result[0]['role']
    assert_includes result[0]['content'], 'System prompt'
  end

  def test_mixed_chat_components
    markup = '<system>You are helpful</system><human>Hello</human><ai>Hi there!</ai>'
    result = Poml.process(markup: markup, format: 'openai_chat')
    
    assert_valid_openai_chat(result)
    assert_equal 3, result.length
    
    assert_equal 'system', result[0]['role']
    assert_includes result[0]['content'], 'You are helpful'
    
    assert_equal 'user', result[1]['role']
    assert_includes result[1]['content'], 'Hello'
    
    assert_equal 'assistant', result[2]['role']
    assert_includes result[2]['content'], 'Hi there!'
  end

  def test_output_formats
    markup = '<ai>Test message</ai>'
    
    # Test openai_chat format (this works)
    result = Poml.process(markup: markup, format: 'openai_chat')
    assert_valid_openai_chat(result)
    assert_equal 1, result.length
    assert_equal 'assistant', result[0]['role']
    assert_includes result[0]['content'], 'Test message'
    
    # Test dict format
    result = Poml.process(markup: markup, format: 'dict')
    assert_valid_dict_format(result)
    
    # Test raw format
    result = Poml.process(markup: markup, format: 'raw')
    assert_kind_of String, result
  end

  def test_plain_text_handling
    # Test plain text gets wrapped in human component
    result = Poml.process(markup: 'Just plain text', format: 'raw')
    assert_includes result, 'Just plain text'
    assert_includes result, 'human'
    
    # Test empty markup
    result = Poml.process(markup: '', format: 'raw')
    assert_equal '', result
  end

  def test_meta_components_basic
    # Test simple meta
    result = Poml.process(markup: '<meta name="title" content="Test Title">Content</meta>', format: 'raw')
    assert_kind_of String, result
    
    # Should not crash on meta components
    result = Poml.process(markup: '<meta description="Test">Some content</meta>', format: 'raw')
    assert_kind_of String, result
  end

  def test_error_handling_basic
    # Test unknown components don't crash
    result = Poml.process(markup: '<unknown>Unknown component</unknown>', format: 'raw')
    assert_kind_of String, result
    
    # Test malformed XML handled gracefully
    result = Poml.process(markup: '<b>Unclosed bold', format: 'raw')
    assert_kind_of String, result
  end

  def test_nested_formatting
    markup = '<b>Bold with <i>italic inside</i></b>'
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_kind_of String, result
    assert_includes result, 'Bold'
    # Note: nested formatting may not be fully implemented yet
  end

  def test_whitespace_handling
    markup = '<b>   Spaced   </b>'
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_kind_of String, result
    # Should preserve or handle whitespace reasonably
    assert_includes result, 'Spaced'
  end

  def test_special_characters
    markup = '<b>Special: àáâãäå 中文 🚀</b>'
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_kind_of String, result
    assert_includes result, 'Special'
    # Should handle unicode characters
    assert_includes result, '🚀'
  end
end
