require "minitest/autorun"
require "poml"

class TutorialSchemaComponentsTest < Minitest::Test
  # Tests for docs/tutorial/components/schema-components.md examples
  
  def test_output_schema_basic
    # From "Output Schema Component - Basic Usage" section
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
    
    assert_kind_of Hash, result
    assert result.key?('metadata')
    assert result['metadata'].key?('schemas')
    
    schemas = result['metadata']['schemas']
    assert_kind_of Array, schemas
    assert_equal 1, schemas.length
    
    schema = schemas[0]
    assert_equal 'AnalysisResult', schema['name']
    assert schema['schema'].key?('type')
    assert_equal 'object', schema['schema']['type']
    assert schema['schema'].key?('properties')
    assert schema['schema']['properties'].key?('insights')
    assert schema['schema']['properties'].key?('confidence')
    assert schema['schema']['properties'].key?('recommendations')
  end

  def test_parser_attribute_support
    # From "Parser Attribute Support" section - new syntax
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

    result = Poml.process(markup: markup)
    
    schemas = result['metadata']['schemas']
    assert_equal 1, schemas.length
    
    schema = schemas[0]
    assert_equal 'CodeReview', schema['name']
    assert schema['schema']['properties'].key?('issues')
    assert schema['schema']['properties'].key?('overall_score')
    
    # Check nested structure
    issues_items = schema['schema']['properties']['issues']['items']
    assert issues_items['properties'].key?('severity')
    assert_equal ['low', 'medium', 'high'], issues_items['properties']['severity']['enum']
  end

  def test_legacy_lang_attribute_support
    # From "Parser Attribute Support" section - legacy syntax
    markup = <<~POML
      <poml>
        <role>Code Reviewer</role>
        <task>Review code and provide feedback</task>
        
        <output-schema name="CodeReview" lang="json">
        {
          "type": "object",
          "properties": {
            "status": {"type": "string"},
            "score": {"type": "number"}
          }
        }
        </output-schema>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    schemas = result['metadata']['schemas']
    assert_equal 1, schemas.length
    
    schema = schemas[0]
    assert_equal 'CodeReview', schema['name']
    assert schema['schema']['properties'].key?('status')
    assert schema['schema']['properties'].key?('score')
  end

  def test_tool_definition_basic
    # From "Tool Definition Component - Basic Usage" section
    markup = <<~POML
      <poml>
        <role>Research Assistant</role>
        <task>Help with research and information gathering</task>
        
        <tool-definition name="search_papers">
        {
          "description": "Search academic papers by keyword and year",
          "parameters": {
            "type": "object",
            "properties": {
              "keywords": {
                "type": "string",
                "description": "Keywords to search for"
              },
              "year_from": {
                "type": "integer",
                "description": "Start year for search"
              },
              "year_to": {
                "type": "integer", 
                "description": "End year for search"
              },
              "max_results": {
                "type": "integer",
                "default": 10,
                "description": "Maximum number of results"
              }
            },
            "required": ["keywords"]
          }
        }
        </tool-definition>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    assert result.key?('tools')
    tools = result['tools']
    assert_kind_of Array, tools
    assert_equal 1, tools.length
    
    tool = tools[0]
    assert_equal 'search_papers', tool['name']
    assert tool.key?('description')
    assert_equal 'Search academic papers by keyword and year', tool['description']
    
    params = tool['parameters']
    assert_equal 'object', params['type']
    assert params['properties'].key?('keywords')
    assert params['properties'].key?('year_from')
    assert params['properties'].key?('max_results')
    assert_equal ['keywords'], params['required']
  end

  def test_multiple_tools_definition
    # From "Multiple Tools" section
    markup = <<~POML
      <poml>
        <role>Data Analysis Assistant</role>
        <task>Analyze data and generate reports</task>
        
        <tool-definition name="fetch_data">
        {
          "description": "Fetch data from database",
          "parameters": {
            "type": "object",
            "properties": {
              "query": {"type": "string"},
              "limit": {"type": "integer", "default": 100}
            },
            "required": ["query"]
          }
        }
        </tool-definition>
        
        <tool-definition name="generate_chart">
        {
          "description": "Generate visualization chart",
          "parameters": {
            "type": "object",
            "properties": {
              "chart_type": {"type": "string", "enum": ["bar", "line", "pie"]},
              "data": {"type": "array"},
              "title": {"type": "string"}
            },
            "required": ["chart_type", "data"]
          }
        }
        </tool-definition>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    tools = result['tools']
    assert_equal 2, tools.length
    
    # First tool
    fetch_tool = tools.find { |t| t['name'] == 'fetch_data' }
    assert fetch_tool
    assert_equal 'Fetch data from database', fetch_tool['description']
    
    # Second tool
    chart_tool = tools.find { |t| t['name'] == 'generate_chart' }
    assert chart_tool
    assert_equal 'Generate visualization chart', chart_tool['description']
    assert_equal ['bar', 'line', 'pie'], chart_tool['parameters']['properties']['chart_type']['enum']
  end

  def test_schema_with_template_variables
    # From "Template Variables in Schemas" section
    markup = <<~POML
      <poml>
        <role>{{analysis_type}} Analyst</role>
        <task>Perform {{analysis_type}} analysis</task>
        
        <output-schema name="{{schema_name}}">
        {
          "type": "object",
          "properties": {
            "analysis_type": {"type": "string", "default": "{{analysis_type}}"},
            "results": {"type": "array"},
            "confidence": {"type": "number"}
          }
        }
        </output-schema>
      </poml>
    POML

    context = {
      'analysis_type' => 'Financial',
      'schema_name' => 'FinancialAnalysis'
    }

    result = Poml.process(markup: markup, context: context)
    
    # Check content has variables replaced
    assert result['content'].include?('Financial Analyst')
    assert result['content'].include?('Financial analysis')
    
    # Check schema metadata
    schemas = result['metadata']['schemas']
    assert_equal 1, schemas.length
    
    schema = schemas[0]
    assert_equal 'FinancialAnalysis', schema['name']
    assert_equal 'Financial', schema['schema']['properties']['analysis_type']['default']
  end

  def test_backward_compatibility_meta_tags
    # From "Backward Compatibility" section - legacy meta tags
    markup = <<~POML
      <poml>
        <role>Legacy Test</role>
        <task>Test backward compatibility</task>
        
        <meta type="output-schema" lang="json">
        {
          "name": "LegacySchema",
          "schema": {
            "type": "object",
            "properties": {
              "result": {"type": "string"}
            }
          }
        }
        </meta>
        
        <meta type="tool-definition" lang="json">
        {
          "name": "legacy_tool",
          "description": "Legacy tool definition",
          "parameters": {
            "type": "object",
            "properties": {
              "input": {"type": "string"}
            }
          }
        }
        </meta>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    # Should have both schemas and tools from legacy format
    assert result['metadata'].key?('schemas')
    assert result.key?('tools')
    
    schemas = result['metadata']['schemas']
    tools = result['tools']
    
    assert_equal 1, schemas.length
    assert_equal 1, tools.length
    
    assert_equal 'LegacySchema', schemas[0]['name']
    assert_equal 'legacy_tool', tools[0]['name']
  end

  def test_openai_format_with_schemas
    # From "OpenAI Integration" section
    markup = <<~POML
      <poml>
        <system>You are a helpful assistant.</system>
        <human>Analyze this data for me.</human>
        
        <output-schema name="DataAnalysis">
        {
          "type": "object",
          "properties": {
            "summary": {"type": "string"},
            "insights": {"type": "array", "items": {"type": "string"}}
          }
        }
        </output-schema>
        
        <tool-definition name="create_chart">
        {
          "description": "Create a data visualization",
          "parameters": {
            "type": "object",
            "properties": {
              "data": {"type": "array"},
              "chart_type": {"type": "string"}
            }
          }
        }
        </tool-definition>
      </poml>
    POML

    # Test openai_chat format
    chat_result = Poml.process(markup: markup, format: 'openai_chat')
    assert_kind_of Array, chat_result
    assert_equal 2, chat_result.length
    assert_equal 'system', chat_result[0]['role']
    assert_equal 'user', chat_result[1]['role']

    # Test openaiResponse format (includes tools/schemas)
    response_result = Poml.process(markup: markup, format: 'openaiResponse')
    assert_kind_of Hash, response_result
    assert response_result.key?('messages')
    assert response_result.key?('metadata')
    
    # Should include schema and tool information
    metadata = response_result['metadata']
    assert metadata.key?('schemas')
    assert metadata.key?('tools')
  end

  def test_complex_nested_schema
    # From "Complex Examples" section
    markup = <<~POML
      <poml>
        <role>Project Manager</role>
        <task>Generate project report</task>
        
        <output-schema name="ProjectReport">
        {
          "type": "object",
          "properties": {
            "project": {
              "type": "object",
              "properties": {
                "name": {"type": "string"},
                "status": {"type": "string", "enum": ["active", "completed", "on-hold"]},
                "team_members": {
                  "type": "array",
                  "items": {
                    "type": "object",
                    "properties": {
                      "name": {"type": "string"},
                      "role": {"type": "string"},
                      "hours_logged": {"type": "number"}
                    },
                    "required": ["name", "role"]
                  }
                }
              },
              "required": ["name", "status"]
            },
            "milestones": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "title": {"type": "string"},
                  "due_date": {"type": "string", "format": "date"},
                  "completed": {"type": "boolean"}
                }
              }
            }
          },
          "required": ["project"]
        }
        </output-schema>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    schemas = result['metadata']['schemas']
    schema = schemas[0]
    
    # Verify complex nested structure
    project_props = schema['schema']['properties']['project']['properties']
    assert project_props.key?('name')
    assert project_props.key?('status')
    assert project_props.key?('team_members')
    
    # Verify nested array with object items
    team_member_props = project_props['team_members']['items']['properties']
    assert team_member_props.key?('name')
    assert team_member_props.key?('role')
    assert team_member_props.key?('hours_logged')
    
    # Verify milestones array
    milestone_props = schema['schema']['properties']['milestones']['items']['properties']
    assert milestone_props.key?('title')
    assert milestone_props.key?('due_date')
    assert milestone_props.key?('completed')
  end

  def test_error_handling_invalid_schema
    # Test graceful handling of invalid JSON in schemas
    markup = <<~POML
      <poml>
        <role>Test Role</role>
        <task>Test invalid schema</task>
        
        <output-schema name="InvalidSchema">
        {
          "type": "object",
          "properties": {
            "test": {"type": "string"}
          }
          // This comma makes it invalid JSON
        }
        </output-schema>
      </poml>
    POML

    # Should not raise an error, but handle gracefully
    result = Poml.process(markup: markup)
    
    # Should still process the main content
    assert result['content'].include?('Test Role')
    assert result['content'].include?('Test invalid schema')
    
    # Schema may be omitted or marked as invalid
    schemas = result['metadata']['schemas'] || []
    # Implementation may vary on how it handles invalid schemas
  end
end
