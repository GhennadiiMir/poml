require_relative 'test_helper'

class TestXmlParsingAndCodeReview < Minitest::Test
  include TestHelper

  def test_xml_parsing_with_code_review_scenario
    # Test case from debug_xml_parsing.rb - comprehensive XML parsing
    markup = <<~POML
      <poml>
        <system>You are a Ruby programming expert</system>
        
        <human>
          Please review this code:
          
          <code>
          def calculate_total(items)
            total = 0
            items.each do |item|
              total += item.price
            end
            total
          end
          </code>
        </human>
        
        <ai>
          I see several opportunities for optimization:
          
          <list>
            <item><b>Use reduce:</b> Replace the manual loop with <code>reduce</code></item>
            <item><b>Use sum:</b> Even better, use <code>sum</code> method</item>
          </list>
          
          <p>Here's the improved version:</p>
          <code>
          def calculate_total(items)
            items.sum(&:price)
          end
          </code>
        </ai>
      </poml>
    POML

    result = Poml.process(markup: markup, format: 'openai_chat')
    
    # Should return array of chat messages
    assert_kind_of Array, result
    assert_equal 3, result.length
    
    # Test system message
    system_msg = result[0]
    assert_equal 'system', system_msg['role']
    assert_includes system_msg['content'], 'Ruby programming expert'
    
    # Test human message
    human_msg = result[1]
    assert_equal 'user', human_msg['role']
    assert_includes human_msg['content'], 'Please review this code'
    assert_includes human_msg['content'], 'def calculate_total(items)'
    assert_includes human_msg['content'], 'items.each do |item|'
    
    # Test AI message
    ai_msg = result[2]
    assert_equal 'assistant', ai_msg['role']
    assert_includes ai_msg['content'], 'several opportunities for optimization'
    assert_includes ai_msg['content'], '**Use reduce:**'
    assert_includes ai_msg['content'], '**Use sum:**'
    assert_includes ai_msg['content'], 'items.sum(&amp;:price)'
  end

  def test_comprehensive_formatting_combinations
    # Test case from debug_formatting_test.rb - extensive formatting combinations
    markup = <<~POML
      <poml>
        <role>Technical Documentation Lead</role>
        <task>Document API endpoints and formatting guidelines</task>
        
        <h1>User Management API</h1>
        
        <h2>Overview</h2>
        <p>This API provides comprehensive <b>user management</b> functionality with advanced 
        <i>authentication</i> and <u>authorization</u> features. The base URL is 
        <code>https://api.example.com/v1</code>.</p>
        
        <h2>Authentication</h2>
        <p>All requests require authentication using <code>Bearer tokens</code>. 
        Include the token in the <b><i>Authorization header</i></b>:</p>
        
        <code-block language="bash">
        curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \\
             -X GET https://api.example.com/v1/users
        </code-block>
        
        <h2>Endpoints</h2>
        
        <h3>GET /users</h3>
        <p>Retrieve a paginated list of users with optional filtering.</p>
        
        <b>Query Parameters:</b>
        <table>
          <thead>
            <tr>
              <th>Parameter</th>
              <th>Type</th>
              <th>Description</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><code>page</code></td>
              <td>integer</td>
              <td>Page number (default: 1)</td>
            </tr>
            <tr>
              <td><code>limit</code></td>
              <td>integer</td>
              <td>Items per page (default: 20, max: 100)</td>
            </tr>
            <tr>
              <td><code>status</code></td>
              <td>string</td>
              <td>Filter by status: <i>active</i>, <i>inactive</i>, <i>pending</i></td>
            </tr>
            <tr>
              <td><code>role</code></td>
              <td>string</td>
              <td>Filter by role: <b>admin</b>, <b>user</b>, <b>moderator</b></td>
            </tr>
          </tbody>
        </table>
        
        <h4>Response Format</h4>
        <code-block language="json">
        {
          "users": [
            {
              "id": 123,
              "username": "alice",
              "email": "alice@example.com",
              "role": "admin",
              "status": "active"
            }
          ],
          "meta": {
            "page": 1,
            "limit": 20,
            "total": 1
          }
        }
        </code-block>
        
        <callout type="success">
          <b>Pro Tip:</b> Use <code>role=admin</code> to filter administrative users.
        </callout>
      </poml>
    POML

    result = Poml.process(markup: markup, format: 'raw')
    content = result

    # Test multiple formatting combinations (markdown format)
    assert_includes content, '**user management**'
    assert_includes content, '*authentication*'
    assert_includes content, '__authorization__'
    assert_includes content, '`https://api.example.com/v1`'
    
    # Test nested formatting (markdown format)
    assert_includes content, '***Authorization header***'
    
    # Test code blocks with different languages
    assert_includes content, '```bash'
    assert_includes content, '```json'
    
    # Test table with mixed formatting in cells (markdown format)
    assert_includes content, '`page`'
    assert_includes content, '*active*, *inactive*, *pending*'
    assert_includes content, '**admin**, **user**, **moderator**'
    
    # Test callout (markdown format with emoji)
    assert_includes content, '✅'
    assert_includes content, '**Pro Tip:**'
  end

  def test_syntax_distinction_and_parsing_modes
    # Test different syntax modes for parsing
    xml_markup = <<~POML
      <poml syntax="xml">
        <role>XML Parser</role>
        <task>Parse XML-style content</task>
        
        <h1>XML Mode Test</h1>
        <p>This uses <b>XML syntax</b> for parsing.</p>
      </poml>
    POML

    default_markup = <<~POML
      <poml>
        <role>Default Parser</role>
        <task>Parse default content</task>
        
        <h1>Default Mode Test</h1>
        <p>This uses <b>default syntax</b> for parsing.</p>
      </poml>
    POML

    # Test XML syntax mode
    xml_result = Poml.process(markup: xml_markup)
    xml_content = xml_result['content']
    
    assert_includes xml_content, 'XML Parser'
    assert_includes xml_content, '<h1>XML Mode Test</h1>'
    assert_includes xml_content, '<b>XML syntax</b>'
    
    # Test default mode (markdown format)
    default_result = Poml.process(markup: default_markup)
    default_content = default_result['content']
    
    assert_includes default_content, 'Default Parser'
    assert_includes default_content, '# Default Mode Test'
    assert_includes default_content, '**default syntax**'
  end

  def test_step_by_step_parsing_validation
    # Test case that validates parsing happens correctly step by step
    markup = <<~POML
      <poml>
        <role>Step-by-step processor</role>
        <task>Validate parsing order</task>
        
        <h1>Step 1: Initialize</h1>
        <p>First, we <b>initialize</b> the system.</p>
        
        <h2>Step 2: Process</h2>
        <list>
          <item><i>Parse</i> the input</item>
          <item><i>Validate</i> the structure</item>
          <item><i>Generate</i> the output</item>
        </list>
        
        <h2>Step 3: Finalize</h2>
        <p>Finally, we <code>return</code> the result with proper formatting.</p>
        
        <callout type="info">
          All steps should maintain <b>HTML structure</b> integrity.
        </callout>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']

    # Test role and task are processed first
    assert_includes content, 'Step-by-step processor'
    assert_includes content, 'Validate parsing order'
    
    # Test headers are processed in order (markdown format)
    assert_includes content, '# Step 1: Initialize'
    assert_includes content, '## Step 2: Process'
    assert_includes content, '## Step 3: Finalize'
    
    # Test formatting elements are preserved (markdown format)
    assert_includes content, '**initialize**'
    assert_includes content, '*Parse*'
    assert_includes content, '*Validate*'
    assert_includes content, '*Generate*'
    assert_includes content, '`return`'
    
    # Test list structure appears (markdown format)
    assert_includes content, '- *Parse*'
    assert_includes content, '- *Validate*'
    
    # Test callout (markdown format with emoji)
    assert_includes content, 'ℹ️'
    assert_includes content, '**HTML structure**'
  end

  def test_word_boundary_and_regex_handling
    # Test case from debug_word_boundary.rb - ensure proper word boundary handling
    markup = <<~POML
      <poml>
        <role>Regex Tester</role>
        <task>Test word boundary scenarios</task>
        
        <p>Testing word boundaries:</p>
        <list>
          <item>The word <b>test</b> should be bold</item>
          <item>The word <b>testing</b> should also be bold</item>
          <item>Words like <b>contest</b> should work too</item>
          <item>And <b>fastest</b> as well</item>
        </list>
        
        <p>Code examples with <code>function</code> and <code>functional</code> keywords.</p>
        
        <h2>Edge Cases</h2>
        <p>Words at boundaries: <i>start</i> and <i>end</i>.</p>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']

    # Test that all bold words are properly formatted (markdown)
    assert_includes content, '**test**'
    assert_includes content, '**testing**'
    assert_includes content, '**contest**'
    assert_includes content, '**fastest**'
    
    # Test code formatting (markdown)
    assert_includes content, '`function`'
    assert_includes content, '`functional`'
    
    # Test italic formatting at boundaries (markdown)
    assert_includes content, '*start*'
    assert_includes content, '*end*'
    
    # Test structure (markdown headers)
    assert_includes content, 'Regex Tester'
    assert_includes content, '## Edge Cases'
  end
end
