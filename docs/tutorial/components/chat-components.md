# Chat Components

POML provides specialized components for creating structured AI conversations with proper role-based messaging.

## Overview

Chat components (`<ai>`, `<human>`, `<system>`) are designed to create structured conversation flows that work seamlessly across different AI platforms and output formats.

## System Component

The `<system>` component defines system-level instructions and context:

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <system>
      You are a helpful assistant specializing in Ruby programming. 
      Provide clear, practical solutions with code examples.
      Always explain your reasoning and suggest best practices.
    </system>
  </poml>
POML

result = Poml.process(markup: markup, format: 'openai_chat')
puts JSON.pretty_generate(result)
```

Output:

```json
[
  {
    "role": "system",
    "content": "You are a helpful assistant specializing in Ruby programming..."
  }
]
```

## Human Component

The `<human>` component represents user messages and queries:

```ruby
markup = <<~POML
  <poml>
    <system>You are a code review assistant.</system>
    
    <human>
      Please review this Ruby method for potential improvements:
      
      <code>
def calculate_total(items)
  total = 0
  items.each do |item|
    total += item.price * item.quantity
  end
  total
end
      </code>
    </human>
  </poml>
POML

result = Poml.process(markup: markup, format: 'openai_chat')
```

## AI Component

The `<ai>` component represents assistant responses and can be used for few-shot examples:

```ruby
markup = <<~POML
  <poml>
    <system>You are a Ruby expert providing code reviews.</system>
    
    <human>How can I optimize this method?</human>
    
    <ai>
      Here's an optimized version using Ruby's built-in methods:
      
      <code>
def calculate_total(items)
  items.sum { |item| item.price * item.quantity }
end
      </code>
      
      This approach is more idiomatic and efficient.
    </ai>
    
    <human>Now please review this new code I've written:</human>
  </poml>
POML

result = Poml.process(markup: markup, format: 'openai_chat')
```

## Multi-Turn Conversations

Create complex conversation flows with multiple exchanges:

```ruby
markup = <<~POML
  <poml>
    <system>
      You are a technical interviewer conducting a Ruby programming interview.
      Ask progressive questions to assess the candidate's knowledge.
    </system>
    
    <human>I'm ready for the Ruby interview questions.</human>
    
    <ai>
      Great! Let's start with a basic question:
      
      What's the difference between a class method and an instance method in Ruby? 
      Can you provide examples of each?
    </ai>
    
    <human>
      A class method is called on the class itself, while an instance method 
      is called on an instance of the class. 
      
      Class method: `User.find_by_email(email)`
      Instance method: `user.save`
    </human>
    
    <ai>
      Excellent! Now let's dive deeper. Can you explain how Ruby's method 
      lookup chain works? What happens when you call a method on an object?
    </ai>
    
    <human>{{candidate_response}}</human>
  </poml>
POML

context = {
  'candidate_response' => 'Please explain the method lookup process...'
}

result = Poml.process(markup: markup, context: context, format: 'openai_chat')
```

## Chat Components with Formatting

Chat components support nested formatting and structure:

```ruby
markup = <<~POML
  <poml>
    <system>You are a code documentation assistant.</system>
    
    <human>
      Please document this API endpoint:
      
      <list>
        <item><b>Method:</b> POST</item>
        <item><b>Path:</b> /api/users</item>
        <item><b>Purpose:</b> Create new user account</item>
      </list>
    </human>
    
    <ai>
      I'll create comprehensive documentation for this endpoint:
      
      <h2>POST /api/users</h2>
      
      <p><b>Description:</b> Creates a new user account in the system.</p>
      
      <p><b>Request Body:</b></p>
      <code>
{
  "name": "string (required)",
  "email": "string (required, unique)",
  "password": "string (required, min 8 chars)"
}
      </code>
      
      <p><b>Response Codes:</b></p>
      <list>
        <item><code>201</code> - User created successfully</item>
        <item><code>400</code> - Validation errors</item>
        <item><code>409</code> - Email already exists</item>
      </list>
    </ai>
  </poml>
POML

