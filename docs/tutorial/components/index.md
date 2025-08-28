# Components Overview

POML provides a rich set of components for creating structured, dynamic AI prompts. This page provides an overview of all available components organized by category.

## Component Categories

### [Chat Components](chat-components.md)

Specialized components for creating structured AI conversations:

- **`<system>`** - System-level instructions and context
- **`<human>`** - User messages and queries  
- **`<ai>`** - Assistant responses and few-shot examples

```ruby
<poml>
  <system>You are a helpful programming assistant.</system>
  <human>How do I optimize this Ruby code?</human>
  <ai>Here are some optimization strategies...</ai>
</poml>
```

### [Formatting Components](formatting.md)

Text formatting and structure components:

- **`<b>`** - **Bold text**
- **`<i>`** - *Italic text*
- **`<u>`** - Underlined text  
- **`<s>`** - ~~Strikethrough text~~
- **`<code>`** - `Inline code`
- **`<h1>` to `<h6>`** - Headers
- **`<br>`** - Line breaks
- **`<p>`** - Paragraphs

### [Data Components](data-components.md)

Components for handling data and structured content:

- **`<table>`** - Render tables from CSV/JSON data
- **`<object>`** - Object serialization (JSON, YAML, XML)
- **`<file>`** - File content reading with path resolution
- **`<folder>`** - Directory listing with depth control

### [Media Components](media-components.md)

Multimedia content components:

- **`<img>`** - Image processing with URL fetching and base64 support
- **`<audio>`** - Audio file handling

### [Schema Components](schema-components.md)

Components for defining structured AI responses and tools:

- **`<output-schema>`** - AI response schema definitions
- **`<tool-definition>`** - AI tool registration with parameters
- **`<meta type="output-schema">`** - Legacy schema support
- **`<meta type="tool-definition">`** - Legacy tool definition support

### [Utility Components](utility-components.md)

Helper components for specialized content:

- **`<list>` & `<item>`** - Unordered lists with nested content
- **`<conversation>`** - Chat conversation display
- **`<tree>`** - Tree structure display with JSON data
- **`<include>`** - Template inclusion and composition

### Template Engine Components

Dynamic content generation components:

- **`<if condition="">`** - Conditional logic with comparisons
- **`<for variable="" items="">`** - Loops and iteration
- **`{{variable}}`** - Variable substitution
- **`<meta variables="">`** - Template variables definition

### Structural Components

Basic structural components:

- **`<poml>`** - Root container for all POML content
- **`<role>`** - Define AI role and expertise
- **`<task>`** - Specify what AI should accomplish
- **`<hint>`** - Provide additional guidance

## Common Attributes

### Global Attributes

Most components support these attributes:

- **`inline="true"`** - Enable inline rendering for seamless text flow
- **Template variables** - Use `{{variable}}` in any attribute value

### Chat-Specific Attributes

Chat components support:

- **`role="..."`** - Override default role (system, user, assistant)
- **`speaker="..."`** - Custom speaker name for conversations

### Formatting Attributes

Components support various formatting attributes:

- **`style="..."`** - Custom styling
- **`class="..."`** - CSS class names

## Component Usage Patterns

### Basic Structure

```ruby
<poml>
  <role>Expert in {{domain}}</role>
  <task>{{primary_objective}}</task>
  
  <p>Context and instructions...</p>
  
  <list>
    <item>First requirement</item>
    <item>Second requirement</item>
  </list>
  
  <hint>Additional guidance</hint>
</poml>
```

### Chat Conversation

```ruby
<poml>
  <system>You are a {{expertise}} expert.</system>
  
  <human>
    I need help with {{problem_description}}.
    
    <p>Specific requirements:</p>
    <list>
      <for variable="req" items="{{requirements}}">
        <item>{{req}}</item>
      </for>
    </list>
  </human>
</poml>
```

### Data Analysis

```ruby
<poml>
  <role>Data Analyst</role>
  <task>Analyze the provided dataset</task>
  
  <table src="{{data_file}}" maxRecords="10" />
  
  <output-schema name="AnalysisResult">
  {
    "type": "object",
    "properties": {
      "insights": {"type": "array"},
      "recommendations": {"type": "array"}
    }
  }
  </output-schema>
</poml>
```

### Code Review

```ruby
<poml>
  <role>Senior {{language}} Developer</role>
  <task>Review code for best practices</task>
  
  <file src="{{code_file}}" />
  
  <p>Review focus areas:</p>
  <list>
    <item><b>Performance</b> - Algorithm efficiency</item>
    <item><b>Security</b> - Vulnerability assessment</item>
    <item><b>Maintainability</b> - Code organization</item>
  </list>
  
  <tool-definition name="suggest_improvements">
  {
    "description": "Suggest specific code improvements",
    "parameters": {
      "type": "object",
      "properties": {
        "file_path": {"type": "string"},
        "line_number": {"type": "integer"},
        "suggestion": {"type": "string"},
        "priority": {"type": "string", "enum": ["low", "medium", "high"]}
      }
    }
  }
  </tool-definition>
</poml>
```

