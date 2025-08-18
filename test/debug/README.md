# Debug Scripts

This directory contains debugging and development scripts used during POML Ruby gem development.

## Files

### Component Debugging

- `test_chat_debug.rb` - Debug chat component rendering with verbose output
- `test_meta_debug.rb` - Debug meta component processing and schema handling
- `test_render_debug.rb` - Debug the overall rendering pipeline
- `test_debug_for.rb` - Debug for component with detailed substitution logging
- `test_for_debug.rb` - Debug for loop children creation and processing
- `test_child_context.rb` - Debug child context variable access and inheritance

### Feature Testing

- `test_debug.rb` - General template evaluation debugging
- `test_arrays.rb` - Debug array variable evaluation in templates
- `test_implementation.rb` - Test current formatting component implementations
- `test_templates.rb` - Test template engine with variable substitution

## Usage

These scripts can be run individually for debugging specific components:

```bash
# Debug template evaluation
ruby -Ilib test/debug/test_debug.rb

# Debug chat components
ruby -Ilib test/debug/test_chat_debug.rb

# Debug for loops
ruby -Ilib test/debug/test_debug_for.rb
```

## Purpose

These debug scripts help developers:

- Understand component behavior during development
- Trace template variable substitution
- Debug parsing and rendering issues
- Test specific component implementations

**Note**: These are development tools, not part of the main test suite.
