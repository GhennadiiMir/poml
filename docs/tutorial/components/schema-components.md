# Schema Components

POML provides powerful schema components for defining structured AI responses and tool definitions that work across different AI platforms.

## Overview

Schema components allow you to define:

- **Output Schemas** - Structure for AI responses
- **Tool Definitions** - AI function calling capabilities
- **Metadata Integration** - Automatic inclusion in response metadata

## Output Schema Component

The `<output-schema>` component defines the expected structure of AI responses:

### Basic Usage

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>Data Analyst</role>
    <task>Analyze the provided dataset and generate insights</task>
    
    <output-schema name="AnalysisResult">
    {
      "type": "object",
      "properties": {
        "insights": {
          "type": "array",
          "items": {"type": "string"},
          "description": "Key insights from the data"
        },
        "confidence": {
          "type": "number",
          "minimum": 0,
          "maximum": 1,
          "description": "Confidence level of the analysis"
        },
        "recommendations": {
          "type": "array",
          "items": {"type": "string"},
          "description": "Actionable recommendations"
        }
      },
      "required": ["insights", "confidence"]
    }
    </output-schema>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['metadata']['schemas']
```

### Parser Attribute Support

POML supports both legacy `lang` and new `parser` attributes:

```ruby
# New syntax (recommended)
markup = <<~POML
  <poml>
    <role>Code Reviewer</role>
    <task>Review code and provide feedback</task>
    
    <output-schema name="CodeReview" parser="json">
    {
      "type": "object",
      "properties": {
        "issues": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "severity": {"type": "string", "enum": ["low", "medium", "high"]},
              "description": {"type": "string"},
              "line_number": {"type": "integer"}
            }
          }
        },
        "overall_score": {
          "type": "integer",
          "minimum": 1,
          "maximum": 10
        }
      }
    }
    </output-schema>
  </poml>
POML

# Legacy syntax (still supported)
markup_legacy = <<~POML
  <poml>
    <output-schema name="CodeReview" lang="json">
    <!-- Same JSON schema -->
    </output-schema>
  </poml>
