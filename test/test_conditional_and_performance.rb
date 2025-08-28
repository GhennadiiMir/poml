require_relative 'test_helper'

class TestConditionalAndPerformance < Minitest::Test
  include TestHelper

  def test_conditional_loops_with_severity_filtering
    # Test case from debug_conditional_loops.rb - complex conditional logic
    markup = <<~POML
      <poml>
        <role>Security Analyst</role>
        <task>Security assessment report</task>
        
        <if condition="{{alerts.length}} > 0">
          <p><b>🚨 Security Alerts ({{alerts.length}}):</b></p>
          <list>
            <for variable="alert" items="{{alerts}}">
              <item>
                <if condition="{{alert.severity}} == 'high'">
                  <b>🔴 HIGH:</b> {{alert.message}}
                </if>
                <if condition="{{alert.severity}} == 'medium'">
                  <b>🟡 MEDIUM:</b> {{alert.message}}
                </if>
                <if condition="{{alert.severity}} == 'low'">
                  <b>🟢 LOW:</b> {{alert.message}}
                </if>
              </item>
            </for>
          </list>
        </if>
        
        <if condition="{{alerts.length}} == 0">
          <p>✅ No security alerts detected</p>
        </if>
      </poml>
    POML

    # Test with alerts
    alert_context = {
      'alerts' => [
        { 'severity' => 'high', 'message' => 'Suspicious login attempt detected' },
        { 'severity' => 'medium', 'message' => 'Outdated SSL certificate' },
        { 'severity' => 'low', 'message' => 'Minor configuration warning' }
      ]
    }

    result = Poml.process(markup: markup, context: alert_context)
    content = result['content']

    # Test presence of alert summary
    assert_includes content, '🚨 Security Alerts (3)'
    
    # Test severity-based formatting (markdown format with emojis)
    assert_includes content, '**🔴 HIGH:** Suspicious login attempt detected'
    assert_includes content, '**🟡 MEDIUM:** Outdated SSL certificate'
    assert_includes content, '**🟢 LOW:** Minor configuration warning'
    
    # Ensure "no alerts" message is not present
    refute_includes content, 'No security alerts detected'

    # Test with no alerts
    no_alert_context = { 'alerts' => [] }
    no_alert_result = Poml.process(markup: markup, context: no_alert_context)
    no_alert_content = no_alert_result['content']

    # Should show no alerts message
    assert_includes no_alert_content, '✅ No security alerts detected'
    
    # Should not show alerts section
    refute_includes no_alert_content, '🚨 Security Alerts'
  end

  def test_for_loop_with_task_processing
    # Test case from debug_for_loop.rb
    markup = <<~POML
      <poml>
        <role>Task Manager</role>
        <task>Review pending tasks</task>
        
        <p>Tasks to complete:</p>
        <list>
          <for variable="task" items="{{tasks}}">
            <item>{{task.priority}}: {{task.title}} (Due: {{task.due_date}})</item>
          </for>
        </list>
      </poml>
    POML

    context = {
      'tasks' => [
        { 'priority' => 'High', 'title' => 'Fix critical bug', 'due_date' => '2024-01-10' },
        { 'priority' => 'Medium', 'title' => 'Update documentation', 'due_date' => '2024-01-15' },
        { 'priority' => 'Low', 'title' => 'Refactor old code', 'due_date' => '2024-01-20' }
      ]
    }

    result = Poml.process(markup: markup, context: context)
    content = result['content']

    assert_includes content, 'Task Manager'
    assert_includes content, 'Tasks to complete:'
    assert_includes content, 'High: Fix critical bug (Due: 2024-01-10)'
    assert_includes content, 'Medium: Update documentation (Due: 2024-01-15)'
    assert_includes content, 'Low: Refactor old code (Due: 2024-01-20)'
  end

  def test_performance_with_conditional_filtering
    # Test case from debug_performance.rb - performance with conditional logic
    items = (1..10).map do |i|
      {
        'id' => i,
        'name' => "Item #{i}",
        'priority' => ['low', 'medium', 'high'][i % 3],
        'active' => i.even?
      }
    end

    markup = <<~POML
      <poml>
        <role>Data Processor</role>
        <task>Process dataset</task>
        
        <p>Processing {{items.length}} items:</p>
        
        <for variable="item" items="{{items}}">
          <if condition="{{item.active}}">
            <p>{{item.priority}}: {{item.name}} (ID: {{item.id}})</p>
          </if>
        </for>
        
        <h2>Summary</h2>
        <p>Only active items are displayed above.</p>
      </poml>
    POML

    context = { 'items' => items }

    result = Poml.process(markup: markup, context: context)
    content = result['content']

    # Test dataset size
    assert_includes content, 'Processing 10 items'
    
    # Test that only even-numbered items appear (active items)
    assert_includes content, 'Item 2'
    assert_includes content, 'Item 4'
    assert_includes content, 'Item 6'
    assert_includes content, 'Item 8'
    assert_includes content, 'Item 10'
    
    # Test that odd-numbered items don't appear (inactive items)
    refute_includes content, 'Item 1 ('
    refute_includes content, 'Item 3 ('
    refute_includes content, 'Item 5 ('
    refute_includes content, 'Item 7 ('
    refute_includes content, 'Item 9 ('
    
    # Test summary section (markdown format)
    assert_includes content, '## Summary'
    assert_includes content, 'Only active items are displayed'
  end

  def test_template_variable_substitution_edge_cases
    # Test case from debug_template_engine.rb
    context_vars = {
      'expert_type' => 'Ruby',
      'tasks' => [{ 'priority' => 'High', 'title' => 'Fix critical bug' }],
      'nonexistent' => nil
    }

    markup = <<~POML
      <poml>
        <role>{{expert_type}} Expert</role>
        <task>Variable substitution test</task>
        
        <p>Expert type: {{expert_type}}</p>
        <p>Task count: {{tasks.length}}</p>
        <p>Nonexistent: {{nonexistent_var}}</p>
        
        <for variable="task" items="{{tasks}}">
          <p>{{task.priority}}: {{task.title}}</p>
        </for>
      </poml>
    POML

    result = Poml.process(markup: markup, context: context_vars)
    content = result['content']

    # Test variable substitution
    assert_includes content, 'Ruby Expert'
    assert_includes content, 'Expert type: Ruby'
    assert_includes content, 'Task count: 1'
    
    # Test undefined variables remain as-is
    assert_includes content, 'Nonexistent: {{nonexistent_var}}'
    
    # Test loop variable substitution
    assert_includes content, 'High: Fix critical bug'
  end

  def test_escaping_in_code_blocks
    # Test case from debug_escaping.rb
    markup = <<~POML
      <poml>
        <h2>Authentication</h2>
        
        <code-block language="http">
