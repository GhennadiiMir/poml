# Output Formats

POML supports multiple output formats to integrate seamlessly with different AI services, frameworks, and applications.

## Two Types of Format Control

POML provides **two distinct levels** of format control:

### 1. Output Structure Formats

Control the **overall structure** of the result (API format):

- `format: 'raw'` - Plain text with role boundaries
- `format: 'dict'` - Ruby Hash with metadata (default)
- `format: 'openai_chat'` - OpenAI message arrays
- `format: 'openaiResponse'` - Standardized AI response
- `format: 'langchain'` - LangChain compatible
- `format: 'pydantic'` - Python interoperability

### 2. Content Rendering Formats

Control how **components render** within the content using `<output format="..."/>`:

- `format="markdown"` - Markdown syntax (default): `# Header`, `**bold**`
- `format="html"` - HTML tags: `<h1>Header</h1>`, `<b>bold</b>`
- `format="text"` - Plain text without markup
- `format="json"` - JSON representation of content
- `format="xml"` - XML-structured content

**Example combining both:**

```ruby
markup = <<~POML
  <poml>
    <role>Writer</role>
    <h1>Article Title</h1>
    <p>Content with <b>emphasis</b></p>
    <output format="html"/>  <!-- Content format -->
  </poml>
POML

# Structure format
result = Poml.process(markup: markup, format: 'dict')
puts result['output']  # HTML: <h1>Article Title</h1><p>Content with <b>emphasis</b></p>
```

## Available Formats

POML provides six main output formats:

- **raw** - Plain text with role boundaries
- **dict** - Ruby Hash with structured metadata  
- **openai_chat** - OpenAI API compatible message arrays
- **openaiResponse** - Standardized AI response structure
- **langchain** - LangChain compatible format
- **pydantic** - Python interoperability with strict schemas

## Raw Format

The raw format outputs plain text with role boundaries, perfect for direct use with AI APIs:

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>Ruby Expert</role>
    <task>Review code for best practices</task>
    <hint>Focus on performance and readability</hint>
  </poml>
POML

result = Poml.process(markup: markup, format: 'raw')
puts result
```

Output:

```
===== system =====

# Role

Ruby Expert

# Task

Review code for best practices

# Hint

Focus on performance and readability
```

### Raw Format with Chat Components

```ruby
markup = <<~POML
  <poml>
    <system>You are a helpful programming assistant.</system>
    <human>How do I optimize this Ruby code?</human>
  </poml>
POML

result = Poml.process(markup: markup, format: 'raw')
```

Output:

```
===== system =====

You are a helpful programming assistant.

===== human =====

How do I optimize this Ruby code?
```

## Dictionary Format (Default)

The dictionary format returns a Ruby Hash with structured content and metadata:

```ruby
markup = <<~POML
  <poml>
    <role>Data Analyst</role>
    <task>Analyze sales data</task>
    <meta variables='{"quarter": "Q4", "year": 2024}' />
  </poml>
POML

result = Poml.process(markup: markup, format: 'dict')
# or simply: result = Poml.process(markup: markup)

puts result.class          # Hash
puts result['content']     # The formatted prompt
puts result['metadata']    # Additional information
```

Structure:

```ruby
{
  'content' => "The formatted prompt text",
  'metadata' => {
    'chat' => true,
    'variables' => {'quarter' => 'Q4', 'year' => 2024},
    'schemas' => [],
    'tools' => [],
    'custom_metadata' => {}
  }
}
```

## OpenAI Chat Format

Perfect for integration with OpenAI's Chat Completions API:

```ruby
markup = <<~POML
  <poml>
    <system>You are a code review assistant specializing in Ruby.</system>
    <human>Please review this method for potential improvements.</human>
  </poml>
POML

messages = Poml.process(markup: markup, format: 'openai_chat')
puts JSON.pretty_generate(messages)
```

Output:

```json
[
  {
    "role": "system",
    "content": "You are a code review assistant specializing in Ruby."
  },
  {
    "role": "user", 
    "content": "Please review this method for potential improvements."
  }
]
```

### With Template Variables

```ruby
markup = <<~POML
  <poml>
    <system>You are a {{expertise}} expert.</system>
    <human>Help me with {{task_type}}.</human>
  </poml>
