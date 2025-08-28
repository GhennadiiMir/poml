require "minitest/autorun"
require "poml"

class TutorialFormattingComponentsTest < Minitest::Test
  # Tests for docs/tutorial/formatting-components.md examples
  
  def test_basic_formatting_components
    # From "Basic Formatting" section
    markup = <<~POML
      <poml>
        <role>Technical Writer</role>
        <task>Create formatted documentation</task>
        
        <p>This is a regular paragraph with <b>bold text</b> and <i>italic text</i>.</p>
        <p>You can also use <code>inline code</code> and <u>underlined text</u>.</p>
        
        <list>
          <item>First item with <b>bold</b> emphasis</item>
          <item>Second item with <i>italic</i> style</item>
          <item>Third item with <code>code snippet</code></item>
        </list>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    assert content.include?('Technical Writer')
    assert content.include?('Create formatted documentation')
    assert content.include?('regular paragraph')
    assert content.include?('**bold text**')
    assert content.include?('*italic text*')
    assert content.include?('`inline code`')
    assert content.include?('__underlined text__')
    assert content.include?('First item')
    assert content.include?('Second item')
    assert content.include?('Third item')
  end

  def test_headers_and_structure
    # From "Headers and Document Structure" section
    markup = <<~POML
      <poml>
        <role>Documentation Expert</role>
        <task>Structure a comprehensive guide</task>
        
        <h1>Main Title: System Architecture</h1>
        
        <h2>Overview</h2>
        <p>This section provides an overview of the system.</p>
        
        <h2>Components</h2>
        
        <h3>Frontend Components</h3>
        <p>Details about frontend architecture.</p>
        
        <h3>Backend Services</h3>
        <p>Information about backend services.</p>
        
        <h4>Database Layer</h4>
        <p>Database design and implementation details.</p>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    assert content.include?('Documentation Expert')
    assert content.include?('# Main Title: System Architecture')
    assert content.include?('## Overview')
    assert content.include?('## Components')
    assert content.include?('### Frontend Components')
    assert content.include?('### Backend Services')
    assert content.include?('#### Database Layer')
    assert content.include?('overview of the system')
    assert content.include?('frontend architecture')
    assert content.include?('backend services')
    assert content.include?('Database design')
  end

  def test_lists_and_organization
    # From "Lists and Organization" section
    markup = <<~POML
      <poml>
        <role>Project Manager</role>
        <task>Organize project requirements</task>
        
        <h2>Functional Requirements</h2>
        <list>
          <item>User authentication and authorization</item>
          <item>Data validation and processing</item>
          <item>Report generation and export</item>
          <item>Real-time notifications</item>
        </list>
        
        <h2>Technical Requirements</h2>
        <numbered-list>
          <item>Database must support ACID transactions</item>
          <item>API must handle 1000+ concurrent users</item>
          <item>Response time must be under 200ms</item>
          <item>System must have 99.9% uptime</item>
        </numbered-list>
        
        <h2>Priority Matrix</h2>
        <checklist>
          <item checked="true">High Priority: Core authentication</item>
          <item checked="true">High Priority: Basic CRUD operations</item>
          <item checked="false">Medium Priority: Advanced reporting</item>
          <item checked="false">Low Priority: Custom themes</item>
        </checklist>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    assert content.include?('Project Manager')
    assert content.include?('Functional Requirements')
    assert content.include?('User authentication')
    assert content.include?('Data validation')
    assert content.include?('Report generation')
    assert content.include?('Real-time notifications')
    
    assert content.include?('Technical Requirements')
    assert content.include?('ACID transactions')
    assert content.include?('1000+ concurrent users')
    assert content.include?('under 200ms')
    assert content.include?('99.9% uptime')
    
    assert content.include?('Priority Matrix')
    assert content.include?('Core authentication')
    assert content.include?('CRUD operations')
    assert content.include?('Advanced reporting')
    assert content.include?('Custom themes')
  end

  def test_code_blocks_and_examples
    # From "Code Blocks and Examples" section
    markup = <<~POML
      <poml>
        <role>Senior Developer</role>
        <task>Provide implementation examples</task>
        
        <p>Here's how to implement user authentication:</p>
        
        <code-block language="python">
