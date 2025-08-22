# POML Ruby Gem Test Guide

This is the comprehensive testing guide for the POML Ruby gem. It covers test execution, development workflow, and contribution guidelines.

## Quick Reference

### Running Tests

**Stable Test Suite (Recommended for CI/CD)**:

```bash
bundle exec rake test        # 123 tests, 590 assertions, 0 failures
bundle exec rake             # Same as above (default task)
```

**Development Test Suite**:

```bash
bundle exec rake test_all    # 211+ tests, ~15+ failures (expected)
```

**Individual Test Files**:

```bash
# Core functionality
bundle exec ruby -I lib test/test_basic_functionality.rb

# Template engine  
bundle exec ruby -I lib test/test_template_engine.rb

# Schema components
bundle exec ruby -I lib test/test_new_schema_components.rb

# All working features
bundle exec ruby -I lib test/test_implemented_features.rb
```

### Test Status Summary

**✅ Stable Tests**: 11 files, 123 tests, 590 assertions - **ALL PASSING**

- `test_basic_functionality.rb` - Core formatting and chat components
- `test_implemented_features.rb` - Current working features  
- `test_real_implementation.rb` - Comprehensive real-world scenarios
- `test_formatting_components.rb` - All formatting components (bold, italic, underline, etc.)
- `test_table_component.rb` - Table rendering from JSON/CSV with all features
- `test_file_components.rb` - File reading operations with path resolution
- `test_utility_components.rb` - Utility components (conversation, tree, lists)
- `test_meta_component.rb` - Metadata handling and template variables
- `test_template_engine.rb` - Template engine with variables, conditionals, and loops
- `test_new_schema_components.rb` - New schema components (output-schema, tool-definition)
- `test_schema_compatibility.rb` - Schema backward compatibility

**⚠️ Development Tests**: 8 additional files with unimplemented features

- `test_chat_components.rb` - Advanced chat features
- `test_error_handling.rb` - Comprehensive error scenarios  
- `test_new_components.rb` - New/experimental components
- `test_poml.rb` - Legacy comprehensive tests
- `test_tutorial_examples.rb` - Tutorial examples
- `test_actual_behavior.rb` - Actual behavior tests
- `test_new_schema_components.rb` - New schema components (✅ **NOW PASSING**)
- `test_schema_compatibility.rb` - Schema backward compatibility (✅ **NOW PASSING**)

## Test Framework

This project uses **Minitest**, Ruby's built-in testing framework, following standard Ruby testing conventions.

### Why Minitest?

- ✅ **Built-in**: Ships with Ruby, no extra dependencies
- ✅ **Simple**: Clean, readable test syntax  
- ✅ **Fast**: Lightweight and efficient execution
- ✅ **Standard**: Follows Ruby community conventions
- ✅ **Flexible**: Supports multiple testing styles and options

### Test Helper Utilities

The test suite includes comprehensive helper methods in `test/test_helper.rb`:

```ruby
# Fixture management
fixture_path()                    # Get fixtures directory path
load_fixture(filename)            # Load test data files
create_temp_poml_file(content)    # Create temporary .poml files

# Assertion helpers
assert_poml_output(markup, expected, format: 'raw')  # Test POML processing
assert_valid_openai_chat(result)                     # Validate chat format
assert_valid_dict_format(result)                     # Validate dict format
```

## Features Tested and Working

### ✅ Core Components

- **Chat Components**: `<ai>`, `<human>`, `<system>`
- **Basic Formatting**: `<b>` (bold), `<i>` (italic), `<u>` (underline), `<s>` (strikethrough)
- **Headers**: `<h1>` through `<h6>`
- **Code**: `<code>` inline code formatting
- **Line Breaks**: `<br>` and `<br/>`

### ✅ Data Components

- **Tables**: `<table>` with JSON/CSV data, column selection, record limits
- **Files**: `<file>` content reading with path resolution and error handling
- **Folders**: `<folder>` directory listing with depth control and filtering

### ✅ Utility Components

- **Lists**: `<list>` and `<item>` with proper markdown formatting
- **Conversations**: `<conversation>` with role/speaker support
- **Trees**: `<tree>` structure display with JSON data

### ✅ Template Engine

- **Variables**: `{{variable}}` substitution from context
- **Conditionals**: `<if condition="">` with comparisons (>=, <=, ==, !=, >, <)
- **Loops**: `<for variable="" items="">` iteration over arrays
- **Meta Variables**: `<meta variables="">` template variables definition

### ✅ Schema Components (NEW)

- **Output Schema**: `<output-schema>` for AI response definitions
- **Tool Definitions**: `<tool-definition>` for AI tool registration  
- **Backward Compatibility**: `<meta type="output-schema">` and `<meta type="tool-definition">`
- **Parser Support**: Both `lang` and `parser` attributes (JSON/eval)

### ✅ Output Formats

- **Raw**: Plain text with markdown formatting
- **Dict**: Hash with content key and metadata
- **OpenAI Chat**: Array of chat message objects

### ✅ Infrastructure

- **Error Handling**: Graceful unknown component handling
- **Unicode Support**: Full UTF-8 character support
- **XML Parsing**: REXML-based parser with JSON attribute support
- **Component Registry**: Dynamic component mapping with enhanced lookup

## Development Workflow

### Test Organization Strategy

The test suite is organized for stability and development efficiency:

**Stable Tests** (`bundle exec rake test`):

- Only tests that pass with current implementation
- Used for CI/CD to ensure reliability
- Should never fail

**Development Tests** (`bundle exec rake test_all`):