result = Poml.process(markup: markup, format: 'raw')
```

## Template Variables in Chat

Use template variables within chat components:

```ruby
markup = <<~POML
  <poml>
    <system>
      You are a {{expertise_area}} expert helping with {{project_type}} projects.
      Provide detailed, practical guidance based on industry best practices.
    </system>
    
    <human>
      I'm working on a {{project_type}} and need help with {{specific_issue}}.
      
      <p>Project Details:</p>
      <list>
        <item>Technology: {{technology_stack}}</item>
        <item>Timeline: {{timeline}}</item>
        <item>Team Size: {{team_size}}</item>
      </list>
    </human>
  </poml>
POML

context = {
  'expertise_area' => 'DevOps',
  'project_type' => 'microservices deployment',
  'specific_issue' => 'container orchestration',
  'technology_stack' => 'Docker + Kubernetes',
  'timeline' => '3 months',
  'team_size' => '5 developers'
}

result = Poml.process(markup: markup, context: context, format: 'openai_chat')
```

## Conditional Chat Content

Use conditionals to create dynamic conversation flows:

```ruby
markup = <<~POML
  <poml>
    <system>You are a debugging assistant.</system>
    
    <human>I'm having an issue with my {{language}} code.</human>
    
    <ai>
      I'd be happy to help you debug your {{language}} code!
      
      <if condition="{{language}} == 'Ruby'">
        <p>For Ruby issues, I'll need to see:</p>
        <list>
          <item>The Ruby version you're using</item>
          <item>Your Gemfile (if applicable)</item>
          <item>The specific error message</item>
          <item>The problematic code snippet</item>
        </list>
      </if>
      
      <if condition="{{language}} == 'Python'">
        <p>For Python issues, please provide:</p>
        <list>
          <item>Python version and virtual environment info</item>
          <item>requirements.txt or pip freeze output</item>
          <item>Full traceback of the error</item>
          <item>Minimal code to reproduce the issue</item>
        </list>
      </if>
      
      <p>Please share these details and I'll help you solve the problem.</p>
    </ai>
  </poml>
POML

context = { 'language' => 'Ruby' }
result = Poml.process(markup: markup, context: context, format: 'raw')
```

## Output Format Behavior

Chat components behave differently based on the output format:

### OpenAI Chat Format

```ruby
markup = <<~POML
  <poml>
    <system>You are a helpful assistant.</system>
    <human>What is Ruby?</human>
  </poml>
POML

result = Poml.process(markup: markup, format: 'openai_chat')
# Returns: [{"role": "system", "content": "..."}, {"role": "user", "content": "..."}]
```

### Raw Format

```ruby
result = Poml.process(markup: markup, format: 'raw')
# Returns: Text with role boundaries like "===== system ====="
```

### LangChain Format

```ruby
result = Poml.process(markup: markup, format: 'langchain')
# Returns: LangChain-compatible message structure
```

## Advanced Chat Patterns

### Interview Flow

```ruby
markup = <<~POML
  <poml>
    <system>
      You are conducting a technical interview for a {{position}} role.
      Ask progressive questions starting from basic concepts to advanced topics.
      Provide feedback and follow-up questions based on responses.
    </system>
    
    <human>I'm ready to begin the {{position}} interview.</human>
    
    <ai>
      Welcome to the {{position}} interview! Let's start with some foundational questions.
      
      <p><b>Question 1:</b> {{first_question}}</p>
      
      <p>Take your time to explain your thought process.</p>
    </ai>
    
    <human>{{candidate_answer_1}}</human>
    
    <ai>
      <if condition="{{question_difficulty}} == 'basic'">
        Good start! Now let's move to something more challenging.
      </if>
      
      <if condition="{{question_difficulty}} == 'advanced'">
        Excellent answer! You clearly understand the concepts well.
      </if>
      
      <p><b>Follow-up:</b> {{follow_up_question}}</p>
    </ai>
  </poml>
POML
```

### Debugging Session

```ruby
markup = <<~POML
  <poml>
    <system>
      You are a senior developer helping debug a complex issue.
      Guide the user through systematic debugging steps.
    </system>
    
    <human>
      I'm getting this error in production:
      
      <code>{{error_message}}</code>
      
      It happens intermittently and I can't reproduce it locally.
    </human>
    
    <ai>
      Intermittent production-only errors can be tricky! Let's debug this systematically.
      
      <p><b>First, let's gather information:</b></p>
      <list>
        <item>What's the frequency of this error?</item>
        <item>Are there any patterns in timing or user actions?</item>
        <item>What are the differences between your local and production environments?</item>
        <item>Do you have logging around the error location?</item>
      </list>
      
      <p>Based on the error message, here are some initial hypotheses:</p>
      
      <if condition="{{error_type}} == 'timeout'">
        <list>
          <item>Database connection pooling issues</item>
          <item>External API timeouts</item>
          <item>Load-related performance degradation</item>
        </list>
      </if>
      
      <if condition="{{error_type}} == 'memory'">
        <list>
          <item>Memory leaks in long-running processes</item>
          <item>Large dataset processing without pagination</item>
          <item>Inefficient caching strategies</item>
        </list>
      </if>
    </ai>
  </poml>
