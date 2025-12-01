---
description: Analyze and explain system architecture and design patterns
allowed-tools: ["Read", "Bash(find . -name '*.py' -o -name '*.ts' -o -name '*.kt')"]
model: claude-opus-4
---

# Architecture Analysis

Analyze the architecture and design of the provided code or system.

## Analysis Areas

1. **Current Design**: Understand and describe the architecture
2. **Patterns**: Identify design patterns used (or missing)
3. **Components**: Map out key components and their responsibilities
4. **Data Flow**: How data moves through the system
5. **Scalability**: Will the design scale?
6. **Maintainability**: Is it easy to modify and extend?

## Architectural Concerns

- **Separation of Concerns**: Are responsibilities properly divided?
- **Modularity**: Are components well-defined and cohesive?
- **Coupling**: How tightly are components connected?
- **Extensibility**: Easy to add new features?
- **Testability**: Easy to write tests?
- **Performance**: Does architecture support performance goals?

## Archetype Architectures

**rag-project archetype:**
```
┌─── FastAPI Application ───┐
│  ┌─────────────────────┐  │
│  │   API Endpoints     │  │
│  └──────────┬──────────┘  │
│             ↓              │
│  ┌─────────────────────┐  │
│  │   RAG Pipeline      │  │
│  │  • Embedding        │  │
│  │  • Retrieval        │  │
│  │  • Generation       │  │
│  └──┬──────┬──────┬───┘  │
└─────┼──────┼──────┼──────┘
      ↓      ↓      ↓
  OpenSearch Ollama Redis
```

**api-service archetype:**
```
┌─── FastAPI Application ───┐
│  ┌─────────────────────┐  │
│  │   REST/GraphQL API  │  │
│  └──────────┬──────────┘  │
│             ↓              │
│  ┌─────────────────────┐  │
│  │   Service Layer     │  │
│  └──────────┬──────────┘  │
│             ↓              │
│  ┌─────────────────────┐  │
│  │  Repository Layer   │  │
│  └──┬──────────────┬───┘  │
└─────┼──────────────┼──────┘
      ↓              ↓
  PostgreSQL      Celery
      ↑              ↓
    Redis         Redis
```

**frontend archetype:**
```
┌──── Next.js App ────┐
│  ┌───────────────┐  │
│  │ App Router    │  │
│  │ • Pages       │  │
│  │ • Layouts     │  │
│  └───────┬───────┘  │
│          ↓          │
│  ┌───────────────┐  │
│  │ Components    │  │
│  │ • Server      │  │
│  │ • Client      │  │
│  └───────┬───────┘  │
│          ↓          │
│  ┌───────────────┐  │
│  │ API Layer     │  │
│  │ • REST        │  │
│  │ • GraphQL     │  │
│  └───────────────┘  │
└─────────────────────┘
```

## Common Patterns to Identify

**Creational**:
- Factory Pattern
- Builder Pattern
- Singleton Pattern
- Dependency Injection

**Structural**:
- Repository Pattern
- Adapter Pattern
- Facade Pattern
- Proxy Pattern

**Behavioral**:
- Strategy Pattern
- Observer Pattern
- Command Pattern
- Template Method

## Output Format

Provide:
1. **High-Level Architecture**: System overview with diagram
2. **Component Breakdown**: Key components and responsibilities
3. **Data Flow**: How data moves through the system
4. **Design Patterns**: Patterns used (or missing)
5. **Strengths**: What's done well
6. **Weaknesses**: Areas for improvement
7. **Recommendations**: Specific improvements
8. **Scalability Analysis**: How it scales

## Example Output

```
High-Level Architecture:
This is a RAG (Retrieval-Augmented Generation) system with a FastAPI backend.

Architecture Diagram:
[ASCII/Mermaid diagram]

Component Breakdown:
1. API Layer (src/api/)
   - FastAPI endpoints for search and chat
   - Request validation with Pydantic
   - Dependency injection for services

2. RAG Pipeline (src/services/rag/)
   - Orchestrates retrieval and generation
   - Uses strategy pattern for different search types
   - Implements async/await for performance

3. Data Layer
   - OpenSearch for vector storage
   - Redis for caching
   - PostgreSQL for metadata

Design Patterns:
- ✅ Factory Pattern: Service creation
- ✅ Strategy Pattern: Search strategies
- ✅ Repository Pattern: Data access
- ❌ Missing: Circuit Breaker for LLM calls

Strengths:
- Clean separation of concerns
- Async throughout for performance
- Good type safety with Pydantic
- Dependency injection

Weaknesses:
- No circuit breaker for external services
- Missing error recovery strategies
- No request tracing/correlation IDs

Recommendations:
1. Add circuit breaker for Ollama calls
2. Implement structured logging with correlation IDs
3. Add retry logic with exponential backoff
4. Consider adding a caching layer for embeddings

Scalability:
- Horizontal scaling: ✅ Stateless design
- Database scaling: ⚠️ Need read replicas for high load
- Cache scaling: ✅ Redis cluster ready
- LLM scaling: ⚠️ Need load balancing for Ollama
```
