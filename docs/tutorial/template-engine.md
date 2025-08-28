# Template Engine

POML includes a powerful template engine that supports variables, conditionals, loops, and meta variables for creating dynamic, reusable prompts.

## Variable Substitution

### Basic Variables

Use `{{variable_name}}` syntax for simple variable substitution:

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>{{expert_type}} Expert</role>
    <task>{{main_task}}</task>
    <hint>Focus on {{focus_area}} and provide {{output_type}}</hint>
  </poml>
POML

context = {
  'expert_type' => 'Machine Learning',
  'main_task' => 'Analyze model performance',
  'focus_area' => 'accuracy metrics',
  'output_type' => 'actionable recommendations'
}

result = Poml.process(markup: markup, context: context)
puts result['content']
```

### Variable Safety

Variables that don't exist in context are left unchanged:

```ruby
markup = '<poml><role>{{existing}} and {{missing}}</role></poml>'
context = { 'existing' => 'Data Scientist' }

result = Poml.process(markup: markup, context: context)
# Output will contain: "Data Scientist and {{missing}}"
```

## Meta Variables

Use the `<meta variables="">` component to define template variables within the POML document:

```ruby
markup = <<~POML
  <poml>
    <meta variables='{"project": "E-commerce Platform", "deadline": "Q4 2024", "team_size": 8}' />
    
    <role>Project Manager</role>
    <task>Create project plan for {{project}}</task>
    
    <p>Project Details:</p>
    <list>
      <item>Deadline: {{deadline}}</item>
      <item>Team Size: {{team_size}} developers</item>
    </list>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['content']
```

### Combining Context and Meta Variables

External context overrides meta variables:

```ruby
markup = <<~POML
  <poml>
    <meta variables='{"environment": "development", "debug": true}' />
    
    <role>DevOps Engineer</role>
    <task>Deploy to {{environment}} environment</task>
    <hint>Debug mode: {{debug}}</hint>
  </poml>
POML

# Override meta variables
context = { 'environment' => 'production', 'debug' => false }

result = Poml.process(markup: markup, context: context)
# Will use production/false instead of development/true
```

## Conditional Logic

### Basic If Statements

Use `<if condition="">` for conditional content:

```ruby
markup = <<~POML
  <poml>
    <role>Security Analyst</role>
    <task>Analyze security requirements</task>
    
    <if condition="{{security_level}} == 'high'">
      <p>Implement additional security measures:</p>
      <list>
        <item>Multi-factor authentication</item>
        <item>End-to-end encryption</item>
        <item>Regular security audits</item>
      </list>
    </if>
    
    <if condition="{{compliance_required}}">
      <p>Ensure compliance with {{compliance_standards}}.</p>
    </if>
  </poml>
POML

context = {
  'security_level' => 'high',
  'compliance_required' => true,
  'compliance_standards' => 'SOC 2 and GDPR'
}

result = Poml.process(markup: markup, context: context)
```

### Comparison Operators

POML supports various comparison operators:

```ruby
markup = <<~POML
  <poml>
    <role>Performance Analyst</role>
    <task>Analyze performance metrics</task>
    
    <if condition="{{response_time}} > 500">
      <p>⚠️ Response time is too slow: {{response_time}}ms</p>
    </if>
    
    <if condition="{{cpu_usage}} >= 80">
      <p>🔥 High CPU usage detected: {{cpu_usage}}%</p>
    </if>
    
    <if condition="{{error_rate}} <= 0.1">
      <p>✅ Error rate is acceptable: {{error_rate}}%</p>
    </if>
    
    <if condition="{{environment}} != 'production'">
      <p>🚧 Non-production environment: {{environment}}</p>
    </if>
  </poml>
POML

context = {
  'response_time' => 750,
  'cpu_usage' => 85,
  'error_rate' => 0.05,
  'environment' => 'staging'
}
```

Supported operators:

- `==` - Equal to
- `!=` - Not equal to  
- `>` - Greater than
- `>=` - Greater than or equal to
- `<` - Less than
- `<=` - Less than or equal to

### Boolean Conditions

```ruby
markup = <<~POML
  <poml>
    <role>DevOps Engineer</role>
    <task>Configure deployment</task>
    
    <if condition="{{enable_monitoring}}">
      <p>Enable monitoring and alerting systems.</p>
    </if>
    
    <if condition="!{{debug_mode}}">
      <p>Disable debug logging for production.</p>
    </if>
  </poml>
POML

