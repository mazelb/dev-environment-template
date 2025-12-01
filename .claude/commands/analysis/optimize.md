---
description: Identify and implement performance optimizations for Python, TypeScript, Kotlin
allowed-tools: ["Read", "Edit", "Bash(time *)"]
model: claude-sonnet-4-5
---

# Performance Optimization

Analyze code for performance improvements and optimizations.

## Optimization Areas

1. **Algorithmic**: Use more efficient algorithms and data structures
2. **Database**: Optimize queries, add indexes, use caching
3. **Memory**: Reduce allocations and memory usage
4. **I/O**: Minimize and batch I/O operations
5. **Async**: Use concurrency where beneficial
6. **Caching**: Add strategic caching layers

## Language-Specific Optimizations

### Python
- Use list comprehensions over loops
- leverage `set` for membership testing
- Use `dataclasses` instead of regular classes
- Implement async/await for I/O
- Use `@lru_cache` for expensive functions
- Batch database queries with `joinedload()`
- Use connection pooling

### TypeScript/JavaScript
- Use `useMemo` and `useCallback` in React
- Implement lazy loading and code splitting
- Debounce expensive operations
- Use Web Workers for heavy computations
- Optimize re-renders with `React.memo`
- Batch API calls
- Implement virtual scrolling for lists

### Kotlin
- Use `sequence` for lazy evaluation
- Leverage coroutines for async operations
- Use `data class` copy() instead of mutations
- Implement object pooling if needed
- Use `@Cacheable` for Spring Boot
- Optimize database queries with projections

## Archetype-Specific Optimizations

**For rag-project:**
- Cache embeddings for repeated queries
- Batch document indexing
- Use async for OpenSearch queries
- Implement connection pooling for Ollama
- Add Redis caching layer
- Optimize chunk size and overlap

**For api-service:**
- Add database query indexes
- Implement Redis caching
- Use async database operations
- Batch Celery tasks
- Optimize serialization with orjson
- Add connection pooling

**For frontend:**
- Implement React.memo for components
- Use Next.js Image optimization
- Implement infinite scroll
- Add request deduplication
- Use SWR or React Query for caching
- Optimize bundle size

## Performance Analysis

For the code provided:

1. **Identify Bottlenecks**:
   - Measure current performance
   - Profile hot paths
   - Find N+1 queries
   - Identify unnecessary computations

2. **Propose Optimizations**:
   - Specific code changes
   - Expected performance gain
   - Trade-offs to consider
   - When optimization matters (scale)

3. **Implementation**:
   - Provide optimized code
   - Explain changes made
   - Suggest benchmarking approach

## Output Format

Provide:
1. **Current Performance Issues**: What's slow and why
2. **Optimization Strategy**: High-level approach
3. **Optimized Code**: Improved implementation
4. **Performance Gains**: Expected improvements
5. **Trade-offs**: Complexity vs performance
6. **Benchmarking**: How to measure improvements

## Example Output

```
Current Issues:
- N+1 query problem in user endpoint (100 queries for 100 users)
- Missing database index on email column
- Synchronous HTTP calls blocking event loop

Optimization Strategy:
1. Use eager loading with joinedload()
2. Add database index
3. Convert to async/await

Optimized Code:
[... improved code ...]

Performance Gains:
- Endpoint response time: 2000ms → 150ms (13x faster)
- Database queries: 100 → 1 (99% reduction)
- Memory usage: Similar

Trade-offs:
- Slightly more complex code
- Requires async runtime

Benchmarking:
```bash
# Before
curl -w "@-" -o /dev/null -s http://localhost:8000/users
# Time: 2.1s

# After
curl -w "@-" -o /dev/null -s http://localhost:8000/users
# Time: 0.15s
```
```