POML
```

### Code Review Conversation

```ruby
markup = <<~POML
  <poml>
    <system>
      You are a senior developer conducting a code review.
      Provide constructive feedback focusing on maintainability, performance, and best practices.
    </system>
    
    <human>
      Here's my implementation for the user authentication system:
      
      <code>{{code_submission}}</code>
      
      I'm particularly concerned about security and performance.
    </human>
    
    <ai>
      Thanks for submitting this code! I'll review it focusing on security and performance as requested.
      
      <p><b>Overall Assessment:</b> {{overall_assessment}}</p>
      
      <p><b>Security Review:</b></p>
      <list>
        <for variable="security_issue" items="{{security_issues}}">
          <item><b>{{security_issue.severity}}:</b> {{security_issue.description}}</item>
        </for>
      </list>
      
      <p><b>Performance Considerations:</b></p>
      <list>
        <for variable="perf_issue" items="{{performance_issues}}">
          <item>{{perf_issue.description}} - <i>{{perf_issue.solution}}</i></item>
        </for>
      </list>
      
      <p><b>Recommended Changes:</b></p>
      <code>{{suggested_improvements}}</code>
      
      <p>Would you like me to explain any of these recommendations in more detail?</p>
    </ai>
  </poml>
POML
```

## Best Practices

### 1. Clear Role Definition

```ruby
# Good
<system>
  You are a Ruby on Rails expert with 10+ years of experience.
  Provide practical, production-ready solutions with security considerations.
</system>

# Better
<system>
  You are a Senior Ruby on Rails Developer and Technical Lead specializing in:
  - Performance optimization and scaling
  - Security best practices and compliance
  - Code architecture and maintainability
  
  Always provide working code examples and explain trade-offs.
</system>
```

### 2. Structured Conversations

```ruby
# Structure conversations logically
<system>Context and role definition</system>
<human>Initial request or question</human>
<ai>Example response (for few-shot learning)</ai>
<human>Actual user input</human>
```

### 3. Use Formatting for Clarity

```ruby
<human>
  <p>I need help with this problem:</p>
  
  <p><b>Context:</b> {{context}}</p>
  <p><b>Goal:</b> {{goal}}</p>
  <p><b>Constraints:</b> {{constraints}}</p>
  
  <p>Current code:</p>
  <code>{{current_code}}</code>
</human>
```

### 4. Error Handling

```ruby
def safe_chat_processing(markup, context = {})
  begin
    result = Poml.process(markup: markup, context: context, format: 'openai_chat')
    
    # Validate chat structure
    if result.is_a?(Array) && result.all? { |msg| msg.is_a?(Hash) && msg['role'] && msg['content'] }
      { success: true, messages: result }
    else
      { success: false, error: 'Invalid chat structure' }
    end
  rescue => e
    { success: false, error: e.message }
  end
end
```

## Integration with AI Services

### OpenAI API

```ruby
require 'net/http'
require 'json'

def send_to_openai(poml_markup, context = {})
  messages = Poml.process(
    markup: poml_markup, 
    context: context, 
    format: 'openai_chat'
  )
  
  payload = {
    model: 'gpt-4',
    messages: messages,
    max_tokens: 1000,
    temperature: 0.7
  }
  
  # Send to OpenAI API...
end
```

### Claude API

```ruby
def send_to_claude(poml_markup, context = {})
  # Convert to raw format for Claude
  prompt = Poml.process(
    markup: poml_markup,
    context: context,
    format: 'raw'
  )
  
  # Send to Claude API...
end
```

## Next Steps

- Learn about [Output Formats](../output-formats.md) for different AI services
- Explore [Schema Components](schema-components.md) for structured responses
- Check [Integration Examples](../integration/rails.md) for real-world usage
