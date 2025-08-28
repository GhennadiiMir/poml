# Performance Optimization

Learn how to optimize POML processing for speed, memory usage, and scalability in production environments.

## Performance Fundamentals

### Component Performance Characteristics

| Component Type | Processing Speed | Memory Usage | I/O Impact |
|---------------|------------------|--------------|------------|
| Text (`<p>`, `<b>`, `<i>`) | ⚡⚡⚡⚡⚡ | Very Low | None |
| Lists (`<list>`, `<item>`) | ⚡⚡⚡⚡ | Low | None |
| Templates (`{{}}`, `<if>`, `<for>`) | ⚡⚡⚡ | Medium | None |
| File Reading (`<file>`, `<img>`) | ⚡⚡ | High | High |
| External Data (`<table>` with URLs) | ⚡ | High | Very High |

### Optimization Principles

1. **Minimize I/O Operations** - Cache file reads and external data
2. **Limit Loop Iterations** - Use conditions to restrict processing
3. **Optimize Template Variables** - Pre-compute complex expressions
4. **Choose Appropriate Output Formats** - Match format to use case
5. **Enable Caching** - Reuse processed templates

## Template Engine Optimization

### Variable Pre-computation

```ruby
# Slow: Complex computation in template
<poml>
  <for variable="item" items="{{items}}">
    <p>{{item.complex_calculation.expensive_method}}</p>
  </for>
</poml>

# Fast: Pre-compute values
context = {
  'items' => items.map do |item|
    item.merge('display_value' => item.complex_calculation.expensive_method)
  end
}

<poml>
  <for variable="item" items="{{items}}">
    <p>{{item.display_value}}</p>
  </for>
</poml>
```

### Conditional Optimization

```ruby
# Slow: Check condition inside loop
<poml>
  <for variable="item" items="{{all_items}}">
    <if condition="{{item.visible}}">
      <p>{{item.name}}</p>
    </if>
  </for>
</poml>

# Fast: Filter before processing
context = {
  'visible_items' => all_items.select(&:visible)
}

<poml>
  <for variable="item" items="{{visible_items}}">
    <p>{{item.name}}</p>
  </for>
</poml>
```

### Loop Limiting

```ruby
# Potentially slow: Unlimited iteration
<poml>
  <for variable="item" items="{{large_dataset}}">
    <p>{{item.description}}</p>
  </for>
</poml>

# Optimized: Limit iteration count
<poml>
  <for variable="item" items="{{large_dataset}}" limit="100">
    <p>{{item.description}}</p>
  </for>
</poml>

# Or pre-limit in context
context = {
  'limited_items' => large_dataset.first(100)
}
```

## File Operation Optimization

### Caching File Reads

```ruby
class CachedPomlProcessor
  def initialize
    @file_cache = {}
    @poml = POML.new
  end
  
  def process_with_cache(template_path, context = {})
    # Cache file content
    cached_files = {}
    
    # Pre-read files referenced in context
    context.each do |key, value|
      if key.end_with?('_file') && File.exist?(value)
        cached_files[value] = File.read(value) unless @file_cache[value]
        @file_cache[value] ||= cached_files[value]
      end
    end
    
    # Process with cached context
    enhanced_context = context.merge(cached_files)
    @poml.process_file(template_path, variables: enhanced_context)
  end
end
```

### Lazy File Loading

```ruby
# Template using lazy loading
<poml>
  <if condition="{{show_details}}">
    <file src="{{details_file}}" />
  </if>
  
  <if condition="{{include_logs}}">
    <file src="{{log_file}}" maxLines="50" />
  </if>
</poml>

# Context controls loading
context = {
  'show_details' => user_requested_details,
  'include_logs' => debug_mode_enabled,
  'details_file' => 'path/to/details.txt',
  'log_file' => 'path/to/debug.log'
}
```

### Streaming Large Files

