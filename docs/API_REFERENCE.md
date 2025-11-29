# API Reference

**Last Updated:** November 29, 2025
**Version:** 1.0.0

This document provides comprehensive API documentation for both the RAG and API-Service archetypes, including REST endpoints, GraphQL schema, request/response formats, authentication, and error handling.

---

## Table of Contents

1. [RAG Archetype REST API](#rag-archetype-rest-api)
2. [API-Service GraphQL API](#api-service-graphql-api)
3. [Authentication](#authentication)
4. [Rate Limiting](#rate-limiting)
5. [Error Handling](#error-handling)
6. [WebSocket API](#websocket-api)
7. [API Collections](#api-collections)

---

## RAG Archetype REST API

### Base URL

```
http://localhost:8000
```

### Interactive Documentation

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### OpenAPI Specification

The RAG API follows OpenAPI 3.0 specification. Download the spec:

```bash
curl http://localhost:8000/openapi.json > rag-openapi.json
```

---

### Health & Status Endpoints

#### GET /health

Health check endpoint to verify service status.

**Request:**
```http
GET /health HTTP/1.1
Host: localhost:8000
```

**Response:**
```json
{
  "status": "healthy",
  "app": "RAG API",
  "version": "1.0.0"
}
```

**Status Codes:**
- `200 OK` - Service is healthy
- `503 Service Unavailable` - Service is down

---

#### GET /

Root endpoint with API information and navigation.

**Response:**
```json
{
  "message": "RAG API",
  "docs": "/docs",
  "redoc": "/redoc",
  "health": "/health",
  "rag_endpoints": {
    "ask": "/rag/ask",
    "search": "/rag/search",
    "index": "/rag/index",
    "chat": "/rag/chat"
  }
}
```

---

### RAG Endpoints

#### POST /rag/ask

Ask a question and get an AI-generated answer with retrieved context.

**Description:**
Performs retrieval-augmented generation (RAG):
1. Retrieves relevant documents based on the query
2. Constructs a prompt with retrieved context
3. Generates an answer using the LLM

**Request Body:**
```json
{
  "query": "What is machine learning?",
  "top_k": 5,
  "search_type": "hybrid",
  "system_message": "You are a helpful AI assistant.",
  "temperature": 0.7,
  "max_tokens": 500,
  "stream": false
}
```

**Parameters:**
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `query` | string | Yes | - | Question to ask |
| `top_k` | integer | No | 5 | Number of documents to retrieve (1-20) |
| `search_type` | string | No | "hybrid" | Search type: "keyword", "vector", or "hybrid" |
| `system_message` | string | No | null | Optional system message for the LLM |
| `temperature` | float | No | 0.7 | LLM temperature (0.0-1.0) |
| `max_tokens` | integer | No | null | Maximum tokens to generate |
| `stream` | boolean | No | false | Whether to stream the response |

**Response (Non-Streaming):**
```json
{
  "answer": "Machine learning is a subset of artificial intelligence...",
  "context": [
    {
      "id": "doc-123",
      "content": "Machine learning involves...",
      "score": 0.95,
      "metadata": {
        "source": "ml-basics.pdf",
        "page": 1
      }
    }
  ],
  "query": "What is machine learning?",
  "search_type": "hybrid"
}
```

**Response (Streaming):**
When `stream: true`, returns Server-Sent Events (SSE):

```
data: {"token": "Machine", "type": "token"}

data: {"token": " learning", "type": "token"}

data: {"token": " is", "type": "token"}

data: {"type": "done"}
```

**Status Codes:**
- `200 OK` - Successful response
- `400 Bad Request` - Invalid request parameters
- `500 Internal Server Error` - Server error

**Example cURL:**
```bash
curl -X POST "http://localhost:8000/rag/ask" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What is machine learning?",
    "top_k": 5,
    "search_type": "hybrid"
  }'
```

---

#### POST /rag/search

Search for relevant documents without LLM generation.

**Description:**
Performs semantic search using keyword, vector, or hybrid search to find relevant documents.

**Request Body:**
```json
{
  "query": "machine learning algorithms",
  "top_k": 10,
  "search_type": "hybrid",
  "filters": {
    "category": "ai",
    "year": 2023
  }
}
```

**Parameters:**
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `query` | string | Yes | - | Search query |
| `top_k` | integer | No | 10 | Number of results (1-50) |
| `search_type` | string | No | "hybrid" | Search type: "keyword", "vector", or "hybrid" |
| `filters` | object | No | null | Optional metadata filters |

**Response:**
```json
{
  "query": "machine learning algorithms",
  "results": [
    {
      "id": "doc-456",
      "content": "Machine learning algorithms can be categorized...",
      "score": 0.92,
      "metadata": {
        "source": "ml-guide.pdf",
        "page": 5,
        "category": "ai",
        "year": 2023
      }
    }
  ],
  "total": 10,
  "search_type": "hybrid"
}
```

**Status Codes:**
- `200 OK` - Successful search
- `400 Bad Request` - Invalid parameters
- `500 Internal Server Error` - Server error

**Example cURL:**
```bash
curl -X POST "http://localhost:8000/rag/search" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "machine learning algorithms",
    "top_k": 10,
    "search_type": "hybrid"
  }'
```

---

#### POST /rag/index

Index documents for retrieval.

**Description:**
Chunks documents, generates embeddings, and indexes them in OpenSearch for later retrieval.

**Request Body:**
```json
{
  "documents": [
    {
      "id": "doc-1",
      "content": "Machine learning is a method of data analysis...",
      "metadata": {
        "source": "ml-intro.txt",
        "category": "ai",
        "year": 2023
      }
    },
    {
      "id": "doc-2",
      "content": "Deep learning is a subset of machine learning...",
      "metadata": {
        "source": "dl-basics.txt",
        "category": "ai",
        "year": 2023
      }
    }
  ],
  "text_field": "content"
}
```

**Parameters:**
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `documents` | array | Yes | - | List of documents to index |
| `text_field` | string | No | "content" | Field containing text to index |

**Response:**
```json
{
  "message": "Documents indexed successfully",
  "indexed": 2,
  "errors": 0
}
```

**Status Codes:**
- `200 OK` - Documents indexed successfully
- `400 Bad Request` - No documents provided or invalid format
- `500 Internal Server Error` - Indexing error

**Example cURL:**
```bash
curl -X POST "http://localhost:8000/rag/index" \
  -H "Content-Type: application/json" \
  -d '{
    "documents": [
      {
        "content": "Machine learning basics...",
        "metadata": {"source": "ml.txt"}
      }
    ],
    "text_field": "content"
  }'
```

---

#### POST /rag/chat

Chat with context retrieval.

**Description:**
Performs RAG-enhanced chat where the system retrieves relevant context based on the conversation history.

**Request Body:**
```json
{
  "messages": [
    {
      "role": "user",
      "content": "What is machine learning?"
    },
    {
      "role": "assistant",
      "content": "Machine learning is a subset of AI..."
    },
    {
      "role": "user",
      "content": "Can you give me an example?"
    }
  ],
  "top_k": 5,
  "search_type": "hybrid",
  "temperature": 0.7,
  "max_tokens": 300
}
```

**Parameters:**
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `messages` | array | Yes | - | Chat message history |
| `messages[].role` | string | Yes | - | Message role: "system", "user", or "assistant" |
| `messages[].content` | string | Yes | - | Message content |
| `top_k` | integer | No | 5 | Number of documents to retrieve (1-20) |
| `search_type` | string | No | "hybrid" | Search type |
| `temperature` | float | No | 0.7 | LLM temperature (0.0-1.0) |
| `max_tokens` | integer | No | null | Maximum tokens to generate |

**Response:**
```json
{
  "response": "Sure! For example, a spam filter uses machine learning...",
  "context": [
    {
      "id": "doc-789",
      "content": "Email spam filtering is a common ML application...",
      "score": 0.88
    }
  ]
}
```

**Status Codes:**
- `200 OK` - Chat response generated
- `400 Bad Request` - Invalid message format
- `500 Internal Server Error` - Server error

---

## API-Service GraphQL API

### Base URL

```
http://localhost:8001/graphql
```

### GraphQL Playground

Interactive GraphQL playground available at:
```
http://localhost:8001/graphql
```

### GraphQL Schema (SDL)

Download the full GraphQL schema:

```bash
curl http://localhost:8001/graphql/schema > api-schema.graphql
```

---

### Schema Overview

```graphql
type Query {
  hello: String!
  health: HealthStatus!
  users: [User!]!
  user(id: Int!): User
  tasks: [Task!]!
  task(id: String!): Task
}

type Mutation {
  createUser(input: UserInput!): User!
  updateUser(id: Int!, input: UserUpdateInput!): User
  deleteUser(id: Int!): Boolean!
  submitTask(name: String!, data: JSON!): Task!
  cancelTask(id: String!): Boolean!
}
```

---

### Queries

#### hello

Simple hello query for testing.

**Query:**
```graphql
query {
  hello
}
```

**Response:**
```json
{
  "data": {
    "hello": "Hello from GraphQL!"
  }
}
```

---

#### health

Health check query with service status.

**Query:**
```graphql
query {
  health {
    status
    version
    timestamp
    services
  }
}
```

**Response:**
```json
{
  "data": {
    "health": {
      "status": "healthy",
      "version": "1.0.0",
      "timestamp": "2025-11-29T10:30:00Z",
      "services": {
        "api": "up",
        "database": "up",
        "redis": "up",
        "celery": "up"
      }
    }
  }
}
```

---

#### users

Get all users.

**Query:**
```graphql
query {
  users {
    id
    username
    email
    isActive
    createdAt
  }
}
```

**Response:**
```json
{
  "data": {
    "users": [
      {
        "id": 1,
        "username": "admin",
        "email": "admin@example.com",
        "isActive": true,
        "createdAt": "2025-11-29T10:00:00Z"
      },
      {
        "id": 2,
        "username": "user",
        "email": "user@example.com",
        "isActive": true,
        "createdAt": "2025-11-29T10:15:00Z"
      }
    ]
  }
}
```

---

#### user

Get a single user by ID.

**Query:**
```graphql
query GetUser($id: Int!) {
  user(id: $id) {
    id
    username
    email
    isActive
    createdAt
  }
}
```

**Variables:**
```json
{
  "id": 1
}
```

**Response:**
```json
{
  "data": {
    "user": {
      "id": 1,
      "username": "admin",
      "email": "admin@example.com",
      "isActive": true,
      "createdAt": "2025-11-29T10:00:00Z"
    }
  }
}
```

---

#### tasks

Get all background tasks.

**Query:**
```graphql
query {
  tasks {
    id
    name
    status
    createdAt
    completedAt
    result
    error
  }
}
```

**Response:**
```json
{
  "data": {
    "tasks": [
      {
        "id": "task-1",
        "name": "send_email",
        "status": "completed",
        "createdAt": "2025-11-29T10:00:00Z",
        "completedAt": "2025-11-29T10:00:05Z",
        "result": "Email sent successfully",
        "error": null
      }
    ]
  }
}
```

---

#### task

Get a single task by ID.

**Query:**
```graphql
query GetTask($id: String!) {
  task(id: $id) {
    id
    name
    status
    createdAt
    completedAt
    result
    error
  }
}
```

**Variables:**
```json
{
  "id": "task-123"
}
```

---

### Mutations

#### createUser

Create a new user.

**Mutation:**
```graphql
mutation CreateUser($input: UserInput!) {
  createUser(input: $input) {
    id
    username
    email
    isActive
    createdAt
  }
}
```

**Variables:**
```json
{
  "input": {
    "username": "newuser",
    "email": "newuser@example.com",
    "password": "securepassword123"
  }
}
```

**Response:**
```json
{
  "data": {
    "createUser": {
      "id": 3,
      "username": "newuser",
      "email": "newuser@example.com",
      "isActive": true,
      "createdAt": "2025-11-29T11:00:00Z"
    }
  }
}
```

---

#### updateUser

Update an existing user.

**Mutation:**
```graphql
mutation UpdateUser($id: Int!, $input: UserUpdateInput!) {
  updateUser(id: $id, input: $input) {
    id
    username
    email
    isActive
  }
}
```

**Variables:**
```json
{
  "id": 3,
  "input": {
    "username": "updateduser",
    "email": "updated@example.com",
    "isActive": true
  }
}
```

---

#### deleteUser

Delete a user.

**Mutation:**
```graphql
mutation DeleteUser($id: Int!) {
  deleteUser(id: $id)
}
```

**Variables:**
```json
{
  "id": 3
}
```

**Response:**
```json
{
  "data": {
    "deleteUser": true
  }
}
```

---

#### submitTask

Submit a background task for processing.

**Mutation:**
```graphql
mutation SubmitTask($name: String!, $data: JSON!) {
  submitTask(name: $name, data: $data) {
    id
    name
    status
    createdAt
  }
}
```

**Variables:**
```json
{
  "name": "process_data",
  "data": {
    "file": "data.csv",
    "operation": "aggregate"
  }
}
```

**Response:**
```json
{
  "data": {
    "submitTask": {
      "id": "task-456",
      "name": "process_data",
      "status": "pending",
      "createdAt": "2025-11-29T11:30:00Z"
    }
  }
}
```

---

#### cancelTask

Cancel a running task.

**Mutation:**
```graphql
mutation CancelTask($id: String!) {
  cancelTask(id: $id)
}
```

**Variables:**
```json
{
  "id": "task-456"
}
```

**Response:**
```json
{
  "data": {
    "cancelTask": true
  }
}
```

---

## Authentication

### JWT Authentication (API-Service)

The API-Service uses JWT (JSON Web Token) authentication for secure access.

#### Login Endpoint

**POST /auth/login**

**Request:**
```json
{
  "username": "admin",
  "password": "password123"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

#### Using Authentication

Include the JWT token in the Authorization header:

**REST API:**
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**GraphQL:**
```http
POST /graphql HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "query": "{ users { id username } }"
}
```

---

## Rate Limiting

### Default Rate Limits

| Service | Endpoint | Limit |
|---------|----------|-------|
| RAG API | `/rag/ask` | 30 requests/minute |
| RAG API | `/rag/search` | 60 requests/minute |
| RAG API | `/rag/index` | 10 requests/minute |
| API-Service | All endpoints | 100 requests/minute |

### Rate Limit Headers

Responses include rate limit information:

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1701259200
```

### Rate Limit Exceeded

**Response:**
```json
{
  "error": "Rate limit exceeded",
  "message": "Too many requests. Please try again in 30 seconds.",
  "retry_after": 30
}
```

**Status Code:** `429 Too Many Requests`

---

## Error Handling

### Error Response Format

All errors follow a consistent format:

```json
{
  "error": "ErrorType",
  "message": "Human-readable error message",
  "details": {
    "field": "Additional context"
  },
  "timestamp": "2025-11-29T12:00:00Z"
}
```

### HTTP Status Codes

| Code | Description | Example |
|------|-------------|---------|
| `200 OK` | Successful request | Data retrieved successfully |
| `201 Created` | Resource created | User created successfully |
| `400 Bad Request` | Invalid request | Missing required field |
| `401 Unauthorized` | Authentication required | Invalid or missing token |
| `403 Forbidden` | Permission denied | Insufficient permissions |
| `404 Not Found` | Resource not found | User ID does not exist |
| `422 Unprocessable Entity` | Validation error | Invalid email format |
| `429 Too Many Requests` | Rate limit exceeded | Too many API calls |
| `500 Internal Server Error` | Server error | Unexpected server issue |
| `503 Service Unavailable` | Service down | Database unavailable |

### GraphQL Errors

GraphQL errors are returned in the `errors` array:

```json
{
  "data": null,
  "errors": [
    {
      "message": "User not found",
      "locations": [{"line": 2, "column": 3}],
      "path": ["user"],
      "extensions": {
        "code": "NOT_FOUND",
        "userId": 999
      }
    }
  ]
}
```

---

## WebSocket API

### Connection

Connect to WebSocket for real-time updates:

```javascript
const ws = new WebSocket('ws://localhost:8000/ws');

ws.onopen = () => {
  console.log('Connected to WebSocket');
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Received:', data);
};
```

### Authentication

Send authentication token after connection:

```javascript
ws.onopen = () => {
  ws.send(JSON.stringify({
    type: 'auth',
    token: 'your-jwt-token'
  }));
};
```

### Streaming RAG Responses

Subscribe to streaming RAG responses:

```javascript
// Send request
ws.send(JSON.stringify({
  type: 'rag_stream',
  data: {
    query: 'What is machine learning?',
    top_k: 5
  }
}));

// Receive stream
ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  
  if (message.type === 'token') {
    console.log('Token:', message.data);
  } else if (message.type === 'done') {
    console.log('Stream complete');
  }
};
```

### Task Status Updates

Subscribe to task status updates:

```javascript
ws.send(JSON.stringify({
  type: 'subscribe_task',
  task_id: 'task-123'
}));

ws.onmessage = (event) => {
  const update = JSON.parse(event.data);
  console.log('Task status:', update.status);
};
```

---

## API Collections

### Postman Collection

Download the Postman collection for RAG API:

**File:** `collections/rag-api.postman_collection.json`

**Import Instructions:**
1. Open Postman
2. Click "Import" button
3. Select `rag-api.postman_collection.json`
4. Import the environment: `rag-api.postman_environment.json`

**Collection Contents:**
- Health check requests
- RAG ask/search/index/chat endpoints
- Pre-request scripts for authentication
- Test scripts for response validation

### Insomnia Collection

Download the Insomnia collection for API-Service GraphQL:

**File:** `collections/api-service.insomnia.json`

**Import Instructions:**
1. Open Insomnia
2. Go to Application → Preferences → Data
3. Click "Import Data" → "From File"
4. Select `api-service.insomnia.json`

**Collection Contents:**
- All GraphQL queries and mutations
- Environment variables for local/production
- Authentication setup
- Example variables for each query

### Environment Variables

**RAG API Environment:**
```json
{
  "base_url": "http://localhost:8000",
  "api_key": "your-api-key"
}
```

**API-Service Environment:**
```json
{
  "base_url": "http://localhost:8001",
  "graphql_endpoint": "http://localhost:8001/graphql",
  "jwt_token": "your-jwt-token"
}
```

---

## Code Examples

### Python

**RAG API Client:**
```python
import requests

class RAGClient:
    def __init__(self, base_url="http://localhost:8000"):
        self.base_url = base_url
    
    def ask(self, query, top_k=5, search_type="hybrid"):
        response = requests.post(
            f"{self.base_url}/rag/ask",
            json={
                "query": query,
                "top_k": top_k,
                "search_type": search_type
            }
        )
        response.raise_for_status()
        return response.json()

# Usage
client = RAGClient()
result = client.ask("What is machine learning?")
print(result["answer"])
```

### JavaScript/TypeScript

**GraphQL Client:**
```typescript
import { ApolloClient, InMemoryCache, gql } from '@apollo/client';

const client = new ApolloClient({
  uri: 'http://localhost:8001/graphql',
  cache: new InMemoryCache(),
  headers: {
    authorization: `Bearer ${token}`
  }
});

// Query users
const GET_USERS = gql`
  query GetUsers {
    users {
      id
      username
      email
    }
  }
`;

const { data } = await client.query({ query: GET_USERS });
console.log(data.users);
```

### cURL Examples

**RAG Ask:**
```bash
curl -X POST http://localhost:8000/rag/ask \
  -H "Content-Type: application/json" \
  -d '{"query": "What is ML?", "top_k": 5}'
```

**GraphQL Query:**
```bash
curl -X POST http://localhost:8001/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"query": "{ users { id username } }"}'
```

---

## Next Steps

- **Explore Interactive Docs**: Visit http://localhost:8000/docs (RAG) or http://localhost:8001/graphql (API-Service)
- **Download Collections**: Import Postman/Insomnia collections for quick testing
- **Read Guides**: Check [TECHNICAL_REFERENCE.md](TECHNICAL_REFERENCE.md) for implementation details
- **View Architecture**: See [ARCHITECTURE.md](ARCHITECTURE.md) for system design

---

**Questions or Issues?** Open an issue on GitHub or refer to [FAQ.md](FAQ.md)
