# Formatting Components

POML provides comprehensive text formatting components that work seamlessly with templates and other POML features. These components support both block and inline rendering modes.

## Text Formatting

### Bold Text - `<b>`

Make text **bold** for emphasis:

```xml
<poml>
  <p>This is <b>important information</b> to remember.</p>
  
  <!-- Inline rendering for seamless flow -->
  <p>The <b inline="true">critical step</b> requires attention.</p>
  
  <!-- With template variables -->
  <p><b>{{important_concept}}</b> is fundamental to understanding.</p>
</poml>
```

**Output:**

```
This is **important information** to remember.

The **critical step** requires attention.

**Machine Learning** is fundamental to understanding.
```

### Italic Text - `<i>`

Use *italic* text for emphasis or citations:

```xml
<poml>
  <p>According to <i>{{source_title}}</i>, the results show improvement.</p>
  
  <!-- Technical terms -->
  <p>The <i inline="true">algorithmic complexity</i> is O(n log n).</p>
  
  <!-- Multiple emphasis levels -->
  <p><i>Note:</i> <b>Critical</b> - Please review carefully.</p>
</poml>
```

### Underlined Text - `<u>`

Underline text for highlighting:

```xml
<poml>
  <p><u>Important:</u> All fields marked with * are required.</p>
  
  <!-- Combined formatting -->
  <p><b><u>{{section_title}}</u></b></p>
</poml>
```

### Strikethrough Text - `<s>`

Show deleted or outdated information:

```xml
<poml>
  <p>The original approach was <s>{{old_method}}</s> {{new_method}}.</p>
  
  <!-- Corrections -->
  <p>Price: <s>$99</s> <b>$79</b> (on sale)</p>
</poml>
```

### Inline Code - `<code>`

Format code snippets and technical terms:

```xml
<poml>
  <p>Use the <code>{{method_name}}</code> method to process data.</p>
  
  <!-- Multi-line code blocks -->
  <code>
    def process_data(input)
      {{processing_logic}}
    end
  </code>
  
  <!-- Inline technical terms -->
  <p>Set the <code inline="true">API_KEY</code> environment variable.</p>
</poml>
```

**Output:**

```
Use the `process_user_data` method to process data.

```

def process_data(input)
  input.map(&:transform).filter(&:valid?)
end

```

Set the `API_KEY` environment variable.
```

## Headers

### Header Levels - `<h1>` to `<h6>`

Create hierarchical content structure:

```xml
<poml>
  <h1>{{main_title}}</h1>
  
  <h2>Overview</h2>
  <p>Brief description of the topic.</p>
  
  <h3>{{subsection_title}}</h3>
  <p>Detailed information about {{specific_aspect}}.</p>
  
  <h4>Implementation Details</h4>
  <list>
    <item>Step 1: {{step_one}}</item>
    <item>Step 2: {{step_two}}</item>
  </list>
  
  <h5>Technical Notes</h5>
  <p>Additional technical considerations.</p>
  
  <h6>References</h6>
  <p>See {{documentation_link}} for more details.</p>
</poml>
```

**Output:**

```markdown
# Machine Learning Pipeline

## Overview
Brief description of the topic.

### Data Preprocessing
Detailed information about feature engineering.

#### Implementation Details
- Step 1: Data collection and validation
- Step 2: Feature extraction and transformation

##### Technical Notes
Additional technical considerations.

###### References
See https://ml-docs.example.com for more details.
```

### Dynamic Headers

```xml
<poml>
  <for variable="section" items="{{documentation_sections}}">
    <h2>{{section.title}}</h2>
    <p>{{section.description}}</p>
    
    <for variable="subsection" items="{{section.subsections}}">
      <h3>{{subsection.title}}</h3>
      <p>{{subsection.content}}</p>
    </for>
  </for>
</poml>
```

## Structural Elements

### Line Breaks - `<br>`

Control line spacing and layout:

```xml
<poml>
  <p>First line<br>Second line</p>
  
  <!-- Multiple breaks for spacing -->
  <p>Section A content</p>
  <br><br>
  <p>Section B content with extra spacing</p>
  
  <!-- Conditional breaks -->
  <if condition="{{add_spacing}}">
    <br>
  </if>
</poml>
```

