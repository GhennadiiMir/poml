# Quick Start

Here's a very simple POML example. Please put it in a file named `example.poml`. Make sure it resides in the same directory as the `photosynthesis_diagram.png` image file.

```xml
<poml>
  <role>You are a patient teacher explaining concepts to a 10-year-old.</role>
  <task>Explain the concept of photosynthesis using the provided image as a reference.</task>

  <img src="photosynthesis_diagram.png" alt="Diagram of photosynthesis" />

  <output-format>
    Keep the explanation simple, engaging, and under 100 words.
    Start with "Hey there, future scientist!".
  </output-format>
</poml>
```

This example defines a role and task for the LLM, includes an image for context, and specifies the desired output format. With the POML toolkit, the prompt can be easily rendered with a flexible format, and tested with a vision LLM.

## YouTube Video

We also recommend watching our [YouTube video](https://youtu.be/b9WDcFsKixo) for a quick introduction to POML and how to get started.

## Next Steps

- [Learn POML Syntax](basic-usage.md): Understand the structure and syntax of POML with Ruby examples.
- [Explore Components](components/index.md): Discover the available components and how to use them.
- [Ruby SDK Guide](../ruby/index.md): Learn how to use POML in your Ruby applications.
- [Template Engine](template-engine.md): Learn about variables, conditionals, and loops in POML.