```ruby
class StreamingFileProcessor
  def process_large_file(file_path, max_size: 1_000_000)
    if File.size(file_path) > max_size
      # Stream first portion
      content = File.open(file_path) do |file|
        file.read(max_size) + "\n... (truncated)"
      end
    else
      content = File.read(file_path)
    end
    
    content
  end
end
```

## Memory Management

### Efficient Data Structures

```ruby
# Memory-heavy: Full object loading
context = {
  'users' => User.all.map(&:to_hash)  # Loads all data
}

# Memory-efficient: Lazy loading
context = {
  'users' => User.limit(50).pluck(:id, :name, :email)  # Minimal data
}

# For templates
<poml>
  <for variable="user" items="{{users}}">
    <p>{{user[1]}} ({{user[2]}})</p>  <!-- name, email -->
  </for>
</poml>
```

### Garbage Collection Optimization

```ruby
class OptimizedProcessor
  def process_batch(templates, contexts)
    results = []
    
    templates.each_with_index do |template, index|
      result = POML.new.process(
        markup: template,
        variables: contexts[index]
      )
      results << result
      
      # Force GC every 100 items for large batches
      GC.start if (index + 1) % 100 == 0
    end
    
    results
  end
end
```

### Memory Pooling

```ruby
class PomlPool
  def initialize(pool_size: 5)
    @pool = Array.new(pool_size) { POML.new }
    @available = @pool.dup
    @mutex = Mutex.new
  end
  
  def process(template, context = {})
    processor = acquire_processor
    begin
      processor.process(markup: template, variables: context)
    ensure
      release_processor(processor)
    end
  end
  
  private
  
  def acquire_processor
    @mutex.synchronize do
      @available.pop || POML.new
    end
  end
  
  def release_processor(processor)
    @mutex.synchronize do
      @available.push(processor) if @available.size < @pool.size
    end
  end
end
```

## Caching Strategies

### Template Caching

```ruby
class TemplateCache
  def initialize(max_size: 100, ttl: 3600)
    @cache = {}
    @access_times = {}
    @max_size = max_size
    @ttl = ttl
  end
  
  def get_or_process(template_path, context = {})
    cache_key = generate_key(template_path, context)
    
    if cached = get_cached(cache_key)
      return cached
    end
    
    result = POML.new.process_file(template_path, variables: context)
    store_cached(cache_key, result)
    result
  end
  
  private
  
  def generate_key(template_path, context)
    "#{template_path}:#{context.hash}"
  end
  
  def get_cached(key)
    return nil unless @cache[key]
    return nil if expired?(key)
    
    @access_times[key] = Time.now
    @cache[key]
  end
  
  def store_cached(key, value)
    evict_if_needed
    @cache[key] = value
    @access_times[key] = Time.now
  end
  
  def expired?(key)
    Time.now - @access_times[key] > @ttl
  end
  
  def evict_if_needed
    return if @cache.size < @max_size
    
    # Remove least recently used
    lru_key = @access_times.min_by { |k, v| v }.first
    @cache.delete(lru_key)
    @access_times.delete(lru_key)
  end
end
```

### Context Caching

```ruby
class ContextCache
  def initialize
    @computed_values = {}
  end
  
  def enhanced_context(base_context)
    base_context.merge(computed_values(base_context))
  end
  
  private
  
  def computed_values(context)
    cache_key = context.hash
    
    @computed_values[cache_key] ||= {
      'formatted_date' => format_date(context['date']),
      'user_summary' => summarize_user(context['user']),
      'processed_items' => process_items(context['items'])
    }
  end
  
  def format_date(date)
    return '' unless date
    Date.parse(date.to_s).strftime('%B %d, %Y')
  end
  
  def summarize_user(user)
    return {} unless user
    {
      'display_name' => "#{user['first_name']} #{user['last_name']}",
      'initials' => "#{user['first_name'][0]}#{user['last_name'][0]}"
    }
  end
  
  def process_items(items)
    return [] unless items
    items.map.with_index do |item, index|
      item.merge(
        'index' => index + 1,
        'is_last' => index == items.length - 1
      )
    end
  end
end
```