POML

context = {
  'expertise' => 'Ruby on Rails',
  'task_type' => 'performance optimization'
}

messages = Poml.process(markup: markup, context: context, format: 'openai_chat')
```

### Direct OpenAI Integration

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
  
  uri = URI('https://api.openai.com/v1/chat/completions')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Post.new(uri)
  request['Authorization'] = "Bearer #{ENV['OPENAI_API_KEY']}"
  request['Content-Type'] = 'application/json'
  request.body = JSON.generate(payload)
  
  response = http.request(request)
  JSON.parse(response.body)
end

# Usage
markup = <<~POML
  <poml>
    <system>You are a helpful assistant.</system>
    <human>Explain recursion in programming.</human>
  </poml>
POML

response = send_to_openai(markup)
puts response['choices'][0]['message']['content']
```

## OpenAI Response Format

Standardized AI response structure separate from conversational chat format:

```ruby
markup = <<~POML
  <poml>
    <role>Research Assistant</role>
    <task>Summarize research findings</task>
    
    <output-schema name="ResearchSummary">
    {
      "type": "object",
      "properties": {
        "key_findings": {"type": "array"},
        "confidence": {"type": "number"}
      }
    }
    </output-schema>
  </poml>
POML

result = Poml.process(markup: markup, format: 'openaiResponse')
puts JSON.pretty_generate(result)
```

Output:

```json
{
  "content": "Research Assistant\n\nSummarize research findings",
  "type": "prompt",
  "metadata": {
    "variables": {},
    "schemas": [
      {
        "name": "ResearchSummary",
        "content": {"type": "object", "properties": {...}}
      }
    ],
    "tools": [],
    "custom_metadata": {}
  }
}
```

### With Tools and Schemas

```ruby
markup = <<~POML
  <poml>
    <role>Data Analyst</role>
    <task>Analyze dataset and provide insights</task>
    
    <tool-definition name="load_data">
    {
      "description": "Load dataset from file",
      "parameters": {
        "type": "object",
        "properties": {
          "file_path": {"type": "string"},
          "format": {"type": "string"}
        }
      }
    }
    </tool-definition>
    
    <output-schema name="Analysis">
    {
      "type": "object",
      "properties": {
        "insights": {"type": "array"},
        "recommendations": {"type": "array"}
      }
    }
    </output-schema>
  </poml>
POML

result = Poml.process(markup: markup, format: 'openaiResponse')
```

## LangChain Format

Compatible with LangChain framework for Python/Node.js integration:

```ruby
markup = <<~POML
  <poml>
    <system>You are a helpful assistant.</system>
    <human>Explain machine learning concepts.</human>
  </poml>
POML

result = Poml.process(markup: markup, format: 'langchain')
puts JSON.pretty_generate(result)
```

Output:

```json
{
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful assistant."
    },
    {
      "role": "human",
      "content": "Explain machine learning concepts."
    }
  ],
  "content": "===== system =====\n\nYou are a helpful assistant.\n\n===== human =====\n\nExplain machine learning concepts."
}
```

### LangChain Integration Example

```python
# Python example using the output
import json
from langchain.schema import SystemMessage, HumanMessage

def process_poml_for_langchain(poml_output):
    messages = []
    for msg in poml_output['messages']:
        if msg['role'] == 'system':
            messages.append(SystemMessage(content=msg['content']))
        elif msg['role'] == 'human':
            messages.append(HumanMessage(content=msg['content']))
    return messages
```

## Pydantic Format

Enhanced Python interoperability with strict JSON schemas:

```ruby
markup = <<~POML
  <poml>
    <role>API Designer</role>
    <task>Design REST API endpoints</task>
    
    <meta title="API Design Session" author="Senior Developer" />
    
    <output-schema name="APIDesign">
    {
      "type": "object",
      "properties": {
        "endpoints": {"type": "array"},
        "schemas": {"type": "object"}
      }
    }
    </output-schema>
  </poml>
POML

result = Poml.process(markup: markup, format: 'pydantic')
puts JSON.pretty_generate(result)
```

