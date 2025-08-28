# POML Ruby Gem - Comprehensive Tutorial

This tutorial provides detailed examples and practical use cases for using the POML Ruby gem in your applications.

## Table of Contents

- [Basic Usage](#basic-usage)
- [Output Formats](#output-formats)
- [Template Variables](#template-variables)
- [Stylesheets](#stylesheets)
- [Working with Files](#working-with-files)
- [Image Components](#image-components)
- [Inline Rendering](#inline-rendering)
- [Advanced Components](#advanced-components)
- [Error Handling](#error-handling)
- [Integration Examples](#integration-examples)
- [Best Practices](#best-practices)

## Basic Usage

### Simple Prompt Creation

```ruby
require 'poml'

# Basic role and task
markup = '<poml><role>Assistant</role><task>Help users with questions</task></poml>'
result = Poml.process(markup: markup)

puts result['content']
# Output: Raw text with role and task formatted
```

### Adding Hints and Context

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>Expert Data Scientist</role>
    <task>Analyze the provided dataset and identify trends</task>
    <hint>Focus on seasonal patterns and anomalies</hint>
    <p>Please provide detailed insights with visualizations.</p>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['content']
```

### Using Paragraphs and Structure

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>Technical Writer</role>
    <task>Create documentation</task>
    
    <p>Write clear and concise documentation for the following API endpoints:</p>
    
    <list>
      <item>GET /users - Retrieve user list</item>
      <item>POST /users - Create new user</item>
      <item>PUT /users/:id - Update user</item>
      <item>DELETE /users/:id - Delete user</item>
    </list>
    
    <p>Include examples and error handling for each endpoint.</p>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['content']
```

## Output Formats

### Raw Format

Perfect for direct use with AI APIs or when you need plain text output:

```ruby
require 'poml'

markup = '<poml><role>Assistant</role><task>Summarize this text</task></poml>'
result = Poml.process(markup: markup, format: 'raw')

puts result
# Output: Plain text with message boundaries
# ===== system =====
# 
# # Role
# 
# Assistant
# 
# # Task
# 
# Summarize this text
```

### Dictionary Format (Default)

Best for Ruby applications that need structured data:

```ruby
require 'poml'

markup = '<poml><role>Assistant</role><task>Help users</task></poml>'
result = Poml.process(markup: markup, format: 'dict')

puts result.class  # Hash
puts result['content']  # The formatted content
puts result['metadata']['chat']  # true
puts result['metadata']['variables']  # {}
```

### OpenAI Chat Format

Perfect for integration with OpenAI API:

```ruby
require 'poml'
require 'json'

markup = <<~POML
  <poml>
    <role>Helpful assistant specialized in Ruby programming</role>
    <task>Help debug Ruby code and suggest improvements</task>
  </poml>
POML

messages = Poml.process(markup: markup, format: 'openai_chat')

# Use with OpenAI API
require 'net/http'
require 'uri'

payload = {
  model: 'gpt-4',
  messages: messages,
  max_tokens: 1000
}

# Send to OpenAI API (example)
puts JSON.pretty_generate(payload)
```

### LangChain Format

Useful for LangChain-compatible applications:

```ruby
require 'poml'

markup = '<poml><role>SQL Expert</role><task>Help write database queries</task></poml>'
result = Poml.process(markup: markup, format: 'langchain')

puts result['messages']  # Array of message objects
puts result['content']   # Raw content string
```

### OpenAI Response Format

Perfect for AI model integration with standardized response structure:

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>Data Analyst</role>
    <task>Analyze the provided dataset and generate insights</task>
    <schema name="AnalysisResult">
    {
      "type": "object",
      "properties": {
        "insights": {"type": "array", "items": {"type": "string"}},
        "confidence": {"type": "number"}
      }
    }
    </schema>
  </poml>
POML

result = Poml.process(markup: markup, format: 'openaiResponse')

puts result['content']    # The formatted prompt content
puts result['type']       # Response type
puts result['metadata']   # Includes schemas, variables, tools, etc.
```

### Enhanced Pydantic Format

Returns comprehensive structure with Python interoperability features:

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>Code Reviewer</role>
    <task>Review Ruby code for best practices</task>
    <meta title="Code Review Session" author="AI Assistant"/>
    <schema name="ReviewResult">
    {
      "type": "object",
      "properties": {
        "issues": {"type": "array", "items": {"type": "string"}},
        "suggestions": {"type": "array", "items": {"type": "string"}},
        "score": {"type": "integer", "minimum": 1, "maximum": 10}
      }
    }
    </schema>
  </poml>
POML

result = Poml.process(markup: markup, format: 'pydantic')

puts result['content']          # The formatted prompt
puts result['variables']        # Template variables used
puts result['chat_enabled']     # Whether chat mode is enabled
puts result['schemas']          # Array of strict JSON schemas
puts result['custom_metadata']  # Metadata from meta components
puts result['metadata']         # Format metadata with Python compatibility info
```

## Template Variables

### Basic Variable Substitution

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

### Dynamic Content with Variables

```ruby
require 'poml'

def create_code_review_prompt(language, complexity, focus_areas)
  markup = <<~POML
    <poml>
      <role>Senior {{language}} Developer</role>
      <task>Review the following {{language}} code</task>
      
      <p>Code complexity level: {{complexity}}</p>
      
      <p>Please focus on:</p>
      <list>
        {{#focus_areas}}
        <item>{{.}}</item>
        {{/focus_areas}}
      </list>
      
      <hint>Provide specific suggestions for improvement</hint>
    </poml>
  POML

  context = {
    'language' => language,
    'complexity' => complexity,
    'focus_areas' => focus_areas
  }

  Poml.process(markup: markup, context: context, format: 'raw')
end

# Usage
prompt = create_code_review_prompt(
  'Ruby', 
  'Intermediate',
  ['Performance', 'Readability', 'Security', 'Testing']
)

puts prompt
```

### Conditional Content

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>{{role_type}}</role>
    <task>{{task_description}}</task>
    
    {{#include_examples}}
    <p>Please include practical examples in your response.</p>
    {{/include_examples}}
    
    {{#urgency_level}}
    <hint>This is {{urgency_level}} priority - respond accordingly</hint>
    {{/urgency_level}}
  </poml>
POML

# High priority with examples
context = {
  'role_type' => 'Emergency Response Coordinator',
  'task_description' => 'Coordinate disaster response',
  'include_examples' => true,
  'urgency_level' => 'HIGH'
}

result = Poml.process(markup: markup, context: context)
puts result['content']
```

## Stylesheets

### Custom Component Styling

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>API Documentation Writer</role>
    <task>Document REST endpoints</task>
    
    <cp caption="Authentication">
      <p>All requests require authentication via API key.</p>
    </cp>
    
    <cp caption="Rate Limiting">
      <p>API calls are limited to 1000 requests per hour.</p>
    </cp>
  </poml>
POML

stylesheet = {
  'role' => {
    'captionStyle' => 'bold',
    'caption' => 'System Role'
  },
  'cp' => {
    'captionStyle' => 'header'
  }
}

result = Poml.process(markup: markup, stylesheet: stylesheet)
puts result['content']
```

### Dynamic Styling

```ruby
require 'poml'

def create_styled_prompt(style_type = 'professional')
  markup = <<~POML
    <poml>
      <role>Technical Consultant</role>
      <task>Provide technical recommendations</task>
      
      <cp caption="Analysis">
        <p>Detailed technical analysis follows.</p>
      </cp>
      
      <cp caption="Recommendations">
        <p>Actionable recommendations based on analysis.</p>
      </cp>
    </poml>
  POML

  stylesheets = {
    'professional' => {
      'cp' => { 'captionStyle' => 'header' },
      'role' => { 'captionStyle' => 'bold' }
    },
    'casual' => {
      'cp' => { 'captionStyle' => 'plain' },
      'role' => { 'captionStyle' => 'plain' }
    },
    'minimal' => {
      'cp' => { 'captionStyle' => 'hidden' },
      'role' => { 'captionStyle' => 'hidden' }
    }
  }

  Poml.process(
    markup: markup, 
    stylesheet: stylesheets[style_type],
    format: 'raw'
  )
end

# Different styles
puts "=== PROFESSIONAL STYLE ==="
puts create_styled_prompt('professional')

puts "\n=== CASUAL STYLE ==="
puts create_styled_prompt('casual')

puts "\n=== MINIMAL STYLE ==="
puts create_styled_prompt('minimal')
```

## Working with Files

### Loading POML from Files

```ruby
require 'poml'

# Assuming you have a file 'prompts/code_review.poml'
result = Poml.process(markup: 'prompts/code_review.poml')
puts result['content']
```

### Saving Output to Files

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>Report Generator</role>
    <task>Generate monthly performance report</task>
  </poml>
POML

# Save raw output
Poml.process(
  markup: markup, 
  format: 'raw',
  output_file: 'reports/prompt.txt'
)

# Save JSON output
result = Poml.process(markup: markup, format: 'openai_chat')
File.write('reports/messages.json', JSON.pretty_generate(result))
```

### Working with Context Files

```ruby
require 'poml'
require 'json'

# Create context file
context_data = {
  'project_name' => 'E-commerce Platform',
  'team_size' => 5,
  'deadline' => '2024-12-31',
  'technologies' => ['Ruby on Rails', 'PostgreSQL', 'Redis']
}

File.write('context.json', JSON.pretty_generate(context_data))

# Use context from file
markup = <<~POML
  <poml>
    <role>Project Manager</role>
    <task>Create project plan for {{project_name}}</task>
    
    <p>Team size: {{team_size}} developers</p>
    <p>Deadline: {{deadline}}</p>
    
    <p>Technology stack:</p>
    <list>
      {{#technologies}}
      <item>{{.}}</item>
      {{/technologies}}
    </list>
  </poml>
POML

# Load context from file
context = JSON.parse(File.read('context.json'))
result = Poml.process(markup: markup, context: context)
puts result['content']
```

## Image Components

The POML Ruby gem now supports comprehensive image handling including URL fetching, base64 encoding, and local file processing.

### Basic Image Usage

```ruby
require 'poml'

# Local image file
markup = <<~POML
  <poml>
    <role>Image Analysis Expert</role>
    <img src="charts/sales_data.png" alt="Sales Data Chart" />
    <p>Please analyze the trends shown in this chart.</p>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['content']
```

### Image from URL

```ruby
require 'poml'

# Remote image URL
markup = <<~POML
  <poml>
    <role>Visual Content Analyst</role>
    <img src="https://example.com/images/product.jpg" alt="Product Image" />
    <p>Analyze this product image for quality and features.</p>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['content']
```

### Base64 Encoded Images

```ruby
require 'poml'

# Embedded base64 image (small example - 1x1 transparent PNG)
base64_data = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAI9jU77zgAAAABJRU5ErkJggg=='

markup = <<~POML
  <poml>
    <role>Image Processor</role>
    <img base64="#{base64_data}" alt="Embedded Image" />
    <p>Process this embedded image data.</p>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['content']
```

### Advanced Image Processing

```ruby
require 'poml'

# Image with processing parameters
markup = <<~POML
  <poml>
    <role>Image Optimizer</role>
    <img src="https://example.com/large-image.jpg" 
         alt="Large Image" 
         maxWidth="800" 
         maxHeight="600" 
         resize="0.5" 
         type="png" 
         syntax="multimedia" />
    <p>Optimize and analyze this image.</p>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['content']
```

### XML Mode Image Rendering

```ruby
require 'poml'

markup = <<~POML
  <poml syntax="xml">
    <role>Image Cataloger</role>
    <img src="catalog/item001.jpg" 
         alt="Catalog Item 001" 
         position="top" 
         type="jpeg" />
    <p>Catalog this item with full metadata.</p>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['content']
```

### Error Handling for Images

```ruby
require 'poml'

def safe_image_processing(image_src, alt_text = '')
  markup = <<~POML
    <poml>
      <role>Safe Image Processor</role>
      <img src="#{image_src}" alt="#{alt_text}" />
      <p>Process this image safely with error handling.</p>
    </poml>
  POML

  begin
    result = Poml.process(markup: markup)
    { success: true, content: result['content'] }
  rescue => e
    { success: false, error: e.message, fallback: alt_text }
  end
end

# Usage examples
results = [
  safe_image_processing('valid-image.jpg', 'Valid Image'),
  safe_image_processing('https://example.com/image.png', 'Remote Image'),
  safe_image_processing('nonexistent.jpg', 'Missing Image'),
  safe_image_processing('invalid-url', 'Invalid Source')
]

results.each_with_index do |result, i|
  puts "Result #{i + 1}:"
  if result[:success]
    puts "SUCCESS: #{result[:content][0..100]}..."
  else
    puts "ERROR: #{result[:error]}"
    puts "FALLBACK: #{result[:fallback]}"
  end
  puts "-" * 50
end
```

### Image Component Attributes

The `<img>` component supports the following attributes:

- **src**: Local file path or HTTP(S) URL to the image
- **base64**: Base64-encoded image data (alternative to src)
- **alt**: Alternative text for accessibility and fallback
- **maxWidth**: Maximum width for resizing (pixels)
- **maxHeight**: Maximum height for resizing (pixels)
- **resize**: Resize factor (0.1 to 1.0)
- **type**: Target image format (jpeg, png, gif, webp)
- **syntax**: Display mode ('multimedia' or 'text')
- **position**: Image position ('top', 'bottom', 'here')

### Performance Considerations

```ruby
require 'poml'

# For better performance with multiple images
class ImageProcessor
  def initialize
    @cache = {}
  end

  def process_with_caching(markup, cache_key = nil)
    if cache_key && @cache[cache_key]
      return @cache[cache_key]
    end

    result = Poml.process(markup: markup)
    
    if cache_key
      @cache[cache_key] = result
    end

    result
  end

  def clear_cache
    @cache.clear
  end
end

# Usage
processor = ImageProcessor.new

# Process images with caching
result1 = processor.process_with_caching(
  '<poml><img src="large-image.jpg" alt="Chart" /></poml>',
  'chart_image'
)

result2 = processor.process_with_caching(
  '<poml><img src="large-image.jpg" alt="Chart" /></poml>',
  'chart_image'  # Will use cached result
)

puts "Results are identical: #{result1 == result2}"
```

## Inline Rendering

The POML Ruby gem supports inline rendering for components, allowing them to render seamlessly within text flow without extra whitespace or line breaks.

### Basic Inline Usage

```ruby
require 'poml'

# Block mode (default) - adds newlines and spacing
markup1 = <<~POML
  <poml>
    <p>The user wants to <b>emphasize</b> this word in the sentence.</p>
  </poml>
POML

# Inline mode - seamless text flow
markup2 = <<~POML
  <poml>
    <p>The user wants to <b inline="true">emphasize</b> this word in the sentence.</p>
  </poml>
POML

result1 = Poml.process(markup: markup1, format: 'raw')
result2 = Poml.process(markup: markup2, format: 'raw')

puts "Block mode:"
puts result1
puts "\nInline mode:"
puts result2
```

### Inline Tables and Data

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>Data Analyst</role>
    <p>The summary statistics are: <table inline="true" data='[{"metric": "avg", "value": 85.2}, {"metric": "max", "value": 97.8}]'></table> for this quarter.</p>
  </poml>
POML

result = Poml.process(markup: markup, format: 'raw')
puts result
```

### Inline Code Examples

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>Programming Tutor</role>
    <p>Use the <code inline="true">Array#map</code> method to transform each element, or <code inline="true">Array#select</code> to filter elements.</p>
  </poml>
POML

result = Poml.process(markup: markup, format: 'raw')
puts result
```

### Mixed Inline and Block Components

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>Technical Writer</role>
    <p>For configuration, you can use either <code inline="true">config.yml</code> or environment variables.</p>
    
    <p>Here's the complete configuration structure:</p>
    <code>
# config.yml
database:
  host: localhost
  port: 5432
    </code>
    
    <p>The <code inline="true">host</code> setting is required.</p>
  </poml>
POML

result = Poml.process(markup: markup, format: 'raw')
puts result
```

### Inline Rendering in XML Mode

```ruby
require 'poml'

markup = <<~POML
  <poml syntax="xml">
    <role>API Documentation Writer</role>
    <p>The endpoint <code inline="true">GET /api/users</code> returns user data, while <code inline="true">POST /api/users</code> creates new users.</p>
  </poml>
POML

result = Poml.process(markup: markup, format: 'raw')
puts result
```

## Advanced Components

### Examples and Input/Output Patterns

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>Code Generator</role>
    <task>Generate Ruby code based on examples</task>
    
    <example>
      <input>Create a User class with name and email</input>
      <output>
class User
  attr_accessor :name, :email
  
  def initialize(name, email)
    @name = name
    @email = email
  end
end
      </output>
    </example>
    
    <example>
      <input>Add validation to User class</input>
      <output>
class User
  attr_accessor :name, :email
  
  def initialize(name, email)
    @name = name
    @email = email
    validate!
  end
  
  private
  
  def validate!
    raise ArgumentError, "Name cannot be empty" if name.nil? || name.strip.empty?
    raise ArgumentError, "Invalid email format" unless email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end
end
      </output>
    </example>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['content']
```

### Including External Documents

```ruby
require 'poml'

# Assuming you have external files
markup = <<~POML
  <poml>
    <role>Code Reviewer</role>
    <task>Review the following code and suggest improvements</task>
    
    <Document src="examples/user_model.rb">
    </Document>
    
    <p>Please focus on:</p>
    <list>
      <item>Code organization</item>
      <item>Error handling</item>
      <item>Performance optimizations</item>
    </list>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['content']
```

### XML Syntax Mode

```ruby
require 'poml'

markup = <<~POML
  <poml syntax="xml">
    <role>System Architect</role>
    <cp caption="Requirements Analysis">
      <list>
        <item>Scalability requirements</item>
        <item>Performance benchmarks</item>
        <item>Security considerations</item>
      </list>
    </cp>
    
    <cp caption="Technical Recommendations">
      <p>Based on the analysis, recommend appropriate architecture.</p>
    </cp>
  </poml>
POML

result = Poml.process(markup: markup, format: 'raw')
puts result
```

## Error Handling

### Basic Error Handling

```ruby
require 'poml'

begin
  # Invalid markup
  result = Poml.process(markup: '<poml><invalid_tag>Content</invalid_tag></poml>')
rescue Poml::Error => e
  puts "POML Error: #{e.message}"
rescue StandardError => e
  puts "General Error: #{e.message}"
end
```

### Validating Markup Before Processing

```ruby
require 'poml'

def safe_process_poml(markup, options = {})
  # Basic validation
  return { error: "Empty markup" } if markup.nil? || markup.strip.empty?
  return { error: "Markup must contain <poml> tags" } unless markup.include?('<poml>')
  
  begin
    result = Poml.process(markup: markup, **options)
    { success: true, result: result }
  rescue Poml::Error => e
    { error: "POML processing error: #{e.message}" }
  rescue StandardError => e
    { error: "Unexpected error: #{e.message}" }
  end
end

# Usage
markup = '<poml><role>Assistant</role><task>Help users</task></poml>'
response = safe_process_poml(markup, format: 'raw')

if response[:success]
  puts "Success: #{response[:result]}"
else
  puts "Error: #{response[:error]}"
end
```

## Integration Examples

### Rails Application Integration

```ruby
# app/services/prompt_service.rb
class PromptService
  include Rails.application.routes.url_helpers
  
  def self.generate_ai_prompt(template_name, context = {})
    template_path = Rails.root.join('app', 'prompts', "#{template_name}.poml")
    
    unless File.exist?(template_path)
      raise ArgumentError, "Template #{template_name} not found"
    end
    
    markup = File.read(template_path)
    
    Poml.process(
      markup: markup,
      context: context,
      format: 'openai_chat'
    )
  end
  
  def self.create_support_prompt(user, issue_type, description)
    markup = <<~POML
      <poml>
        <role>Customer Support Specialist</role>
        <task>Help resolve {{issue_type}} for user {{user_name}}</task>
        
        <p>User Information:</p>
        <list>
          <item>Name: {{user_name}}</item>
          <item>Email: {{user_email}}</item>
          <item>Account Type: {{account_type}}</item>
        </list>
        
        <p>Issue Description:</p>
        <p>{{description}}</p>
        
        <hint>Be empathetic and provide step-by-step solutions</hint>
      </poml>
    POML
    
    context = {
      'user_name' => user.name,
      'user_email' => user.email,
      'account_type' => user.account_type,
      'issue_type' => issue_type,
      'description' => description
    }
    
    Poml.process(markup: markup, context: context, format: 'raw')
  end
end

# Usage in controller
class SupportController < ApplicationController
  def generate_response
    prompt = PromptService.create_support_prompt(
      current_user,
      params[:issue_type],
      params[:description]
    )
    
    # Send to AI service
    ai_response = AIService.generate_response(prompt)
    
    render json: { response: ai_response }
  end
end
```

### Background Job Integration

```ruby
# app/jobs/content_generation_job.rb
class ContentGenerationJob < ApplicationJob
  queue_as :default
  
  def perform(content_request_id)
    content_request = ContentRequest.find(content_request_id)
    
    begin
      prompt = generate_prompt(content_request)
      
      # Process with AI service
      generated_content = AIService.generate_content(prompt)
      
      content_request.update!(
        content: generated_content,
        status: 'completed'
      )
      
    rescue StandardError => e
      content_request.update!(
        status: 'failed',
        error_message: e.message
      )
      
      Rails.logger.error "Content generation failed: #{e.message}"
    end
  end
  
  private
  
  def generate_prompt(content_request)
    markup = <<~POML
      <poml>
        <role>{{content_type}} Writer</role>
        <task>Create {{content_type}} about {{topic}}</task>
        
        <p>Target audience: {{audience}}</p>
        <p>Tone: {{tone}}</p>
        <p>Length: {{length}} words</p>
        
        {{#keywords}}
        <p>Include these keywords: {{keywords}}</p>
        {{/keywords}}
        
        <hint>Make it engaging and informative</hint>
      </poml>
    POML
    
    context = {
      'content_type' => content_request.content_type,
      'topic' => content_request.topic,
      'audience' => content_request.target_audience,
      'tone' => content_request.tone,
      'length' => content_request.word_count,
      'keywords' => content_request.keywords
    }
    
    Poml.process(markup: markup, context: context, format: 'raw')
  end
end
```

### Sinatra Application Example

```ruby
require 'sinatra'
require 'poml'
require 'json'

# Simple prompt API
post '/api/prompts/generate' do
  content_type :json
  
  begin
    request_data = JSON.parse(request.body.read)
    
    markup = request_data['markup']
    context = request_data['context'] || {}
    format = request_data['format'] || 'dict'
    
    result = Poml.process(
      markup: markup,
      context: context,
      format: format
    )
    
    { success: true, result: result }.to_json
    
  rescue JSON::ParserError
    status 400
    { error: 'Invalid JSON' }.to_json
  rescue Poml::Error => e
    status 422
    { error: "POML Error: #{e.message}" }.to_json
  rescue StandardError => e
    status 500
    { error: "Server Error: #{e.message}" }.to_json
  end
end

# Template-based prompt generation
get '/api/prompts/templates/:name' do
  content_type :json
  
  template_path = "templates/#{params[:name]}.poml"
  
  unless File.exist?(template_path)
    status 404
    return { error: 'Template not found' }.to_json
  end
  
  begin
    markup = File.read(template_path)
    context = params[:context] ? JSON.parse(params[:context]) : {}
    
    result = Poml.process(
      markup: markup,
      context: context,
      format: params[:format] || 'dict'
    )
    
    { success: true, result: result }.to_json
    
  rescue StandardError => e
    status 500
    { error: e.message }.to_json
  end
end
```

## Best Practices

### 1. Template Organization

```ruby
# Good: Organize templates in modules
module PromptTemplates
  module CodeReview
    BASIC_REVIEW = <<~POML
      <poml>
        <role>Senior {{language}} Developer</role>
        <task>Review the following code for best practices</task>
        <hint>Focus on readability, performance, and maintainability</hint>
      </poml>
    POML
    
    SECURITY_REVIEW = <<~POML
      <poml>
        <role>Security Expert</role>
        <task>Review code for security vulnerabilities</task>
        <hint>Look for common security issues like injection attacks, XSS, etc.</hint>
      </poml>
    POML
  end
  
  module Documentation
    API_DOCS = <<~POML
      <poml>
        <role>Technical Writer</role>
        <task>Document the API endpoint</task>
        <hint>Include examples, parameters, and error responses</hint>
      </poml>
    POML
  end
end

# Usage
def generate_code_review_prompt(language, code)
  context = { 'language' => language, 'code' => code }
  Poml.process(markup: PromptTemplates::CodeReview::BASIC_REVIEW, context: context)
end
```

### 2. Context Validation

```ruby
class PromptGenerator
  REQUIRED_FIELDS = {
    'user_support' => %w[user_name issue_type description],
    'code_review' => %w[language code_snippet],
    'content_generation' => %w[topic audience tone]
  }.freeze
  
  def self.generate(template_type, context)
    validate_context!(template_type, context)
    
    template = load_template(template_type)
    Poml.process(markup: template, context: context)
  end
  
  private
  
  def self.validate_context!(template_type, context)
    required = REQUIRED_FIELDS[template_type]
    return unless required
    
    missing = required - context.keys
    raise ArgumentError, "Missing required fields: #{missing.join(', ')}" if missing.any?
  end
  
  def self.load_template(template_type)
    template_path = "templates/#{template_type}.poml"
    raise ArgumentError, "Template not found: #{template_type}" unless File.exist?(template_path)
    
    File.read(template_path)
  end
end
```

### 3. Caching Strategies

```ruby
require 'digest'

class CachedPromptProcessor
  def initialize(cache_store = {})
    @cache = cache_store
  end
  
  def process(markup, context = {}, format = 'dict')
    cache_key = generate_cache_key(markup, context, format)
    
    @cache[cache_key] ||= Poml.process(
      markup: markup,
      context: context,
      format: format
    )
  end
  
  private
  
  def generate_cache_key(markup, context, format)
    content = "#{markup}#{context.to_json}#{format}"
    Digest::SHA256.hexdigest(content)
  end
end

# Usage
processor = CachedPromptProcessor.new
result1 = processor.process(markup, context)  # Processes
result2 = processor.process(markup, context)  # Returns cached result
```

### 4. Environment-Specific Configuration

```ruby
class PomlConfig
  def self.default_options
    case Rails.env
    when 'development'
      { chat: true, format: 'raw' }
    when 'test'
      { chat: false, format: 'dict' }
    when 'production'
      { chat: true, format: 'openai_chat' }
    else
      { chat: true, format: 'dict' }
    end
  end
  
  def self.process_with_defaults(markup, options = {})
    final_options = default_options.merge(options)
    Poml.process(markup: markup, **final_options)
  end
end

# Usage
result = PomlConfig.process_with_defaults(markup, context: context)
```

### 5. Error Logging and Monitoring

```ruby
class MonitoredPromptProcessor
  def self.process(markup, options = {})
    start_time = Time.current
    
    begin
      result = Poml.process(markup: markup, **options)
      
      log_success(markup, options, Time.current - start_time)
      result
      
    rescue Poml::Error => e
      log_poml_error(markup, options, e)
      raise
    rescue StandardError => e
      log_system_error(markup, options, e)
      raise
    end
  end
  
  private
  
  def self.log_success(markup, options, duration)
    Rails.logger.info "POML processed successfully in #{duration.round(3)}s"
  end
  
  def self.log_poml_error(markup, options, error)
    Rails.logger.error "POML Error: #{error.message}"
    Rails.logger.error "Markup: #{markup.truncate(200)}"
  end
  
  def self.log_system_error(markup, options, error)
    Rails.logger.error "System Error during POML processing: #{error.message}"
    Rails.logger.error error.backtrace.join("\n")
  end
end
```

This comprehensive tutorial covers the main use cases and patterns for using the POML Ruby gem. Each example is practical and can be adapted to your specific needs.
