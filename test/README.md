# Test Suite Documentation

The POML Ruby gem includes comprehensive test coverage to ensure reliability and compatibility.

## Test Structure

### Main Test Suite (`test/test_poml.rb`)

- **Basic functionality tests** - Core gem operations
- **Output format tests** - Available output formats (raw, dict, openai_chat)
- **Template variable tests** - Context substitution and templating
- **Component tests** - Complex markup with lists, hints, paragraphs
- **Stylesheet tests** - Custom styling and formatting
- **File I/O tests** - Reading from files and writing output
- **Error handling tests** - Proper error catching and validation
- **Integration pattern tests** - Common usage patterns
- **Performance tests** - Basic performance validation

### Additional Test Files

- **`test_basic_functionality.rb`** - Core formatting and chat components
- **`test_template_engine.rb`** - Template variables, loops, conditions
- **`test_formatting_components.rb`** - Text formatting components
- **`test_chat_components.rb`** - Chat message components
- **`test_table_component.rb`** - Table rendering from JSON/CSV
- **`test_file_components.rb`** - File reading operations
- **`test_utility_components.rb`** - Utility components (folder, tree, conversation)
- **`test_meta_component.rb`** - Metadata handling
- **`test_error_handling.rb`** - Error scenarios
- **`test_new_components.rb`** - New/experimental components
- **`test_implemented_features.rb`** - Currently working features
- **`test_real_implementation.rb`** - Real-world scenarios

## Test Framework

This project uses **Minitest**, Ruby's built-in testing framework, following standard Ruby testing conventions. The test suite is designed to be simple, fast, and comprehensive.

### Why Minitest?

- ✅ **Built-in**: Ships with Ruby, no extra dependencies
- ✅ **Simple**: Clean, readable test syntax
- ✅ **Fast**: Lightweight and efficient execution
- ✅ **Standard**: Follows Ruby community conventions
- ✅ **Flexible**: Supports multiple testing styles and options

## Running Tests

The test suite uses Minitest and can be run in several ways. Use `bundle exec` to avoid gem version conflicts:

### Run All Tests (Recommended)

```bash
# Let Minitest discover and run all tests
bundle exec ruby -I lib test/run_all_tests.rb

# Alternative: use specific test runner
bundle exec ruby test/run_tests.rb
```

### Run Individual Test Files

```bash
# Main functionality tests
bundle exec ruby -I lib test/test_poml.rb

# Template engine tests
bundle exec ruby -I lib test/test_template_engine.rb

# Basic functionality tests
bundle exec ruby -I lib test/test_basic_functionality.rb

# Formatting components tests
bundle exec ruby -I lib test/test_formatting_components.rb
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

✅ **Available output formats** - Comprehensive testing of implemented formats (raw, dict, openai_chat)  
✅ **Template variables** - Context substitution and dynamic content  
✅ **Error handling** - Proper error catching and user-friendly messages  
✅ **File operations** - Input from files, output to files  
✅ **Component rendering** - All POML components and their combinations  
✅ **Integration patterns** - Real-world usage scenarios  
✅ **Performance** - Basic performance validation  
✅ **Documentation examples** - Code examples from documentation work  

## Test Statistics

Current test suite status (see [ROADMAP.md](../ROADMAP.md) for detailed breakdown):

- **Passing tests**: 157 tests passing
- **Failing tests**: 30 tests failing  
- **Error tests**: 2 tests with errors
- **Total coverage**: 187 tests, 969 assertions
- **Implementation progress**: Core template engine and basic components working

## Simple Test Execution

For basic testing (note: may have gem conflicts, prefer bundle exec):

```bash
# Basic test without bundle exec (may have version conflicts)
ruby -I lib test/test_poml.rb