## Profiling and Monitoring

### Performance Measurement

```ruby
require 'benchmark'

class PomlProfiler
  def self.profile_processing(template, context = {})
    results = {}
    
    # Measure overall processing
    results[:total] = Benchmark.measure do
      POML.new.process(markup: template, variables: context)
    end
    
    # Measure template parsing
    results[:parsing] = Benchmark.measure do
      POML.new.send(:parse_template, template)
    end
    
    # Measure variable substitution
    results[:substitution] = Benchmark.measure do
      POML.new.send(:substitute_variables, template, context)
    end
    
    results
  end
  
  def self.profile_components(template)
    component_counts = Hash.new(0)
    
    # Count component usage
    template.scan(/<(\w+)/).each do |match|
      component_counts[match[0]] += 1
    end
    
    component_counts
  end
end

# Usage
template = File.read('complex_template.poml')
context = { 'items' => (1..1000).to_a }

profile = PomlProfiler.profile_processing(template, context)
puts "Total time: #{profile[:total].real}s"
puts "Parsing time: #{profile[:parsing].real}s"

components = PomlProfiler.profile_components(template)
puts "Component usage: #{components}"
```

### Memory Profiling

```ruby
require 'memory_profiler'

def profile_memory(template, context)
  report = MemoryProfiler.report do
    POML.new.process(markup: template, variables: context)
  end
  
  puts "Total allocated: #{report.total_allocated_memsize} bytes"
  puts "Total retained: #{report.total_retained_memsize} bytes"
  
  # Top allocations
  report.allocated_memory_by_class.first(5).each do |allocation|
    puts "#{allocation[:data]}: #{allocation[:count]} objects"
  end
end
```

### Performance Monitoring

```ruby
class PerformanceMonitor
  def initialize
    @metrics = {
      processing_times: [],
      memory_usage: [],
      cache_hits: 0,
      cache_misses: 0
    }
  end
  
  def track_processing(template_name, &block)
    start_time = Time.now
    start_memory = memory_usage
    
    result = yield
    
    end_time = Time.now
    end_memory = memory_usage
    
    @metrics[:processing_times] << {
      template: template_name,
      duration: end_time - start_time,
      memory_delta: end_memory - start_memory,
      timestamp: start_time
    }
    
    result
  end
  
  def cache_hit!
    @metrics[:cache_hits] += 1
  end
  
  def cache_miss!
    @metrics[:cache_misses] += 1
  end
  
  def statistics
    times = @metrics[:processing_times].map { |m| m[:duration] }
    
    {
      avg_processing_time: times.sum / times.length,
      max_processing_time: times.max,
      min_processing_time: times.min,
      cache_hit_rate: cache_hit_rate,
      total_processes: times.length
    }
  end
  
  private
  
  def memory_usage
    `ps -o rss= -p #{Process.pid}`.to_i * 1024
  end
  
  def cache_hit_rate
    total = @metrics[:cache_hits] + @metrics[:cache_misses]
    return 0 if total == 0
    (@metrics[:cache_hits].to_f / total * 100).round(2)
  end
end
```

## Production Optimization

### Asynchronous Processing

```ruby
require 'concurrent-ruby'

class AsyncPomlProcessor
  def initialize(pool_size: 10)
    @executor = Concurrent::ThreadPoolExecutor.new(
      min_threads: 2,
      max_threads: pool_size,
      max_queue: 100
    )
  end
  
  def process_async(templates_and_contexts)
    futures = templates_and_contexts.map do |template, context|
      Concurrent::Future.execute(executor: @executor) do
        POML.new.process(markup: template, variables: context)
      end
    end
    
    # Wait for all to complete
    futures.map(&:value)
  end
  
  def shutdown
    @executor.shutdown
    @executor.wait_for_termination(30)
  end
