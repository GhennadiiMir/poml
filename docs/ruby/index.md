# Ruby SDK

The POML Ruby gem provides a simple and powerful way to integrate POML into your Ruby applications.

## Installation

Add to your Gemfile:

```ruby
gem 'poml'
```

Or install directly:

```bash
gem install poml
```

## Basic Usage

### Processing POML Documents

```ruby
require 'poml'

# Process a POML document from a string
markup = <<~POML
  <poml>
    <role>Expert Assistant</role>
    <task>Help users with their questions</task>
    <p>How can I help you today?</p>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['content']
```

### Processing Files

```ruby
require 'poml'

# Process a POML file
result = Poml.process(file: 'path/to/your/document.poml')
puts result['content']
```

### Working with Context Variables

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>{{role_name}}</role>
    <task>Answer questions about {{topic}}</task>
  </poml>
POML

# Provide variables
variables = {
  'role_name' => 'Science Teacher',
  'topic' => 'physics'
}

result = Poml.process(markup: markup, variables: variables)
puts result['content']
```

### Response Schemas

The Ruby gem supports both the legacy `<meta type="responseSchema">` syntax and the new `<output-schema>` component:

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <output-schema parser="json">
      {
        "type": "object",
        "properties": {
          "answer": { "type": "string" },
          "confidence": { "type": "number" }
        },
        "required": ["answer"]
      }
    </output-schema>
    
    <role>Expert Assistant</role>
    <task>Provide structured responses</task>
  </poml>
POML

result = Poml.process(markup: markup)
puts "Schema: #{result['metadata']['response_schema']}"
```

### Tool Registration

Register tools that AI models can use:

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <tool-definition name="calculate" description="Perform calculations" parser="json">
      {
        "type": "object",
        "properties": {
          "operation": { "type": "string", "enum": ["add", "subtract", "multiply", "divide"] },
          "a": { "type": "number" },
          "b": { "type": "number" }
        },
        "required": ["operation", "a", "b"]
      }
    </tool-definition>
    
    <role>Math Assistant</role>
    <task>Help with calculations using the calculate tool</task>
  </poml>
POML

result = Poml.process(markup: markup)
puts "Tools: #{result['tools']}"  # Tools are now at top level
```

### Image Processing

The Ruby implementation includes advanced image processing with libvips:

```ruby
require 'poml'

markup = <<~POML
  <poml>
    <role>Image Analyst</role>
    <task>Analyze this image</task>
    
    <!-- Local image with resizing -->
    <img src="large-photo.jpg" 
         max-width="800" 
         max-height="600" 
         resize="fit" 
         type="webp" />
    
    <!-- Remote image -->
    <img src="https://example.com/chart.png" alt="Data visualization" />
  </poml>
POML

result = Poml.process(markup: markup)
# Images are automatically processed and converted to base64 data URLs
```

**Image Processing Features:**

* **libvips integration** for high-performance processing
* **Multiple resize modes**: `fit`, `fill`, `stretch`
* **Format conversion**: JPEG, PNG, WebP, TIFF, GIF
* **URL support**: Fetch images from HTTP(S) URLs
* **Graceful fallback** when libvips is not available

## API Reference

### `Poml.process(options)`

Process a POML document and return the rendered result.

#### Parameters

* `markup` (String, optional): POML markup string to process
* `file` (String, optional): Path to POML file to process  
* `variables` (Hash, optional): Template variables to substitute
* `base_path` (String, optional): Base path for resolving relative file references

#### Returns

A hash containing:

* `content`: The rendered prompt content
* `tools`: Registered tools (top-level array)  
* `metadata`: Document metadata including:
  * `chat`: Whether the document uses chat format
  * `stylesheet`: Applied stylesheets
  * `variables`: Template variables used
  * `response_schema`: Response schema if defined

#### Example

```ruby
result = Poml.process(
  markup: '<poml><role>Assistant</role></poml>',
  variables: { 'name' => 'Claude' }
)

puts result['content']     # Rendered content
puts result['tools']       # Tools array (top-level)
puts result['metadata']    # Metadata hash
```

## Integration Examples

### With OpenAI

```ruby
require 'poml'
require 'openai'

# Process POML document
markup = <<~POML
  <poml>
    <output-schema parser="json">
      {
        "type": "object",
        "properties": {
          "summary": { "type": "string" },
          "key_points": { "type": "array", "items": { "type": "string" } }
        }
      }
    </output-schema>
    
    <role>Research Assistant</role>
    <task>Summarize the provided document</task>
    <document src="research_paper.pdf" />
  </poml>
POML

result = Poml.process(markup: markup)

# Use with OpenAI
client = OpenAI::Client.new
response = client.chat(
  model: "gpt-4",
  messages: [{ role: "user", content: result['content'] }],
  response_format: { type: "json_object" }
)
```

### With Anthropic Claude

```ruby
require 'poml'
require 'anthropic'

markup = <<~POML
  <poml>
    <role>Helpful Assistant</role>
    <task>Answer the user's question clearly and concisely</task>
    <p>What is the capital of France?</p>
  </poml>
POML

result = Poml.process(markup: markup)

# Use with Anthropic
client = Anthropic::Client.new
response = client.messages(
  model: "claude-3-sonnet-20240229",
  max_tokens: 1000,
  messages: [{ role: "user", content: result['content'] }]
)
```

## Error Handling

The Ruby gem provides detailed error messages for common issues:

```ruby
require 'poml'

begin
  result = Poml.process(markup: '<poml><invalid-component /></poml>')
rescue Poml::Error => e
  puts "POML Error: #{e.message}"
rescue => e
  puts "General Error: #{e.message}"
end
```

## Compatibility

This Ruby gem maintains compatibility with the original POML specification and supports:

* Legacy `lang` attribute (maps to `parser`)
* Legacy `<meta type="responseSchema">` (use `<output-schema>` for new projects)
* Legacy `<meta type="tool">` (use `<tool-definition>` for new projects)
* All current POML components and features

For the most up-to-date feature compatibility, see the [ROADMAP.md](../../ROADMAP.md).
