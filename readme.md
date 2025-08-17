# POML Ruby Gem

A Ruby implementation of the POML (Prompt Oriented Markup Language) interpreter.

## About This Implementation

This is a **Ruby port** of the original [POML library](https://github.com/microsoft/poml) developed by Microsoft, which was originally implemented in JavaScript/TypeScript and Python. This Ruby gem is designed to be **fully compatible** with the original POML specification and will **closely follow** the development of the original library to maintain feature parity.

## Demo Video

[![The 5-minute guide to POML](https://i3.ytimg.com/vi/b9WDcFsKixo/maxresdefault.jpg)](https://youtu.be/b9WDcFsKixo)

### Original Library Resources

For comprehensive documentation, tutorials, and examples, please refer to the **original POML library documentation**:

- 📚 **Main Repository**: <https://github.com/microsoft/poml>
- 📖 **Documentation**: Complete language reference and guides
- 💡 **Examples**: Extensive collection of POML examples
- 🎯 **Use Cases**: Real-world applications and patterns

The original documentation is an excellent resource for learning POML concepts, syntax, and best practices that apply to this Ruby implementation as well.

## Installation

```bash
gem install poml
```

Or add to your Gemfile:

```ruby
gem 'poml'
```

After installation, check out [TUTORIAL.md](TUTORIAL.md) for comprehensive examples and integration patterns.

## Usage

### Ruby API

```ruby
require 'poml'

# Basic usage
result = Poml.process(markup: '<poml><role>Assistant</role><task>Help users</task></poml>')
puts result['content']

# With template variables
markup = '<poml><role>{{role_name}}</role><task>{{task_name}}</task></poml>'
context = { 'role_name' => 'Data Analyst', 'task_name' => 'Analyze data' }
result = Poml.process(markup: markup, context: context)

# Different output formats
result = Poml.process(markup: markup, format: 'openai_chat')  # OpenAI chat format
result = Poml.process(markup: markup, format: 'raw')          # Raw text
result = Poml.process(markup: markup, format: 'dict')         # Dictionary (default)

# With custom stylesheet
stylesheet = { 'role' => { 'captionStyle' => 'bold' } }
result = Poml.process(markup: markup, stylesheet: stylesheet)

# Disable chat mode for single prompts
result = Poml.process(markup: markup, chat: false)
```

📖 **For comprehensive examples and advanced usage patterns, see [TUTORIAL.md](TUTORIAL.md)**

#### Quick Reference - Common Patterns

```ruby
# OpenAI API integration
messages = Poml.process(markup: prompt_template, context: vars, format: 'openai_chat')
response = openai_client.chat.completions.create(model: 'gpt-4', messages: messages)

# Rails service integration  
class PromptService
  def self.generate(template_name, context = {})
    markup = File.read("app/prompts/#{template_name}.poml")
    Poml.process(markup: markup, context: context, format: 'raw')
  end
end

# Error handling
begin
  result = Poml.process(markup: user_input)
rescue Poml::Error => e
  puts "POML Error: #{e.message}"
end
```

### Command Line Interface

```bash
# Process a POML file
poml examples/101_explain_character.poml

# Process markup directly
poml "<poml><role>Test</role><task>Say hello</task></poml>" --format raw

# With context variables
poml markup.poml --context '{"name": "John", "role": "developer"}'

# Different output formats
poml markup.poml --format openai_chat
poml markup.poml --format raw
```

### CLI Options

- `-f, --format FORMAT`: Output format (raw, dict, openai_chat, langchain, pydantic)
  - `raw`: Plain text output with message boundaries (like `===== system =====`)
  - `dict`: JSON object with content and metadata
  - `openai_chat`: Array of messages in OpenAI Chat Completion API format
  - `langchain`: Object with both messages array and raw content
  - `pydantic`: Simplified object structure with prompt, variables, and settings
- `-c, --context JSON`: Context variables as JSON
- `--no-chat`: Disable chat mode
- `-s, --stylesheet JSON`: Stylesheet as JSON
- `-o, --output FILE`: Output to file
- `-h, --help`: Show help
- `-v, --version`: Show version

> **Note**: While this Ruby implementation aims for compatibility with the original POML library, the output format structures may differ slightly from the original TypeScript/Python implementations. The format names are kept consistent for API compatibility, but the Ruby gem provides its own implementation of each format suitable for Ruby applications.

## POML Components

### Basic Components

- `<role>`: Define the AI's role
- `<task>`: Define the task to perform
- `<hint>`: Provide hints or additional information
- `<p>`: Paragraph text

### Content Components

- `<Document src="file.txt">`: Include external documents (.txt, .docx, .pdf)
- `<img src="image.jpg" alt="description">`: Include images
- `<Table src="data.csv">`: Include tabular data

### Layout Components

- `<cp caption="Section Title">`: Captioned paragraph/section
- `<list>` with `<item>`: Create lists
- `<example>` with `<input>` and `<output>`: Define examples

### Template Variables

Use `{{variable}}` syntax for template substitution:

```xml
<poml>
  <role>{{user_role}}</role>
  <task>Process {{count}} items</task>
</poml>
```

### XML Syntax Mode

Enable XML output mode:

```xml
<poml syntax="xml">
  <role>Consultant</role>
  <cp caption="Requirements">
    <list>
      <item>Requirement 1</item>
      <item>Requirement 2</item>
    </list>
  </cp>
</poml>
```

### Stylesheets

Customize component appearance:

```xml
<poml>
  <stylesheet>
  {
    "role": {
      "captionStyle": "bold",
      "caption": "System Role"
    }
  }
  </stylesheet>
  <role>Assistant</role>
</poml>
```

## Features

- ✅ Full POML component support
- ✅ Template variable substitution
- ✅ Multiple output formats (raw, dict, OpenAI chat, etc.)
- ✅ Document inclusion (.txt, .docx, .pdf)
- ✅ Image handling
- ✅ Table data processing
- ✅ XML syntax mode
- ✅ Stylesheet support
- ✅ Command-line interface
- ✅ Chat vs non-chat modes

## Document Support

The gem supports including external documents:

- **Text files** (.txt): Direct inclusion
- **Word documents** (.docx): Text extraction using system tools or zip parsing
- **PDF files** (.pdf): Text extraction using `pdftotext` (when available)

## Development

```bash
git clone https://github.com/GhennadiiMir/poml.git
cd poml
bundle install
```

Run tests:

```bash
# Run all tests
bundle exec ruby test/run_all_tests.rb

# Run main test suite
bundle exec ruby -I lib test/test_poml.rb

# Run tutorial examples tests  
bundle exec ruby -I lib test/test_tutorial_examples.rb
```

Build and install locally:

```bash
gem build poml.gemspec
gem install poml-0.0.1.gem
```

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