### Paragraphs - `<p>`

Structure text content:

```xml
<poml>
  <p>
    This is a paragraph with <b>{{highlighted_term}}</b> and 
    <i>{{emphasized_concept}}</i>. It can contain multiple
    formatting elements.
  </p>
  
  <p>
    Another paragraph with <code>{{code_example}}</code> and
    a reference to <u>{{important_document}}</u>.
  </p>
  
  <!-- Conditional paragraphs -->
  <if condition="{{include_warning}}">
    <p><b>Warning:</b> {{warning_message}}</p>
  </if>
</poml>
```

## Advanced Formatting

### Nested Formatting

Combine multiple formatting elements:

```xml
<poml>
  <p>
    <b>
      <i>Very important</i>
    </b> information that requires
    <u>
      <code>special_attention()</code>
    </u>
  </p>
  
  <!-- Complex combinations -->
  <p>
    Status: <b><u>{{status}}</u></b><br>
    Method: <code><i>{{method_name}}</i></code><br>
    Result: <s>{{old_result}}</s> → <b>{{new_result}}</b>
  </p>
</poml>
```

### Inline Rendering Mode

Enable seamless text flow:

```xml
<poml>
  <p>
    The method 
    <code inline="true">{{method_name}}</code> 
    returns a 
    <b inline="true">{{return_type}}</b> 
    value representing 
    <i inline="true">{{description}}</i>.
  </p>
  
  <!-- Without inline mode (default) -->
  <p>
    The method <code>{{method_name}}</code> returns
    a <b>{{return_type}}</b> value.
  </p>
</poml>
```

**With inline="true":**

```
The method process_data returns a DataResult value representing processed user information.
```

**Without inline (default):**

```
The method `process_data` returns
a **DataResult** value.
```

### Template Integration

Use formatting with template engine:

```xml
<poml>
  <for variable="item" items="{{task_list}}">
    <p>
      <if condition="{{item.priority}} == 'high'">
        <b><u>{{item.title}}</u></b>
      </if>
      <if condition="{{item.priority}} == 'medium'">
        <b>{{item.title}}</b>
      </if>
      <if condition="{{item.priority}} == 'low'">
        <i>{{item.title}}</i>
      </if>
      
      <br>
      <code>Status: {{item.status}}</code>
      
      <if condition="{{item.notes}}">
        <br><small>{{item.notes}}</small>
      </if>
    </p>
  </for>
</poml>
```

### Conditional Formatting

Apply formatting based on conditions:

```xml
<poml>
  <p>
    Result: 
    <if condition="{{success}}">
      <b style="color: green">✅ {{result_message}}</b>
    </if>
    <if condition="!{{success}}">
      <b style="color: red">❌ {{error_message}}</b>
    </if>
  </p>
  
  <!-- Format based on data type -->
  <for variable="field" items="{{data_fields}}">
    <p>
      {{field.name}}: 
      <if condition="{{field.type}} == 'string'">
        <i>"{{field.value}}"</i>
      </if>
      <if condition="{{field.type}} == 'number'">
        <code>{{field.value}}</code>
      </if>
      <if condition="{{field.type}} == 'boolean'">
        <b>{{field.value}}</b>
      </if>
    </p>
  </for>
</poml>
```

## Accessibility and Best Practices

### Semantic Markup

Use appropriate formatting for meaning:

```xml
<poml>
  <!-- Good: Semantic usage -->
  <h2>{{section_title}}</h2>
  <p><b>Important:</b> {{critical_information}}</p>
  <p>Reference: <i>{{citation}}</i></p>
  <p>Command: <code>{{terminal_command}}</code></p>
  
  <!-- Avoid: Formatting without meaning -->
  <!-- Don't use <h1> just for large text -->
  <!-- Don't use <b> for non-important text -->
</poml>
```

### Consistent Formatting

Establish formatting patterns:

```xml
<poml>
  <!-- API documentation pattern -->
  <h3>{{endpoint_name}}</h3>
  <p><code>{{http_method}} {{endpoint_path}}</code></p>
  <p><b>Purpose:</b> {{endpoint_description}}</p>
  <p><i>Authentication required:</i> {{auth_required}}</p>
  
  <!-- Error message pattern -->
  <p><b>Error:</b> <code>{{error_code}}</code></p>
  <p><i>Description:</i> {{error_description}}</p>
  
  <!-- Success message pattern -->
  <p><b>✅ Success:</b> {{success_message}}</p>
</poml>
```

