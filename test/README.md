# Test Suite Documentation

The POML Ruby gem includes comprehensive test coverage to ensure reliability and compatibility.

## Test Structure

### Main Test Suite (`test/test_poml.rb`)

- **Basic functionality tests** - Core gem operations
- **Output format tests** - All 5 output formats (raw, dict, openai_chat, langchain, pydantic)
- **Template variable tests** - Context substitution and templating
- **Component tests** - Complex markup with lists, hints, paragraphs
- **Stylesheet tests** - Custom styling and formatting
- **File I/O tests** - Reading from files and writing output
- **Error handling tests** - Proper error catching and validation
- **Integration pattern tests** - Common usage patterns
- **Performance tests** - Basic performance validation

### Tutorial Examples Test Suite (`test/test_tutorial_examples.rb`)

- **All tutorial examples verification** - Every code example from TUTORIAL.md
- **Format-specific examples** - Detailed testing of each output format
- **Template patterns** - Dynamic content creation patterns
- **Integration examples** - Rails/Sinatra service patterns
- **Best practices** - Template organization and validation patterns
- **Real-world scenarios** - Practical usage patterns

## Test Framework

This project uses **Minitest**, Ruby's built-in testing framework, following standard Ruby testing conventions. The test suite is designed to be simple, fast, and comprehensive.

### Why Minitest?

- ✅ **Built-in**: Ships with Ruby, no extra dependencies
- ✅ **Simple**: Clean, readable test syntax
- ✅ **Fast**: Lightweight and efficient execution
- ✅ **Standard**: Follows Ruby community conventions
- ✅ **Flexible**: Supports multiple testing styles and options

## Running Tests

The test suite uses Minitest and can be run in several ways:

### Run All Tests (Recommended)

```bash
# Let Minitest discover and run all tests
bundle exec ruby -I lib test/run_all_tests.rb

# Alternative: use rake test (equivalent)
bundle exec rake test
```

### Run Individual Test Files

```bash
# Main functionality tests
bundle exec ruby -I lib test/test_poml.rb

# Tutorial examples validation
bundle exec ruby -I lib test/test_tutorial_examples.rb

# Specific debug/development tests
bundle exec ruby -I lib test/debug_comments.rb
```

### Using Minitest's Built-in Options

```bash
# Run with verbose output
bundle exec ruby -I lib test/run_all_tests.rb -v

# Run specific test methods
bundle exec ruby -I lib test/test_poml.rb -n test_basic_functionality

# Run with seed for reproducible results
bundle exec ruby -I lib test/run_all_tests.rb --seed 12345
```

## Test Coverage

The test suite covers:

✅ **All output formats** - Comprehensive testing of each format's behavior  
✅ **Template variables** - Context substitution and dynamic content  
✅ **Error handling** - Proper error catching and user-friendly messages  
✅ **File operations** - Input from files, output to files  
✅ **Component rendering** - All POML components and their combinations  
✅ **Integration patterns** - Real-world usage scenarios  
✅ **Performance** - Basic performance validation  
✅ **Tutorial examples** - Every code example from documentation works  

## Test Statistics

- **Main test suite**: 17 tests, 122+ assertions
- **Tutorial examples**: 14 tests, 90+ assertions  
- **Total**: 31 tests, 212+ assertions
- **Coverage**: All major functionality and tutorial examples

## Continuous Testing

These tests ensure that:

1. All documentation examples work correctly
2. The gem maintains compatibility with the original POML specification
3. New features don't break existing functionality
4. Integration patterns work in real applications
5. Performance remains acceptable

```bash
ruby -Ilib test/test_poml.rb
```

### `compatibility_checker.rb`

**Main compatibility test suite** - compares Ruby gem output with Python package expected outputs.

#### Features

- ✅ Tests all examples against Python package expectations
- 🔍 Identifies missing features vs. implementation bugs
- 📊 Provides detailed progress reports
- 🎯 Shows compatibility percentage
- 💡 Suggests next development steps
- 🎨 Color-coded output for easy reading

#### Usage

```bash
# Run all compatibility tests
ruby -Ilib test/compatibility_checker.rb

# Run with minitest
ruby -Ilib -r minitest/autorun test/compatibility_checker.rb

# Run via rake (if configured)
rake test
```

#### Output Interpretation

- **🟢 Passed**: Ruby gem output matches Python package exactly
- **🔴 Failed**: Ruby gem processes the file but output differs (formatting/logic issues)
- **🟡 Not Implemented**: Missing core features (document import, image handling, etc.)
- **💥 Errors**: Ruby gem crashes or fails to process

### `generate_ruby_expects.rb`

Utility to generate current Ruby gem outputs for debugging and comparison.

#### Usage

```bash
# Generate all Ruby outputs
ruby test/generate_ruby_expects.rb

# View help
ruby test/generate_ruby_expects.rb --help
```

#### Generated Files

- Saves to `examples/ruby_expects/`
- Compare with `examples/expects/` (Python outputs)
- Useful for manual inspection and debugging

## Test Data

The tests use the examples in `examples/` directory:

- `*.poml` files: POML source files
- `expects/*.txt`: Expected outputs from Python package
- `ruby_expects/*.txt`: Current Ruby gem outputs (generated)

## Example Test Output

```
🔍 Running POML Ruby Gem Compatibility Tests
Testing 10 examples against Python package expectations

📋 Testing: 101_explain_character
  ⚠️  NOT IMPLEMENTED
  Missing features: Document import, Image handling, System messages

📋 Testing: 102_render_xml
  ✅ PASSED

📋 Testing: 103_word_todos
  ❌ FAILED
  Differences found:
    • Missing section: system
    • Line 1: expected '===== system =====', got 'Role: You are a helpful assistant'

================================================================================
📊 POML Ruby Gem Compatibility Test Summary
================================================================================
✅ Passed: 2/10
❌ Failed: 3/10
⚠️  Not Implemented: 4/10
💥 Errors: 1/10

📈 Implementation Progress: 90% (9/10 features attempted)
🎯 Compatibility Rate: 20% (2/10 fully compatible)

💡 Next Steps for Development:
  • Focus on implementing: Document import, Image handling, System messages
  • Fix critical errors in: 201_orders_qa
  • Debug output formatting issues in: 103_word_todos, 104_financial_analysis
```

## Development Workflow

1. **Run compatibility tests** to see current state:

   ```bash
   ruby -Ilib test/compatibility_checker.rb
   ```

2. **Identify highest-impact missing features** from the report

3. **Implement features** in the Ruby gem

4. **Generate Ruby outputs** to debug:

   ```bash
   ruby test/generate_ruby_expects.rb
   ```

5. **Compare outputs manually**:

   ```bash
   diff examples/expects/101_explain_character.txt examples/ruby_expects/101_explain_character.txt
   ```

6. **Re-run tests** to verify improvements

## Debugging Tips

- **Missing features**: Check the "Not Implemented" list for core features to add
- **Format differences**: Look at actual vs expected output for formatting issues
- **Parser errors**: Check if POML syntax parsing is working correctly
- **Component support**: Verify that POML components (role, task, etc.) are implemented

## Adding New Tests

To add tests for new examples:

1. Add `.poml` file to `examples/`
2. Generate expected output with Python package
3. Add to `examples/expects/`
4. Tests will automatically pick up new files

## Integration with CI/CD

These tests are designed to track implementation progress over time. Consider:

- Running in CI to prevent regressions
- Tracking compatibility percentage over time
- Failing builds when compatibility drops
- Using for release readiness assessment
