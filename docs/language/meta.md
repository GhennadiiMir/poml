# Meta

POML documents support several types of meta elements that control document behavior and configuration:

1. **The `<meta>` element** - Defines fundamental metadata about a POML file, such as version requirements and component control
2. **Schema components** - `<output-schema>` defines structured response formats for AI models
3. **Tool components** - `<tool-definition>` (or `<tool>`) registers callable functions for AI models  
4. **Meta-like components** - Elements like `<stylesheet>`, `<runtime>` that affect prompt rendering

**Breaking Changes Note**: The original POML library has updated from `<meta type="responseSchema">` to `<output-schema>` and from `<meta type="tool">` to `<tool-definition>`. The Ruby gem supports both syntaxes for compatibility, but new projects should use the newer components.

## The `<meta>` Element

The `<meta>` element provides core metadata and configuration for POML documents. It allows you to specify version requirements and disable/enable components.

### Basic Usage

Meta elements are typically placed at the beginning of a POML document and don't produce any visible output. One POML file can have multiple `<meta>` elements at any position, but they should be used carefully to avoid conflicts.

```xml
<poml>
  <meta minVersion="1.0.0" />
  <p>Your content here</p>
</poml>
```

### Meta Element Usage

Meta elements are used for general document configuration:

- Version control (`minVersion`, `maxVersion`)
- Component management (`components`)

## Response Schema

Response schemas define the expected structure of AI-generated responses, ensuring that language models return data in a predictable, parsable format. This transforms free-form text generation into structured data generation.

### New Syntax (Recommended)

Use the standalone `<output-schema>` component with the `parser` attribute:

```xml
<output-schema parser="json">
  {
    "type": "object",
    "properties": {
      "name": { "type": "string" },
      "age": { "type": "number" }
    },
    "required": ["name"]
  }
</output-schema>
```

### Legacy Syntax (Supported)

The older `<meta type="responseSchema">` syntax is still supported:

```xml
<meta type="responseSchema" parser="json">
  {
    "type": "object",
    "properties": {
      "name": { "type": "string" },
      "age": { "type": "number" }
    },
    "required": ["name"]
  }
</meta>
```

### JSON Schema Format

Use the `parser="json"` attribute to specify JSON Schema format. The schema must be a valid JSON Schema object:

```xml
<output-schema parser="json">
  {
    "type": "object",
    "properties": {
      "name": { "type": "string" },
      "age": { "type": "number" }
    },
    "required": ["name"]
  }
</output-schema>
```

### Expression Format

Use the `parser="eval"` attribute (or `parser="expr"`) to evaluate JavaScript expressions that return schemas:

```xml
<output-schema parser="eval">
  z.object({
    name: z.string(),
    age: z.number().optional()
  })
</output-schema>
```

**Note**: Expression evaluation is not fully implemented in the Ruby gem and will return a placeholder indicating the limitation.

When `parser` is omitted, POML auto-detects the format:

- If the content starts with `{`, it's treated as JSON
- Otherwise, it's treated as an expression

### Template Expressions in Schemas

JSON schemas support template expressions using `{{ }}` syntax:

```xml
<let name="maxAge" value="100" />
<output-schema parser="json">
  {
    "type": "object",
    "properties": {
      "name": { "type": "string" },
      "age": { 
        "type": "number",
        "minimum": 0,
        "maximum": {{ maxAge }}
      }
    }
  }
</output-schema>
```

**Important limitations:**

- Only one `output-schema` element is allowed per document. Multiple response schemas will result in an error.

## Tool Registration

Tool registration enables AI models to interact with external functions during conversation. Tools are function definitions that tell the AI model what functions are available, what parameters they expect, and what they do.

### New Syntax (Recommended)

Use the standalone `<tool-definition>` component (or its alias `<tool>`):

```xml
<tool-definition name="getWeather" description="Get weather information" parser="json">
  {
    "type": "object",
    "properties": {
      "location": { "type": "string" },
      "unit": { 
        "type": "string", 
        "enum": ["celsius", "fahrenheit"] 
      }
    },
    "required": ["location"]
  }
</tool-definition>
```

### Legacy Syntax (Supported)

The older `<meta type="tool">` syntax is still supported:

```xml
<meta type="tool" name="getWeather" description="Get weather information" parser="json">
  {
    "type": "object",
    "properties": {
      "location": { "type": "string" },
      "unit": { 
        "type": "string", 
        "enum": ["celsius", "fahrenheit"] 
      }
    },
    "required": ["location"]
  }
</meta>
```

### Tool Definition Examples

#### JSON Schema Format

```xml
<tool-definition name="calculate" description="Perform mathematical calculations" parser="json">
  {
    "type": "object",
    "properties": {
      "operation": { "type": "string", "enum": ["add", "subtract", "multiply", "divide"] },
      "a": { "type": "number" },
      "b": { "type": "number" }
    },
    "required": ["operation", "a", "b"]
  }
</tool-definition>
```

#### Expression Format

```xml
<tool-definition name="search" description="Search for information" parser="eval">
  z.object({
    query: z.string(),
    limit: z.number().min(1).max(10).default(5)
  })
</tool-definition>
```

### Template Expressions in Tools

Both schemas and tools support template expressions in their attributes:

```xml
<let name="toolName" value="calculate" />
<let name="toolDesc" value="Perform mathematical calculations" />

<tool-definition name="{{toolName}}" description="{{toolDesc}}" parser="json">
  {
    "type": "object",
    "properties": {
      "operation": { "type": "string" }
    }
  }
</tool-definition>
```

**Required attributes for tools:**

