require_relative 'test_helper'

class TestOutputFormatsAndIntegration < Minitest::Test
  include TestHelper

  def test_comprehensive_openai_chat_format
    # Test comprehensive OpenAI chat format with various message types
    markup = <<~POML
      <poml>
        <system>You are an expert software architect with 10+ years of experience.</system>
        
        <human>I need help designing a microservices architecture.</human>
        
        <ai>Based on your requirements, I recommend the following architecture.</ai>
        
        <human>What about monitoring and logging?</human>
        
        <ai>Implement comprehensive observability.</ai>
      </poml>
    POML

    result = Poml.process(markup: markup, format: 'openai_chat')
    
    # Validate structure
    assert_kind_of Array, result
    assert_equal 5, result.length
    
    # Test system message
    system_msg = result[0]
    assert_equal 'system', system_msg['role']
    assert_includes system_msg['content'], 'expert software architect'
    
    # Test messages
    assert_equal 'user', result[1]['role']
    assert_includes result[1]['content'], 'microservices architecture'
    
    assert_equal 'assistant', result[2]['role']
    assert_includes result[2]['content'], 'recommend the following'
    
    assert_equal 'user', result[3]['role']
    assert_includes result[3]['content'], 'monitoring and logging'
    
    assert_equal 'assistant', result[4]['role']
    assert_includes result[4]['content'], 'comprehensive observability'
  end

  def test_dict_format_with_complex_content
    # Test dict format with complex nested content
    markup = <<~POML
      <poml>
        <role>Content Strategist</role>
        <task>Create comprehensive content strategy</task>
        
        <h1>Q4 Content Strategy</h1>
        
        <h2>Objectives</h2>
        <numbered-list>
          <item>Increase brand awareness by <b>25%</b></item>
          <item>Generate <i>500 qualified leads</i></item>
          <item>Improve engagement rates to <code>5%+</code></item>
        </numbered-list>
        
        <h2>Content Calendar</h2>
        <table>
          <thead>
            <tr>
              <th>Month</th>
              <th>Theme</th>
              <th>Content Types</th>
              <th>Target</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>October</td>
              <td>Product Launch</td>
              <td>Blog posts, Videos, Webinars</td>
              <td>Prospects</td>
            </tr>
            <tr>
              <td>November</td>
              <td>Customer Success</td>
              <td>Case studies, Testimonials</td>
              <td>Existing customers</td>
            </tr>
          </tbody>
        </table>
        
        <callout type="success">
          <p><b>Key Insight:</b> Focus on <i>quality over quantity</i> for better ROI.</p>
        </callout>
        
        <output format="json">
        {
          "strategy_id": "q4-2024-content",
          "budget": 75000,
          "channels": ["blog", "social", "email", "webinars"],
          "kpis": {
            "awareness": 25,
            "leads": 500,
            "engagement": 5.0
          }
        }
        </output>
      </poml>
    POML

    result = Poml.process(markup: markup, format: 'dict')
    
    # Test dict structure
    assert_kind_of Hash, result
    assert_includes result.keys, 'content'
    assert_includes result.keys, 'metadata'
    
    # Test that role and task are included in the content
    content = result['content']
    assert_includes content, 'Content Strategist'
    assert_includes content, 'Create comprehensive content strategy'
    
    # Test content structure (markdown format)
    content = result['content']
    assert_includes content, '# Q4 Content Strategy'
    assert_includes content, '**25%**'
    assert_includes content, '*500 qualified leads*'
    assert_includes content, '`5%+`'
    assert_includes content, '| Month | Theme |'
    assert_includes content, '✅'
    
    # Test output JSON
    assert_kind_of String, result['output']
    output_json = JSON.parse(result['output'])
    assert_equal 'q4-2024-content', output_json['strategy_id']
    assert_equal 75000, output_json['budget']
    assert_equal 25, output_json['kpis']['awareness']
  end

  def test_integration_with_all_component_types
    # Integration test using all major component types
    markup = <<~POML
      <poml>
        <role>Integration Tester</role>
        <task>Test all component types together</task>
        
        <h1>Comprehensive Integration Test</h1>
        
        <h2>Text Formatting</h2>
        <p>This paragraph includes <b>bold</b>, <i>italic</i>, <u>underline</u>, 
        and <code>inline code</code> formatting elements.</p>
        
        <h2>Lists</h2>
        <h3>Bullet List</h3>
        <list>
          <item>First bullet point</item>
          <item>Second with <b>bold text</b></item>
          <item>Third with <code>code snippet</code></item>
        </list>
        
        <h3>Numbered List</h3>
        <numbered-list>
          <item>First numbered item</item>
          <item>Second numbered item</item>
          <item>Third numbered item</item>
        </numbered-list>
        
        <h2>Code Blocks</h2>
        <code-block language="python">
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# Example usage
print(fibonacci(10))  # Output: 55
        </code-block>
        
        <h2>Tables</h2>
        <table>
          <thead>
            <tr>
              <th>Feature</th>
              <th>Status</th>
              <th>Priority</th>
              <th>Notes</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><b>Text Formatting</b></td>
              <td>✅ Complete</td>
              <td>High</td>
              <td>All basic formatting supported</td>
            </tr>
            <tr>
              <td><i>Lists</i></td>
              <td>✅ Complete</td>
              <td>High</td>
              <td>Both bullet and numbered</td>
            </tr>
            <tr>
              <td><code>Code Blocks</code></td>
              <td>✅ Complete</td>
              <td>Medium</td>
              <td>Syntax highlighting available</td>
            </tr>
          </tbody>
        </table>
        
        <h2>Callouts</h2>
        <callout type="info">
          <p><b>Information:</b> This is an informational callout.</p>
        </callout>
        
        <callout type="warning">
          <p><b>Warning:</b> This is a warning callout with <i>emphasis</i>.</p>
        </callout>
        
        <callout type="success">
          <p><b>Success:</b> All components are working correctly!</p>
        </callout>
        
        <h2>Template Variables</h2>
        <p>Current user: {{user.name}}</p>
        <p>Test environment: {{environment}}</p>
        <p>Timestamp: {{timestamp}}</p>
      </poml>
    POML

    context = {
      'user' => { 'name' => 'Integration Tester' },
      'environment' => 'test',
      'timestamp' => '2024-01-15T10:30:00Z'
    }

    result = Poml.process(markup: markup, context: context, format: 'raw')
    
    # Test all component types are present and formatted correctly (markdown format)
    
    # Headers
    assert_includes result, '# Comprehensive Integration Test'
    assert_includes result, '## Text Formatting'
    assert_includes result, '### Bullet List'
    
    # Text formatting
    assert_includes result, '**bold**'
    assert_includes result, '*italic*'
    assert_includes result, '__underline__'
    assert_includes result, '`inline code`'
    
    # Lists
    assert_includes result, '- First bullet point'
    assert_includes result, 'Second with **bold text**'
    assert_includes result, '1. First numbered item'
    
    # Code blocks
    assert_includes result, '```python'
    assert_includes result, 'def fibonacci(n):'
    assert_includes result, 'print(fibonacci(10))'
    
    # Tables (markdown format)
    assert_includes result, '| Feature | Status |'
    assert_includes result, '**Text Formatting**'
    assert_includes result, '✅ Complete'
    
    # Callouts (markdown format with emojis)
    assert_includes result, 'ℹ️'
    assert_includes result, '⚠️'
    assert_includes result, '✅'
    
    # Template variables
    assert_includes result, 'Current user: Integration Tester'
    assert_includes result, 'Test environment: test'
    assert_includes result, 'Timestamp: 2024-01-15T10:30:00Z'
  end

  def test_complex_template_integration_with_loops_and_conditionals
    # Test complex template scenarios - simplified to work with current system
    markup = <<~POML
      <poml>
        <role>{{expert.role}}</role>
        <task>{{task.description}}</task>
        
        <h1>{{project.name}} - Status Report</h1>
        
        <if condition="{{features.length}} > 0">
          <h2>Feature Development Status</h2>
          
          <for variable="feature" items="{{features}}">
            <h3>{{feature.name}}</h3>
            <p><b>Status:</b> 
              <if condition="{{feature.status}} == 'complete'">
                ✅ Complete
              </if>
              <if condition="{{feature.status}} == 'in_progress'">
                🚧 In Progress
              </if>
              <if condition="{{feature.status}} == 'pending'">
                ⏳ Pending
              </if>
            </p>
            <p><b>Progress:</b> {{feature.progress}}%</p>
            <p><b>Developer:</b> {{feature.developer}}</p>
          </for>
        </if>
        
        <if condition="{{features.length}} == 0">
          <p>No features currently in development.</p>
        </if>
        
        <h2>Summary</h2>
        <p>Project: <b>{{project.name}}</b></p>
        <p>Total features: {{features.length}}</p>
        <p>Report generated by: {{expert.name}}</p>
      </poml>
    POML

    context = {
      'expert' => {
        'role' => 'Senior Developer',
        'name' => 'Alice Johnson'
      },
      'task' => {
        'description' => 'Generate weekly development report'
      },
      'project' => {
        'name' => 'POML Framework'
      },
      'features' => [
        {
          'name' => 'Template Engine',
          'status' => 'complete',
          'progress' => 100,
          'developer' => 'Alice'
        },
        {
          'name' => 'Component System',
          'status' => 'in_progress',
          'progress' => 75,
          'developer' => 'Bob'
        },
        {
          'name' => 'Error Handling',
          'status' => 'pending',
          'progress' => 0,
          'developer' => 'Charlie'
        }
      ]
    }

    result = Poml.process(markup: markup, context: context)
    content = result['content']

    # Test template variable substitution
    assert_includes content, 'Senior Developer'
    assert_includes content, 'Generate weekly development report'
    assert_includes content, '# POML Framework - Status Report'
    
    # Test conditional display of features section (markdown format)
    assert_includes content, '## Feature Development Status'
    
    # Test loop with conditional status display (markdown format)
    assert_includes content, '### Template Engine'
    assert_includes content, '✅ Complete'
    assert_includes content, '100%'
    assert_includes content, 'Alice'
    
    assert_includes content, '### Component System'
    assert_includes content, '🚧 In Progress'
    assert_includes content, '75%'
    assert_includes content, 'Bob'
    
    assert_includes content, '### Error Handling'
    assert_includes content, '⏳ Pending'
    assert_includes content, '0%'
    assert_includes content, 'Charlie'
    
    # Test summary section (markdown format)
    assert_includes content, 'Project: **POML Framework**'
    assert_includes content, 'Total features: 3'
    assert_includes content, 'Report generated by: Alice Johnson'
    
    # Ensure "no features" message is not present
    refute_includes content, 'No features currently in development'
  end
end
