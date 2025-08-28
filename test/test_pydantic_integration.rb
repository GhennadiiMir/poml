require_relative 'test_helper'

class TestPydanticIntegration < Minitest::Test
  include TestHelper

  def test_basic_pydantic_format
    markup = "Hello world!"
    result = Poml.process(markup: markup, format: 'pydantic', chat: false)
    
    assert_instance_of Hash, result
    assert_equal "Hello world!", result['content']
    assert_equal false, result['chat_enabled']
    assert_instance_of Hash, result['variables']
    assert_instance_of Array, result['schemas']
    assert_instance_of Hash, result['metadata']
  end

  def test_pydantic_with_variables
    markup = "Hello {{name}}!"
    variables = { 'name' => 'Python Developer' }
    result = Poml.process(markup: markup, format: 'pydantic', variables: variables, chat: false)
    
    assert_equal "Hello Python Developer!", result['content']
    assert_equal variables, result['variables']
    assert_equal false, result['chat_enabled']
  end

  def test_pydantic_metadata_structure
    markup = "Test content"
    result = Poml.process(markup: markup, format: 'pydantic', chat: false)
    
    metadata = result['metadata']
    assert_equal 'pydantic', metadata['format']
    assert_equal '1.0', metadata['version']
    assert_equal true, metadata['python_compatible']
    assert_equal true, metadata['strict_json_schema']
  end

  def test_pydantic_with_schema_element
    markup = <<~POML
      <schema name="UserQuery" type="object" description="User query schema">
      {
        "type": "object",
        "properties": {
          "query": {"type": "string", "description": "The search query"},
          "limit": {"type": "integer", "description": "Result limit"}
        }
      }
      </schema>
      Process user query
    POML
    
    result = Poml.process(markup: markup, format: 'pydantic', chat: false)
    
    assert_equal 1, result['schemas'].length
    schema = result['schemas'].first
    
    # Check that schema was properly parsed and made strict
    assert_equal 'object', schema['type']
    assert_equal false, schema['additionalProperties']
    
    # Check strict schema properties
    assert_instance_of Hash, schema['properties']
    assert_equal ['query', 'limit'], schema['required']
  end

  def test_pydantic_strict_json_schema_processing
    markup = <<~POML
      <schema name="StrictSchema">
      {
        "type": "object",
        "properties": {
          "name": {"type": "string"},
          "age": {"type": "integer"},
          "settings": {
            "type": "object",
            "properties": {
              "theme": {"type": "string"},
              "notifications": {"type": "boolean"}
            }
          }
        }
      }
      </schema>
    POML
    
    result = Poml.process(markup: markup, format: 'pydantic', chat: false)
    schema = result['schemas'].first
    
    # Root level should be strict
    assert_equal false, schema['additionalProperties']
    assert_equal ['name', 'age', 'settings'], schema['required']
    
    # Nested objects should also be strict
    settings_schema = schema['properties']['settings']
    assert_equal false, settings_schema['additionalProperties']
    assert_equal ['theme', 'notifications'], settings_schema['required']
  end

  def test_pydantic_with_tools
    markup = <<~POML
      <tool name="search_database" description="Search the user database">
      {
        "type": "object",
        "properties": {
          "query": {"type": "string", "description": "Search query"},
          "limit": {"type": "integer", "description": "Result limit"}
        },
        "required": ["query"]
      }
      </tool>
      Search for users
    POML
    
    result = Poml.process(markup: markup, format: 'pydantic', chat: false)
    
    assert_equal 1, result['tools'].length
    tool = result['tools'].first
    
    assert_equal 'search_database', tool['name']
    assert_equal 'Search the user database', tool['description']
    
    # Check that parameters were processed and made strict
    params = tool['parameters']
    assert_equal 'object', params['type']
    assert_equal false, params['additionalProperties']
    assert_equal ['query'], params['required']  # Only query is required as defined in JSON
    assert_equal ['query', 'limit'], params['properties'].keys  # Both properties exist
  end

  def test_pydantic_with_custom_metadata
    markup = <<~POML
      <meta title="Test Document" description="A test document for Pydantic integration"/>
      <meta author="Developer"/>
      Process with metadata
    POML
    
    result = Poml.process(markup: markup, format: 'pydantic', chat: false)
    
    custom_metadata = result['custom_metadata']
    assert_equal 'Test Document', custom_metadata['title']
    assert_equal 'A test document for Pydantic integration', custom_metadata['description']
    assert_equal 'Developer', custom_metadata['author']
  end

  def test_pydantic_with_single_schema
    markup = <<~POML
      <schema name="InputSchema" type="object">
      {"type": "object", "properties": {"input": {"type": "string"}}}
      </schema>
      
      Process with schema
    POML
    
    result = Poml.process(markup: markup, format: 'pydantic', chat: false)
    
    assert_equal 1, result['schemas'].length
    schema = result['schemas'].first
    assert_equal 'object', schema['type']
    assert_equal false, schema['additionalProperties']
  end

  def test_pydantic_schema_with_arrays
    markup = <<~POML
      <schema name="ArraySchema">
      {
        "type": "object",
        "properties": {
          "items": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "id": {"type": "integer"},
                "name": {"type": "string"}
              }
            }
          }
        }
      }
      </schema>
    POML
    
    result = Poml.process(markup: markup, format: 'pydantic', chat: false)
    schema = result['schemas'].first
    
    # Check array items are processed strictly
    items_schema = schema['properties']['items']
    assert_equal 'array', items_schema['type']
    
    item_schema = items_schema['items']
    assert_equal false, item_schema['additionalProperties']
    assert_equal ['id', 'name'], item_schema['required']
  end

  def test_pydantic_convenience_method
    markup = "Test Pydantic convenience method"
    result = Poml.to_pydantic(markup, chat: false)
    
    assert_instance_of Hash, result
    assert_equal "Test Pydantic convenience method", result['content']
    assert_equal 'pydantic', result['metadata']['format']
  end

  def test_pydantic_with_null_default_removal
    markup = <<~POML
      <schema name="NullDefaultSchema">
      {
        "type": "object",
        "properties": {
          "required_field": {"type": "string"},
          "optional_field": {"type": "string", "default": null},
          "other_field": {"type": "string", "default": "value"}
        }
      }
      </schema>
    POML
    
    result = Poml.process(markup: markup, format: 'pydantic', chat: false)
    schema = result['schemas'].first
    
    properties = schema['properties']
    
    # Null default should be removed
    refute properties['optional_field'].key?('default')
    
    # Non-null default should be preserved
    assert_equal 'value', properties['other_field']['default']
  end

  def test_pydantic_empty_elements_handling
    markup = "Just plain content without special elements"
    result = Poml.process(markup: markup, format: 'pydantic', chat: false)
    
    assert_equal [], result['schemas']
    assert_equal [], result['tools']
    assert_equal({}, result['custom_metadata'])
    assert_equal "Just plain content without special elements", result['content']
  end

  def test_pydantic_chat_mode_enabled
    markup = "Chat enabled test"
    result = Poml.process(markup: markup, format: 'pydantic', chat: true)
    
    assert_equal true, result['chat_enabled']
  end
end
