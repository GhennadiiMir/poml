# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Breaking Changes

- **Tools Structure Change**: Moved tools from `result['metadata']['tools']` to `result['tools']` to align with original POML library structure
  - ⚠️ **Action Required**: Update code accessing `result['metadata']['tools']` to use `result['tools']`
  - This change ensures full compatibility with the original TypeScript/Node.js POML implementation
  - Matches the `CliResult` interface: `{ messages, schema?, tools?, runtime? }`

### Added

- **Structural Compatibility**: Complete alignment with original POML library architecture
  - Tools positioning now matches original implementation exactly
  - Chat components properly handle raw format rendering (return empty content for structured messages)
  - Comprehensive batch test updates for 372+ test files

### Fixed

- **Chat Components**: Fixed `<ai>`, `<human>`, `<system>` components to return empty content in raw format
  - These components are structured messages and should not render content in raw format
  - Proper handling of chat boundaries in different output formats
- **Tool Registration**: Enhanced tool component processing and metadata integration
- **Test Suite Compatibility**: 78.4% of test suite now passing (29/37 test files)
  - Tool Registration Tests: 7/7 passing
  - Schema Compatibility Tests: 16/16 passing
  - Tutorial Integration Tests: 4/4 passing  
  - Main Test Suite: 35/35 tests passing (252 assertions)
  - Core Functionality: 10/10 tests passing (112 assertions)

### Enhanced

- **Performance Testing Suite**: New `test_performance.rb` with comprehensive performance benchmarks
  - Large loop performance tests (100-item arrays, sub-second completion)
  - Nested loops performance validation (sub-0.5s completion)
  - Variable substitution performance tests (50 variables, sub-0.5s completion)
  - Complex document processing benchmarks (sub-1s completion)

- **Format Compatibility Testing**: New `test_format_compatibility.rb` with cross-format validation
  - All output formats testing with consistent input
  - Schema format consistency validation across formats
  - Content consistency verification between formats
  - Format-specific feature testing (variable metadata preservation)
  - Error handling validation across all output formats

### Enhanced

- **Test Suite Expansion**: Expanded from 276 to **291 tests** (1494 to **1591 assertions**)
- **Error Handling**: Enhanced `test_error_handling.rb` with comprehensive unknown component testing
- **Debug Test Migration**: Successfully migrated valuable tests from `test/debug/` folder to main suite
- **Test Coverage**: Added performance and compatibility testing for production resilience

### Technical Improvements

- **Test Organization**: Clean separation of production tests from debug/development tests
- **Performance Validation**: Established performance benchmarks for template engine under load
- **Format Consistency**: Ensured consistent behavior across all output formats
- **Error Resilience**: Enhanced unknown component handling for graceful degradation

## [0.0.7] - 2025-08-28 ✅ Published

### 🔄 Complete Synchronization with Original Library v0.0.9

This release completes the comprehensive synchronization with the original POML library v0.0.9, bringing full feature parity and enhanced capabilities.

### Added

- **Enhanced Pydantic Integration (Phase 5)**:
  - `render_pydantic()`: Advanced Python interoperability with strict JSON schema processing
  - `make_schema_strict()`: Converts schemas to strict JSON schema format
  - `format_tool_for_pydantic()`: Enhanced tool formatting for Python integration
  - Complete test coverage with 13 new tests (48 assertions)

- **OpenAI Response Format**:
  - Separate `openaiResponse` format distinct from `openai_chat`
  - Standardized AI response structure with comprehensive metadata
  - Enhanced compatibility with OpenAI API patterns

- **Enhanced LangChain Format**:
  - Complete LangChain format implementation with messages and content structure
  - Full integration with existing component system

### Enhanced

- **Test Suite Consolidation**: Unified test suite at 276 tests (1494 assertions, all passing) with improved organization and naming
- **Test Suite Expansion**: Final test coverage at 212 stable tests (1044 assertions, all passing), 285 total tests
- **Chat Component Fixes**: Complete chat component behavior with nested formatting and template integration
- **Template Engine**: Full template variable support with conditional logic and loops
- **Error Handling**: Enhanced unknown component handling and graceful error recovery
- **Documentation Updates**: Comprehensive documentation refresh across README, ROADMAP, and TUTORIAL
- **Component System**: Enhanced inline rendering and format compatibility
- **Dependencies**: Clean dependency management following Ruby conventions

### Technical Improvements

- **Version Management**: Updated version tracking from 0.0.6 to 0.0.7
- **Bundle Integration**: Enhanced compatibility with `bundle exec` workflow
- **Error Handling**: Improved error reporting and debugging capabilities

### Synchronization Phases Completed

All 5 planned synchronization phases are now complete:

- ✅ Phase 1: Image URL Support  
- ✅ Phase 2: Inline Rendering Support
- ✅ Phase 3: OpenAI Response Format
- ✅ Phase 4: Enhanced File Operations
- ✅ Phase 5: Pydantic Integration

