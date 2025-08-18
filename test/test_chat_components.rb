require_relative "test_helper"

class TestChatComponents < Minitest::Test
  include TestHelper

  def test_ai_human_system_message_components
    markup = '<ai>AI response</ai><human>User question</human><system>System prompt</system>'
    
    # Test OpenAI chat format
    result = Poml.process(markup: markup, format: 'openai_chat')
    assert_valid_openai_chat(result)
    assert_equal 3, result.length
    
    assert_equal 'assistant', result[0]['role']
    assert_equal 'AI response', result[0]['content']
    
    assert_equal 'user', result[1]['role']
    assert_equal 'User question', result[1]['content']
    
    assert_equal 'system', result[2]['role']
    assert_equal 'System prompt', result[2]['content']
  end

  def test_chat_components_in_raw_format
    markup = '<ai>AI message</ai><human>Human message</human>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Chat components should return empty content in raw format
    # since they add to structured chat messages instead
    refute_includes result, 'AI message'
    refute_includes result, 'Human message'
  end

  def test_chat_components_with_nested_formatting
    markup = '<ai>This is <b>bold</b> and <i>italic</i> text</ai>'
    result = Poml.process(markup: markup, format: 'openai_chat')
    
    assert_equal 1, result.length
    assert_equal 'assistant', result[0]['role']
    assert_includes result[0]['content'], 'bold'
    assert_includes result[0]['content'], 'italic'
  end

  def test_mixed_chat_and_regular_content
    markup = '<role>Assistant</role><ai>Hello!</ai><task>Be helpful</task><human>Hi there</human>'
    
    # Test dict format to see both content and chat messages
    result = Poml.process(markup: markup, format: 'dict')
    assert_includes result['content'], 'Assistant'
    assert_includes result['content'], 'Be helpful'
    
    # Test chat format to see structured messages
    chat_result = Poml.process(markup: markup, format: 'openai_chat')
    assert_equal 2, chat_result.length
    assert_equal 'assistant', chat_result[0]['role']
    assert_equal 'user', chat_result[1]['role']
  end

  def test_empty_chat_messages
    markup = '<ai></ai><human></human>'
    result = Poml.process(markup: markup, format: 'openai_chat')
    
    assert_equal 2, result.length
    assert_equal '', result[0]['content']
    assert_equal '', result[1]['content']
  end

  def test_capitalized_chat_components
    markup = '<Ai>AI message</Ai><Human>Human message</Human><System>System message</System>'
    result = Poml.process(markup: markup, format: 'openai_chat')
    
    assert_equal 3, result.length
    assert_equal 'assistant', result[0]['role']
    assert_equal 'user', result[1]['role']
    assert_equal 'system', result[2]['role']
  end

  def test_chat_with_fixture_file
    file_content = load_fixture('chat/simple_conversation.poml')
    file_path = create_temp_poml_file(file_content)
    
    result = Poml.process(markup: file_path, format: 'openai_chat')
    assert_valid_openai_chat(result)
    assert result.length >= 3  # Should have system, human, ai messages
    
    File.unlink(file_path)
  end
end