Output:

```json
{
  "content": "API Designer\n\nDesign REST API endpoints", 
  "variables": {},
  "chat_enabled": true,
  "schemas": [
    {
      "name": "APIDesign",
      "schema": {"type": "object", "properties": {...}}
    }
  ],
  "custom_metadata": {
    "title": "API Design Session",
    "author": "Senior Developer"
  },
  "metadata": {
    "format": "pydantic",
    "python_compatibility": true,
    "strict_schemas": true
  }
}
```

### Python Integration

```python
# Python example using pydantic output
from pydantic import BaseModel, create_model
import json

def create_pydantic_model(poml_output):
    """Create Pydantic model from POML schema output"""
    schemas = poml_output.get('schemas', [])
    
    if schemas:
        schema = schemas[0]['schema']
        model_name = schemas[0]['name']
        
        # Create Pydantic model from JSON schema
        return create_model(model_name, **schema['properties'])
    
    return None
```

## Format Comparison

### When to Use Each Format

| Format | Best For | Output Type | Metadata |
|--------|----------|-------------|----------|
| `raw` | Direct AI API calls, Claude, custom models | String | None |
| `dict` | Ruby applications, general processing | Hash | Full |
| `openai_chat` | OpenAI Chat Completions API | Array | None |
| `openaiResponse` | Structured AI responses with metadata | Hash | Full |
| `langchain` | LangChain framework integration | Hash | Partial |
| `pydantic` | Python applications, strict schemas | Hash | Enhanced |

### Performance Characteristics

```ruby
require 'benchmark'

markup = <<~POML
  <poml>
    <role>Performance Tester</role>
    <task>Test processing speed</task>
  </poml>
POML

Benchmark.bm(15) do |x|
  x.report('raw:') { 1000.times { Poml.process(markup: markup, format: 'raw') } }
  x.report('dict:') { 1000.times { Poml.process(markup: markup, format: 'dict') } }
  x.report('openai_chat:') { 1000.times { Poml.process(markup: markup, format: 'openai_chat') } }
  x.report('openaiResponse:') { 1000.times { Poml.process(markup: markup, format: 'openaiResponse') } }
  x.report('langchain:') { 1000.times { Poml.process(markup: markup, format: 'langchain') } }
  x.report('pydantic:') { 1000.times { Poml.process(markup: markup, format: 'pydantic') } }
end
```

## Advanced Format Usage

### Dynamic Format Selection

```ruby
class PomlFormatter
  FORMATS = {
    openai: 'openai_chat',
    claude: 'raw',
    langchain: 'langchain',
    python: 'pydantic',
    default: 'dict'
  }.freeze
  
  def self.process_for_service(markup, service, context = {})
    format = FORMATS[service] || FORMATS[:default]
    Poml.process(markup: markup, context: context, format: format)
  end
end

# Usage
markup = '<poml><role>Assistant</role><task>Help users</task></poml>'

openai_result = PomlFormatter.process_for_service(markup, :openai)
claude_result = PomlFormatter.process_for_service(markup, :claude)
python_result = PomlFormatter.process_for_service(markup, :python)
```

### Format Validation

```ruby
def validate_format_output(markup, format)
  result = Poml.process(markup: markup, format: format)
  
  case format
  when 'openai_chat'
    return result.is_a?(Array) && result.all? { |msg| msg['role'] && msg['content'] }
  when 'dict', 'openaiResponse', 'langchain', 'pydantic'
    return result.is_a?(Hash) && result['content']
  when 'raw'
    return result.is_a?(String)
  else
    false
  end
end

# Test all formats
formats = ['raw', 'dict', 'openai_chat', 'openaiResponse', 'langchain', 'pydantic']
markup = '<poml><role>Tester</role><task>Test formats</task></poml>'

formats.each do |format|
  valid = validate_format_output(markup, format)
  puts "#{format}: #{valid ? '✅' : '❌'}"
end
```

