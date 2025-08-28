# Media Components

This guide covers POML components for handling multimedia content including images and other media types.

## Image Component

The `<img>` component displays images in your POML documents with advanced processing capabilities.

### Basic Usage

```ruby
require 'poml'

# Local image file
markup = <<~POML
  <poml>
    <role>Image Analyst</role>
    <task>Describe the contents of this image</task>
    <img src="photo.jpg" alt="User photo" />
  </poml>
POML

result = Poml.process(markup: markup)
puts result['content']
```

### URL-based Images

The Ruby implementation supports fetching images from HTTP(S) URLs:

```ruby
markup = <<~POML
  <poml>
    <role>Visual Analyst</role>
    <img src="https://example.com/image.png" alt="Remote image" />
  </poml>
POML

result = Poml.process(markup: markup)
```

### Advanced Image Processing

The Ruby implementation uses **libvips** for high-performance image processing:

#### Image Resizing

```ruby
# Fit within bounds (preserves aspect ratio)
markup = <<~POML
  <poml>
    <img src="large-photo.jpg" 
         max-width="800" 
         max-height="600" 
         resize="fit" />
  </poml>
POML

# Fill area (may crop)
markup = <<~POML
  <poml>
    <img src="photo.jpg" 
         max-width="400" 
         max-height="400" 
         resize="fill" />
  </poml>
POML

# Stretch to exact dimensions
markup = <<~POML
  <poml>
    <img src="photo.jpg" 
         max-width="300" 
         max-height="200" 
         resize="stretch" />
  </poml>
POML
```

#### Format Conversion

```ruby
# Convert JPEG to PNG
markup = <<~POML
  <poml>
    <img src="photo.jpg" type="png" />
  </poml>
POML

# Convert to WebP for better compression
markup = <<~POML
  <poml>
    <img src="large-image.png" type="webp" />
  </poml>
POML
```

### Component Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `src` | String | Path to image file or HTTP(S) URL |
| `alt` | String | Alternative text for accessibility |
| `base64` | String | Base64 encoded image data (cannot use with `src`) |
| `type` | String | Output format: `jpeg`, `png`, `webp`, `tiff`, `gif` |
| `max-width` | Integer | Maximum width in pixels |
| `max-height` | Integer | Maximum height in pixels |
| `resize` | String | Resize mode: `fit`, `fill`, `stretch` |
| `position` | String | Position: `top`, `bottom`, `here` (default: `here`) |
| `syntax` | String | Output syntax: `multimedia`, `markdown`, etc. |

### Resize Modes

- **`fit`**: Resize to fit within bounds while preserving aspect ratio
- **`fill`**: Fill the entire area, potentially cropping to maintain aspect ratio
- **`stretch`**: Stretch to exact dimensions (may distort aspect ratio)

### Format Support

The libvips-powered implementation supports:

- **Input formats**: JPEG, PNG, GIF, WebP, TIFF, BMP, SVG
- **Output formats**: JPEG (with quality control), PNG, WebP, TIFF, GIF
- **Automatic format detection** from file headers
- **MIME type handling** for web images

### Base64 Encoding

All processed images are automatically converted to base64 data URLs:

```ruby
markup = <<~POML
  <poml>
    <img src="photo.jpg" />
  </poml>
POML

result = Poml.process(markup: markup)
# Result contains: data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEA...
```

### Error Handling

The implementation provides graceful error handling:

```ruby
# Missing file
markup = '<poml><img src="missing.jpg" alt="Missing image" /></poml>'
result = Poml.process(markup: markup)
# Returns alt text: "Missing image"

# Invalid URL
markup = '<poml><img src="https://invalid-url.com/image.jpg" /></poml>'
result = Poml.process(markup: markup)
# Returns error message with graceful fallback
```

### Fallback Behavior

When libvips is not available, the implementation:

1. **Falls back** to basic image handling
2. **Warns the user** about limited functionality
3. **Continues processing** without breaking
4. **Returns original image data** when possible

### Installation Requirements

For full image processing capabilities:

```bash
# Install libvips system library (macOS)
brew install vips

# Install libvips system library (Ubuntu/Debian)
sudo apt-get install libvips-dev

# Ruby gem is automatically installed with POML
gem install poml
```

The ruby-vips gem is automatically included as a dependency.

### Examples

#### Simple Image Display

```ruby
markup = <<~POML
  <poml>
    <role>Photo Critic</role>
    <task>Analyze the composition of this photograph</task>
    <img src="artwork.jpg" alt="Artistic photograph" />
    <instruction>Focus on lighting, composition, and visual impact</instruction>
  </poml>
POML
```

#### Image Processing Pipeline

```ruby
markup = <<~POML
  <poml>
    <role>Image Processor</role>
    <task>Process and optimize images for web display</task>
    
    <h2>Original Image</h2>
    <img src="large-photo.jpg" alt="Original high-resolution photo" />
    
    <h2>Optimized for Web</h2>
    <img src="large-photo.jpg" 
         type="webp" 
         max-width="800" 
         resize="fit" 
         alt="Web-optimized version" />
  </poml>
POML
```

#### Multiple Format Output

```ruby
markup = <<~POML
  <poml>
    <role>Format Converter</role>
    
    <h3>JPEG Version</h3>
    <img src="source.png" type="jpeg" />
    
    <h3>WebP Version</h3>
    <img src="source.png" type="webp" />
    
    <h3>Thumbnail</h3>
    <img src="source.png" max-width="150" max-height="150" resize="fill" />
  </poml>
POML
```

## Best Practices

1. **Always provide alt text** for accessibility
2. **Use appropriate formats**: WebP for web, PNG for transparency, JPEG for photos
3. **Optimize dimensions** before processing when possible
4. **Handle errors gracefully** with meaningful alt text
5. **Consider performance** when processing many large images

## Performance Notes

- **libvips is highly optimized** for image processing
- **Streaming processing** minimizes memory usage
- **Format conversion** is efficient with quality control
- **URL fetching** includes timeout and error handling
- **Base64 encoding** is automatic and optimized

## See Also

- [Data Components](data-components.md) - For handling other data types
- [Template Engine](../template-engine.md) - For dynamic image paths
- [Error Handling](../advanced/error-handling.md) - For robust error handling patterns
