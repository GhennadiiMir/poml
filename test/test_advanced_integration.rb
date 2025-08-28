require_relative 'test_helper'

class TestAdvancedIntegration < Minitest::Test
  include TestHelper

  def test_complex_api_documentation_with_all_components
    # Complex test case from debug_complex_test.rb - comprehensive API documentation
    markup = <<~POML
      <poml>
        <role>Technical Documentation Lead</role>
        <task>Create comprehensive API documentation</task>
        
        <h1>User Management API</h1>
        
        <h2>Overview</h2>
        <p>This API provides endpoints for <b>user management</b> operations including 
        <i>authentication</i>, <i>profile management</i>, and <i>access control</i>.</p>
        
        <callout type="info">
          <b>Base URL:</b> <code>https://api.example.com/v1</code>
        </callout>
        
        <h2>Authentication</h2>
        <p>All requests require a valid JWT token in the Authorization header:</p>
        
        <code-block language="http">
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
        </code-block>
        
        <h2>Endpoints</h2>
        
        <h3>GET /users</h3>
        <p>Retrieve a list of users with optional filtering.</p>
        
        <h4>Query Parameters</h4>
        <table>
          <thead>
            <tr>
              <th>Parameter</th>
              <th>Type</th>
              <th>Required</th>
              <th>Description</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><code>page</code></td>
              <td>integer</td>
              <td>No</td>
              <td>Page number (default: 1)</td>
            </tr>
            <tr>
              <td><code>limit</code></td>
              <td>integer</td>
              <td>No</td>
              <td>Results per page (default: 10, max: 100)</td>
            </tr>
            <tr>
              <td><code>status</code></td>
              <td>string</td>
              <td>No</td>
              <td>Filter by user status: <code>active</code>, <code>inactive</code></td>
            </tr>
          </tbody>
        </table>
        
        <h4>Example Request</h4>
        <code-block language="bash">