### Performance Considerations

Optimize formatting for large documents:

```xml
<poml>
  <!-- Efficient: Use inline for short text -->
  <p>The <code inline="true">{{variable}}</code> contains data.</p>
  
  <!-- Efficient: Batch similar formatting -->
  <for variable="item" items="{{items}}">
    <if condition="{{item.important}}">
      <p><b>{{item.title}}</b> - {{item.description}}</p>
    </if>
  </for>
  
  <!-- Less efficient: Excessive nesting -->
  <!-- Avoid deep nesting when possible -->
</poml>
```

## Output Format Compatibility

### All Formats

Basic formatting works across all output formats:

```xml
<poml>
  <p><b>Bold</b> and <i>italic</i> text.</p>
  <code>code_example</code>
</poml>
```

### Raw Format

```
**Bold** and *italic* text.
`code_example`
```

### Dict Format

```ruby
{
  "content" => "**Bold** and *italic* text.\n`code_example`",
  "formatting" => ["bold", "italic", "code"]
}
```

### Chat Formats

```ruby
{
  "messages" => [
    {
      "role" => "user",
      "content" => "**Bold** and *italic* text.\n`code_example`"
    }
  ]
}
```

## Common Patterns

### Documentation Generation

```xml
<poml>
  <h1>{{api_name}} Documentation</h1>
  
  <h2>Methods</h2>
  <for variable="method" items="{{api_methods}}">
    <h3><code>{{method.name}}</code></h3>
    <p><i>{{method.description}}</i></p>
    
    <h4>Parameters</h4>
    <for variable="param" items="{{method.parameters}}">
      <p>
        <code>{{param.name}}</code> 
        <i>({{param.type}})</i> - {{param.description}}
        <if condition="{{param.required}}">
          <b>Required</b>
        </if>
      </p>
    </for>
    
    <h4>Example</h4>
    <code>{{method.example}}</code>
  </for>
</poml>
```

### Status Reports

```xml
<poml>
  <h2>System Status Report</h2>
  
  <for variable="service" items="{{services}}">
    <p>
      <b>{{service.name}}:</b> 
      <if condition="{{service.status}} == 'operational'">
        <b style="color: green">✅ Operational</b>
      </if>
      <if condition="{{service.status}} == 'degraded'">
        <b style="color: orange">⚠️ Degraded</b>
      </if>
      <if condition="{{service.status}} == 'down'">
        <b style="color: red">❌ Down</b>
      </if>
    </p>
    
    <if condition="{{service.issues}}">
      <p><i>Issues:</i> {{service.issues}}</p>
    </if>
  </for>
</poml>
```

### Code Review Comments

```xml
<poml>
  <h3>Code Review for {{file_name}}</h3>
  
  <for variable="issue" items="{{code_issues}}">
    <p>
      <b>Line {{issue.line}}:</b>
      <if condition="{{issue.severity}} == 'error'">
        <b><u>Error</u></b>
      </if>
      <if condition="{{issue.severity}} == 'warning'">
        <b>Warning</b>
      </if>
      <if condition="{{issue.severity}} == 'suggestion'">
        <i>Suggestion</i>
      </if>
    </p>
    
    <p>{{issue.description}}</p>
    
    <if condition="{{issue.suggested_fix}}">
      <p><b>Suggested fix:</b></p>
      <code>{{issue.suggested_fix}}</code>
    </if>
  </for>
</poml>
```

## Next Steps

1. **Practice Basic Formatting** - Start with simple `<b>`, `<i>`, `<code>` usage
2. **Learn Template Integration** - Combine formatting with variables and conditions
3. **Explore Advanced Components** - Move to [Data Components](data-components.md)
4. **Master Layout** - Check [Component Overview](index.md) for structure patterns

For more advanced formatting techniques, see:

- [Template Engine](../template-engine.md) for dynamic formatting
- [Component Overview](index.md) for layout patterns
- [Advanced Techniques](../advanced/) for optimization tips
