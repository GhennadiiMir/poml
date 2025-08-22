# POML Ruby Gem Documentation

Welcome to the POML Ruby Gem documentation - a Ruby implementation of the Prompt Orchestration Markup Language (POML).

**POML (Prompt Orchestration Markup Language)** is a novel markup language designed to bring structure, maintainability, and versatility to advanced prompt engineering for Large Language Models (LLMs). This Ruby gem provides full compatibility with the original POML specification.

## About This Implementation

This is a **Ruby port** of the original [POML library](https://github.com/microsoft/poml) developed by Microsoft. This Ruby gem is designed to be **fully compatible** with the original POML specification and closely follows the development of the original library to maintain feature parity.

## Key Features

* **Structured Prompting Markup**: Employs an HTML-like syntax with semantic components such as `<role>`, `<task>`, and `<example>` to encourage modular design, enhancing prompt readability, reusability, and maintainability.
* **Comprehensive Data Handling**: Incorporates specialized data components (e.g., `<document>`, `<table>`, `<img>`) that seamlessly embed or reference external data sources like text files, spreadsheets, and images, with customizable formatting options.
* **Decoupled Presentation Styling**: Features a CSS-like styling system that separates content from presentation. This allows developers to modify styling via `<stylesheet>` definitions or inline attributes without altering core prompt logic.
* **Integrated Templating Engine**: Includes a built-in templating engine with support for variables (`{{ }}`), loops (`for`), conditionals (`if`), and variable definitions (`<let>`) for dynamically generating complex, data-driven prompts.
* **Ruby Integration**: Provides seamless integration into Ruby applications with a clean API for embedding POML into your Ruby workflows.

## Quick Start

Install the gem:

```bash
gem install poml
```

Basic usage:

```ruby
require 'poml'

# Process a POML document
result = Poml.process(markup: '<poml><role>Assistant</role><task>Help users</task></poml>')
puts result['content']
```

## Documentation Sections

* [Tutorial](./tutorial/quickstart.md): Get started with POML syntax and structure
* [Language Reference](./language/standalone.md): Complete POML language documentation
* [Components](./language/components.md): Available POML components and their usage
* [Meta Elements](./language/meta.md): Document metadata and configuration
* [Ruby SDK](./ruby/index.md): Ruby-specific integration guide
* [Deep Dive](./deep-dive/ir.md): Internal representation and advanced topics

## Original Library Resources

For comprehensive examples and additional documentation, please refer to the **original POML library**:

* 📚 **Main Repository**: <https://github.com/microsoft/poml>
* 📖 **Documentation**: [Complete language reference and guides](https://microsoft.github.io/poml/latest/)
* 💡 **Examples**: Extensive collection of POML examples
* 🎯 **Use Cases**: Real-world applications and patterns

## Research Papers

* **Prompt Orchestration Markup Language** — Introduces POML with component-based markup, specialized data tags, CSS-like styling, templating, and developer tooling. [arXiv:2508.13948](https://arxiv.org/abs/2508.13948)
* **Beyond Prompt Content: Enhancing LLM Performance via Content-Format Integrated Prompt Optimization** — Presents an iterative method that jointly optimizes prompt content and formatting, yielding measurable gains across tasks. [arXiv:2502.04295](https://arxiv.org/abs/2502.04295)

## Implementation Status

Please refer to [ROADMAP.md](../ROADMAP.md) for understanding which features are already implemented in this Ruby gem.

## Community

Join our Discord community: Connect with the team and other users on our [Discord server](https://discord.gg/FhMCqWzAn6).