Authorization: Bearer <token>value</token>
        </code-block>
        
        <h2>Endpoints</h2>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']

    # Code blocks are converted to markdown format
    assert_includes content, '```http'
    
    # HTML elements outside code blocks should be converted to markdown  
    assert_includes content, '## Authentication'
    assert_includes content, '## Endpoints'
    
    # Code block content should be properly handled
    assert_includes content, 'Authorization: Bearer'
  end

  def test_complex_table_with_mixed_formatting
    # Test case from debug_table.rb with enhanced formatting
    markup = <<~POML
      <poml syntax="xml">
        <h2>API Parameters</h2>
        
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
              <td><i>integer</i></td>
              <td><b>No</b></td>
              <td>Page number (default: 1)</td>
            </tr>
            <tr>
              <td><code>limit</code></td>
              <td><i>integer</i></td>
              <td><b>No</b></td>
              <td>Items per page (max: <code>100</code>)</td>
            </tr>
            <tr>
              <td><code>status</code></td>
              <td><i>string</i></td>
              <td><b>Yes</b></td>
              <td>Filter by status: <code>active</code>, <code>inactive</code></td>
            </tr>
          </tbody>
        </table>
        
        <h2>Response Format</h2>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']

    # Test table structure (XML syntax keeps HTML format)
    assert_includes content, '<table>'
    assert_includes content, '<thead>'
    assert_includes content, '<tbody>'
    assert_includes content, '</table>'
    
    # Test mixed formatting within table cells (HTML format)
    assert_includes content, '<code>page</code>'
    assert_includes content, '<i>integer</i>'
    assert_includes content, '<b>No</b>'
    assert_includes content, '<b>Yes</b>'
    assert_includes content, 'max: <code>100</code>'
    
    # Test headers before and after table (HTML format)
    assert_includes content, '<h2>API Parameters</h2>'
    assert_includes content, '<h2>Response Format</h2>'
  end
end