end
```

### Background Job Integration

```ruby
# Sidekiq job example
class PomlProcessingJob
  include Sidekiq::Job
  
  sidekiq_options queue: 'poml_processing', retry: 3
  
  def perform(template_path, context, user_id)
    result = OptimizedPomlProcessor.process_with_cache(template_path, context)
    
    # Store result
    ProcessingResult.create!(
      user_id: user_id,
      template_path: template_path,
      result: result,
      processed_at: Time.current
    )
  rescue StandardError => e
    Rails.logger.error "POML processing failed: #{e.message}"
    raise
  end
end

# Usage
PomlProcessingJob.perform_async(
  'templates/report.poml',
  { 'user_id' => user.id, 'data' => report_data },
  user.id
)
```

### Load Balancing

```ruby
class DistributedPomlProcessor
  def initialize(worker_urls)
    @workers = worker_urls.map { |url| Worker.new(url) }
    @current_worker = 0
  end
  
  def process(template, context)
    worker = next_worker
    worker.process_remote(template, context)
  rescue WorkerError => e
    # Failover to next worker
    retry_with_next_worker(template, context, e)
  end
  
  private
  
  def next_worker
    worker = @workers[@current_worker]
    @current_worker = (@current_worker + 1) % @workers.length
    worker
  end
  
  def retry_with_next_worker(template, context, original_error)
    @workers.each do |worker|
      return worker.process_remote(template, context)
    rescue WorkerError
      next
    end
    
    raise original_error
  end
end
```

## Performance Best Practices

### Template Design

```ruby
# ✅ Good: Efficient template structure
<poml>
  <!-- Pre-filter data -->
  <for variable="item" items="{{priority_items}}">
    <p><b>{{item.title}}</b></p>
    <if condition="{{item.details}}">
      <p>{{item.details}}</p>
    </if>
  </for>
</poml>

# ❌ Avoid: Inefficient nested conditions
<poml>
  <for variable="item" items="{{all_items}}">
    <if condition="{{item.category}} == 'important'">
      <if condition="{{item.status}} == 'active'">
        <if condition="{{item.user_can_view}}">
          <p>{{item.title}}</p>
        </if>
      </if>
    </if>
  </for>
</poml>
```

### Context Preparation

```ruby
# ✅ Good: Optimized context
def prepare_context(user, items)
  {
    'user_name' => user.full_name,
    'priority_items' => items
      .select(&:important?)
      .select(&:active?)
      .select { |item| user.can_view?(item) }
      .map { |item| item.to_hash.slice(:title, :details, :created_at) }
  }
end

# ❌ Avoid: Heavy context objects
def heavy_context(user, items)
  {
    'user' => user,  # Full ActiveRecord object
    'all_items' => items,  # All items, not filtered
    'computed_data' => expensive_computation()  # Computed every time
  }
end
```

### Monitoring Setup

```ruby
# Application monitoring
class PomlMetrics
  def self.setup_monitoring
    ActiveSupport::Notifications.subscribe('poml.process') do |name, start, finish, id, payload|
      duration = finish - start
      template_name = payload[:template_name]
      
      # Send to monitoring service
      StatsD.histogram('poml.processing_time', duration, tags: ["template:#{template_name}"])
      
      # Log slow processing
      if duration > 1.0
        Rails.logger.warn "Slow POML processing: #{template_name} took #{duration}s"
      end
    end
  end
end

# Usage in initializer
PomlMetrics.setup_monitoring
```

## Next Steps

1. **Identify Bottlenecks** - Profile your specific use cases
2. **Implement Caching** - Start with template and context caching
3. **Monitor Performance** - Set up metrics and alerting
4. **Optimize Iteratively** - Make incremental improvements
5. **Scale Appropriately** - Add async processing for heavy workloads

For related topics, see:

- [Error Handling](error-handling.md) for robust error management
- [Integration Patterns](../integration/) for production deployment
- [Template Engine](../template-engine.md) for optimization techniques
