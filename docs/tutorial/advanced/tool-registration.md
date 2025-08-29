# Tool Registration

POML provides an enhanced tool registration system with automatic parameter conversion, multiple registration formats, and comprehensive metadata integration.

## Overview

The enhanced tool registration system includes:

- **Multiple Registration Formats** - Various ways to define tools
- **Runtime Parameter Conversion** - Automatic type conversion for parameters
- **kebab-case to camelCase Conversion** - Automatic parameter key conversion
- **Comprehensive Metadata** - Full tool integration in response metadata

## Basic Tool Registration

### Using tool-definition Component

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>Database Assistant</role>
    <task>Help with database operations</task>
    
    <tool-definition name="execute_query">
    {
      "description": "Execute a SQL query on the database",
      "parameters": {
        "type": "object",
        "properties": {
          "query": {
            "type": "string",
            "description": "The SQL query to execute"
          },
          "database": {
            "type": "string",
            "description": "Target database name"
          }
        },
        "required": ["query", "database"]
      }
    }
    </tool-definition>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['tools']  # Tools are now at top level
```

### Using meta Component

```ruby
markup = <<~POML
  <poml>
    <role>File Manager</role>
    <task>Manage files and directories</task>
    
    <meta type="tool" name="file_operations">
    {
      "description": "Perform file system operations", 
      "parameters": {
        "type": "object",
        "properties": {
          "operation": {"type": "string", "enum": ["read", "write", "delete"]},
          "path": {"type": "string"},
          "content": {"type": "string"}
        },
        "required": ["operation", "path"]
      }
    }
    </meta>
  </poml>
POML

result = Poml.process(markup: markup)
```

### Attribute-Based Registration

```ruby
markup = <<~POML
  <poml>
    <role>API Helper</role>
    <task>Make HTTP requests</task>
    
    <meta tool="http_request" description="Make HTTP API requests">
    {
      "parameters": {
        "type": "object",
        "properties": {
          "url": {"type": "string", "format": "uri"},
          "method": {"type": "string", "enum": ["GET", "POST", "PUT", "DELETE"]},
          "headers": {"type": "object"},
          "body": {"type": "object"}
        },
        "required": ["url", "method"]
      }
    }
    </meta>
  </poml>
POML

result = Poml.process(markup: markup)
```

## Enhanced Parameter Conversion

### Automatic Type Conversion

The enhanced tool registration automatically converts parameter types at runtime:

```ruby
markup = <<~POML
  <poml>
    <role>Configuration Manager</role>
    <task>Manage application configuration</task>
    
    <tool-definition name="update_config">
    {
      "description": "Update application configuration",
      "parameters": {
        "type": "object",
        "properties": {
          "enabled": "boolean",
          "max_connections": "number", 
          "timeout": "number",
          "features": "array",
          "metadata": "object",
          "config_name": "string"
        }
      }
    }
    </tool-definition>
  </poml>
POML

result = Poml.process(markup: markup)

# Parameter types are automatically converted:
# "boolean" -> {"type": "boolean"}
# "number" -> {"type": "number"}
# "array" -> {"type": "array"}
# "object" -> {"type": "object"}
# "string" -> {"type": "string"}
```

### Complex Type Conversion

```ruby
markup = <<~POML
  <poml>
    <role>Data Processor</role>
    <task>Process and validate data</task>
    
    <tool-definition name="process_data">
    {
      "description": "Process and validate input data",
      "parameters": {
        "type": "object",
        "properties": {
          "input_data": {
            "type": "array",
            "items": "object",
            "description": "Array of data objects to process"
          },
          "validation_rules": {
            "type": "object",
            "properties": {
              "required_fields": "array",
              "field_types": "object",
              "custom_validators": "array"
            }
          },
          "processing_options": {
            "type": "object", 
            "properties": {
              "batch_size": "number",
              "parallel_processing": "boolean",
              "error_handling": "string"
            }
          }
        }
      }
    }
    </tool-definition>
  </poml>
POML

