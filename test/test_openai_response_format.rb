require_relative 'test_helper'

class TestOpenAIResponseFormat < Minitest::Test
  include TestHelper

  def test_basic_openai_response_format
    markup = '<b>Hello World</b>'
    result = Poml.process(markup: markup, format: 'openaiResponse', chat: false)
    
    # Should be a hash with content and type
    assert_instance_of Hash, result
    assert_equal '**Hello World**', result['content']
    assert_equal 'assistant', result['type']
  end

  def test_openai_response_with_variables
    markup = '<b>{{greeting}} {{name}}</b>'
    variables = { 'greeting' => 'Hello', 'name' => 'World' }
    result = Poml.process(markup: markup, format: 'openaiResponse', variables: variables, chat: false)
    
    assert_equal '**Hello World**', result['content']
    assert_equal 'assistant', result['type']
    assert_includes result['metadata']['variables'], 'greeting'
    assert_includes result['metadata']['variables'], 'name'
  end

  def test_openai_response_with_schema
    markup = '<output-schema lang="json">{"name": "string"}</output-schema><b>Response</b>'
    result = Poml.process(markup: markup, format: 'openaiResponse', chat: false)
    
    assert_equal '**Response**', result['content']
    assert_equal 'assistant', result['type']
    assert_includes result['metadata'], 'response_schema'
    # The schema is parsed as JSON, so check the structure
    assert_instance_of Hash, result['metadata']['response_schema']
    assert_includes result['metadata']['response_schema'], 'name'
  end

  def test_openai_response_with_tools
    markup = '<tool-definition name="test">Test tool</tool-definition><b>Tool response</b>'
    result = Poml.process(markup: markup, format: 'openaiResponse', chat: false)
    
    assert_equal '**Tool response**', result['content']
    assert_equal 'assistant', result['type']
    assert result.key?('tools'), "Result should have tools key"
    assert_equal 1, result['tools'].length
    assert_equal 'test', result['tools'].first['name']
  end

  def test_openai_response_with_meta_data
    markup = '<meta title="Test Response" description="A test"></meta><b>Content here</b>'
    result = Poml.process(markup: markup, format: 'openaiResponse', chat: false)
    
    assert_equal '**Content here**', result['content']
    assert_equal 'assistant', result['type']
    assert_includes result['metadata'], 'title'
    assert_includes result['metadata'], 'description'
    assert_equal 'Test Response', result['metadata']['title']
    assert_equal 'A test', result['metadata']['description']
  end

  def test_openai_response_empty_metadata_excluded
    markup = '<b>Simple content</b>'
    result = Poml.process(markup: markup, format: 'openaiResponse', chat: false)
    
    assert_equal '**Simple content**', result['content']
    assert_equal 'assistant', result['type']
    refute_includes result, 'metadata'
  end

  def test_openai_response_vs_openai_chat_difference
    markup = '<human>Question</human><ai>Answer</ai>'
    
    # OpenAI Chat format should return message array
    chat_result = Poml.process(markup: markup, format: 'openai_chat')
    assert_instance_of Array, chat_result
    
    # OpenAI Response format should return structured response
    response_result = Poml.process(markup: markup, format: 'openaiResponse')
    assert_instance_of Hash, response_result
    assert_equal 'assistant', response_result['type']
    # Content may be formatted differently, just ensure it's a hash structure
    assert_includes response_result, 'content'
  end

  def test_openai_response_convenience_method
    markup = '<b>Test</b>'
    
    # Test convenience method
    result1 = Poml.to_openai_response(markup, chat: false)
    result2 = Poml.process(markup: markup, format: 'openaiResponse', chat: false)
    
    assert_equal result2, result1
  end

  def test_openai_response_with_complex_content
    markup = %{
      <h1>Analysis Results</h1>
      <table data='[{"metric": "accuracy", "value": 0.95}]'></table>
      <code inline="false" lang="python">print("Hello")</code>
    }
    
    result = Poml.process(markup: markup, format: 'openaiResponse', chat: false)
    
    assert_equal 'assistant', result['type']
    assert_includes result['content'], '# Analysis Results'
    assert_includes result['content'], '| metric | value |'
    assert_includes result['content'], '```python'
  end

  def test_openai_response_maintains_backward_compatibility
    # Ensure existing openai_chat format still works unchanged
    markup = '<human>Hello</human><ai>Hi there</ai>'
    
    chat_result = Poml.process(markup: markup, format: 'openai_chat')
    assert_instance_of Array, chat_result
    assert_equal 2, chat_result.length
    assert_equal 'user', chat_result[0]['role']
    assert_equal 'assistant', chat_result[1]['role']
  end
end