## Component Combinations

### Inline Formatting

```ruby
<p>
  The <code inline="true">{{method_name}}</code> method should return a 
  <b inline="true">{{return_type}}</b> value, not 
  <s inline="true">{{incorrect_type}}</s>.
</p>
```

### Conditional Content

```ruby
<if condition="{{include_examples}}">
  <p><b>Examples:</b></p>
  <for variable="example" items="{{examples}}">
    <p><i>Example {{example.index}}:</i></p>
    <code>{{example.code}}</code>
  </for>
</if>
```

### Nested Structures

```ruby
<list>
  <for variable="category" items="{{categories}}">
    <item>
      <b>{{category.name}}</b>
      <list>
        <for variable="item" items="{{category.items}}">
          <item>{{item.name}} - {{item.description}}</item>
        </for>
      </list>
    </item>
  </for>
</list>
```

## Advanced Features

### Template Composition

```ruby
<!-- Base template -->
<poml>
  <role>{{role_type}} Expert</role>
  <task>{{main_task}}</task>
  
  <include src="{{template_path}}" />
  
  <if condition="{{include_footer}}">
    <include src="templates/footer.poml" />
  </if>
</poml>
```

### Multi-Format Support

```ruby
<!-- Works across all output formats -->
<poml>
  <system>You are a helpful assistant.</system>
  
  <output-schema name="Response">
  {
    "type": "object",
    "properties": {
      "answer": {"type": "string"},
      "confidence": {"type": "number"}
    }
  }
  </output-schema>
  
  <human>{{user_question}}</human>
</poml>
```

### Error Handling

```ruby
<poml>
  <role>Support Assistant</role>
  <task>Help resolve the issue</task>
  
  <if condition="{{error_logs}}">
    <p><b>Error Analysis:</b></p>
    <file src="{{error_logs}}" />
  </if>
  
  <if condition="!{{error_logs}}">
    <p>⚠️ No error logs provided. Please share relevant error information.</p>
  </if>
</poml>
```

## Performance Considerations

### Component Efficiency

- **Light components**: `<p>`, `<b>`, `<i>`, `<code>` - Very fast
- **Medium components**: `<list>`, `<table>`, `<if>`, `<for>` - Moderate processing
- **Heavy components**: `<file>`, `<img>`, `<include>` - I/O dependent

### Optimization Tips

1. **Use inline rendering** for seamless text flow
2. **Limit file operations** with `maxRecords` on tables
3. **Cache include templates** for repeated use
4. **Validate schemas** before processing for better error handling

### Memory Usage

```ruby
# Good: Process in chunks for large datasets
<table src="large_dataset.csv" maxRecords="100" />

# Good: Use conditions to avoid unnecessary processing
<if condition="{{debug_mode}}">
  <file src="debug.log" />
</if>

# Good: Limit nested loops
<for variable="category" items="{{categories}}">
  <if condition="{{category.items.length}} <= 10">
    <for variable="item" items="{{category.items}}">
      <item>{{item.name}}</item>
    </for>
  </if>
</for>
```

## Component Reference Quick Links

### By Use Case

- **Chat Applications**: [Chat Components](chat-components.md)
- **Data Processing**: [Data Components](data-components.md)
- **Content Generation**: [Formatting Components](formatting.md)
- **AI Integration**: [Schema Components](schema-components.md)
- **Dynamic Content**: [Template Engine](../template-engine.md)

### By Complexity

- **Beginner**: `<p>`, `<b>`, `<i>`, `<list>`, `<item>`
- **Intermediate**: `<if>`, `<for>`, `<table>`, `<img>`, `<system>`, `<human>`
- **Advanced**: `<output-schema>`, `<tool-definition>`, `<include>`, `<meta>`

### By Output Format

- **All Formats**: Basic formatting, structure, template engine
- **Chat Formats**: `<system>`, `<human>`, `<ai>` components
- **Schema Formats**: `<output-schema>`, `<tool-definition>` components

## Next Steps

1. **Start Simple** - Begin with [Formatting Components](formatting.md)
2. **Add Structure** - Learn [Template Engine](../template-engine.md)  
3. **Enable Chat** - Explore [Chat Components](chat-components.md)
4. **Add Intelligence** - Master [Schema Components](schema-components.md)
5. **Optimize** - Review [Performance Guide](../advanced/performance.md)
