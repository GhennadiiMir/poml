require_relative "test_helper"

class TestSchemaCompatibility < Minitest::Test
  include TestHelper

  def test_output_schema_new_component_syntax
    markup = <<~POML
      <poml>
        <output-schema parser="json">
          {
            "type": "object",
            "properties": {
              "name": { "type": "string" },
              "age": { "type": "number" }
            },
            "required": ["name"]
          }
        </output-schema>
        <p>Test content</p>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    assert result['metadata']['response_schema']
    assert_equal "object", result['metadata']['response_schema']['type']
    assert result['metadata']['response_schema']['properties']
    assert_includes result['content'], "Test content"
  end

  def test_tool_definition_new_component_syntax
    markup = <<~POML
      <poml>
        <tool-definition name="calculate" description="Perform calculations" parser="json">
          {
            "type": "object",
            "properties": {
              "operation": { "type": "string" },
              "a": { "type": "number" },
              "b": { "type": "number" }
            },
            "required": ["operation", "a", "b"]
          }
        </tool-definition>
        <p>Test content</p>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    assert result['metadata']['tools']
    assert_equal 1, result['metadata']['tools'].length
    
    tool = result['metadata']['tools'].first
    assert_equal "calculate", tool['name']
    assert_equal "Perform calculations", tool['description']
    assert tool['parameters']
  end

  def test_tool_alias_syntax
    markup = <<~POML
      <poml>
        <tool name="search" description="Search for information" parser="json">
          {
            "type": "object",
            "properties": {
              "query": { "type": "string" }
            },
            "required": ["query"]
          }
        </tool>
        <p>Test content</p>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    assert result['metadata']['tools']
    assert_equal 1, result['metadata']['tools'].length
    
    tool = result['metadata']['tools'].first
    assert_equal "search", tool['name']
    assert_equal "Search for information", tool['description']
  end

  def test_multiple_output_schemas_error
    markup = <<~POML
      <poml>
        <output-schema parser="json">
          { "type": "object" }
        </output-schema>
        <output-schema parser="json">
          { "type": "string" }
        </output-schema>
      </poml>
    POML

    assert_raises(Poml::Error) do
      Poml.process(markup: markup)
    end
  end

  def test_output_schema_with_old_lang_json_attribute
    markup = <<~POML
      <poml>
        <meta type="responseschema" lang="json">
          {
            "type": "object",
            "properties": {
              "name": {"type": "string"},
              "age": {"type": "number"}
            }
          }
        </meta>
        <p>Generate a person object</p>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'dict')
    
    assert result['metadata']['response_schema']
    schema = result['metadata']['response_schema']
    assert_equal 'object', schema['type']
    assert schema['properties']['name']
    assert schema['properties']['age']
  end

  def test_output_schema_with_new_parser_json_attribute
    markup = <<~POML
      <poml>
        <meta type="responseschema" parser="json">
          {
            "type": "object",
            "properties": {
              "task": {"type": "string"},
              "priority": {"type": "number"}
            }
          }
        </meta>
        <p>Generate a task object</p>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'dict')
    
    assert result['metadata']['response_schema']
    schema = result['metadata']['response_schema']
    assert_equal 'object', schema['type']
    assert schema['properties']['task']
    assert schema['properties']['priority']
  end

  def test_output_schema_with_old_lang_expr_attribute
    markup = <<~POML
      <poml>
        <meta type="responseschema" lang="expr">
          {"type": "string", "maxLength": 100}
        </meta>
        <p>Generate a short string</p>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'dict')
    
    assert result['metadata']['response_schema']
    schema = result['metadata']['response_schema']
    assert_equal 'string', schema['type']
    assert_equal 100, schema['maxLength']
  end

  def test_output_schema_with_new_parser_eval_attribute
    markup = <<~POML
      <poml>
        <meta type="responseschema" parser="eval">
          {"type": "array", "items": {"type": "string"}}
        </meta>
        <p>Generate a string array</p>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'dict')
    
    assert result['metadata']['response_schema']
    schema = result['metadata']['response_schema']
    assert_equal 'array', schema['type']
    assert_equal 'string', schema['items']['type']
  end

  def test_tool_definition_with_old_lang_json_attribute
    markup = <<~POML
      <poml>
        <meta type="tool" name="calculate" description="Perform calculations" lang="json">
          {
            "type": "object",
            "properties": {
              "operation": {"type": "string", "enum": ["add", "subtract", "multiply", "divide"]},
              "a": {"type": "number"},
              "b": {"type": "number"}
            },
            "required": ["operation", "a", "b"]
          }
        </meta>
        <p>Use the calculator tool</p>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'dict')
    
    assert result['metadata']['tools']
    assert_equal 1, result['metadata']['tools'].length
    
    tool = result['metadata']['tools'].first
    assert_equal 'calculate', tool['name']
    assert_equal 'Perform calculations', tool['description']
    assert_equal 'object', tool['type']
    assert tool['properties']['operation']
    assert tool['properties']['a']
    assert tool['properties']['b']
    assert_includes tool['required'], 'operation'
  end

  def test_tool_definition_with_new_parser_json_attribute
    markup = <<~POML
      <poml>
        <meta type="tool" name="search" description="Search for information" parser="json">
          {
            "type": "object",
            "properties": {
              "query": {"type": "string"},
              "limit": {"type": "number", "default": 10}
            },
            "required": ["query"]
          }
        </meta>
        <p>Use the search tool</p>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'dict')
    
    assert result['metadata']['tools']
    assert_equal 1, result['metadata']['tools'].length
    
    tool = result['metadata']['tools'].first
    assert_equal 'search', tool['name']
    assert_equal 'Search for information', tool['description']
    assert_equal 'object', tool['type']
    assert tool['properties']['query']
    assert tool['properties']['limit']
    assert_includes tool['required'], 'query'
  end

  def test_tool_definition_with_old_lang_expr_attribute
    markup = <<~POML
      <poml>
        <meta type="tool" name="format" description="Format text" lang="expr">
          {
            "type": "object",
            "properties": {
              "text": {"type": "string"},
              "style": {"type": "string", "enum": ["bold", "italic", "underline"]}
            }
          }
        </meta>
        <p>Use the format tool</p>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'dict')
    
    assert result['metadata']['tools']
    tool = result['metadata']['tools'].first
    assert_equal 'format', tool['name']
    assert_equal 'Format text', tool['description']
    assert tool['properties']['text']
    assert tool['properties']['style']
  end

  def test_tool_definition_with_new_parser_eval_attribute
    markup = <<~POML
      <poml>
        <meta type="tool" name="validate" description="Validate data" parser="eval">
          {
            "type": "object",
            "properties": {
              "data": {"type": "string"},
              "rules": {"type": "array", "items": {"type": "string"}}
            }
          }
        </meta>
        <p>Use the validate tool</p>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'dict')
    
    assert result['metadata']['tools']
    tool = result['metadata']['tools'].first
    assert_equal 'validate', tool['name']
    assert_equal 'Validate data', tool['description']
    assert tool['properties']['data']
    assert tool['properties']['rules']
  end

  def test_auto_detection_with_json_content
    markup = <<~POML
      <poml>
        <meta type="responseschema">
          {
            "type": "boolean"
          }
        </meta>
        <p>Generate a boolean</p>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'dict')
    
    assert result['metadata']['response_schema']
    schema = result['metadata']['response_schema']
    assert_equal 'boolean', schema['type']
  end

  def test_auto_detection_with_expression_content
    markup = <<~POML
      <poml>
        <meta type="responseschema">
          {"type": "number", "minimum": 0}
        </meta>
        <p>Generate a positive number</p>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'dict')
    
    assert result['metadata']['response_schema']
    schema = result['metadata']['response_schema']
    assert_equal 'number', schema['type']
    assert_equal 0, schema['minimum']
  end

  def test_parser_attribute_takes_precedence_over_lang
    markup = <<~POML
      <poml>
        <meta type="responseschema" lang="expr" parser="json">
          {
            "type": "string",
            "enum": ["yes", "no"]
          }
        </meta>
        <p>Choose yes or no</p>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'dict')
    
    assert result['metadata']['response_schema']
    schema = result['metadata']['response_schema']
    assert_equal 'string', schema['type']
    assert_includes schema['enum'], 'yes'
    assert_includes schema['enum'], 'no'
  end

  def test_multiple_tools_with_mixed_attributes
    markup = <<~POML
      <poml>
        <meta type="tool" name="old_tool" description="Using old syntax" lang="json">
          {
            "type": "object",
            "properties": {"input": {"type": "string"}}
          }
        </meta>
        <meta type="tool" name="new_tool" description="Using new syntax" parser="json">
          {
            "type": "object",
            "properties": {"output": {"type": "string"}}
          }
        </meta>
        <p>Use both tools</p>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'dict')
    
    assert result['metadata']['tools']
    assert_equal 2, result['metadata']['tools'].length
    
    tool_names = result['metadata']['tools'].map { |t| t['name'] }
    assert_includes tool_names, 'old_tool'
    assert_includes tool_names, 'new_tool'
    
    old_tool = result['metadata']['tools'].find { |t| t['name'] == 'old_tool' }
    new_tool = result['metadata']['tools'].find { |t| t['name'] == 'new_tool' }
    
    assert old_tool['properties']['input']
    assert new_tool['properties']['output']
  end
end
