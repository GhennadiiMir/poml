require "minitest/autorun"
require "poml"

class PomlFormatCompatibilityTest < Minitest::Test
  
  def setup
    @base_markup = '<poml><role>Assistant</role><task>Help users</task></poml>'
    @chat_markup = '<poml><ai>Hello from AI</ai><human>Hello from human</human></poml>'
    @schema_markup = <<~POML
      <poml>
        <output-schema parser="json">
          {"type": "object", "properties": {"answer": {"type": "string"}}}
        </output-schema>
        <role>Assistant</role>
        <task>Provide structured response</task>
      </poml>
    POML
  end
  
  def test_all_formats_with_basic_markup
    # Test all output formats with the same basic input (based on debug_output_formats.rb)
    formats = ['raw', 'dict', 'openai_chat', 'openaiResponse', 'langchain', 'pydantic']
    results = {}
    
    formats.each do |format|
      begin
        results[format] = Poml.process(markup: @base_markup, format: format)
      rescue => e
        flunk "Format '#{format}' failed with error: #{e.message}"
      end
    end
    
    # All formats should return some result
    assert_equal formats.length, results.length, "All formats should return results"
    
    # Verify format-specific expectations
    assert_kind_of String, results['raw']
    assert_kind_of Hash, results['dict']
    assert_kind_of Array, results['openai_chat']
    assert_kind_of Hash, results['openaiResponse']
    assert_kind_of Hash, results['langchain']
    assert_kind_of Hash, results['pydantic']
  end
  
  def test_chat_formats_consistency
    # Test chat-specific formats with chat markup
    chat_formats = ['openai_chat', 'langchain', 'dict']
    results = {}
    
    chat_formats.each do |format|
      results[format] = Poml.process(markup: @chat_markup, format: format)
    end
    
    # OpenAI chat should return array of messages
    openai_result = results['openai_chat']
    assert_kind_of Array, openai_result
    assert_equal 2, openai_result.length
    assert_equal 'assistant', openai_result[0]['role']
    assert_equal 'user', openai_result[1]['role']
    
    # LangChain should have messages array
    langchain_result = results['langchain']
    assert_kind_of Hash, langchain_result
    assert langchain_result.key?('messages')
    
    # Dict should have content and metadata
    dict_result = results['dict']
    assert_kind_of Hash, dict_result
    assert dict_result.key?('content')
    assert dict_result.key?('metadata')
  end
  
  def test_schema_formats_consistency
    # Test formats with schema markup
    schema_formats = ['dict', 'openaiResponse', 'pydantic']
    results = {}
    
    schema_formats.each do |format|
      results[format] = Poml.process(markup: @schema_markup, format: format)
    end
    
    # All should include schema information in metadata
    results.each do |format, result|
      assert_kind_of Hash, result, "Format #{format} should return hash"
      
      case format
      when 'dict'
        assert result.key?('metadata'), "Dict format should have metadata"
        assert result['metadata'].key?('response_schema'), "Dict should have response_schema in metadata"
      when 'openaiResponse'
        assert result.key?('metadata'), "OpenAI response should have metadata"
        assert result['metadata'].key?('response_schema'), "OpenAI response should have response_schema in metadata"
      when 'pydantic'
        assert result.key?('schemas'), "Pydantic should have schemas array"
        assert_kind_of Array, result['schemas'], "Pydantic schemas should be an array"
      end
    end
  end
  
  def test_format_content_consistency
    # Test that the core content is consistent across formats
    markup = '<poml><role>Test Role</role><p>Test content with formatting</p></poml>'
    
    raw_result = Poml.process(markup: markup, format: 'raw')
    dict_result = Poml.process(markup: markup, format: 'dict')
    
    # Both should contain the same core content
    assert_includes raw_result, 'Test Role'
    assert_includes raw_result, 'Test content'
    assert_includes raw_result, 'formatting'
    
    assert_includes dict_result['content'], 'Test Role'
    assert_includes dict_result['content'], 'Test content'
    assert_includes dict_result['content'], 'formatting'
  end
  
  def test_format_specific_features
    # Test features that are specific to certain formats
    markup_with_variables = <<~POML
      <poml>
        <role>Assistant for {{name}}</role>
        <task>Process {{count}} items</task>
      </poml>
    POML
    
    variables = {"name" => "Alice", "count" => 5}
    
    # Test variable metadata preservation
    dict_result = Poml.process(markup: markup_with_variables, variables: variables, format: 'dict')
    pydantic_result = Poml.process(markup: markup_with_variables, variables: variables, format: 'pydantic')
    
    # Both should preserve variable metadata
    assert dict_result['metadata'].key?('variables'), "Dict should preserve variables"
    assert_equal 'Alice', dict_result['metadata']['variables']['name']
    
    assert pydantic_result.key?('variables'), "Pydantic should preserve variables"
    assert_equal 'Alice', pydantic_result['variables']['name']
  end
  
  def test_format_error_handling
    # Test that all formats handle problematic input gracefully
    problematic_markup = '<poml><unknown>Unknown component</unknown></poml>'
    formats = ['raw', 'dict', 'openai_chat', 'openaiResponse', 'langchain', 'pydantic']
    
    formats.each do |format|
      begin
        result = Poml.process(markup: problematic_markup, format: format)
        refute_nil result, "Format #{format} should return result even with unknown components"
      rescue => e
        flunk "Format '#{format}' should handle unknown components gracefully, but raised: #{e.message}"
      end
    end
  end
  
end
