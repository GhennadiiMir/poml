require "minitest/autorun"
require "poml"

class TutorialTemplateEngineTest < Minitest::Test
  # Tests for docs/tutorial/template-engine.md examples
  
  def test_basic_variable_substitution
    # From "Basic Variable Substitution" section
    markup = <<~POML
      <poml>
        <role>{{role_type}} Expert</role>
        <task>{{main_task}}</task>
        <hint>Focus on {{focus_area}} and provide {{output_type}}</hint>
      </poml>
    POML

    context = {
      'role_type' => 'Data Science',
      'main_task' => 'Analyze model performance',
      'focus_area' => 'accuracy metrics',
      'output_type' => 'actionable recommendations'
    }

    result = Poml.process(markup: markup, context: context)
    content = result['content']
    
    assert content.include?('Data Science Expert')
    assert content.include?('Analyze model performance')
    assert content.include?('accuracy metrics')
    assert content.include?('actionable recommendations')
    
    # Verify no unreplaced variables
    refute content.include?('{{role_type}}')
    refute content.include?('{{main_task}}')
  end

  def test_nested_object_access
    # From "Nested Object Access" section
    markup = <<~POML
      <poml>
        <role>Assistant for {{user.name}}</role>
        <task>Help with {{project.type}} development</task>
        
        <p>Project Details:</p>
        <list>
          <item>Name: {{project.name}}</item>
          <item>Priority: {{project.priority}}</item>
          <item>Team Size: {{project.team.size}}</item>
          <item>Lead: {{project.team.lead}}</item>
        </list>
      </poml>
    POML

    context = {
      'user' => {
        'name' => 'Alice Johnson'
      },
      'project' => {
        'name' => 'Customer Portal',
        'type' => 'web application',
        'priority' => 'high',
        'team' => {
          'size' => 5,
          'lead' => 'Bob Smith'
        }
      }
    }

    result = Poml.process(markup: markup, context: context)
    content = result['content']
    
    assert content.include?('Assistant for Alice Johnson')
    assert content.include?('web application development')
    assert content.include?('Name: Customer Portal')
    assert content.include?('Priority: high')
    assert content.include?('Team Size: 5')
    assert content.include?('Lead: Bob Smith')
  end

  def test_missing_variable_handling
    # From "Missing Variables" section
    markup = <<~POML
      <poml>
        <role>{{role_type}} and {{missing_variable}}</role>
        <task>{{available_task}}</task>
      </poml>
    POML

    context = {
      'role_type' => 'Data Scientist'
      # 'missing_variable' is intentionally omitted
      # 'available_task' is also omitted
    }

    result = Poml.process(markup: markup, context: context)
    content = result['content']
    
    # Should include available variable
    assert content.include?('Data Scientist')
    
    # Missing variables behavior may vary - check that processing doesn't fail
    assert_kind_of Hash, result
    assert result.key?('content')
  end

  def test_conditional_logic_basic
    # From "Conditional Logic" section
    markup = <<~POML
      <poml>
        <role>{{role_name}}</role>
        <task>{{task_description}}</task>
        
        <if condition="{{is_urgent}}">
          <p><b>🚨 URGENT:</b> This requires immediate attention!</p>
        </if>
        
        <if condition="!{{is_urgent}}">
          <p>Please handle this at your earliest convenience.</p>
        </if>
        
        <if condition="{{include_deadline}}">
          <p><b>Deadline:</b> {{deadline_date}}</p>
        </if>
      </poml>
    POML

    # Test urgent case
    urgent_context = {
      'role_name' => 'Support Agent',
      'task_description' => 'Handle customer escalation',
      'is_urgent' => true,
      'include_deadline' => true,
      'deadline_date' => '2024-01-15'
    }

    urgent_result = Poml.process(markup: markup, context: urgent_context)
    urgent_content = urgent_result['content']
    
    assert urgent_content.include?('Support Agent')
    assert urgent_content.include?('Handle customer escalation')
    assert urgent_content.include?('🚨 URGENT')
    assert urgent_content.include?('immediate attention')
    assert urgent_content.include?('**Deadline:** 2024-01-15')
    refute urgent_content.include?('earliest convenience')

    # Test non-urgent case
    normal_context = {
      'role_name' => 'Developer',
      'task_description' => 'Code review',
      'is_urgent' => false,
      'include_deadline' => false
    }

    normal_result = Poml.process(markup: markup, context: normal_context)
    normal_content = normal_result['content']
    
    assert normal_content.include?('Developer')
    assert normal_content.include?('Code review')
    refute normal_content.include?('🚨 URGENT')
    assert normal_content.include?('earliest convenience')
    refute normal_content.include?('Deadline:')
  end

  def test_comparison_operators
    # From "Comparison Operators" section
    markup = <<~POML
      <poml>
        <role>Performance Analyst</role>
        <task>System status check</task>
        
        <if condition="{{cpu_usage}} > 80">
          <p>⚠️ High CPU usage detected: {{cpu_usage}}%</p>
        </if>
        
        <if condition="{{memory_usage}} < 50">
          <p>✅ Memory usage is optimal: {{memory_usage}}%</p>
        </if>
        
        <if condition="{{error_count}} == 0">
          <p>✅ No errors detected</p>
        </if>
        
        <if condition="{{status}} == 'critical'">
          <p>🔴 CRITICAL: Immediate action required</p>
        </if>
      </poml>
    POML

    context = {
      'cpu_usage' => 85,
      'memory_usage' => 45,
      'error_count' => 0,
      'status' => 'critical'
    }

    result = Poml.process(markup: markup, context: context)
    content = result['content']
    
    assert content.include?('⚠️ High CPU usage detected: 85%')
    assert content.include?('✅ Memory usage is optimal: 45%')
    assert content.include?('✅ No errors detected')
    assert content.include?('🔴 CRITICAL: Immediate action required')
  end

  def test_loops_basic
    # From "Loops and Iteration" section
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
    
    assert content.include?('Task Manager')
    assert content.include?('Tasks to complete')
    assert content.include?('High: Fix critical bug (Due: 2024-01-10)')
    assert content.include?('Medium: Update documentation (Due: 2024-01-15)')
    assert content.include?('Low: Refactor old code (Due: 2024-01-20)')
  end

  def test_nested_loops
    # From "Nested Loops" section
    markup = <<~POML
      <poml>
        <role>System Administrator</role>
        <task>Review server configurations</task>
        
        <for variable="environment" items="{{environments}}">
          <p><b>{{environment.name}} Environment:</b></p>
          <list>
            <for variable="server" items="{{environment.servers}}">
              <item>{{server.name}} - {{server.status}} ({{server.cpu}}% CPU)</item>
            </for>
          </list>
        </for>
      </poml>
    POML

    context = {
      'environments' => [
        {
          'name' => 'Production',
          'servers' => [
            { 'name' => 'web-01', 'status' => 'healthy', 'cpu' => 25 },
            { 'name' => 'db-01', 'status' => 'healthy', 'cpu' => 60 }
          ]
        },
        {
          'name' => 'Development',
          'servers' => [
            { 'name' => 'dev-01', 'status' => 'healthy', 'cpu' => 15 }
          ]
        }
      ]
    }

    result = Poml.process(markup: markup, context: context)
    content = result['content']
    
    assert content.include?('System Administrator')
    assert content.include?('Production Environment:')
    assert content.include?('web-01 - healthy (25% CPU)')
    assert content.include?('db-01 - healthy (60% CPU)')
    assert content.include?('Development Environment:')
    assert content.include?('dev-01 - healthy (15% CPU)')
  end

  def test_conditional_loops
    # From "Conditional Loops" section
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

    alert_result = Poml.process(markup: markup, context: alert_context)
    alert_content = alert_result['content']
    
    assert alert_content.include?('🚨 Security Alerts (3)')
    assert alert_content.include?('**🔴 HIGH:** Suspicious login attempt')
    assert alert_content.include?('**🟡 MEDIUM:** Outdated SSL certificate')
    assert alert_content.include?('**🟢 LOW:** Minor configuration warning')
    refute alert_content.include?('No security alerts detected')

    # Test with no alerts
    no_alert_context = { 'alerts' => [] }
    
    no_alert_result = Poml.process(markup: markup, context: no_alert_context)
    no_alert_content = no_alert_result['content']
    
    refute no_alert_content.include?('🚨 Security Alerts')
    assert no_alert_content.include?('✅ No security alerts detected')
  end

  def test_meta_variables
    # From "Meta Variables" section
    markup = <<~POML
      <poml>
        <meta variables='{"default_role": "Assistant", "default_priority": "medium"}'>
        
        <role>{{user_role || default_role}}</role>
        <task>{{task_description}}</task>
        
        <p>Priority: {{priority || default_priority}}</p>
      </poml>
    POML

    # Test with partial override
    context = {
      'user_role' => 'Specialist',
      'task_description' => 'Analyze data'
      # 'priority' omitted - should use default
    }

    result = Poml.process(markup: markup, context: context)
    content = result['content']
    
    assert content.include?('Specialist')  # Overridden
    assert content.include?('Analyze data')
    assert content.include?('medium')  # Default used
    
    # Test with defaults only
    default_context = {
      'task_description' => 'General assistance'
    }

    default_result = Poml.process(markup: markup, context: default_context)
    default_content = default_result['content']
    
    assert default_content.include?('Assistant')  # Default used
    assert default_content.include?('General assistance')
    assert default_content.include?('medium')  # Default used
  end

  def test_complex_template_example
    # From "Complex Template Example" section
    markup = <<~POML
      <poml>
        <role>{{analysis_type}} Analyst</role>
        <task>Generate comprehensive {{analysis_type}} report</task>
        
        <if condition="{{include_summary}}">
          <p><b>Executive Summary:</b></p>
          <p>{{summary_text}}</p>
        </if>
        
        <p><b>Key Findings:</b></p>
        <list>
          <for variable="finding" items="{{findings}}">
            <item>
              <if condition="{{finding.importance}} == 'critical'">
                🔴 <b>CRITICAL:</b> {{finding.description}}
              </if>
              <if condition="{{finding.importance}} == 'important'">
                🟡 <b>IMPORTANT:</b> {{finding.description}}
              </if>
              <if condition="{{finding.importance}} == 'minor'">
                🟢 {{finding.description}}
              </if>
            </item>
          </for>
        </list>
        
        <if condition="{{recommendations.length}} > 0">
          <p><b>Recommendations:</b></p>
          <list>
            <for variable="rec" items="{{recommendations}}">
              <item>{{rec.action}} (Priority: {{rec.priority}})</item>
            </for>
          </list>
        </if>
      </poml>
    POML

    context = {
      'analysis_type' => 'Security',
      'include_summary' => true,
      'summary_text' => 'Overall security posture is good with some areas for improvement.',
      'findings' => [
        { 'importance' => 'critical', 'description' => 'Outdated authentication system' },
        { 'importance' => 'important', 'description' => 'Missing security headers' },
        { 'importance' => 'minor', 'description' => 'Verbose error messages' }
      ],
      'recommendations' => [
        { 'action' => 'Upgrade authentication system', 'priority' => 'High' },
        { 'action' => 'Implement security headers', 'priority' => 'Medium' }
      ]
    }

    result = Poml.process(markup: markup, context: context)
    content = result['content']
    
    assert content.include?('Security Analyst')
    assert content.include?('comprehensive Security report')
    assert content.include?('Executive Summary')
    assert content.include?('Overall security posture is good')
    assert content.include?('🔴 **CRITICAL:** Outdated authentication system')
    assert content.include?('🟡 **IMPORTANT:** Missing security headers')
    assert content.include?('🟢 Verbose error messages')
    assert content.include?('Upgrade authentication system (Priority: High)')
    assert content.include?('Implement security headers (Priority: Medium)')
  end

  def test_performance_with_large_datasets
    # Test template engine performance with larger datasets
    large_items = (1..100).map do |i|
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
        <task>Process large dataset</task>
        
        <p>Processing {{items.length}} items:</p>
        
        <for variable="item" items="{{items}}">
          <if condition="{{item.active}}">
            <p>{{item.priority}}: {{item.name}} (ID: {{item.id}})</p>
          </if>
        </for>
      </poml>
    POML

    context = { 'items' => large_items }

    start_time = Time.now
    result = Poml.process(markup: markup, context: context)
    end_time = Time.now
    
    processing_time = end_time - start_time
    
    # Should process reasonably quickly
    assert processing_time < 1.0, "Processing took too long: #{processing_time}s"
    
    # Verify content
    content = result['content']
    assert content.include?('Processing 100 items')
    assert content.include?('Item 2 (ID: 2)')  # Even numbered items should be included
    refute content.include?('Item 1 (ID: 1)')  # Odd numbered items should be excluded
  end
end
