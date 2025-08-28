# Basic Usage

This guide covers the fundamental concepts and syntax of POML for creating structured AI prompts.

## Core Concepts

### POML Structure

Every POML document is wrapped in a `<poml>` tag and contains components that define the prompt structure:

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>Assistant</role>
    <task>Help users with questions</task>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['content']
```

### Basic Components

#### Role Component

Defines the AI's role and expertise:

```ruby
markup = <<~POML
  <poml>
    <role>Expert Ruby Developer</role>
    <task>Review code for best practices</task>
  </poml>
POML
```

#### Task Component

Specifies what the AI should accomplish:

```ruby
markup = <<~POML
  <poml>
    <role>Technical Writer</role>
    <task>Create API documentation for the user management endpoints</task>
  </poml>
POML
```

#### Hint Component

Provides additional guidance:

```ruby
markup = <<~POML
  <poml>
    <role>Code Reviewer</role>
    <task>Analyze the following Ruby code</task>
    <hint>Focus on performance, security, and maintainability</hint>
  </poml>
POML
```

### Text Structure

#### Paragraphs

Use `<p>` tags for structured text content:

```ruby
markup = <<~POML
  <poml>
    <role>Product Manager</role>
    <task>Create a feature specification</task>
    
    <p>The new user authentication system should include:</p>
    <p>Please provide detailed requirements and acceptance criteria.</p>
  </poml>
POML
```

#### Lists

Create structured lists with `<list>` and `<item>`:

```ruby
markup = <<~POML
  <poml>
    <role>Software Architect</role>
    <task>Design system architecture</task>
    
    <p>Consider these requirements:</p>
    <list>
      <item>Scalability for 10,000+ concurrent users</item>
      <item>High availability with 99.9% uptime</item>
      <item>Security compliance (SOC 2, GDPR)</item>
      <item>Cost optimization for cloud deployment</item>
    </list>
  </poml>
POML
```

### Text Formatting

POML supports various text formatting components:

```ruby
markup = <<~POML
  <poml>
    <role>Technical Writer</role>
    <task>Document the API endpoint</task>
    
    <p>The <b>POST /users</b> endpoint creates a new user account.</p>
    <p>Required fields: <code>email</code>, <code>password</code>, and <code>name</code>.</p>
    <p><i>Note</i>: Password must be at least 8 characters.</p>
    <p><u>Important</u>: Email must be unique in the system.</p>
  </poml>
POML
```

Available formatting components:

- `<b>text</b>` - **Bold text**
- `<i>text</i>` - *Italic text*  
- `<u>text</u>` - **Underlined text**
- `<s>text</s>` - ~~Strikethrough text~~
- `<code>text</code>` - `Inline code`
- `<h1>` to `<h6>` - Headers
- `<br>` - Line breaks

### Processing POML

#### Basic Processing

```ruby
require 'poml'

# From string
markup = '<poml><role>Assistant</role><task>Help users</task></poml>'
result = Poml.process(markup: markup)

puts result['content']    # The formatted prompt
puts result['metadata']   # Additional metadata
```

#### From File

```ruby
# From file
result = Poml.process(markup: 'path/to/prompt.poml')
```

#### With Context

```ruby
# With variables
markup = <<~POML
  <poml>
    <role>{{expert_type}} Expert</role>
    <task>{{main_task}}</task>
  </poml>
POML

context = {
  'expert_type' => 'Database',
  'main_task' => 'Optimize query performance'
}

result = Poml.process(markup: markup, context: context)
```

### Output Structure

The default output is a Hash with:

```ruby
result = Poml.process(markup: markup)

# Available keys:
result['content']     # The formatted prompt text
result['metadata']    # Hash with additional information
result['variables']   # Template variables used
result['schemas']     # Any output schemas defined
result['tools']       # Any tools registered
```

### Metadata

Every POML document includes metadata:

```ruby
result = Poml.process(markup: markup)
metadata = result['metadata']

puts metadata['chat']        # true/false - whether chat mode is enabled
puts metadata['variables']   # Hash of template variables
puts metadata['schemas']     # Array of output schemas
puts metadata['tools']       # Array of tool definitions
```

### Error Handling

POML provides graceful error handling:

```ruby
begin
  result = Poml.process(markup: invalid_markup)
rescue Poml::Error => e
  puts "POML Error: #{e.message}"
rescue StandardError => e
  puts "System Error: #{e.message}"
end
```

## Best Practices

### 1. Use Descriptive Roles

```ruby
# Good
<role>Senior Ruby Developer with 10+ years experience</role>

# Better  
<role>Senior Ruby Developer specializing in Rails performance optimization</role>
```

### 2. Be Specific in Tasks

```ruby
# Good
<task>Review code</task>

# Better
<task>Review the authentication module for security vulnerabilities and performance issues</task>
```

### 3. Structure Content Logically

```ruby
markup = <<~POML
  <poml>
    <role>System Analyst</role>
    <task>Analyze the proposed system architecture</task>
    
    <p>Architecture Overview:</p>
    <!-- Main content here -->
    
    <p>Specific Analysis Areas:</p>
    <list>
      <item>Performance characteristics</item>
      <item>Security considerations</item>
      <item>Scalability potential</item>
    </list>
    
    <hint>Provide concrete recommendations with implementation steps</hint>
  </poml>
POML
```

### 4. Use Comments for Documentation

```ruby
markup = <<~POML
  <poml>
    <!-- This prompt is used for code review automation -->
    <role>Senior Developer</role>
    <task>Review pull request changes</task>
    
    <!-- Context will be provided by the CI system -->
    <p>Changes to review: {{changes_summary}}</p>
  </poml>
POML
```

## Next Steps

- Learn about [Output Formats](output-formats.md) for different integration scenarios
- Explore [Template Engine](template-engine.md) for dynamic content generation
- Check [Components Reference](components/index.md) for all available components

## Common Patterns

### API Documentation

```ruby
markup = <<~POML
  <poml>
    <role>API Documentation Specialist</role>
    <task>Create comprehensive documentation for the {{endpoint_name}} endpoint</task>
    
    <p>Include the following sections:</p>
    <list>
      <item>Endpoint description and purpose</item>
      <item>Request parameters and validation rules</item>
      <item>Response format and status codes</item>
      <item>Example requests and responses</item>
      <item>Error handling scenarios</item>
    </list>
    
    <hint>Use clear examples and focus on developer experience</hint>
  </poml>
POML
```

### Code Review

```ruby
markup = <<~POML
  <poml>
    <role>Senior {{language}} Developer</role>
    <task>Perform thorough code review</task>
    
    <p>Review Focus Areas:</p>
    <list>
      <item><b>Code Quality</b>: Readability, maintainability, and style</item>
      <item><b>Performance</b>: Efficiency and optimization opportunities</item>
      <item><b>Security</b>: Vulnerability assessment and best practices</item>
      <item><b>Testing</b>: Test coverage and quality</item>
    </list>
    
    <hint>Provide specific, actionable feedback with examples</hint>
  </poml>
POML
```

### Content Generation

```ruby
markup = <<~POML
  <poml>
    <role>{{content_type}} Writer</role>
    <task>Create engaging {{content_type}} about {{topic}}</task>
    
    <p>Target Audience: {{audience}}</p>
    <p>Tone: {{tone}}</p>
    <p>Length: Approximately {{word_count}} words</p>
    
    <p>Key Points to Cover:</p>
    <list>
      {{#key_points}}
      <item>{{.}}</item>
      {{/key_points}}
    </list>
    
    <hint>Make it engaging, informative, and actionable</hint>
  </poml>
POML
```
