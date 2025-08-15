# How to Test the poml Ruby Gem Locally with Example Files

1. **Install dependencies** (from the gem root):
	```sh
	bundle install
	```

2. **Open an IRB (interactive Ruby) session** in the gem root:

```sh
bundle exec irb -Ilib -rpoml
```

3. **Run the gem on an example file** (replace the path and context as needed):

```ruby
result = Poml.process(
  markup: "examples/101_explain_character.poml",
  context: { name: "World" },
  format: "raw"
)
puts result
```

You should see the rendered output with the context variable replaced.

If you want to run from a Ruby script, use the same code as above in a `.rb` file and run it with `bundle exec ruby your_script.rb`.
# POML Example Library

This directory contains example POML files demonstrating a variety of use cases. Examples are organized by difficulty:

- **Beginner:** Filenames start with `1XX_`
- **Intermediate:** Filenames start with `2XX_`
- **Advanced:** Filenames start with `3XX_`

Each example highlights different POML features, such as structured prompting, data handling, and templating.

Non-POML examples (e.g., Python or JavaScript scripts) are prefixed with `4XX_` and use appropriate file extensions. Inline comments explain their usage.

## Contributing

Contributions are welcome! To add or improve an example:

- Follow the naming conventions above.
- Include clear explanations and comments in your examples.
- Place any assets in an `assets/` subdirectory within the example's folder.
- If your example includes expected output, place it in an `expects/` subdirectory.

Submit your changes via pull request.

