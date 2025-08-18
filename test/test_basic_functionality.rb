require_relative "test_helper"

class TestBasicFunctionality < Minitest::Test
  include TestHelper

  def test_basic_bold_formatting
    markup = '<b>Bold text</b>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '**Bold text**'
  end

  def test_basic_italic_formatting
    markup = '<i>Italic text</i>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '*Italic text*'
  end

  def test_simple_ai_component
    markup = '<ai>Hello from AI</ai>'
    result = Poml.process(markup: markup, format: 'openai_chat')
    assert_valid_openai_chat(result)
    assert_equal 1, result.length
    assert_equal 'assistant', result[0]['role']
    assert_includes result[0]['content'], 'Hello from AI'
  end

  def test_simple_human_component
    markup = '<human>Hello from human</human>'
    result = Poml.process(markup: markup, format: 'openai_chat')
    assert_valid_openai_chat(result)
    assert_equal 1, result.length
    assert_equal 'user', result[0]['role']
    assert_includes result[0]['content'], 'Hello from human'
  end

  def test_dict_format
    markup = '<b>Bold text</b>'
    result = Poml.process(markup: markup, format: 'dict')
    assert_valid_dict_format(result)
    assert_includes result['content'], '**Bold text**'
  end

  def test_empty_markup
    result = Poml.process(markup: '', format: 'raw')
    assert_equal '', result
  end

  def test_plain_text
    markup = 'Just plain text'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'Just plain text'
  end

  def test_mixed_formatting
    markup = '<b>Bold</b> and <i>italic</i> text'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '**Bold**'
    assert_includes result, '*italic*'
    assert_includes result, 'and'
    assert_includes result, 'text'
  end
end
