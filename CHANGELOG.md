# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.5] - 2025-08-21

### 🔄 Breaking Changes Compatibility

- **Schema Syntax Update**: Added support for new `parser` attribute syntax while maintaining backward compatibility
  - Support for new `parser="json"` and `parser="eval"` attributes
  - Maintained backward compatibility with legacy `lang="json"` and `lang="expr"` syntax
  - `parser` attribute takes precedence when both are present
  - Addresses breaking changes in original POML library

### Added

- **Schema Compatibility**: Comprehensive backward compatibility for schema definitions
- **Enhanced Meta Component**: Updated to handle both old and new schema syntax
- **Test Suite Expansion**: Added 12 comprehensive schema compatibility tests (62 assertions)
- **Example Files**:
  - `examples/301_new_schema_syntax.poml` - demonstrates new schema syntax
  - `examples/302_schema_compatibility.poml` - shows backward compatibility
- **Documentation Updates**: Updated README and ROADMAP to reflect compatibility changes

### Enhanced

- **Tool Registration**: Improved tool definition parsing with new syntax support
- **Error Handling**: Enhanced error handling in components and parser
- **Method Signatures**: Updated for future extensibility
- **List Components**: Fixed markdown formatting with proper nested content handling
- **Utility Components**: Enhanced conversation component with role/speaker support
- **Template Engine**: Improved meta variables support and template substitution

### Fixed

- **Meta Component**: Removed from void elements list, now properly processes content and variables
- **Test Assertions**: Improved clarity and reliability of test assertions
- **Component Rendering**: Better handling of nested content in list and utility components

### Developer Experience

- **Test Coverage**: Expanded to 111 tests with improved stability
- **Code Quality**: Refactored error handling and component architecture
- **Compatibility**: Seamless migration path for existing POML documents

## [0.0.3] - 2025-08-19

### Added

- Complete FileComponent implementation with comprehensive file operations support
- Enhanced folder handling capabilities for directory operations
- Improved file reading, writing, and management features
- Comprehensive debug documentation with implementation summaries
- Enhanced test coverage for file operations and table components

### Enhanced

- TableComponent with improved attribute parsing and error handling
- Better validation and error reporting for table data processing
- Enhanced utility components with expanded functionality
- Improved component registration and loading mechanisms

### Changed

- Updated ROADMAP with detailed progress tracking and implementation status
- Enhanced Rakefile with improved task definitions and build processes
- Refined component architecture for better maintainability

### Fixed

- Improved error handling in table component parsing
- Enhanced attribute validation and processing
- Better handling of edge cases in file operations

## [0.0.2] - 2025-08-18

### Added

- Comprehensive test suite with improved coverage
- Enhanced component handling for formatting and media components
- New utility components for better template processing
- Improved meta component handling for structured data
- Enhanced template engine features
- Better error handling and validation
- Comprehensive examples and documentation improvements

### Changed

- Updated ROADMAP with current implementation status
- Consolidated test organization and improved test helpers
- Enhanced components and context for structured chat messages
- Improved metadata handling across components

### Fixed

- Various bug fixes in component rendering
- Improved template substitution reliability
- Enhanced error messages and debugging information

### Documentation

- Updated README with clearer installation and usage instructions
- Enhanced test documentation and guidelines
- Improved component documentation

## [0.0.1] - 2025-08-15

### Initial Release

- Initial release of POML Ruby gem
- Complete POML Ruby implementation with core functionality
- Support for all major POML components
- Template engine with variable substitution
- Multiple output formats (dict, openai_chat, langchain, pydantic)
- Command-line interface
- Comprehensive examples and documentation
- Ruby-specific optimizations and patterns