### Content Consistency Testing

```ruby
def test_content_consistency(markup, context = {})
  formats = ['raw', 'dict', 'openai_chat', 'openaiResponse', 'langchain', 'pydantic']
  results = {}
  
  formats.each do |format|
    results[format] = Poml.process(markup: markup, context: context, format: format)
  end
  
  # Extract content from each format
  contents = {
    'raw' => results['raw'],
    'dict' => results['dict']['content'],
    'openai_chat' => results['openai_chat'].map { |msg| msg['content'] }.join("\n"),
    'openaiResponse' => results['openaiResponse']['content'],
    'langchain' => results['langchain']['content'],
    'pydantic' => results['pydantic']['content']
  }
  
  # Check if core content is consistent
  base_content = contents['dict'].gsub(/=+\s*\w+\s*=+/, '').strip
  
  contents.each do |format, content|
    processed_content = content.gsub(/=+\s*\w+\s*=+/, '').strip
    consistent = processed_content.include?(base_content.split("\n").first)
    puts "#{format}: #{consistent ? '✅' : '❌'} content consistency"
  end
end

# Test consistency
markup = <<~POML
  <poml>
    <role>{{role_type}}</role>
    <task>{{task_description}}</task>
  </poml>
POML

context = { 'role_type' => 'Analyst', 'task_description' => 'Analyze data' }
test_content_consistency(markup, context)
```

## Integration Examples

### Multi-Service AI Client

```ruby
class MultiServiceAIClient
  def initialize
    @services = {
      openai: { format: 'openai_chat', api_class: OpenAIClient },
      claude: { format: 'raw', api_class: ClaudeClient },
      langchain: { format: 'langchain', api_class: LangChainClient }
    }
  end
  
  def process_prompt(service, markup, context = {})
    config = @services[service]
    return nil unless config
    
    formatted_prompt = Poml.process(
      markup: markup,
      context: context,
      format: config[:format]
    )
    
    config[:api_class].new.send_request(formatted_prompt)
  end
end

# Usage
client = MultiServiceAIClient.new

markup = <<~POML
  <poml>
    <system>You are a helpful assistant.</system>
    <human>Explain {{topic}} in simple terms.</human>
  </poml>
POML

context = { 'topic' => 'quantum computing' }

openai_response = client.process_prompt(:openai, markup, context)
claude_response = client.process_prompt(:claude, markup, context)
```

### Format-Specific Optimization

```ruby
class OptimizedPomlProcessor
  def self.process_optimized(markup, target_format, context = {})
    case target_format
    when 'openai_chat'
      # Optimize for OpenAI - ensure proper chat structure
      result = Poml.process(markup: markup, context: context, format: 'openai_chat')
      # Add any OpenAI-specific optimizations
      optimize_for_openai(result)
      
    when 'raw'
      # Optimize for raw text - clean formatting
      result = Poml.process(markup: markup, context: context, format: 'raw')
      result.gsub(/\n{3,}/, "\n\n")  # Remove excessive newlines
      
    when 'pydantic'
      # Optimize for Python - ensure schema compatibility
      result = Poml.process(markup: markup, context: context, format: 'pydantic')
      ensure_python_compatibility(result)
      
    else
      Poml.process(markup: markup, context: context, format: target_format)
    end
  end
  
  private
  
  def self.optimize_for_openai(messages)
    # Ensure messages don't exceed token limits, merge if needed
    messages.map do |msg|
      if msg['content'].length > 4000
        msg['content'] = msg['content'][0..3000] + "... (truncated)"
      end
      msg
    end
  end
  
  def self.ensure_python_compatibility(result)
    # Ensure all schemas are valid JSON Schema Draft 7
    result['schemas']&.each do |schema|
      schema['schema']['$schema'] = 'http://json-schema.org/draft-07/schema#'
    end
    result
  end
end
```

## Next Steps

- Learn about [Template Engine](template-engine.md) for dynamic content
- Explore [Schema Components](components/schema-components.md) for structured outputs
- Check [Integration Examples](integration/rails.md) for real-world usage