context = {
  'enable_monitoring' => true,
  'debug_mode' => false
}
```

## Loops and Iteration

### Basic For Loops

Use `<for variable="" items="">` to iterate over arrays:

```ruby
markup = <<~POML
  <poml>
    <role>API Documentation Writer</role>
    <task>Document API endpoints</task>
    
    <p>Available endpoints:</p>
    <list>
      <for variable="endpoint" items="{{endpoints}}">
        <item><b>{{endpoint.method}} {{endpoint.path}}</b> - {{endpoint.description}}</item>
      </for>
    </list>
  </poml>
POML

context = {
  'endpoints' => [
    { 'method' => 'GET', 'path' => '/users', 'description' => 'List all users' },
    { 'method' => 'POST', 'path' => '/users', 'description' => 'Create new user' },
    { 'method' => 'PUT', 'path' => '/users/:id', 'description' => 'Update user' },
    { 'method' => 'DELETE', 'path' => '/users/:id', 'description' => 'Delete user' }
  ]
}

result = Poml.process(markup: markup, context: context)
```

### Simple Array Iteration

For simple arrays, use `{{.}}` to reference the current item:

```ruby
markup = <<~POML
  <poml>
    <role>Tech Lead</role>
    <task>Review technology stack</task>
    
    <p>Current technologies:</p>
    <list>
      <for variable="tech" items="{{technologies}}">
        <item>{{.}}</item>
      </for>
    </list>
  </poml>
POML

context = {
  'technologies' => ['Ruby on Rails', 'PostgreSQL', 'Redis', 'Docker', 'AWS']
}
```

### Nested Loops

```ruby
markup = <<~POML
  <poml>
    <role>Test Engineer</role>
    <task>Create test plan</task>
    
    <for variable="feature" items="{{features}}">
      <p><b>Feature: {{feature.name}}</b></p>
      <list>
        <for variable="test" items="{{feature.tests}}">
          <item>{{test.type}}: {{test.description}}</item>
        </for>
      </list>
    </for>
  </poml>
POML

context = {
  'features' => [
    {
      'name' => 'User Authentication',
      'tests' => [
        { 'type' => 'Unit', 'description' => 'Test password validation' },
        { 'type' => 'Integration', 'description' => 'Test login flow' }
      ]
    },
    {
      'name' => 'Data Export',
      'tests' => [
        { 'type' => 'Unit', 'description' => 'Test CSV generation' },
        { 'type' => 'E2E', 'description' => 'Test complete export workflow' }
      ]
    }
  ]
}
```

## Combining Conditionals and Loops

### Conditional Lists

```ruby
markup = <<~POML
  <poml>
    <role>Release Manager</role>
    <task>Prepare release notes</task>
    
    <if condition="{{bug_fixes}}">
      <p><b>Bug Fixes:</b></p>
      <list>
        <for variable="fix" items="{{bug_fixes}}">
          <item>{{fix.description}} ({{fix.ticket}})</item>
        </for>
      </list>
    </if>
    
    <if condition="{{new_features}}">
      <p><b>New Features:</b></p>
      <list>
        <for variable="feature" items="{{new_features}}">
          <item>{{feature.name}} - {{feature.description}}</item>
        </for>
      </list>
    </if>
  </poml>
POML

context = {
  'bug_fixes' => [
    { 'description' => 'Fixed login timeout issue', 'ticket' => 'BUG-123' },
    { 'description' => 'Resolved data export corruption', 'ticket' => 'BUG-124' }
  ],
  'new_features' => [
    { 'name' => 'Dark Mode', 'description' => 'Added dark theme support' },
    { 'name' => 'API Rate Limiting', 'description' => 'Implemented request throttling' }
  ]
}
```

### Conditional Content Within Loops

```ruby
markup = <<~POML
  <poml>
    <role>Code Reviewer</role>
    <task>Review code changes</task>
    
    <p>Files Changed:</p>
    <list>
      <for variable="file" items="{{changed_files}}">
        <item>
          <b>{{file.path}}</b>
          <if condition="{{file.lines_added}} > 100">
            ⚠️ Large change: +{{file.lines_added}} lines
          </if>
          <if condition="{{file.complexity}} == 'high'">
            🔍 High complexity - needs careful review
          </if>
        </item>
      </for>
    </list>
  </poml>
POML

