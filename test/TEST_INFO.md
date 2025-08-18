# POML Ruby Test Information

## Quick Reference

### ✅ Running Stable Tests (Recommended)

```bash
bundle exec rake test        # 33 tests, 215 assertions, 0 failures
bundle exec rake             # Same as above (default task)
bundle exec rake test_working # Same as above (legacy alias)
```

### 🔧 Running All Tests (Development)

```bash
bundle exec rake test_all    # 161+ tests, ~128 failures (expected)
```

### 📊 Test Status Summary

**Stable Test Suite**: 3 files, 33 tests, 215 assertions - **ALL PASSING** ✅

- `test_basic_functionality.rb` - Core formatting and chat components
- `test_implemented_features.rb` - Current working features  
- `test_real_implementation.rb` - Comprehensive real-world scenarios

**Development Test Suite**: 15 total test files

- **3 files PASSING** (included in stable suite)
- **12 files FAILING** (testing unimplemented features)

### 🎯 Features Tested and Working

- ✅ **Chat Components**: `<ai>`, `<human>`, `<system>`
- ✅ **Basic Formatting**: `<b>` (bold), `<i>` (italic)
- ✅ **Output Formats**: `raw`, `dict`, `openai_chat`
- ✅ **Error Handling**: Graceful unknown component handling
- ✅ **Unicode Support**: Full UTF-8 character support
- ✅ **Edge Cases**: Empty markup, malformed XML, whitespace

### ⚠️ Features with Failing Tests (Not Yet Implemented)

- ❌ **Template Engine**: Variable substitution, loops, conditions
- ❌ **Data Components**: Table rendering from JSON/CSV
- ❌ **File Operations**: File reading, folder listing
- ❌ **Advanced Formatting**: Underline, strikethrough, headers
- ❌ **Utility Components**: Tree display, conversation formatting

### 🔧 Test Development Guidelines

1. **Always ensure stable tests pass**: `bundle exec rake test` should never fail
2. **Work incrementally**: Implement one component at a time
3. **Move tests to stable**: As features are implemented, move test files to stable suite
4. **Use bundle exec**: Avoids gem version conflicts
5. **Follow Ruby conventions**: Minitest and Rake best practices

See `ROADMAP.md` for complete feature implementation status and testing strategy.
