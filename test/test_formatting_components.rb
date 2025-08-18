require_relative "test_helper"

class TestFormattingComponents < Minitest::Test
  include TestHelper

  def test_bold_component
    markup = '<b>bold text</b>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '**bold text**'
  end

  def test_italic_component
    markup = '<i>italic text</i>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '*italic text*'
  end

  def test_underline_component
    markup = '<u>underlined text</u>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '__underlined text__'
  end

  def test_strikethrough_component
    markup = '<s>strikethrough text</s>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '~~strikethrough text~~'
  end

  def test_code_component
    markup = '<code>console.log("hello")</code>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '`console.log("hello")`'
  end

  def test_nested_formatting
    markup = '<b>Bold with <i>italic</i> inside</b>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '**Bold with *italic* inside**'
  end

  def test_multiple_formatting_types
    markup = '<b>bold</b> and <i>italic</i> and <u>underline</u>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '**bold**'
    assert_includes result, '*italic*'
    assert_includes result, '__underline__'
  end

  def test_header_component
    markup = '<h>Main Header</h>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '# Main Header'
  end

  def test_newline_component
    markup = 'Line 1<br>Line 2'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, "Line 1\nLine 2"
  end

  def test_paragraph_component
    markup = '<p>This is a paragraph</p>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'This is a paragraph'
  end

  def test_inline_span_component
    markup = '<span>inline content</span>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'inline content'
  end

  def test_formatting_in_different_output_formats
    markup = '<b>Bold text</b>'
    
    # Test in all formats
    ['raw', 'dict', 'openai_chat'].each do |format|
      result = Poml.process(markup: markup, format: format)
      
      case format
      when 'raw'
        assert_includes result, '**Bold text**'
      when 'dict'
        assert_includes result['content'], '**Bold text**'
      when 'openai_chat'
        assert result.any? { |msg| msg['content'].include?('Bold text') }
      end
    end
  end

  def test_empty_formatting_components
    markup = '<b></b><i></i><u></u>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle empty gracefully
    assert_kind_of String, result
    assert_includes result, '****'  # Empty bold
    assert_includes result, '**'    # Empty italic  
    assert_includes result, '____'  # Empty underline
  end

  def test_formatting_with_special_characters
    markup = '<b>Text with "quotes" and &amp; symbols</b>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '**Text with "quotes" and &amp; symbols**'
  end
end
