require_relative "test_helper"

class TestRealImplementation < Minitest::Test
  include TestHelper

  # Test only what's actually implemented and working

  def test_formatting_components
    # Bold
    result = Poml.process(markup: '<b>Bold text</b>', format: 'raw')
    assert_includes result, '**Bold text**'
    
    # Italic
    result = Poml.process(markup: '<i>Italic text</i>', format: 'raw')
    assert_includes result, '*Italic text*'
    
    # Combined
    result = Poml.process(markup: '<b>Bold</b> and <i>italic</i>', format: 'raw')
    assert_includes result, '**Bold**'
    assert_includes result, '*italic*'
  end

  def test_chat_components_openai_format
    # AI component
    result = Poml.process(markup: '<ai>AI response</ai>', format: 'openai_chat')
    assert_equal 1, result.length
    assert_equal 'assistant', result[0]['role']
    assert_equal 'AI response', result[0]['content']
    
    # Human component
    result = Poml.process(markup: '<human>Human message</human>', format: 'openai_chat')
    assert_equal 1, result.length
    assert_equal 'user', result[0]['role']
    assert_equal 'Human message', result[0]['content']
    
    # System component
    result = Poml.process(markup: '<system>System prompt</system>', format: 'openai_chat')
    assert_equal 1, result.length
    assert_equal 'system', result[0]['role']
    assert_equal 'System prompt', result[0]['content']
  end

  def test_multiple_chat_components
    markup = '<system>You are helpful</system><human>Hello</human><ai>Hi there!</ai>'
    result = Poml.process(markup: markup, format: 'openai_chat')
    
    assert_equal 3, result.length
    
    assert_equal 'system', result[0]['role']
    assert_equal 'You are helpful', result[0]['content']
    
    assert_equal 'user', result[1]['role']
    assert_equal 'Hello', result[1]['content']
    
    assert_equal 'assistant', result[2]['role']
    assert_equal 'Hi there!', result[2]['content']
  end

  def test_raw_format_output
    result = Poml.process(markup: '<b>Bold text</b>', format: 'raw')
    assert_kind_of String, result
    assert_includes result, '**Bold text**'
    assert_includes result, 'human' # Default wrapper
  end

  def test_dict_format_output
    result = Poml.process(markup: '<b>Bold text</b>', format: 'dict')
    assert_kind_of Hash, result
    assert_includes result.keys, 'content'
    assert_includes result['content'], '**Bold text**'
  end

  def test_plain_text_handling
    result = Poml.process(markup: 'Just plain text', format: 'raw')
    assert_includes result, 'Just plain text'
    assert_includes result, 'human' # Gets wrapped
  end

  def test_empty_markup
    result = Poml.process(markup: '', format: 'raw')
    assert_equal '', result
  end

  def test_unknown_components_graceful_handling
    # Unknown components should not crash
    result = Poml.process(markup: '<unknown>Unknown component</unknown>', format: 'raw')
    assert_kind_of String, result
  end

  def test_malformed_xml_graceful_handling
    # Malformed XML should not crash
    result = Poml.process(markup: '<b>Unclosed bold', format: 'raw')
    assert_kind_of String, result
  end

  def test_nested_formatting_basic
    result = Poml.process(markup: '<b>Bold with <i>italic</i></b>', format: 'raw')
    assert_kind_of String, result
    assert_includes result, 'Bold'
  end

  def test_error_handling_invalid_format
    assert_raises(Poml::Error) do
      Poml.process(markup: '<b>test</b>', format: 'invalid_format')
    end
  end

  def test_error_handling_nil_markup
    assert_raises(TypeError) do
      Poml.process(markup: nil, format: 'raw')
    end
  end

  def test_whitespace_preservation
    result = Poml.process(markup: '<b>  Spaced  </b>', format: 'raw')
    assert_includes result, 'Spaced'
  end

  def test_special_characters
    result = Poml.process(markup: '<b>Special: àáâãäå 中文 🚀</b>', format: 'raw')
    assert_includes result, 'Special'
    assert_includes result, '🚀'
  end

  def test_all_supported_formats
    markup = '<ai>Test message</ai>'
    
    # Raw format
    result = Poml.process(markup: markup, format: 'raw')
    assert_kind_of String, result
    
    # Dict format
    result = Poml.process(markup: markup, format: 'dict')
    assert_kind_of Hash, result
    assert_includes result.keys, 'content'
    
    # OpenAI chat format
    result = Poml.process(markup: markup, format: 'openai_chat')
    assert_kind_of Array, result
    assert_equal 1, result.length
    assert_equal 'assistant', result[0]['role']
  end
end