POML
```

### Eval Parser for Dynamic Schemas

Use `parser="eval"` for dynamic schema generation:

```ruby
markup = <<~POML
  <poml>
    <role>Survey Analyst</role>
    <task>Create survey response schema</task>
    
    <output-schema name="SurveyResponse" parser="eval">
    {
      "type": "object",
      "properties": {
        {{#questions}}
        "{{id}}": {
          "type": "{{type}}",
          "description": "{{description}}"
        }{{#unless @last}},{{/unless}}
        {{/questions}}
      }
    }
    </output-schema>
  </poml>
POML

context = {
  'questions' => [
    { 'id' => 'satisfaction', 'type' => 'integer', 'description' => 'Satisfaction rating 1-10' },
    { 'id' => 'feedback', 'type' => 'string', 'description' => 'Written feedback' },
    { 'id' => 'recommend', 'type' => 'boolean', 'description' => 'Would recommend?' }
  ]
}

result = Poml.process(markup: markup, context: context)
```

## Tool Definition Component

The `<tool-definition>` component defines AI tools and functions:

### Basic Tool Definition

```ruby
markup = <<~POML
  <poml>
    <role>Database Assistant</role>
    <task>Help with database queries and analysis</task>
    
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
            "description": "Database name",
            "enum": ["users", "products", "orders"]
          },
          "limit": {
            "type": "integer",
            "description": "Maximum number of rows to return",
            "default": 100,
            "maximum": 1000
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

### Multiple Tool Definitions

```ruby
markup = <<~POML
  <poml>
    <role>Data Science Assistant</role>
    <task>Perform data analysis and visualization</task>
    
    <tool-definition name="load_dataset">
    {
      "description": "Load a dataset from file or URL",
      "parameters": {
        "type": "object",
        "properties": {
          "source": {"type": "string", "description": "File path or URL"},
          "format": {"type": "string", "enum": ["csv", "json", "excel"]},
          "encoding": {"type": "string", "default": "utf-8"}
        },
        "required": ["source", "format"]
      }
    }
    </tool-definition>
    
    <tool-definition name="create_visualization">
    {
      "description": "Create a data visualization chart",
      "parameters": {
        "type": "object",
        "properties": {
          "chart_type": {
            "type": "string",
            "enum": ["bar", "line", "scatter", "histogram", "pie"]
          },
          "x_column": {"type": "string"},
          "y_column": {"type": "string"},
          "title": {"type": "string"},
          "color_scheme": {"type": "string", "default": "viridis"}
        },
        "required": ["chart_type", "x_column"]
      }
    }
    </tool-definition>
  </poml>
POML

result = Poml.process(markup: markup)
```

### Enhanced Tool Registration

POML supports enhanced tool registration with parameter conversion:

```ruby
markup = <<~POML
  <poml>
    <role>API Integration Assistant</role>
    <task>Help with API calls and data processing</task>
    
    <tool-definition name="api-request" parser="json">
    {
      "description": "Make HTTP API request",
      "parameters": {
        "type": "object",
        "properties": {
          "http-method": {"type": "string", "enum": ["GET", "POST", "PUT", "DELETE"]},
          "endpoint-url": {"type": "string", "format": "uri"},
          "request-headers": {"type": "object"},
          "request-body": {"type": "object"},
          "timeout-seconds": {"type": "integer", "default": 30},
          "retry-attempts": {"type": "integer", "default": 3},
          "follow-redirects": {"type": "boolean", "default": true}
        },
        "required": ["http-method", "endpoint-url"]
      }
    }
    </tool-definition>
  </poml>
POML

result = Poml.process(markup: markup)

# The enhanced tool registration will convert:
# "http-method" -> "httpMethod"
# "endpoint-url" -> "endpointUrl" 
# "request-headers" -> "requestHeaders"
# "request-body" -> "requestBody"
# "timeout-seconds" -> "timeoutSeconds"
# "retry-attempts" -> "retryAttempts"
# "follow-redirects" -> "followRedirects"
```

## Legacy Meta Components

POML maintains backward compatibility with meta-based schema definitions:

### Meta Output Schema

```ruby
markup = <<~POML
  <poml>
    <role>Report Generator</role>
    <task>Generate performance report</task>
    
    <meta type="output-schema" name="PerformanceReport">
    {
      "type": "object",
      "properties": {
        "metrics": {
          "type": "object",
          "properties": {
            "response_time": {"type": "number"},
            "throughput": {"type": "number"},
            "error_rate": {"type": "number"}
          }
        },
        "summary": {"type": "string"},
        "recommendations": {
          "type": "array",
          "items": {"type": "string"}
        }
      }
    }
    </meta>
  </poml>
POML

result = Poml.process(markup: markup)
```

### Meta Tool Definition

```ruby
markup = <<~POML
  <poml>
    <role>File Manager</role>
    <task>Manage files and directories</task>
    
    <meta type="tool-definition" name="file_operations">
    {
      "description": "Perform file system operations",
      "parameters": {
        "type": "object",
        "properties": {
          "operation": {
            "type": "string",
            "enum": ["read", "write", "delete", "list", "move"]
          },
          "path": {"type": "string"},
          "content": {"type": "string"},
          "recursive": {"type": "boolean", "default": false}
        },
        "required": ["operation", "path"]
      }
    }
    </meta>
  </poml>
POML
```

## Template Variables in Schemas

Use template variables to create dynamic schemas:

```ruby
markup = <<~POML
  <poml>
    <role>{{domain}} Expert</role>
    <task>Analyze {{entity_type}} data</task>
    
    <output-schema name="{{schema_name}}">
    {
      "type": "object",
      "properties": {
        "{{primary_metric}}": {
          "type": "number",
          "description": "Primary {{domain}} metric"
        },
        "categories": {
          "type": "array",
          "items": {
            "type": "string",
            "enum": [{{#categories}}"{{.}}"{{#unless @last}},{{/unless}}{{/categories}}]
          }
        },
        "confidence": {
          "type": "number",
          "minimum": 0,
          "maximum": 1
        }
      },
      "required": ["{{primary_metric}}", "confidence"]
    }
    </output-schema>
  </poml>
POML

context = {
  'domain' => 'Marketing',
  'entity_type' => 'campaign',
  'schema_name' => 'CampaignAnalysis',
  'primary_metric' => 'conversion_rate',
  'categories' => ['email', 'social', 'paid', 'organic']
}

result = Poml.process(markup: markup, context: context)
```

## Complex Schema Patterns

### Nested Object Schemas

```ruby
markup = <<~POML
  <poml>
    <role>E-commerce Analyst</role>
    <task>Analyze order data and customer behavior</task>
    
    <output-schema name="OrderAnalysis">
    {
      "type": "object",
      "properties": {
        "order_summary": {
          "type": "object",
          "properties": {
            "total_orders": {"type": "integer"},
            "total_revenue": {"type": "number"},
            "average_order_value": {"type": "number"},
            "top_products": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "product_id": {"type": "string"},
                  "name": {"type": "string"},
                  "sales_count": {"type": "integer"},
                  "revenue": {"type": "number"}
                }
              }
            }
          }
        },
        "customer_insights": {
          "type": "object",
          "properties": {
            "new_customers": {"type": "integer"},
            "returning_customers": {"type": "integer"},
            "customer_segments": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "segment_name": {"type": "string"},
                  "customer_count": {"type": "integer"},
                  "avg_order_value": {"type": "number"}
                }
              }
            }
          }
        },
        "recommendations": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "category": {"type": "string"},
              "priority": {"type": "string", "enum": ["low", "medium", "high"]},
              "action": {"type": "string"},
              "expected_impact": {"type": "string"}
            }
          }
        }
      },
      "required": ["order_summary", "customer_insights", "recommendations"]
    }
    </output-schema>
  </poml>
POML
```

### Conditional Schemas

```ruby
markup = <<~POML
  <poml>
    <role>{{analysis_type}} Specialist</role>
    <task>Perform {{analysis_type}} analysis</task>
    
    <if condition="{{analysis_type}} == 'financial'">
      <output-schema name="FinancialAnalysis">
      {
        "type": "object",
        "properties": {
          "revenue_metrics": {"type": "object"},
          "cost_analysis": {"type": "object"},
          "profitability": {"type": "number"},
          "cash_flow": {"type": "array"}
        }
      }
      </output-schema>
    </if>
    
    <if condition="{{analysis_type}} == 'technical'">
      <output-schema name="TechnicalAnalysis">
      {
        "type": "object",
        "properties": {
          "performance_metrics": {"type": "object"},
          "security_assessment": {"type": "object"},
          "scalability_score": {"type": "number"},
          "recommendations": {"type": "array"}
        }
      }
      </output-schema>
    </if>
  </poml>
POML
```

## Integration with Output Formats

### OpenAI Response Format

```ruby
markup = <<~POML
  <poml>
    <role>Research Assistant</role>
    <task>Summarize research findings</task>
    
    <output-schema name="ResearchSummary">
    {
      "type": "object",
      "properties": {
        "key_findings": {"type": "array", "items": {"type": "string"}},
        "methodology": {"type": "string"},
        "confidence_level": {"type": "number"}
      }
    }
    </output-schema>
  </poml>
POML

result = Poml.process(markup: markup, format: 'openaiResponse')

puts result['content']    # The prompt
puts result['metadata']['schemas']  # Schema definitions
```

### Pydantic Format

```ruby
result = Poml.process(markup: markup, format: 'pydantic')

puts result['schemas']    # Strict JSON schemas for Python
puts result['metadata']['python_compatibility']  # Python-specific info
```

## Validation and Error Handling

### Schema Validation

```ruby
def validate_schema_format(markup)
  result = Poml.process(markup: markup)
  schemas = result['metadata']['schemas']
  
  schemas.each do |schema|
    # Validate JSON schema format
    begin
      JSON.parse(schema['content']) if schema['content'].is_a?(String)
      puts "✅ Schema '#{schema['name']}' is valid"
    rescue JSON::ParserError => e
      puts "❌ Schema '#{schema['name']}' has invalid JSON: #{e.message}"
    end
  end
end
```

### Tool Definition Validation

```ruby
def validate_tool_definitions(markup)
  result = Poml.process(markup: markup)
  tools = result['tools']  # Tools are now at top level
  
  tools.each do |tool|
    required_fields = ['description', 'parameters']
    missing_fields = required_fields - tool.keys
    
    if missing_fields.empty?
      puts "✅ Tool '#{tool['name']}' is complete"
    else
      puts "❌ Tool '#{tool['name']}' missing: #{missing_fields.join(', ')}"
    end
  end
end
```

## Best Practices

### 1. Use Descriptive Schema Names

```ruby
# Good
<output-schema name="UserProfileAnalysis">

# Better
<output-schema name="UserBehaviorAnalysisResult">
```

### 2. Include Comprehensive Descriptions

```ruby
{
  "type": "object",
  "properties": {
    "sentiment_score": {
      "type": "number",
      "minimum": -1,
      "maximum": 1,
      "description": "Sentiment analysis score where -1 is very negative, 0 is neutral, and 1 is very positive"
    }
  }
}
```

### 3. Use Validation Constraints

```ruby
{
  "type": "object",
  "properties": {
    "email": {
      "type": "string",
      "format": "email",
      "description": "Valid email address"
    },
    "age": {
      "type": "integer",
      "minimum": 0,
      "maximum": 150,
      "description": "Age in years"
    },
    "priority": {
      "type": "string",
      "enum": ["low", "medium", "high", "critical"],
      "description": "Priority level"
    }
  }
}
```

### 4. Organize Complex Schemas

```ruby
# Break complex schemas into logical sections
{
  "type": "object",
  "properties": {
    "user_data": {
      "type": "object",
      "description": "User profile information",
      "properties": { /* user fields */ }
    },
    "analytics": {
      "type": "object", 
      "description": "Analytics and metrics",
      "properties": { /* analytics fields */ }
    },
    "metadata": {
      "type": "object",
      "description": "Processing metadata",
      "properties": { /* metadata fields */ }
    }
  }
}
```

## Next Steps

- Learn about [Tool Registration](../advanced/tool-registration.md) for enhanced tool features
- Explore [Output Formats](../output-formats.md) for schema integration
- Check [Integration Examples](../integration/rails.md) for real-world usage
