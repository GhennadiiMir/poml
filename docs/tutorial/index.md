# POML Ruby Gem - Tutorial

Welcome to the comprehensive tutorial for the POML (Prompt Oriented Markup Language) Ruby gem. This tutorial will guide you through all features and capabilities of POML for creating structured AI prompts.

## What is POML?

POML is a markup language designed for creating structured, reusable AI prompts. It provides components for organizing content, managing templates, handling data, and integrating with various AI services.

## Key Concepts for Ruby Implementation

### Output Formats and Rendering

The Ruby POML gem uses a **format-aware rendering system**:

- **Default rendering**: Produces Markdown-like output optimized for readability
- **HTML components**: Use `<output format="html"/>` for HTML output (`<h1>`, `<b>`, `<i>` tags)
- **JSON/XML formats**: Use `<output format="json"/>` or `<output format="xml"/>` for structured data
- **Text format**: Use `<output format="text"/>` for plain text output

**Example - Getting HTML Output:**

```ruby
markup = <<~POML
  <poml>
    <role>Documentation Writer</role>
    <h1>Main Title</h1>
    <p>Content with <b>bold</b> and <i>italic</i> text.</p>
    <output format="html"/>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['output']  # Contains HTML: <h1>Main Title</h1><p>Content with <b>bold</b>...
```

### Component Behavior

- **Headers**: `<h1>Title</h1>` produces `# Title` by default, `<h1>Title</h1>` with HTML format
- **Formatting**: `<b>bold</b>` produces `**bold**` by default, `<b>bold</b>` with HTML format  
- **Structure**: Most components adapt their output based on the specified format

## Quick Start

```ruby
require 'poml'

# Simple example
markup = <<~POML
  <poml>
    <role>Code Reviewer</role>
    <task>Review the following Ruby code for best practices</task>
    <hint>Focus on performance and readability</hint>
  </poml>
POML

result = Poml.process(markup: markup)
puts result['content']
```

## Tutorial Structure

### Core Concepts

- **[Basic Usage](basic-usage.md)** - Fundamental POML concepts and syntax
- **[Output Formats](output-formats.md)** - All supported output formats with examples
- **[Template Engine](template-engine.md)** - Variables, conditionals, and loops

### Components Reference

- **[Components Overview](components/index.md)** - All available POML components
- **[Chat Components](components/chat-components.md)** - AI, human, and system message components
- **[Formatting Components](components/formatting.md)** - Text formatting and structure
- **[Data Components](components/data-components.md)** - Tables, objects, and file handling
- **[Media Components](components/media-components.md)** - Images and multimedia
- **[Schema Components](components/schema-components.md)** - Output schemas and tool definitions
- **[Utility Components](components/utility-components.md)** - Conversations, trees, and folders

### Advanced Features

- **[Tool Registration](advanced/tool-registration.md)** - Enhanced tool registration system
- **[Inline Rendering](advanced/inline-rendering.md)** - Seamless text flow with inline components
- **[Error Handling](advanced/error-handling.md)** - Robust error handling patterns
- **[Performance](advanced/performance.md)** - Caching and optimization strategies

### Integration Guides

- **[Rails Integration](integration/rails.md)** - Using POML in Rails applications
- **[Sinatra Integration](integration/sinatra.md)** - Building APIs with POML
- **[Background Jobs](integration/background-jobs.md)** - Async processing patterns

### Complete Examples

- **[Code Review System](examples/code-review.md)** - Complete code review workflow
- **[API Documentation](examples/documentation.md)** - Automated documentation generation
- **[Content Generation](examples/content-generation.md)** - Dynamic content creation

## Key Features

- **🎯 Multiple Output Formats**: Raw text, OpenAI Chat, LangChain, Pydantic, and more
- **📝 Template Engine**: Variables, conditionals, loops, and meta variables

## XML Mode and Component Rendering

### Dual Rendering Architecture

The Ruby POML implementation supports **dual rendering modes** that automatically adapt based on context:

#### Standard Mode (Default)

Components render to Markdown-like syntax for readability:

- `<code>example</code>` → `` `example` ``
- `<b>bold</b>` → `**bold**`
- `<i>italic</i>` → `*italic*`

#### XML Mode (with `syntax="xml"`)

Components preserve XML structure with attributes:

- `<code inline="true">example</code>` → `<code inline="true">example</code>`
- `<b>bold text</b>` → `<b>bold text</b>`
- `<list style="decimal">...` → `<list style="decimal">...`

### Important XML Parsing Details

**Component Disambiguation**: The parser uses precise boundary detection to distinguish between similar component names:

- `<code>` tags are handled separately from `<code-block>` tags
- Regex patterns use negative lookahead (`(?!-)`) to prevent false matches
- This ensures proper XML parsing when multiple component types are present

**Attribute Preservation**: When `syntax="xml"` is specified, component attributes are maintained in the output, enabling rich structured content while preserving XML compatibility.

### Example: Context-Aware Rendering

```ruby
# Standard mode
markup1 = '<poml><code>example</code></poml>'
result1 = Poml.process(markup: markup1)
# Output: `example`

# XML mode
markup2 = '<poml syntax="xml"><code inline="true">example</code></poml>'
result2 = Poml.process(markup: markup2)  
# Output: <code inline="true">example</code>
```

## Getting Started

- **🔧 Tool Registration**: Enhanced tool definition with parameter conversion
- **📊 Data Components**: Tables, objects, files, and structured data
- **🖼️ Media Support**: Images with URL fetching and base64 encoding
- **💬 Chat Components**: Specialized AI conversation components
- **🎨 Inline Rendering**: Seamless text flow with component integration
- **⚡ Performance**: Caching, optimization, and error handling

## Installation

Add to your Gemfile:

```ruby
gem 'poml'
```

Or install directly:

```bash
gem install poml
```

## Version Compatibility

- **Ruby**: >= 2.7.0
- **Current Version**: 0.0.7
- **Test Coverage**: 399 tests, 2812 assertions, **100% pass rate** (0 failures, 0 errors, 0 skips)

## Next Steps

1. Start with [Basic Usage](basic-usage.md) to learn core concepts
2. Explore [Components](components/index.md) for detailed component reference
3. Check [Integration Guides](integration/rails.md) for your specific use case
4. Review [Examples](examples/code-review.md) for real-world implementations

Happy prompting! 🚀
