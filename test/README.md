# POML Ruby Gem Tests

> **📖 For comprehensive testing documentation, see [TESTING_GUIDE.md](TESTING_GUIDE.md)**

This directory contains the test suite for the POML Ruby gem. The tests are organized to support both stable CI/CD pipelines and active development.

## Quick Start

```bash
# Run stable tests (CI/CD)
bundle exec rake test

# Run all tests (development)
bundle exec rake test_all

# Run specific test file
bundle exec ruby -I lib test/test_basic_functionality.rb
```

## Current Status

- ✅ **177 stable tests** passing (16 test files, 834 assertions)
- ⚠️ **88+ development tests** with expected failures for unimplemented features
- 🎯 **Test-driven development** approach with clear stable/development separation

## Test Organization

```
test/
├── TESTING_GUIDE.md              # 📖 Comprehensive testing documentation
├── test_*.rb                     # Production test files
├── fixtures/                     # Test data and examples
├── debug/                        # Development and debug scripts
└── support/                      # Test helpers and utilities
```

## Documentation

- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Complete testing guide with execution strategies, development workflow, and contribution guidelines
- **[TEST_STRUCTURE_RECOMMENDATIONS.md](TEST_STRUCTURE_RECOMMENDATIONS.md)** - Analysis and recommendations for test restructuring

For detailed information about test execution, development workflow, debugging, and contributing to the test suite, please refer to the comprehensive [Testing Guide](TESTING_GUIDE.md).
