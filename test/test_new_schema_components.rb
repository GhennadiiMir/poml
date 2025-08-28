require_relative 'test_helper'

class TestNewSchemaComponents < Minitest::Test
  
  def test_output_schema_component_basic
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <output-schema parser="json">
          {
            "type": "object",
            "properties": {
              "name": { "type": "string" },
              "age": { "type": "number" }
            }
          }
        </output-schema>
        <task>Generate user data</task>
      </poml>
    POML
    
    result = Poml.process(markup: markup)
    
    # Should process without errors
    assert result['content'].include?('Assistant')
    assert result['content'].include?('Generate user data')
    
    # Schema should be registered in metadata
    assert result['metadata']['response_schema']
    schema = result['metadata']['response_schema']
    assert_equal 'object', schema['type']
    assert schema['properties']['name']
    assert schema['properties']['age']
  end
  
  def test_output_schema_with_eval_parser
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <output-schema parser="eval">
          z.object({
            name: z.string(),
            age: z.number().optional()
          })
        </output-schema>
        <task>Generate user data</task>
      </poml>
    POML
    
    result = Poml.process(markup: markup)
    
    # Should process without errors
    assert result['content'].include?('Assistant')
    assert result['content'].include?('Generate user data')
    
    # Schema should be registered in metadata
    assert result['metadata']['response_schema']
    # For eval parser, we store a placeholder object with the expression
    schema = result['metadata']['response_schema']
    assert schema['_expression']
    assert schema['_expression'].include?('z.object')
  end
  
  def test_tool_definition_component_basic
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <tool-definition name="calculate" description="Perform calculations" parser="json">
          {
            "type": "object",
            "properties": {
              "operation": { "type": "string", "enum": ["add", "subtract", "multiply", "divide"] },
              "a": { "type": "number" },
              "b": { "type": "number" }
            },
            "required": ["operation", "a", "b"]
          }
        </tool-definition>
        <task>You can use the calculate tool to perform math operations</task>
      </poml>
    POML
    
    result = Poml.process(markup: markup)
    
    # Should process without errors
    assert result['content'].include?('Assistant')
    assert result['content'].include?('math operations')
    
    # Tool should be registered in metadata
    assert result['tools']
    assert result['tools'].is_a?(Array)
    
    tool = result['tools'].first
    assert_equal 'calculate', tool['name']
    assert_equal 'Perform calculations', tool['description']
    assert tool['schema']
    
    schema = JSON.parse(tool['schema'])
    assert_equal 'object', schema['type']
    assert schema['properties']['operation']
  end
  
  def test_tool_definition_with_eval_parser
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <tool-definition name="search" description="Search for information" parser="eval">
          z.object({
            query: z.string(),
            limit: z.number().optional().default(10)
          })
        </tool-definition>
        <task>Search for information using the available tools</task>
      </poml>
    POML
    
    result = Poml.process(markup: markup)
    
    # Should process without errors
    assert result['content'].include?('Assistant')
    assert result['content'].include?('Search for information')
    
    # Tool should be registered in metadata
    assert result['tools']
    tool = result['tools'].first
    assert_equal 'search', tool['name']
    assert_equal 'Search for information', tool['description']
    # For eval parser, we store the raw expression
    assert tool['schema'].include?('z.object')
  end
  
  def test_multiple_tool_definitions
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <tool-definition name="calculate" description="Perform calculations">
          {
            "type": "object",
            "properties": {
              "operation": { "type": "string" },
              "a": { "type": "number" },
              "b": { "type": "number" }
            }
          }
        </tool-definition>
        <tool-definition name="search" description="Search information">
          {
            "type": "object",
            "properties": {
              "query": { "type": "string" }
            }
          }
        </tool-definition>
        <task>You have access to calculate and search tools</task>
      </poml>
    POML
    
    result = Poml.process(markup: markup)
    
    # Should process without errors
    assert result['content'].include?('Assistant')
    
    # Both tools should be registered
    assert result['tools']
    assert_equal 2, result['tools'].length
    
    tool_names = result['tools'].map { |t| t['name'] }
    assert_includes tool_names, 'calculate'
    assert_includes tool_names, 'search'
  end
  
  def test_backward_compatibility_meta_response_schema
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <meta type="responseSchema" parser="json">
          {
            "type": "object",
            "properties": {
              "answer": { "type": "string" }
            }
          }
        </meta>
        <task>Answer the question</task>
      </poml>
    POML
    
    result = Poml.process(markup: markup)
    
    # Should process without errors
    assert result['content'].include?('Assistant')
    assert result['content'].include?('Answer the question')
    
    # Schema should be registered in metadata
    assert result['metadata']['response_schema']
    schema = result['metadata']['response_schema']
    assert_equal 'object', schema['type']
    assert schema['properties']['answer']
  end
  
  def test_backward_compatibility_meta_tool
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <meta type="tool" name="weather" description="Get weather info" parser="json">
          {
            "type": "object",
            "properties": {
              "location": { "type": "string" }
            }
          }
        </meta>
        <task>Check the weather</task>
      </poml>
    POML
    
    result = Poml.process(markup: markup)
    
    # Should process without errors
    assert result['content'].include?('Assistant')
    assert result['content'].include?('Check the weather')
    
    # Tool should be registered in metadata
    assert result['tools']
    tool = result['tools'].first
    assert_equal 'weather', tool['name']
    assert_equal 'Get weather info', tool['description']
  end
  
  def test_lang_attribute_backward_compatibility
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <output-schema lang="json">
          {
            "type": "object",
            "properties": {
              "result": { "type": "string" }
            }
          }
        </output-schema>
        <task>Generate structured output</task>
      </poml>
    POML
    
    result = Poml.process(markup: markup)
    
    # Should process without errors and treat lang as parser
    assert result['content'].include?('Assistant')
    
    # Schema should be registered
    assert result['metadata']['response_schema']
    schema = result['metadata']['response_schema']
    assert_equal 'object', schema['type']
  end
  
end