## [0.0.6] - 2025-08-22 ✅ Publishedg

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.7] - 2025-01-13 ✅ Synchronized

### 🎯 Complete Synchronization with Original Project v0.0.9

- **Phase 5 Completion - Pydantic Integration**: Enhanced Python interoperability
  - Advanced Pydantic format with strict JSON schema processing
  - Comprehensive metadata integration and schema validation
  - Full compatibility with Python data models and type systems

### Enhanced

- **Test Coverage**: Expanded from 164 tests (786 assertions) to 177 tests (834 assertions)
  - Added `test_pydantic_integration.rb` with 13 tests covering enhanced Pydantic features
  - Comprehensive validation of schema strictness and tool integration
- **Renderer Capabilities**: Enhanced output format support
  - `openaiResponse` format: Standardized AI response structure with metadata
  - Enhanced `pydantic` format: Python interoperability with strict JSON schemas
  - `langchain` format: LangChain message format with proper content handling

### 🔄 Synchronization Summary

All 5 planned synchronization phases completed:

- ✅ Phase 1: Component Updates (0.0.3 → 0.0.4)
- ✅ Phase 2: Enhanced File Operations (0.0.4 → 0.0.5)  
- ✅ Phase 3: Advanced Components (0.0.5 → 0.0.6)
- ✅ Phase 4: Tool Integration (maintained in 0.0.6)
- ✅ Phase 5: Pydantic Integration (0.0.6 → 0.0.7)

Ruby POML implementation now has full feature parity with original project v0.0.9.

## [0.0.6] - 2025-08-22 ✅ Published

### 🔄 Breaking Changes Alignment with Original Library

- **New Component Syntax**: Implemented standalone components for schemas and tools
  - Added `<output-schema>` component as replacement for `<meta type="responseSchema">`
  - Added `<tool-definition>` component as replacement for `<meta type="tool">`
  - Full backward compatibility maintained - existing code continues to work

### Added

- **Enhanced Tool Registration System**:
  - `MetaComponent`: Enhanced tool registration with multiple syntax formats
    - `<meta tool="name" description="...">` - Attribute-based tool registration
    - `<meta type="tool">` - JSON-based complete tool definition
    - Automatic format detection (JSON vs expression)
    - Full backward compatibility with existing syntax
  - Fixed critical parser bug affecting example components (removed 'input' from void_elements)
  - Comprehensive tool metadata integration in final output
- **New Standalone Components**:
  - `OutputSchemaComponent`: Define AI response schemas with `<output-schema parser="json">`
  - `ToolDefinitionComponent`: Register AI tools with `<tool-definition name="..." parser="json">`
  - Support for `<tool>` as alias for `<tool-definition>`
- **Example Components System**:
  - `ExampleComponent`: Individual example with input/output pairs
  - `InputComponent` & `OutputComponent`: Structured example data
  - `ExampleSetComponent`: Collections of examples for few-shot learning
  - Fixed rendering issues with nested components
- **Updated Documentation Structure**:
  - Created comprehensive documentation index (`docs/index.md`) matching original library
  - Added Ruby SDK documentation (`docs/ruby/index.md`) with examples and API reference
  - Reorganized tutorial structure (`docs/tutorial/quickstart.md`)
  - Added deep-dive documentation (`docs/deep-dive/ir.md`)
  - Updated meta documentation with breaking changes notes and migration guide
- **Enhanced Test Coverage**:
  - New test suite for standalone components (`test/test_new_schema_components.rb`)
  - 8 comprehensive tests covering new and legacy syntax
  - Tests for parser attribute compatibility and auto-detection
  - Verification of metadata structure and tool registration
- **Example Files**:
  - `examples/303_new_component_syntax.poml` - demonstrates new standalone component syntax

### Enhanced

- **Backward Compatibility**: Seamless support for both old and new syntax patterns
  - `<meta type="responseSchema" lang="json">` → `<output-schema parser="json">`
  - `<meta type="tool" lang="json">` → `<tool-definition parser="json">`
  - `lang` attribute automatically mapped to `parser` for compatibility
- **Component Registration**: Improved component lookup with multiple key format support
- **Metadata Handling**:
  - Response schemas stored as parsed objects (not JSON strings)
  - Tools stored with proper `parameters` structure for API compatibility
  - Expression evaluation placeholder for future JavaScript engine integration
- **Auto-detection**: Parser format automatically detected when not specified
  - JSON format detected when content starts with `{`
  - Expression format used otherwise

### Fixed

- **Component Discovery**: Enhanced component mapping to handle hyphenated names (`output-schema`, `tool-definition`)
- **Schema Validation**: Multiple output-schema elements now properly throw errors
- **Tool Structure**: Tools now have correct `parameters` key structure for API compatibility
- **Template Substitution**: Variables properly substituted in schema and tool content

### Developer Experience

- **Migration Path**: Clear documentation for transitioning to new syntax
- **Test Stability**: All existing stable tests continue passing (99 runs, 467 assertions)
- **API Consistency**: Metadata structure matches expected patterns for LLM integrations

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