- **name**: Tool identifier (required)
- **description**: Tool description (optional but recommended)
- **parser**: Schema parser, either "json" or "eval" (optional, auto-detected based on content)

## Compatibility Notes

### Attribute Migration

The Ruby gem supports both old and new attribute names for backward compatibility:

- `lang="json"` → `parser="json"` (both supported)
- `lang="expr"` → `parser="eval"` (both supported)

### Component Migration

The Ruby gem supports both old and new component structures:

- `<meta type="responseSchema">` → `<output-schema>` (both supported)
- `<meta type="tool">` → `<tool-definition>` (both supported)

For new projects, use the newer standalone components (`<output-schema>`, `<tool-definition>`) as they provide better clarity and follow the updated POML specification.

The expression can return either:

- A Zod schema object (detected by the presence of `_def` property)
- A plain JavaScript object treated as JSON Schema

**Important limitations:**

- Only one `responseSchema` meta element is allowed per document. Multiple response schemas will result in an error.
- Response schemas cannot be used together with tool definitions in the same document. You must choose between structured responses or tool calling capabilities.

## Tool Registration

Tool registration enables AI models to interact with external functions during conversation. Tools are function definitions that tell the AI model what functions are available, what parameters they expect, and what they do.

**Important:** Tools and response schemas are mutually exclusive. You cannot use both `responseSchema` and `tool` meta elements in the same POML document.

### JSON Schema Format

```xml
<meta type="tool" name="getWeather" description="Get weather information">
  {
    "type": "object",
    "properties": {
      "location": { "type": "string" },
      "unit": { 
        "type": "string", 
        "enum": ["celsius", "fahrenheit"] 
      }
    },
    "required": ["location"]
  }
</meta>
```

### Expression Format

```xml
<meta type="tool" name="calculate" description="Perform calculation" lang="expr">
  z.object({
    operation: z.enum(['add', 'subtract', 'multiply', 'divide']),
    a: z.number(),
    b: z.number()
  })
</meta>
```

### Expression Evaluation in Tool Schemas

Tool schemas support the same evaluation modes as response schemas:

#### JSON with Template Expressions

```xml
<let name="maxValue" value="1000" />
<meta type="tool" name="calculator" description="Calculate values" lang="json">
  {
    "type": "object",
    "properties": {
      "value": { 
        "type": "number",
        "maximum": {{ maxValue }}
      }
    }
  }
</meta>
```

#### Expression Format

```xml
<let name="supportedOperations" value='["add", "subtract", "multiply", "divide"]' />
<meta type="tool" name="calculator" description="Perform mathematical operations" lang="expr">
  z.object({
    operation: z.enum(supportedOperations),
    a: z.number(),
    b: z.number()
  })
</meta>
```

In expression mode, the `z` variable is automatically available for constructing Zod schemas, and you have direct access to all context variables.

**Required attributes for tools:**

- **name**: Tool identifier (required)
- **description**: Tool description (optional but recommended)
- **lang**: Schema language, either "json" or "expr" (optional, auto-detected based on content)

You can define multiple tools in a single document.

## Runtime Parameters

Runtime parameters configure the language model's behavior during execution. These parameters are automatically used in [VSCode's test command](../vscode/features.md) functionality, which is based on the [Vercel AI SDK](https://ai-sdk.dev/).

```xml
<meta type="runtime" 
      temperature="0.7" 
      maxOutputTokens="1000" 
      model="gpt-5"
      topP="0.9" />
```

All attributes except `type` are passed as runtime parameters. Common parameters include:

- **temperature**: Controls randomness (0-2, typically 0.3-0.7 for balanced output)
- **maxOutputTokens**: Maximum response length in tokens
- **model**: Model identifier (e.g., "gpt-5", "claude-4-sonnet")
- **topP**: Nucleus sampling threshold (0-1, typically 0.9-0.95)
- **frequencyPenalty**: Reduces token repetition based on frequency (-2 to 2)
- **presencePenalty**: Reduces repetition based on presence (-2 to 2)
- **seed**: For deterministic outputs (integer value)

The full parameter list depends on whether you're using standard text generation or structured data generation:

- [Text generation parameters](https://ai-sdk.dev/docs/ai-sdk-core/generating-text) - Standard text generation
- [Structured data parameters](https://ai-sdk.dev/docs/ai-sdk-core/generating-structured-data) - When using response schemas

The [Vercel AI SDK](https://ai-sdk.dev/) automatically handles parameter validation and conversion for different model providers.

## Version Control

Version requirements ensure compatibility between documents and the POML runtime. This prevents runtime errors when documents require specific POML features.

```xml
<meta minVersion="0.5.0" maxVersion="2.0.0" />
```

- **minVersion**: Minimum required POML version. If the current version is lower, an error is thrown.
- **maxVersion**: Maximum supported POML version. Documents may not work correctly with newer versions.

Version checking uses semantic versioning (MAJOR.MINOR.PATCH) and occurs during document parsing.

## Component Control

The `components` attribute dynamically enables or disables POML components within a document. This is useful for conditional content, feature flags, or restricting elements in specific contexts.

### Disabling Components

Prefix component names with `-` to disable them:

```xml
<meta components="-table" />
<!-- Now <table> elements will throw an error -->
```

You can disable multiple components:

```xml
<meta components="-table,-image" />
```

### Re-enabling Components

Use `+` prefix to re-enable previously disabled components:

```xml
<meta components="-table" />
<!-- table is disabled -->
<meta components="+table" />
<!-- table is re-enabled -->
```

Component aliases can be disabled independently of the main component name. For example, if a component has both a main name and aliases, you can disable just the alias while keeping the main component available.