curl -H "Authorization: Bearer TOKEN" \\
  "https://api.example.com/v1/users?page=1&limit=10&status=active"
        </code-block>
        
        <h4>Example Response</h4>
        <code-block language="json">
{
  "users": [
    {
      "id": 123,
      "username": "alice",
      "email": "alice@example.com",
      "status": "active",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "total_pages": 1
  }
}
        </code-block>
        
        <callout type="warning">
          <b>Rate Limiting:</b> This endpoint is limited to <code>100 requests per minute</code> 
          per authenticated user. Exceeding this limit will result in a <code>429 Too Many Requests</code> response.
        </callout>
        
        <h2>Error Handling</h2>
        <p>The API uses standard HTTP status codes and returns error details in JSON format:</p>
        
        <numbered-list>
          <item><code>400 Bad Request</code> - Invalid request parameters</item>
          <item><code>401 Unauthorized</code> - Missing or invalid authentication</item>
          <item><code>403 Forbidden</code> - Insufficient permissions</item>
          <item><code>404 Not Found</code> - Resource not found</item>
          <item><code>429 Too Many Requests</code> - Rate limit exceeded</item>
          <item><code>500 Internal Server Error</code> - Server error</item>
        </numbered-list>
      </poml>
    POML

    result = Poml.process(markup: markup, format: 'raw')
    content = result

    # Test role and task
    assert_includes content, 'Technical Documentation Lead'
    assert_includes content, 'Create comprehensive API documentation'
    
    # Test headers (markdown format)
    assert_includes content, '# User Management API'
    assert_includes content, '## Overview'
    
    # Test formatting elements (markdown format)
    assert_includes content, '**user management**'
    assert_includes content, '*authentication*'
    assert_includes content, '`https://api.example.com/v1`'
    
    # Test callouts (should appear with emoji)
    assert_includes content, 'ℹ️'
    assert_includes content, '⚠️'
    
    # Test code blocks appear correctly
    assert_includes content, '```http'
    assert_includes content, '```bash'
    assert_includes content, '```json'
    assert_includes content, 'Authorization: Bearer'
    
    # Test table structure (markdown format)
    assert_includes content, '| Parameter | Type |'
    assert_includes content, '| --- |'
    assert_includes content, '| `page` | integer |'
    
    # Test numbered list appears
    assert_includes content, '1. `400 Bad Request`'
    assert_includes content, '6. `500 Internal Server Error`'
  end

  def test_accessibility_documentation_structure
    # Test case from debug_accessibility_test.rb
    markup = <<~POML
      <poml syntax="xml">
        <role>Accessibility Expert</role>
        <task>Create accessible documentation</task>
        
        <h1>Accessibility Guidelines</h1>
        
        <h2>Text Alternatives</h2>
        <p>All images must have descriptive <code>alt</code> attributes:</p>
        
        <code-block language="html">
<img src="chart.png" alt="Sales increased 25% from Q1 to Q2" />
        </code-block>
        
        <h2>Keyboard Navigation</h2>
        <p>Ensure all interactive elements are keyboard accessible:</p>
        
        <numbered-list>
          <item>Use semantic HTML elements</item>
          <item>Provide focus indicators</item>
          <item>Implement logical tab order</item>
        </numbered-list>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    assert_includes content, 'Accessibility Expert'
    assert_includes content, '<h1>Accessibility Guidelines</h1>'
    assert_includes content, '<h2>Text Alternatives</h2>'
    assert_includes content, '<code>alt</code>'
    assert_includes content, 'language="html"'
    assert_includes content, 'Use semantic HTML elements'
  end

  def test_code_block_html_escaping_preservation
    # Test case from debug_code_block.rb - ensure HTML after code blocks isn't escaped
    markup = <<~POML
      <poml syntax="xml">
        <h1>Test</h1>
        <code-block language="http">
Authorization: Bearer Token
        </code-block>
        <h2>After Code Block</h2>
        <table>
          <tr><td>test</td></tr>
        </table>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    # Ensure HTML elements after code blocks are properly rendered (XML syntax keeps HTML)
    assert_includes content, '<h2>After Code Block</h2>'
    assert_includes content, '<table>'
    
    # Ensure they're not escaped (should appear as HTML)
    refute_includes content, '&lt;table&gt;'
    refute_includes content, '&lt;h2&gt;'
  end

  def test_html_entities_in_code_elements
    # Test case from debug_html_entities.rb
    markup = <<~POML
      <poml syntax="xml">
        <numbered-list>
          <item>Only one <code>&lt;h1&gt;</code> per page</item>
          <item>Use <code>&lt;h2&gt;</code> for section headers</item>
          <item>Avoid skipping heading levels</item>
        </numbered-list>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    # HTML entities should be preserved in code elements (XML syntax keeps HTML)
    assert_includes content, '<code>&lt;h1&gt;</code>'
    assert_includes content, '<code>&lt;h2&gt;</code>'
    assert_includes content, 'Only one <code>&lt;h1&gt;</code>'
  end

  def test_json_output_format_component
    # Test case from debug_json.rb
    markup = <<~POML
      <poml>
        <role>API Developer</role>
        <task>Generate structured data response</task>
        
        <output format="json">
          {
            "user_profile": {
              "id": 12345,
              "username": "alice_johnson",
              "email": "alice@example.com",
              "preferences": {
                "theme": "dark",
                "notifications": true,
                "language": "en-US"
              },
              "last_login": "2024-01-15T09:30:00Z",
              "status": "active"
            },
            "metadata": {
              "generated_at": "2024-01-15T14:30:00Z",
              "version": "1.0",
              "source": "user_management_api"
            }
          }
        </output>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    # Should have output key with JSON content
    assert_includes result.keys, 'output'
    
    # Validate JSON structure
    json_output = result['output']
    parsed_json = JSON.parse(json_output)
    
    assert_equal 12345, parsed_json['user_profile']['id']
    assert_equal 'alice_johnson', parsed_json['user_profile']['username']
    assert_equal 'dark', parsed_json['user_profile']['preferences']['theme']
    assert_equal '1.0', parsed_json['metadata']['version']
  end
end
