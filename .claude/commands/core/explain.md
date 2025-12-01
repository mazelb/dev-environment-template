---
description: Explain code functionality, design patterns, and logic for Python, TypeScript, Kotlin
model: claude-opus-4
argument-hint: "[file or code to explain]"
---

# Code Explanation

Analyze and explain the provided code clearly and concisely.

## What to Explain

1. **Purpose**: What does this code do? What problem does it solve?
2. **Key Components**: Break down the main parts and their responsibilities
3. **Logic Flow**: How does the code work step by step?
4. **Dependencies**: What does it depend on (libraries, modules, other code)?
5. **Design Patterns**: What patterns or idioms are used?
6. **Potential Issues**: Any concerns, edge cases, or areas for improvement?

## Language-Specific Context

### Python (FastAPI, RAG, SQLAlchemy)
- Explain async/await patterns
- FastAPI dependency injection
- SQLAlchemy query patterns
- Type hints and Pydantic models

### TypeScript/JavaScript (Next.js, React)
- Component structure (Server/Client)
- React hooks and state management
- API routes and data fetching
- Type definitions and interfaces

### Kotlin (Spring Boot)
- Data classes and sealed classes
- Extension functions
- Coroutines and async operations
- Spring dependency injection

## Archetype Context

**For rag-project archetype:**
- OpenSearch indexing logic
- Ollama LLM integration
- RAG pipeline components
- Embedding generation

**For api-service archetype:**
- FastAPI endpoint structure
- Celery task definitions
- GraphQL resolvers
- Database queries

**For frontend archetype:**
- Next.js App Router patterns
- Server/Client component usage
- API integration
- State management

## Output Format

Provide:
- **1-line summary** of what the code does
- **Breakdown** of key components
- **Step-by-step** logic flow
- **Dependencies** and their purpose
- **Best practices** followed or missed
- **Suggestions** for improvement (if any)

## Instructions

- Keep explanations clear and developer-friendly
- Use technical terminology appropriately
- Highlight any non-obvious or complex logic
- Mention best practices or deviations from them
- Be concise but thorough
- Reference specific line numbers when helpful

## Example Usage

```
User: "Explain @src/services/rag/pipeline.py"
Claude: [Reads file and explains]
- This is a RAG pipeline that orchestrates document retrieval and LLM generation
- Key components: OpenSearchClient, OllamaClient, EmbeddingService
- Flow: 1) Embed query → 2) Search documents → 3) Generate response
- Uses async/await for non-blocking I/O
- Good: Proper error handling, type hints
- Suggestion: Add caching for repeated queries
```