result = Poml.process(markup: markup)
```

## kebab-case to camelCase Conversion

### Automatic Key Conversion

Parameter keys in kebab-case are automatically converted to camelCase:

```ruby
markup = <<~POML
  <poml>
    <role>API Integration Specialist</role>
    <task>Configure API integrations</task>
    
    <tool-definition name="configure_api">
    {
      "description": "Configure API integration settings",
      "parameters": {
        "type": "object",
        "properties": {
          "api-endpoint": {"type": "string"},
          "request-timeout": {"type": "number"},
          "retry-attempts": {"type": "number"},
          "authentication-type": {"type": "string"},
          "rate-limit-requests": {"type": "number"},
          "enable-logging": {"type": "boolean"},
          "custom-headers": {"type": "object"},
          "response-format": {"type": "string"}
        }
      }
    }
    </tool-definition>
  </poml>
POML

result = Poml.process(markup: markup)

# Keys are automatically converted:
# "api-endpoint" -> "apiEndpoint"
# "request-timeout" -> "requestTimeout" 
# "retry-attempts" -> "retryAttempts"
# "authentication-type" -> "authenticationType"
# "rate-limit-requests" -> "rateLimitRequests"
# "enable-logging" -> "enableLogging"
# "custom-headers" -> "customHeaders"
# "response-format" -> "responseFormat"
```

### Deep Nested Conversion

The conversion works recursively on nested objects:

```ruby
markup = <<~POML
  <poml>
    <role>Database Configuration Manager</role>
    <task>Configure database connections</task>
    
    <tool-definition name="setup_database">
    {
      "description": "Setup database connection configuration",
      "parameters": {
        "type": "object",
        "properties": {
          "connection-settings": {
            "type": "object",
            "properties": {
              "host-address": {"type": "string"},
              "port-number": {"type": "number"},
              "database-name": {"type": "string"},
              "connection-timeout": {"type": "number"},
              "pool-settings": {
                "type": "object",
                "properties": {
                  "min-connections": {"type": "number"},
                  "max-connections": {"type": "number"},
                  "connection-lifetime": {"type": "number"},
                  "idle-timeout": {"type": "number"}
                }
              }
            }
          },
          "security-options": {
            "type": "object", 
            "properties": {
              "ssl-enabled": {"type": "boolean"},
              "certificate-path": {"type": "string"},
              "encryption-level": {"type": "string"}
            }
          }
        }
      }
    }
    </tool-definition>
  </poml>
POML

result = Poml.process(markup: markup)

# All nested keys are converted:
# connection-settings -> connectionSettings
#   host-address -> hostAddress
#   port-number -> portNumber
#   pool-settings -> poolSettings
#     min-connections -> minConnections
#     max-connections -> maxConnections
#     etc.
```

## Multiple Tool Registration

### Registering Multiple Tools

```ruby
markup = <<~POML
  <poml>
    <role>DevOps Engineer</role>
    <task>Manage infrastructure and deployments</task>
    
    <tool-definition name="deploy_application">
    {
      "description": "Deploy application to specified environment",
      "parameters": {
        "type": "object",
        "properties": {
          "environment": {"type": "string", "enum": ["dev", "staging", "prod"]},
          "version": {"type": "string"},
          "rollback-on-failure": {"type": "boolean", "default": true}
        }
      }
    }
    </tool-definition>
    
    <tool-definition name="scale_service">
    {
      "description": "Scale service instances up or down",
      "parameters": {
        "type": "object",
        "properties": {
          "service-name": {"type": "string"},
          "instance-count": {"type": "number", "minimum": 1},
          "auto-scaling": {"type": "boolean", "default": false}
        }
      }
    }
    </tool-definition>
    
    <tool-definition name="check_health">
    {
      "description": "Perform health check on services",
      "parameters": {
        "type": "object",
        "properties": {
          "services": {"type": "array", "items": {"type": "string"}},
          "include-dependencies": {"type": "boolean", "default": true}
        }
      }
    }
    </tool-definition>
  </poml>
POML

result = Poml.process(markup: markup)
puts "Registered #{result['tools'].length} tools"
```

### Mixed Registration Formats

```ruby
markup = <<~POML
  <poml>
    <role>System Administrator</role>
    <task>Manage system operations</task>
    
    <!-- New format -->
    <tool-definition name="system_monitor">
    {
      "description": "Monitor system performance metrics",
      "parameters": {
        "type": "object",
        "properties": {
          "metric-types": {"type": "array"},
          "time-range": {"type": "string"}
        }
      }
    }
    </tool-definition>
    
    <!-- Legacy format -->
    <meta type="tool" name="backup_data">
    {
      "description": "Backup system data",
      "parameters": {
        "type": "object",
        "properties": {
          "backup-location": {"type": "string"},
          "compression-enabled": {"type": "boolean"}
        }
      }
    }
    </meta>
    
    <!-- Attribute format -->
    <meta tool="restart_service" description="Restart system service">
    {
      "parameters": {
        "type": "object",
        "properties": {
          "service-name": {"type": "string"},
          "force-restart": {"type": "boolean"}
        }
      }
    }
    </meta>
  </poml>