context = {
  'changed_files' => [
    { 'path' => 'app/models/user.rb', 'lines_added' => 45, 'complexity' => 'medium' },
    { 'path' => 'app/services/payment_processor.rb', 'lines_added' => 150, 'complexity' => 'high' },
    { 'path' => 'config/routes.rb', 'lines_added' => 5, 'complexity' => 'low' }
  ]
}
```

## Advanced Template Patterns

### Dynamic Role Assignment

```ruby
markup = <<~POML
  <poml>
    <role>
      <if condition="{{user_level}} == 'beginner'">Friendly Tutor</if>
      <if condition="{{user_level}} == 'intermediate'">Technical Mentor</if>
      <if condition="{{user_level}} == 'expert'">Peer Reviewer</if>
    </role>
    
    <task>{{task_description}}</task>
    
    <if condition="{{user_level}} == 'beginner'">
      <hint>Provide detailed explanations and examples</hint>
    </if>
    <if condition="{{user_level}} == 'expert'">
      <hint>Focus on edge cases and performance considerations</hint>
    </if>
  </poml>
POML
```

### Template Composition

```ruby
def create_review_prompt(review_type, language, complexity)
  markup = <<~POML
    <poml>
      <meta variables='{"review_type": "#{review_type}", "language": "#{language}"}' />
      
      <role>Senior {{language}} Developer</role>
      <task>Perform {{review_type}} review</task>
      
      <if condition="{{review_type}} == 'security'">
        <p>Security Review Checklist:</p>
        <list>
          <item>Input validation and sanitization</item>
          <item>Authentication and authorization</item>
          <item>Data encryption and storage</item>
          <item>Dependency vulnerabilities</item>
        </list>
      </if>
      
      <if condition="{{review_type}} == 'performance'">
        <p>Performance Review Checklist:</p>
        <list>
          <item>Algorithm complexity analysis</item>
          <item>Database query optimization</item>
          <item>Memory usage patterns</item>
          <item>Caching strategies</item>
        </list>
      </if>
      
      <if condition="{{review_type}} == 'code_quality'">
        <p>Code Quality Review Checklist:</p>
        <list>
          <item>Code readability and maintainability</item>
          <item>Design patterns and architecture</item>
          <item>Test coverage and quality</item>
          <item>Documentation completeness</item>
        </list>
      </if>
    </poml>
  POML

  context = { 'complexity' => complexity }
  Poml.process(markup: markup, context: context)
end

# Usage
security_prompt = create_review_prompt('security', 'Ruby', 'high')
performance_prompt = create_review_prompt('performance', 'Python', 'medium')
```

## Error Handling in Templates

### Safe Variable Access

```ruby
markup = <<~POML
  <poml>
    <role>Data Analyst</role>
    <task>Generate report</task>
    
    <if condition="{{report_data}}">
      <p>Processing {{report_data.length}} records...</p>
      
      <if condition="{{report_data.length}} > 1000">
        <hint>Large dataset - consider sampling for initial analysis</hint>
      </if>
    </if>
    
    <if condition="!{{report_data}}">
      <p>⚠️ No data available for analysis</p>
    </if>
  </poml>
POML
```

### Default Values

```ruby
def safe_template_processing(markup, context = {})
  # Provide default values
  defaults = {
    'environment' => 'development',
    'debug_mode' => true,
    'timeout' => 30
  }
  
  final_context = defaults.merge(context)
  Poml.process(markup: markup, context: final_context)
end
```

## Performance Considerations

### Template Caching

```ruby
class TemplateProcessor
  def initialize
    @template_cache = {}
    @result_cache = {}
  end
  
  def process_with_cache(template_key, markup, context)
    # Cache compiled templates
    @template_cache[template_key] ||= markup
    
    # Cache results for identical context
    cache_key = "#{template_key}:#{context.hash}"
    @result_cache[cache_key] ||= Poml.process(
      markup: @template_cache[template_key],
      context: context
    )
  end
end
```

### Large Dataset Handling

```ruby
markup = <<~POML
  <poml>
    <role>Data Processor</role>
    <task>Process dataset</task>
    
    <if condition="{{items.length}} > 100">
      <p>Large dataset detected ({{items.length}} items)</p>
      <hint>Consider batch processing or pagination</hint>
    </if>
    
    <p>Sample items:</p>
    <list>
      <for variable="item" items="{{items}}">
        <if condition="{{item.index}} < 5">
          <item>{{item.name}} - {{item.value}}</item>
        </if>
      </for>
    </list>
  </poml>
POML
```

## Next Steps

- Learn about [Output Formats](output-formats.md) for different use cases
- Explore [Schema Components](components/schema-components.md) for structured data
- Check [Tool Registration](advanced/tool-registration.md) for AI tool integration