- Includes tests for unimplemented features
- Used for development to see what needs to be implemented
- Expected to have failures

### Adding New Features

1. **Start with failing tests** - Write tests for the new feature first
2. **Implement incrementally** - Make one test pass at a time
3. **Move to stable** - Once working, add test file to stable rake task
4. **Maintain stability** - Ensure `bundle exec rake test` always passes

### Debug and Development Scripts

All debug scripts are organized in `test/debug/` directory:

**Component Debugging**:

```bash
bundle exec ruby -I lib test/debug/test_chat_debug.rb    # Chat components
bundle exec ruby -I lib test/debug/test_meta_debug.rb    # Meta components  
bundle exec ruby -I lib test/debug/debug_components.rb   # Component registry
```

**Template Engine Debugging**:

```bash
bundle exec ruby -I lib test/debug/test_debug.rb         # General templates
bundle exec ruby -I lib test/debug/debug_template.rb     # Template processing
bundle exec ruby -I lib test/debug/debug_for_iterations.rb # For loops
```

**Parser Debugging**:

```bash
bundle exec ruby -I lib test/debug/debug_parse.rb        # POML parsing
bundle exec ruby -I lib test/debug/debug_xml.rb          # XML parsing
bundle exec ruby -I lib test/debug/debug_preprocess.rb   # Preprocessing
```

### File Organization Rules

- **`test/`** - Production test files only (`test_*.rb`)
- **`test/debug/`** - All debug and development scripts
- **`test/fixtures/`** - Test data and fixture files
- **Never mix debug scripts with production tests**

## Test Execution Options

### Using Minitest Options

```bash
# Verbose output
bundle exec ruby -I lib test/run_all_tests.rb -v

# Run specific test methods
bundle exec ruby -I lib test/test_basic_functionality.rb -n test_basic_bold_formatting

# Set random seed for reproducible results
bundle exec ruby -I lib test/run_all_tests.rb --seed 12345

# Show test names as they run
bundle exec ruby -I lib test/test_template_engine.rb --verbose
```

### Using Rake Tasks

```bash
bundle exec rake test           # Stable tests only (99 tests)
bundle exec rake test_working   # Same as above (legacy alias)
bundle exec rake test_all       # All tests including failing ones (211+ tests)
bundle exec rake                # Default task (same as rake test)
```

## Contributing Guidelines

### Adding New Tests

1. **Follow naming conventions**: `test_*.rb` for test files
2. **Include TestHelper**: `include TestHelper` in test classes
3. **Use descriptive test names**: `test_feature_specific_behavior`
4. **Add documentation**: Update this guide when adding new test categories

### Test File Templates

**Basic Test File**:

```ruby
require_relative 'test_helper'

class TestNewFeature < Minitest::Test
  include TestHelper

  def test_basic_functionality
    markup = '<new-component>content</new-component>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'expected content'
  end
end
```

**Component Test File**:

```ruby
require_relative 'test_helper'

class TestComponentName < Minitest::Test
  include TestHelper

  def test_component_rendering
    # Test basic rendering
  end

  def test_component_attributes
    # Test attribute handling
  end

  def test_component_edge_cases
    # Test error conditions
  end
end
```

### Debug Script Guidelines

1. **Always place in `test/debug/`** directory
2. **Use descriptive filenames**: `debug_specific_feature.rb`
3. **Add comments**: Explain what the script debugs
4. **Keep focused**: One script per debugging concern

## Troubleshooting

### Common Issues

**Gem Version Conflicts**:

```bash
# Always use bundle exec to avoid conflicts
bundle exec rake test
bundle exec ruby -I lib test/test_file.rb
```

**Test Failures in Development**:

```bash
# Check if it's a stable vs development test issue
bundle exec rake test        # Should always pass
bundle exec rake test_all    # May have failures (expected)
```

**Missing Fixtures**:

```bash
# Check fixtures directory exists and has required files
ls test/fixtures/
```

**Ruby Warnings**:

```bash
# The -w flag in Rakefile shows warnings (this is intentional)
# Fix assigned but unused variable warnings when possible
```

### Getting Help

1. **Check ROADMAP.md** - See current implementation status
2. **Run debug scripts** - Use appropriate debug script for your issue
3. **Check test output** - Use `-v` flag for verbose output
4. **Isolate the problem** - Run specific test files to narrow down issues

## Performance and Metrics

### Current Performance

- **Stable test suite**: ~0.05 seconds (123 tests, 590 assertions)
- **Full test suite**: ~0.1 seconds (235+ tests)
- **Individual test files**: Usually < 0.01 seconds

### Test Statistics

- **Total test files**: 19 (11 stable + 8 development)
- **Stable tests**: 123 tests, 590 assertions, 0 failures
- **Development tests**: 112+ additional tests (~15+ failures expected)
- **Coverage**: Comprehensive coverage of all implemented features

### Monitoring

Monitor test performance and adjust if:

- Stable tests take > 5 seconds
- Individual test files take > 1 second  
- Memory usage becomes excessive

## Integration with ROADMAP

This test suite supports the development strategy outlined in `ROADMAP.md`:

- **Stable tests** ensure reliability for implemented features
- **Development tests** guide implementation priorities
- **Test statistics** track progress toward full feature parity
- **Clear organization** supports incremental development approach

For detailed feature implementation status, see [ROADMAP.md](../ROADMAP.md).

---

**Last Updated**: December 10, 2024 - Schema Components and Backward Compatibility Testing Complete  
**Next Review**: When new major features are implemented or test organization changes