POML

result = Poml.process(markup: markup)
```

## Template Variables in Tools

### Dynamic Tool Definitions

```ruby
markup = <<~POML
  <poml>
    <role>{{service_type}} Manager</role>
    <task>Manage {{service_type}} operations</task>
    
    <tool-definition name="{{tool_name}}">
    {
      "description": "{{tool_description}}",
      "parameters": {
        "type": "object",
        "properties": {
          {{#parameters}}
          "{{name}}": {
            "type": "{{type}}", 
            "description": "{{description}}"
            {{#default}}, "default": {{default}}{{/default}}
          }{{#unless @last}},{{/unless}}
          {{/parameters}}
        }
      }
    }
    </tool-definition>
  </poml>
POML

context = {
  'service_type' => 'Database',
  'tool_name' => 'execute_query',
  'tool_description' => 'Execute SQL query on database',
  'parameters' => [
    { 'name' => 'query', 'type' => 'string', 'description' => 'SQL query to execute' },
    { 'name' => 'timeout', 'type' => 'number', 'description' => 'Query timeout in seconds', 'default' => '30' }
  ]
}

result = Poml.process(markup: markup, context: context)
```

### Conditional Tool Registration

```ruby
markup = <<~POML
  <poml>
    <role>{{environment}} Administrator</role>
    <task>Manage {{environment}} environment</task>
    
    <if condition="{{environment}} == 'production'">
      <tool-definition name="production_deploy">
      {
        "description": "Deploy to production with safety checks",
        "parameters": {
          "type": "object",
          "properties": {
            "version": {"type": "string"},
            "approval-required": {"type": "boolean", "default": true},
            "rollback-plan": {"type": "string"}
          },
          "required": ["version", "rollback-plan"]
        }
      }
      </tool-definition>
    </if>
    
    <if condition="{{environment}} == 'development'">
      <tool-definition name="dev_deploy">
      {
        "description": "Quick deployment for development",
        "parameters": {
          "type": "object",
          "properties": {
            "branch": {"type": "string", "default": "main"},
            "skip-tests": {"type": "boolean", "default": false}
          }
        }
      }
      </tool-definition>
    </if>
  </poml>
POML

context = { 'environment' => 'production' }
result = Poml.process(markup: markup, context: context)
```

## Schema Consistency

### Enhanced Storage Format

The enhanced tool registration ensures consistent schema storage:

```ruby
markup = <<~POML
  <poml>
    <role>API Documentation Generator</role>
    <task>Generate API documentation</task>
    
    <tool-definition name="generate_docs">
    {
      "description": "Generate API documentation from schema",
      "parameters": {
        "type": "object",
        "properties": {
          "api-specification": "object",
          "output-format": "string",
          "include-examples": "boolean"
        }
      }
    }
    </tool-definition>
  </poml>
POML

result = Poml.process(markup: markup)

# Enhanced storage format ensures consistency:
tool = result['tools'][0]  # Tools are now at top level
puts tool['name']         # "generate_docs"
puts tool['description']  # "Generate API documentation from schema"
puts tool['parameters']   # Properly structured parameters object

# Parameters are stored in consistent format:
# - Type conversion applied
# - camelCase conversion applied
# - Proper JSON schema structure maintained
```

## Integration with Output Formats

### OpenAI Chat Format

```ruby
markup = <<~POML
  <poml>
    <role>Code Assistant</role>
    <task>Help with programming tasks</task>
    
    <tool-definition name="analyze_code">
    {
      "description": "Analyze code for issues and improvements",
      "parameters": {
        "type": "object",
        "properties": {
          "source-code": {"type": "string"},
          "language": {"type": "string"},
          "analysis-type": {"type": "array", "items": {"type": "string"}}
        }
      }
    }
    </tool-definition>
  </poml>
POML

result = Poml.process(markup: markup, format: 'openai_chat')

# Tools are included in OpenAI format for function calling
puts result  # Contains both messages and tool definitions
```

### OpenAI Response Format

```ruby
result = Poml.process(markup: markup, format: 'openaiResponse')

puts result['tools']  # Tools available at top level
puts result['content']            # Formatted prompt content
```

## Error Handling and Validation

### Tool Definition Validation

```ruby
def validate_tool_definition(markup)
  begin
    result = Poml.process(markup: markup)
    tools = result['tools']  # Tools are now at top level
    
    tools.each do |tool|
      errors = []
      
      # Check required fields
      errors << "Missing description" unless tool['description']
      errors << "Missing parameters" unless tool['parameters']
      
      # Validate parameters structure
      if tool['parameters']
        params = tool['parameters']
        errors << "Parameters must have type 'object'" unless params['type'] == 'object'
        errors << "Parameters missing properties" unless params['properties']
      end
      
      if errors.empty?
        puts "✅ Tool '#{tool['name']}' is valid"
      else
        puts "❌ Tool '#{tool['name']}' errors: #{errors.join(', ')}"
      end
    end
    
  rescue StandardError => e
    puts "❌ Error processing tools: #{e.message}"
  end
end

# Usage
markup = <<~POML
  <poml>
    <tool-definition name="test_tool">
    {
      "description": "Test tool",
      "parameters": {
        "type": "object",
        "properties": {
          "input": {"type": "string"}
        }
      }
    }
    </tool-definition>
  </poml>
POML

validate_tool_definition(markup)
```

### Safe Tool Processing

```ruby
class SafeToolProcessor
  def self.process_tools(markup, context = {})
    begin
      result = Poml.process(markup: markup, context: context)
      
      # Validate tool structure
      tools = result['tools'] || []  # Tools are now at top level
      valid_tools = tools.select { |tool| valid_tool?(tool) }
      
      {
        'success' => true,
        'tools' => valid_tools,
        'invalid_count' => tools.length - valid_tools.length
      }
      
    rescue StandardError => e
      {
        'success' => false,
        'error' => e.message,
        'tools' => []
      }
    end
  end
  
  private
  
  def self.valid_tool?(tool)
    tool.is_a?(Hash) &&
      tool['name'] &&
      tool['description'] &&
      tool['parameters']&.is_a?(Hash)
  end
end

# Usage
result = SafeToolProcessor.process_tools(markup, context)
if result['success']
  puts "Processed #{result['tools'].length} valid tools"
else
  puts "Error: #{result['error']}"
end
```

## Best Practices

### 1. Use Descriptive Tool Names

```ruby
# Good
<tool-definition name="execute_query">

# Better
<tool-definition name="execute_database_query">

# Best  
<tool-definition name="execute_sql_query_with_validation">
```

### 2. Provide Comprehensive Descriptions

```ruby
{
  "description": "Execute a SQL query on the specified database with optional result limiting and error handling",
  "parameters": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "Valid SQL SELECT, INSERT, UPDATE, or DELETE statement"
      }
    }
  }
}
```

### 3. Use Validation Constraints

```ruby
{
  "parameters": {
    "type": "object",
    "properties": {
      "timeout": {
        "type": "number",
        "minimum": 1,
        "maximum": 300,
        "default": 30,
        "description": "Query timeout in seconds (1-300)"
      },
      "operation": {
        "type": "string",
        "enum": ["select", "insert", "update", "delete"],
        "description": "Type of database operation"
      }
    }
  }
}
```

### 4. Organize Complex Tools

```ruby
# Break complex tools into logical sections
{
  "description": "Comprehensive API request tool",
  "parameters": {
    "type": "object",
    "properties": {
      "request_config": {
        "type": "object",
        "description": "HTTP request configuration",
        "properties": {
          "url": {"type": "string"},
          "method": {"type": "string"}
        }
      },
      "auth_config": {
        "type": "object",
        "description": "Authentication configuration", 
        "properties": {
          "type": {"type": "string"},
          "credentials": {"type": "object"}
        }
      }
    }
  }
}
```

## Next Steps

- Learn about [Schema Components](../components/schema-components.md) for output schemas
- Explore [Performance](performance.md) optimization for tool processing
- Check [Integration Examples](../integration/rails.md) for real-world tool usage
