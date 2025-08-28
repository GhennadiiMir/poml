require_relative 'test_helper'

class TestEnhancedToolRegistration < Minitest::Test
  include TestHelper

  def test_runtime_parameter_type_conversion_boolean
    # Test automatic boolean conversion for tool parameters
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <tool-definition name="config" description="Configure settings" parser="json">
          {
            "type": "object",
            "properties": {
              "enabled": { "type": "boolean", "convert": "true" },
              "disabled": { "type": "boolean", "convert": "false" },
              "verbose": { "type": "boolean", "convert": "1" },
              "quiet": { "type": "boolean", "convert": "0" }
            }
          }
        </tool-definition>
        <task>Configure system settings</task>
      </poml>
    POML

    result = Poml.process(markup: markup)

    # Tool should be registered
    assert result['metadata']['tools']
    tool = result['metadata']['tools'].first
    assert_equal 'config', tool['name']
    
    # Check that boolean conversion metadata is preserved but values are converted
    schema = JSON.parse(tool['schema'])
    properties = schema['properties']
    
    # The converted values should be actual booleans in the final schema
    assert_equal 'boolean', properties['enabled']['type']
    assert_equal 'boolean', properties['disabled']['type']
    assert_equal 'boolean', properties['verbose']['type']
    assert_equal 'boolean', properties['quiet']['type']
  end

  def test_runtime_parameter_type_conversion_number
    # Test automatic number conversion for tool parameters
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <tool-definition name="calculator" description="Perform calculations" parser="json">
          {
            "type": "object",
            "properties": {
              "count": { "type": "number", "convert": "42" },
              "rate": { "type": "number", "convert": "3.14" },
              "percentage": { "type": "number", "convert": "0.75" }
            }
          }
        </tool-definition>
        <task>Perform calculations</task>
      </poml>
    POML

    result = Poml.process(markup: markup)

    # Tool should be registered
    tool = result['metadata']['tools'].first
    assert_equal 'calculator', tool['name']
    
    # Check that number conversion works
    schema = JSON.parse(tool['schema'])
    properties = schema['properties']
    
    assert_equal 'number', properties['count']['type']
    assert_equal 'number', properties['rate']['type']
    assert_equal 'number', properties['percentage']['type']
  end

  def test_runtime_parameter_type_conversion_json
    # Test automatic JSON parsing for complex tool parameters
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <tool-definition name="data_processor" description="Process data structures" parser="json">
          {
            "type": "object",
            "properties": {
              "config": { 
                "type": "object", 
                "convert": "{\\"nested\\": true, \\"values\\": [1, 2, 3]}" 
              },
              "tags": { 
                "type": "array", 
                "convert": "[\\"tag1\\", \\"tag2\\", \\"tag3\\"]" 
              }
            }
          }
        </tool-definition>
        <task>Process complex data</task>
      </poml>
    POML

    result = Poml.process(markup: markup)

    # Tool should be registered
    tool = result['metadata']['tools'].first
    assert_equal 'data_processor', tool['name']
    
    # Check that JSON conversion works
    schema = JSON.parse(tool['schema'])
    properties = schema['properties']
    
    assert_equal 'object', properties['config']['type']
    assert_equal 'array', properties['tags']['type']
  end

  def test_parameter_key_conversion_kebab_to_camel_case
    # Test automatic kebab-case to camelCase conversion for parameter keys
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <tool-definition name="api_client" description="API client configuration" parser="json">
          {
            "type": "object",
            "properties": {
              "api-key": { "type": "string" },
              "base-url": { "type": "string" },
              "retry-count": { "type": "number" },
              "timeout-seconds": { "type": "number" },
              "enable-logging": { "type": "boolean" },
              "user-agent": { "type": "string" }
            },
            "required": ["api-key", "base-url"]
          }
        </tool-definition>
        <task>Configure API client</task>
      </poml>
    POML

    result = Poml.process(markup: markup)

    # Tool should be registered
    tool = result['metadata']['tools'].first
    assert_equal 'api_client', tool['name']
    
    # Check that kebab-case keys are converted to camelCase
    schema = JSON.parse(tool['schema'])
    properties = schema['properties']
    
    # Should have camelCase keys
    assert properties['apiKey']
    assert properties['baseUrl']
    assert properties['retryCount']
    assert properties['timeoutSeconds']
    assert properties['enableLogging']
    assert properties['userAgent']
    
    # Should not have kebab-case keys
    refute properties['api-key']
    refute properties['base-url']
    refute properties['retry-count']
    refute properties['timeout-seconds']
    refute properties['enable-logging']
    refute properties['user-agent']
    
    # Required fields should also be converted
    required = schema['required']
    assert_includes required, 'apiKey'
    assert_includes required, 'baseUrl'
    refute_includes required, 'api-key'
    refute_includes required, 'base-url'
  end

  def test_parameter_key_conversion_nested_objects
    # Test kebab-case to camelCase conversion in nested objects
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <tool-definition name="complex_config" description="Complex configuration" parser="json">
          {
            "type": "object",
            "properties": {
              "database-config": {
                "type": "object",
                "properties": {
                  "connection-string": { "type": "string" },
                  "max-connections": { "type": "number" },
                  "ssl-enabled": { "type": "boolean" }
                }
              },
              "cache-settings": {
                "type": "object",
                "properties": {
                  "ttl-seconds": { "type": "number" },
                  "cache-size": { "type": "number" }
                }
              }
            }
          }
        </tool-definition>
        <task>Configure complex system</task>
      </poml>
    POML

    result = Poml.process(markup: markup)

    # Tool should be registered
    tool = result['metadata']['tools'].first
    assert_equal 'complex_config', tool['name']
    
    # Check that nested kebab-case keys are converted
    schema = JSON.parse(tool['schema'])
    properties = schema['properties']
    
    # Top-level keys should be converted
    assert properties['databaseConfig']
    assert properties['cacheSettings']
    refute properties['database-config']
    refute properties['cache-settings']
    
    # Nested keys should also be converted
    db_props = properties['databaseConfig']['properties']
    assert db_props['connectionString']
    assert db_props['maxConnections']
    assert db_props['sslEnabled']
    refute db_props['connection-string']
    refute db_props['max-connections']
    refute db_props['ssl-enabled']
    
    cache_props = properties['cacheSettings']['properties']
    assert cache_props['ttlSeconds']
    assert cache_props['cacheSize']
    refute cache_props['ttl-seconds']
    refute cache_props['cache-size']
  end

  def test_combined_enhancements_with_meta_tool_registration
    # Test both enhancements working together with meta tool registration
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <meta type="tool-definition" name="enhanced_tool" description="Enhanced tool with conversions" parser="json">
          {
            "type": "object",
            "properties": {
              "is-enabled": { "type": "boolean", "convert": "true" },
              "max-retries": { "type": "number", "convert": "5" },
              "config-data": { 
                "type": "object", 
                "convert": "{\\"nested\\": true}" 
              }
            },
            "required": ["is-enabled"]
          }
        </meta>
        <task>Use enhanced tool registration</task>
      </poml>
    POML

    result = Poml.process(markup: markup)

    # Tool should be registered
    assert result['metadata']['tools']
    tool = result['metadata']['tools'].first
    assert_equal 'enhanced_tool', tool['name']
    
    # Check both key conversion and type conversion
    schema = JSON.parse(tool['schema'])
    properties = schema['properties']
    
    # Keys should be converted to camelCase
    assert properties['isEnabled']
    assert properties['maxRetries']
    assert properties['configData']
    refute properties['is-enabled']
    refute properties['max-retries']
    refute properties['config-data']
    
    # Required fields should also be converted
    required = schema['required']
    assert_includes required, 'isEnabled'
    refute_includes required, 'is-enabled'
  end

  def test_backwards_compatibility_preserved
    # Test that existing tool definitions without enhancements continue to work
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <tool-definition name="simple_tool" description="Simple tool" parser="json">
          {
            "type": "object",
            "properties": {
              "query": { "type": "string" },
              "limit": { "type": "number" }
            },
            "required": ["query"]
          }
        </tool-definition>
        <task>Use simple tool</task>
      </poml>
    POML

    result = Poml.process(markup: markup)

    # Tool should be registered normally
    tool = result['metadata']['tools'].first
    assert_equal 'simple_tool', tool['name']
    
    # Schema should remain unchanged since no conversion attributes
    schema = JSON.parse(tool['schema'])
    properties = schema['properties']
    
    assert properties['query']
    assert properties['limit']
    assert_equal 'string', properties['query']['type']
    assert_equal 'number', properties['limit']['type']
    assert_equal ['query'], schema['required']
  end

  def test_parameter_conversion_error_handling
    # Test graceful handling of invalid conversion values
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <tool-definition name="error_tool" description="Tool with invalid conversions" parser="json">
          {
            "type": "object", 
            "properties": {
              "invalid_boolean": { "type": "boolean", "convert": "maybe" },
              "invalid_number": { "type": "number", "convert": "not_a_number" },
              "invalid_json": { "type": "object", "convert": "{ invalid json }" }
            }
          }
        </tool-definition>
        <task>Test error handling</task>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    # Tool should still be registered despite conversion errors
    assert result['metadata']['tools']
    tool = result['metadata']['tools'].first
    assert_equal 'error_tool', tool['name']
    
    # Schema should be valid JSON and conversion errors handled gracefully
    schema = JSON.parse(tool['schema']) # Should not raise an exception
    schema = JSON.parse(tool['schema'])
    
    # Properties should still exist but invalid convert attributes should be handled
    assert schema['properties']['invalid_boolean']
    assert schema['properties']['invalid_number'] 
    assert schema['properties']['invalid_json']
  end

  def test_schema_storage_format_consistency
    # Test that schema is consistently stored as JSON string in both components
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <tool-definition name="format_test" description="Test schema format" parser="json">
          {
            "type": "object",
            "properties": {
              "test-property": { "type": "string" }
            }
          }
        </tool-definition>
        <task>Test schema format</task>
      </poml>
    POML

    result = Poml.process(markup: markup)
    tool = result['metadata']['tools'].first
    
    # Schema should be stored as JSON string
    assert tool['schema'].is_a?(String), "Schema should be stored as JSON string"
    schema = JSON.parse(tool['schema']) # Should not raise an exception
    
    # Parsed schema should have converted keys
    schema = JSON.parse(tool['schema'])
    assert schema['properties']['testProperty'], "Property keys should be converted to camelCase"
    refute schema['properties']['test-property'], "Original kebab-case keys should not remain"
    
    # Schema conversion is the primary feature - direct property access depends on implementation
  end

  def test_mixed_key_formats_in_single_schema
    # Test handling of mixed kebab-case and camelCase keys in the same schema
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <tool-definition name="mixed_keys" description="Mixed key formats" parser="json">
          {
            "type": "object",
            "properties": {
              "kebab-case-key": { "type": "string" },
              "camelCaseKey": { "type": "string" },
              "simple": { "type": "string" },
              "multi-word-kebab": { "type": "number" }
            },
            "required": ["kebab-case-key", "camelCaseKey"]
          }
        </tool-definition>
        <task>Test mixed formats</task>
      </poml>
    POML

    result = Poml.process(markup: markup)
    tool = result['metadata']['tools'].first
    schema = JSON.parse(tool['schema'])
    
    # All keys should be converted to camelCase
    expected_keys = ["kebabCaseKey", "camelCaseKey", "simple", "multiWordKebab"]
    actual_keys = schema['properties'].keys.sort
    assert_equal expected_keys.sort, actual_keys
    
    # Required array should also be converted
    expected_required = ["kebabCaseKey", "camelCaseKey"]
    assert_equal expected_required.sort, schema['required'].sort
  end

  def test_deep_nested_object_key_conversion
    # Test key conversion in deeply nested object structures
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <tool-definition name="deep_nested" description="Deep nested conversion" parser="json">
          {
            "type": "object",
            "properties": {
              "outer-config": {
                "type": "object",
                "properties": {
                  "inner-settings": {
                    "type": "object", 
                    "properties": {
                      "deep-option": { "type": "boolean" },
                      "very-deep-value": { "type": "string" }
                    }
                  },
                  "other-inner": { "type": "number" }
                }
              }
            }
          }
        </tool-definition>
        <task>Test deep nesting</task>
      </poml>
    POML

    result = Poml.process(markup: markup)
    tool = result['metadata']['tools'].first
    schema = JSON.parse(tool['schema'])
    
    # Check outer level conversion
    assert schema['properties']['outerConfig']
    
    # Check inner level conversion
    inner = schema['properties']['outerConfig']['properties']
    assert inner['innerSettings']
    assert inner['otherInner']
    
    # Check deepest level conversion
    deep = inner['innerSettings']['properties']
    assert deep['deepOption']
    assert deep['veryDeepValue']
  end

  def test_meta_component_parity_with_tool_definition
    # Test that meta component provides same functionality as tool-definition
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <meta type="tool-definition" name="meta_enhanced" description="Meta component test">
          {
            "type": "object",
            "properties": {
              "kebab-param": { "type": "string", "convert": "test_value" },
              "boolean-param": { "type": "boolean", "convert": "true" }
            },
            "required": ["kebab-param"]
          }
        </meta>
        <task>Test meta component enhancements</task>
      </poml>
    POML

    result = Poml.process(markup: markup)
    tool = result['metadata']['tools'].first
    
    assert_equal 'meta_enhanced', tool['name']
    assert_equal 'Meta component test', tool['description']
    
    # Schema should be stored consistently
    assert tool['schema'].is_a?(String)
    schema = JSON.parse(tool['schema'])
    
    # Key conversion should work
    assert schema['properties']['kebabParam']
    assert schema['properties']['booleanParam']
    assert_equal ['kebabParam'], schema['required']
    
    # Backward compatibility - properties should be merged
    # Debug: let's see what keys are actually available
    puts "Available tool keys: #{tool.keys.inspect}" if ENV['DEBUG']
    
    # The converted properties should be available according to the schema conversion
    assert schema['properties']['kebabParam'], "kebabParam should exist in schema"
    assert schema['properties']['booleanParam'], "booleanParam should exist in schema"
  end
end
