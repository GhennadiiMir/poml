# POML Ruby Gem - Test Suite

Test suite for the POML Ruby gem with comprehensive coverage of all implemented features.

## Running Tests

### All Tests

```bash
bundle exec rake test
```

### Specific Test Files

```bash
# Single test file
bundle exec rake test test/test_basic_functionality.rb

# Multiple test files  
bundle exec rake test test/test_basic_functionality.rb test/test_template_engine.rb test/test_enhanced_tool_registration.rb

# Alternative method (single file only)
bundle exec ruby -I lib:test test/test_basic_functionality.rb

# Run specific test method
bundle exec ruby -I lib:test test/test_basic_functionality.rb -n test_specific_method_name
```

## Current Status

- ✅ **303 tests** passing (25 test files, 1681 assertions)
- ✅ **ALL TESTS PASSING** - 0 failures, 0 errors, 0 skips
- ✅ **Enhanced tool registration** with runtime parameter conversion and key conversion
- ✅ **Complete feature coverage** including chat components, formatting, template engine, file operations, and schema components

## Writing Tests

### Test File Template

```ruby
require_relative 'test_helper'

class TestNewFeature < Minitest::Test
  include TestHelper

  def test_basic_functionality
    markup = '<new-component>content</new-component>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'expected content'
  end

  def test_component_with_attributes
    markup = '<new-component attr="value">content</new-component>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_equal 'expected output', result
  end

  def test_error_handling
    markup = '<new-component invalid="true">content</new-component>'
    result = Poml.process(markup: markup, format: 'raw')
    # Test graceful error handling
    assert_includes result, 'content'
  end
end
```

### Test Helper Methods

Available in `test_helper.rb`:

```ruby
# Test POML processing with different output formats
assert_poml_output(markup, expected, format: 'raw')
assert_poml_output(markup, expected, format: 'dict') 
assert_poml_output(markup, expected, format: 'openai_chat')

# Load test fixture files
load_fixture('example.poml')
fixture_path('data.json')

# Create temporary test files
create_temp_poml_file(content)
```

## Test Organization

```
test/
├── README.md                     # This guide
├── test_helper.rb               # Test utilities and setup
├── test_*.rb                    # All test files (25 files)
├── fixtures/                    # Test data and examples
└── debug/                       # Development and debug scripts
```

### Key Test Files

- `test_basic_functionality.rb` - Core formatting and chat components
- `test_template_engine.rb` - Variables, conditionals, loops
- `test_enhanced_tool_registration.rb` - Enhanced tool registration features
- `test_new_schema_components.rb` - Schema components (output-schema, tool-definition)
- `test_file_components.rb` - File reading operations
- `test_table_component.rb` - Table rendering from JSON/CSV
- `test_error_handling.rb` - Error scenarios and graceful failures

## Development Guidelines

### Naming Conventions

- **Test files**: `test_feature_name.rb`
- **Test classes**: `TestFeatureName < Minitest::Test`  
- **Test methods**: `test_specific_behavior_description`

### Best Practices

1. **Test files must be self-contained** - Include all necessary setup
2. **Use descriptive test names** - Explain what behavior is being tested
3. **Test both success and error cases** - Ensure robust error handling
4. **Include TestHelper** - For consistent test utilities
5. **Follow Ruby conventions** - Standard Minitest patterns and assertions

### Adding New Tests

1. Create test file following naming convention
2. Include `TestHelper` for utilities
3. Write comprehensive test cases covering normal and edge cases
4. Ensure all tests pass before committing

---

**Current Status**: 303 tests, 1681 assertions, 0 failures  
**Framework**: Minitest  
**Ruby Compatibility**: >= 2.7.0
