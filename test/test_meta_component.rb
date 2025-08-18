require_relative "test_helper"

class TestMetaComponent < Minitest::Test
  include TestHelper

  def test_meta_with_title_and_description
    markup = '<meta title="Test Document" description="A test document">Content</meta>'
    result = Poml.process(markup: markup, format: 'dict')
    
    assert_equal 'Test Document', result['metadata']['title']
    assert_equal 'A test document', result['metadata']['description']
  end

  def test_meta_with_author_and_keywords
    markup = '<meta author="John Doe" keywords="test, poml, ruby">Content</meta>'
    result = Poml.process(markup: markup, format: 'dict')
    
    assert_equal 'John Doe', result['metadata']['author']
    assert_equal 'test, poml, ruby', result['metadata']['keywords']
  end

  def test_meta_with_variables
    markup = '<meta variables="{\"name\": \"Alice\", \"age\": 30}"><p>Hello {{name}}, you are {{age}} years old!</p></meta>'
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_includes result, 'Hello Alice'
    assert_includes result, 'you are 30 years old'
  end

  def test_meta_variables_in_dict_format
    markup = '<meta variables="{\"user\": \"Bob\"}">Content</meta>'
    result = Poml.process(markup: markup, format: 'dict')
    
    assert_kind_of Hash, result['metadata']['variables']
    # Variables might be processed differently, so just check structure
    assert result['metadata'].key?('variables')
  end

  def test_meta_component_returns_empty_content
    markup = '<meta title="Test">Some content inside meta</meta>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Meta component should not render its content directly
    refute_includes result, 'Some content inside meta'
  end

  def test_multiple_meta_attributes
    markup = '<meta title="Doc" description="Test" author="Jane" keywords="ruby,poml">Content</meta>'
    result = Poml.process(markup: markup, format: 'dict')
    
    metadata = result['metadata']
    assert_equal 'Doc', metadata['title']
    assert_equal 'Test', metadata['description']
    assert_equal 'Jane', metadata['author']
    assert_equal 'ruby,poml', metadata['keywords']
  end

  def test_meta_in_different_output_formats
    markup = '<meta title="Test Title">Content</meta>'
    
    # Raw format
    raw_result = Poml.process(markup: markup, format: 'raw')
    assert_kind_of String, raw_result
    
    # Dict format should include metadata
    dict_result = Poml.process(markup: markup, format: 'dict')
    assert_equal 'Test Title', dict_result['metadata']['title']
    
    # OpenAI chat format
    chat_result = Poml.process(markup: markup, format: 'openai_chat')
    assert_kind_of Array, chat_result
  end

  def test_meta_without_attributes
    markup = '<meta>Just content</meta>'
    result = Poml.process(markup: markup, format: 'dict')
    
    # Should still work, just without custom metadata
    assert_kind_of Hash, result['metadata']
    assert result['metadata'].key?('chat')
    assert result['metadata'].key?('stylesheet')
    assert result['metadata'].key?('variables')
  end
end