# Recommended approach with bundle exec
bundle exec ruby -I lib test/test_poml.rb
```

## Development Testing

The test suite includes debug scripts in the `test/debug/` directory for development purposes.

### Debug Script Organization Rule

**All debug and development scripts should be placed in the `test/debug/` directory.**

Do not create debug files in the main `test/` directory. This keeps:

- Main test files clean and focused on actual testing
- Debug utilities organized and easy to find  
- Clear separation between production tests and development tools

### Debug Script Categories

#### Component Debugging

- `test_chat_debug.rb` - Debug chat component rendering with verbose output
- `test_meta_debug.rb` - Debug meta component processing and schema handling
- `test_render_debug.rb` - Debug the overall rendering pipeline
- `test_debug_for.rb` - Debug for component with detailed substitution logging
- `test_for_debug.rb` - Debug for loop children creation and processing
- `test_child_context.rb` - Debug child context variable access and inheritance
- `debug_components.rb` - Debug component registration and basic rendering
- `debug_meta_flow.rb` - Debug meta component processing flow

#### Template Engine Debugging

- `test_debug.rb` - General template evaluation debugging
- `test_templates.rb` - Test template engine with variable substitution
- `debug_template.rb` - Debug template processing
- `debug_template2.rb` - Additional template debugging
- `debug_for_iterations.rb` - Debug for loop iteration details
- `debug_if.rb` - Debug conditional logic processing
- `debug_var_condition.rb` - Debug variable conditions in templates

#### Parser and XML Debugging

- `debug_parse.rb` - Debug POML parsing logic
- `debug_markup.rb` - Debug markup processing
- `debug_xml.rb` - Debug XML parsing
- `debug_xml2.rb` - Additional XML debugging
- `debug_xml_less_than.rb` - Debug XML less-than operator handling
- `debug_preprocess.rb` - Debug preprocessing steps

#### Feature Testing and Analysis

- `test_arrays.rb` - Debug array variable evaluation in templates
- `test_implementation.rb` - Test current formatting component implementations
- `debug_assertion.rb` - Debug assertion failures
- `debug_failing_test.rb` - Debug specific failing tests
- `debug_fixture.rb` - Debug test fixture handling
- `debug_spacing.rb` - Debug whitespace and spacing issues
- `debug_substring.rb` - Debug string manipulation
- `debug_convert_operand.rb` - Debug operand conversion logic

### Running Debug Scripts

Debug scripts can be run individually for debugging specific components:

```bash
# Debug template evaluation
bundle exec ruby -I lib test/debug/test_debug.rb

# Debug chat components  
bundle exec ruby -I lib test/debug/test_chat_debug.rb

# Debug for loops
bundle exec ruby -I lib test/debug/test_debug_for.rb

# Debug XML parsing
bundle exec ruby -I lib test/debug/debug_xml.rb

# Test current implementations
bundle exec ruby -I lib test/debug/test_implementation.rb

# Debug specific failing tests
bundle exec ruby -I lib test/debug/debug_failing_test.rb
```

### Purpose of Debug Scripts

These debug scripts help developers:

- Understand component behavior during development
- Trace template variable substitution step-by-step
- Debug parsing and rendering issues with verbose output
- Test specific component implementations in isolation
- Analyze assertion failures and test issues
- Investigate XML parsing and preprocessing problems

**Note**: These are development tools, not part of the main test suite.

## Continuous Testing

These tests ensure that:

1. Core POML functionality works correctly
2. The gem maintains compatibility with the original POML specification  
3. New features don't break existing functionality
4. Integration patterns work in real applications
5. Performance remains acceptable

## Adding New Tests

To add tests for new features:

### Production Tests

1. Create test file in `test/` directory following `test_*.rb` naming convention
2. Include `TestHelper` module for common utilities
3. Add tests to appropriate test runner files
4. Update this documentation

### Debug Scripts

1. **Always create debug files in `test/debug/` directory** following these naming conventions:
   - `debug_*.rb` for specific debugging utilities
   - `test_*.rb` for debug test scripts
2. Add descriptive comments explaining the debug purpose
3. Update `test/debug/README.md` with the new script description
4. Follow the categorization (Component, Template Engine, Parser, Feature Testing)

### File Organization Rules

- **`test/`** - Production test files only (`test_*.rb`)
- **`test/debug/`** - All debug and development scripts  
- **`test/fixtures/`** - Test data and fixture files
- **Never mix debug scripts with production tests**

## Integration with Development

The test suite is designed to support development workflow:

- Run tests frequently during development
- Use debug scripts to trace specific issues
- Check ROADMAP.md for current implementation status
- Focus on failing tests for next implementation priorities

### Reorganization Complete

**All debug scripts have been consolidated into `test/debug/` directory.**

This reorganization provides:

- ✅ Clean separation between production tests and debug utilities
- ✅ Easy discovery of debug tools by category
- ✅ Consistent file organization following Ruby conventions
- ✅ Clear documentation of debug script purposes and usage

**Going forward**: Always place debug and development scripts in `test/debug/` directory.