def authenticate_user(username, password):
    user = User.find_by_username(username)
    if user and user.check_password(password):
        return generate_token(user)
    return None
        </code-block>
        
        <p>For the frontend, use this JavaScript:</p>
        
        <code-block language="javascript">
async function login(username, password) {
    const response = await fetch('/api/auth', {
        method: 'POST',
        body: JSON.stringify({ username, password })
    });
    return response.json();
}
        </code-block>
        
        <p>Configuration example:</p>
        
        <code-block language="yaml">
authentication:
  method: jwt
  expiry: 24h
  secret_key: ${AUTH_SECRET}
        </code-block>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    assert content.include?('Senior Developer')
    assert content.include?('implementation examples')
    assert content.include?('authenticate_user')
    assert content.include?('def authenticate_user(username, password):')
    assert content.include?('User.find_by_username')
    assert content.include?('generate_token')
    
    assert content.include?('async function login')
    assert content.include?('fetch(\'/api/auth\'')
    assert content.include?('JSON.stringify')
    
    assert content.include?('authentication:')
    assert content.include?('method: jwt')
    assert content.include?('expiry: 24h')
  end

  def test_tables_and_data_presentation
    # From "Tables and Data Presentation" section
    markup = <<~POML
      <poml>
        <role>Data Analyst</role>
        <task>Present performance metrics</task>
        
        <h2>System Performance Metrics</h2>
        
        <table>
          <thead>
            <tr>
              <th>Metric</th>
              <th>Current Value</th>
              <th>Target</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Response Time</td>
              <td>145ms</td>
              <td>&lt; 200ms</td>
              <td>✅ Good</td>
            </tr>
            <tr>
              <td>CPU Usage</td>
              <td>65%</td>
              <td>&lt; 80%</td>
              <td>✅ Good</td>
            </tr>
            <tr>
              <td>Memory Usage</td>
              <td>85%</td>
              <td>&lt; 75%</td>
              <td>⚠️ Warning</td>
            </tr>
            <tr>
              <td>Error Rate</td>
              <td>0.05%</td>
              <td>&lt; 0.1%</td>
              <td>✅ Good</td>
            </tr>
          </tbody>
        </table>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    assert content.include?('Data Analyst')
    assert content.include?('Performance Metrics')
    assert content.include?('| Column ')
    assert content.include?('| --- |')
    assert content.include?('| Metric |')
    assert content.include?('| Response Time |')
    assert content.include?('| 145ms |')
    assert content.include?('✅ Good')
    assert content.include?('⚠️ Warning')
    assert content.include?('Memory Usage')
    assert content.include?('Error Rate')
  end

  def test_quotes_and_callouts
    # From "Quotes and Callouts" section
    markup = <<~POML
      <poml>
        <role>Technical Lead</role>
        <task>Document design decisions</task>
        
        <p>As stated in our architecture review:</p>
        
        <blockquote>
          "The microservices architecture provides better scalability 
          and maintainability, but requires careful service boundary design 
          and robust inter-service communication patterns."
        </blockquote>
        
        <callout type="info">
          <b>Design Principle:</b> Each microservice should own its data 
          and expose well-defined APIs for external access.
        </callout>
        
        <callout type="warning">
          <b>Important:</b> Distributed transactions should be avoided. 
          Use eventual consistency patterns instead.
        </callout>
        
        <callout type="error">
          <b>Critical:</b> Never share database connections between services. 
          This breaks service isolation and can cause cascading failures.
        </callout>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    assert content.include?('Technical Lead')
    assert content.include?('design decisions')
    assert content.include?('> "The microservices architecture')
    assert content.include?('microservices architecture')
    assert content.include?('scalability')
    assert content.include?('maintainability')
    assert content.include?('service boundary design')
    
    assert content.include?('Design Principle')
    assert content.include?('own its data')
    assert content.include?('well-defined APIs')
    
    assert content.include?('Important:')
    assert content.include?('Distributed transactions')
    assert content.include?('eventual consistency')
    
    assert content.include?('Critical:')
    assert content.include?('database connections')
    assert content.include?('cascading failures')
  end

  def test_links_and_references
    # From "Links and References" section
    markup = <<~POML
      <poml>
        <role>Documentation Specialist</role>
        <task>Create comprehensive documentation</task>
        
        <p>For more information, see the <link url="https://docs.example.com">official documentation</link>.</p>
        
        <p>Related resources:</p>
        <list>
          <item><link url="https://api.example.com">API Reference</link></item>
          <item><link url="https://github.com/example/repo">Source Code</link></item>
          <item><link url="mailto:support@example.com">Technical Support</link></item>
        </list>
        
        <p>Internal references:</p>
        <list>
          <item><ref target="section-1">Getting Started Guide</ref></item>
          <item><ref target="section-2">Advanced Configuration</ref></item>
          <item><ref target="appendix-a">Troubleshooting Guide</ref></item>
        </list>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    assert content.include?('Documentation Specialist')
    assert content.include?('comprehensive documentation')
    assert content.include?('official documentation')
    assert content.include?('https://docs.example.com')
    assert content.include?('API Reference')
    assert content.include?('https://api.example.com')
    assert content.include?('Source Code')
    assert content.include?('github.com')
    assert content.include?('Technical Support')
    assert content.include?('support@example.com')
    assert content.include?('Getting Started Guide')
    assert content.include?('Advanced Configuration')
    assert content.include?('Troubleshooting Guide')
  end

  def test_complex_formatting_combination
    # From "Complex Formatting Example" section
    markup = <<~POML
      <poml syntax="xml">
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
curl -H "Authorization: Bearer TOKEN" \
     "https://api.example.com/v1/users?page=1&limit=20&status=active"
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

    result = Poml.process(markup: markup)
    content = result['content']
    
    # Test main structure - content appears as raw XML in conversation format
    assert content.include?('Technical Documentation Lead')
    assert content.include?('<h1>User Management API</h1>')
    assert content.include?('<h2>Overview</h2>')
    assert content.include?('<h2>Authentication</h2>')
    assert content.include?('<h2>Endpoints</h2>')
    
    # Test formatting combinations - raw XML format
    assert content.include?('<b>user management</b>')
    assert content.include?('<i>authentication</i>')
    assert content.include?('<code>https://api.example.com/v1</code>')
    
    # Test table content - raw XML format
    assert content.include?('<table>')
    assert content.include?('<code>page</code>')
    assert content.include?('integer')
    assert content.include?('Page number (default: 1)')
    
    # Test code blocks
    assert content.include?('curl -H "Authorization: Bearer TOKEN"')
    assert content.include?('https://api.example.com/v1/users')
    assert content.include?('"username": "alice"')
    assert content.include?('"pagination"')
    
    # Test callouts
    assert content.include?('Rate Limiting')
    assert content.include?('100 requests per minute')
    assert content.include?('429 Too Many Requests')
    
    # Test numbered list
    assert content.include?('400 Bad Request')
    assert content.include?('401 Unauthorized')
    assert content.include?('500 Internal Server Error')
  end

  def test_accessibility_and_semantics
    # Test proper semantic structure
    markup = <<~POML
      <poml syntax="xml">
        <role>Accessibility Expert</role>
        <task>Create accessible documentation</task>
        
        <h1>Accessibility Guidelines</h1>
        
        <h2>Text Alternatives</h2>
        <p>All images must have descriptive <code>alt</code> attributes:</p>
        
        <code-block language="html">
&lt;img src="chart.png" alt="Sales performance chart showing 25% increase in Q4" /&gt;
        </code-block>
        
        <h2>Navigation Structure</h2>
        <p>Use proper heading hierarchy:</p>
        
        <numbered-list>
          <item>Only one <code>&lt;h1&gt;</code> per page</item>
          <item>Don't skip heading levels (h1 → h2 → h3)</item>
          <item>Use headings for structure, not styling</item>
        </numbered-list>
        
        <callout type="info">
          <b>Screen Reader Tip:</b> Proper heading structure allows users to navigate efficiently 
          using keyboard shortcuts to jump between sections.
        </callout>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    assert content.include?('Accessibility Expert')
    assert content.include?('<h1>Accessibility Guidelines</h1>')
    assert content.include?('<h2>Text Alternatives</h2>')
    assert content.include?('<h2>Navigation Structure</h2>')
    assert content.include?('descriptive <code>alt</code> attributes')
    assert content.include?('Sales performance chart')
    assert content.include?('Only one <code>&lt;h1&gt;</code>')
    assert content.include?('Screen Reader Tip')
    assert content.include?('keyboard shortcuts')
  end
end
