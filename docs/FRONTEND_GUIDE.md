# Frontend Development Guide

## Overview

This frontend archetype provides a production-ready TypeScript frontend built with Next.js 14, featuring REST and GraphQL API clients, WebSocket support, and a modern component library.

## Architecture

### Tech Stack

- **Framework**: Next.js 14 with App Router
- **Language**: TypeScript 5.6
- **Styling**: Tailwind CSS 3.4
- **Components**: shadcn/ui (Radix UI primitives)
- **State Management**: 
  - Zustand (client state)
  - TanStack Query (server state)
- **API Clients**:
  - Axios (REST API with retry logic)
  - Apollo Client (GraphQL with caching)
  - Socket.io (WebSocket)
- **Testing**: Vitest + React Testing Library

### Project Structure

```
frontend/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── layout.tsx         # Root layout with providers
│   │   ├── page.tsx           # Home page
│   │   ├── search/            # Search feature
│   │   ├── rag/               # RAG Q&A feature
│   │   └── dashboard/         # Dashboard feature
│   ├── components/
│   │   ├── ui/                # shadcn/ui components
│   │   ├── layout/            # Layout components
│   │   │   ├── Header.tsx
│   │   │   ├── Footer.tsx
│   │   │   └── Sidebar.tsx
│   │   └── features/          # Feature-specific components
│   │       ├── SearchBar.tsx
│   │       ├── RAGChat.tsx
│   │       └── TaskList.tsx
│   ├── lib/
│   │   ├── http-client.ts     # REST API client
│   │   ├── graphql-client.ts  # GraphQL client
│   │   ├── graphql-queries.ts # GraphQL queries/mutations
│   │   ├── websocket.ts       # WebSocket client
│   │   └── utils.ts           # Helper utilities
│   ├── hooks/
│   │   ├── use-api.ts         # REST API hooks
│   │   ├── use-graphql.ts     # GraphQL hooks
│   │   └── use-websocket.ts   # WebSocket hooks
│   ├── types/
│   │   ├── api.ts             # REST API types
│   │   └── graphql.ts         # GraphQL types
│   └── styles/
│       └── globals.css        # Global styles
├── public/                     # Static assets
├── package.json               # Dependencies
├── tsconfig.json              # TypeScript config
├── next.config.js             # Next.js config
├── tailwind.config.ts         # Tailwind config
├── Dockerfile                 # Docker configuration
└── Makefile                   # Development commands
```

## Getting Started

### Prerequisites

- Node.js 20+
- npm 10+
- Backend API running (default: http://localhost:8000)

### Installation

```bash
# Clone and navigate to frontend
cd archetypes/frontend

# Copy environment variables
cp .env.example .env.local

# Install dependencies
npm install

# Start development server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Environment Variables

Edit `.env.local`:

```bash
# Backend API URLs
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_GRAPHQL_URL=http://localhost:8000/graphql
NEXT_PUBLIC_WS_URL=ws://localhost:8000

# Feature flags
NEXT_PUBLIC_ENABLE_GRAPHQL=true
NEXT_PUBLIC_ENABLE_WEBSOCKET=true
NEXT_PUBLIC_ENABLE_AUTH=true
```

## API Integration

### REST API Client

The `http-client.ts` provides a robust Axios-based client with:
- Automatic retries for network errors
- Request/response interceptors
- Authentication token management
- Error handling

**Example usage:**

```typescript
import { apiClient } from '@/lib/http-client';

// GET request
const users = await apiClient.get<User[]>('/api/users');

// POST request
const newUser = await apiClient.post<User>('/api/users', {
  email: 'user@example.com',
  name: 'John Doe'
});

// Set auth token
apiClient.setAuthToken('your-jwt-token');
```

### GraphQL Client

The `graphql-client.ts` provides Apollo Client with:
- Authentication middleware
- Retry logic
- Error handling
- Cache management

**Example usage:**

```typescript
import { useQuery, useMutation } from '@apollo/client';
import { GET_USERS, CREATE_USER } from '@/lib/graphql-queries';

function UsersComponent() {
  // Query
  const { data, loading, error } = useQuery(GET_USERS);

  // Mutation
  const [createUser, { loading: creating }] = useMutation(CREATE_USER);

  const handleCreate = async () => {
    const result = await createUser({
      variables: {
        input: { email: 'user@example.com', name: 'John' }
      }
    });
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return <ul>{data.users.map(user => <li key={user.id}>{user.name}</li>)}</ul>;
}
```

### WebSocket Client

The `websocket.ts` provides Socket.io client with:
- Auto-reconnection
- Event management
- Connection state tracking

**Example usage:**

```typescript
import { wsClient } from '@/lib/websocket';
import { useEffect, useState } from 'react';

function StreamingComponent() {
  const [messages, setMessages] = useState<string[]>([]);

  useEffect(() => {
    // Connect to WebSocket
    wsClient.connect();

    // Listen for messages
    wsClient.on('message', (data) => {
      setMessages(prev => [...prev, data.text]);
    });

    // Cleanup
    return () => {
      wsClient.off('message');
      wsClient.disconnect();
    };
  }, []);

  const sendMessage = () => {
    wsClient.emit('send_message', { text: 'Hello' });
  };

  return (
    <div>
      {messages.map((msg, i) => <p key={i}>{msg}</p>)}
      <button onClick={sendMessage}>Send</button>
    </div>
  );
}
```

## Component Library

### shadcn/ui Components

The archetype uses shadcn/ui components built on Radix UI. Components are:
- Fully accessible (ARIA compliant)
- Customizable with Tailwind CSS
- Type-safe with TypeScript

**Available components:**
- Button
- Dialog
- Dropdown Menu
- Tabs
- Select
- Toast
- And more...

### Creating Custom Components

```typescript
// src/components/features/SearchBar.tsx
'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

export function SearchBar({ onSearch }: { onSearch: (query: string) => void }) {
  const [query, setQuery] = useState('');

  return (
    <div className="flex gap-2">
      <Input
        type="text"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search..."
      />
      <Button onClick={() => onSearch(query)}>Search</Button>
    </div>
  );
}
```

## Routing

Next.js 14 uses file-based routing with the App Router:

```
src/app/
├── page.tsx           # Home page (/)
├── layout.tsx         # Root layout
├── search/
│   └── page.tsx       # Search page (/search)
├── rag/
│   └── page.tsx       # RAG Q&A page (/rag)
└── dashboard/
    └── page.tsx       # Dashboard (/dashboard)
```

## State Management

### Client State (Zustand)

```typescript
// src/stores/user-store.ts
import { create } from 'zustand';

interface UserState {
  user: User | null;
  setUser: (user: User) => void;
  clearUser: () => void;
}

export const useUserStore = create<UserState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  clearUser: () => set({ user: null }),
}));
```

### Server State (TanStack Query)

```typescript
import { useQuery } from '@tanstack/react-query';
import { apiClient } from '@/lib/http-client';

function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => apiClient.get<User[]>('/api/users'),
  });
}
```

## Testing

### Unit Tests

```typescript
// src/components/SearchBar.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { SearchBar } from './SearchBar';

test('calls onSearch when button clicked', async () => {
  const onSearch = vi.fn();
  render(<SearchBar onSearch={onSearch} />);

  const input = screen.getByPlaceholderText('Search...');
  const button = screen.getByRole('button', { name: 'Search' });

  await userEvent.type(input, 'test query');
  await userEvent.click(button);

  expect(onSearch).toHaveBeenCalledWith('test query');
});
```

### Run Tests

```bash
# Run all tests
npm test

# Run with UI
npm run test:ui

# Generate coverage
npm run test:coverage
```

## Docker Deployment

### Build Image

```bash
docker build -t frontend-archetype .
```

### Run Container

```bash
docker run -p 3000:3000 \
  -e NEXT_PUBLIC_API_URL=http://api:8000 \
  -e NEXT_PUBLIC_GRAPHQL_URL=http://api:8000/graphql \
  -e NEXT_PUBLIC_WS_URL=ws://api:8000 \
  frontend-archetype
```

### Docker Compose

```yaml
version: '3.8'
services:
  frontend:
    build: ./archetypes/frontend
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://api:8000
      - NEXT_PUBLIC_GRAPHQL_URL=http://api:8000/graphql
      - NEXT_PUBLIC_WS_URL=ws://api:8000
    depends_on:
      - api
```

## Development Workflow

### Available Commands

```bash
# Development
make dev              # Start dev server
make build            # Build for production
make start            # Start production server

# Code quality
make lint             # Run ESLint
make type-check       # TypeScript checking
make format           # Format with Prettier

# Testing
make test             # Run tests
make test-coverage    # Coverage report

# Docker
make docker-build     # Build Docker image
make docker-run       # Run container

# Setup
make setup            # Complete setup
make clean            # Clean build artifacts
```

## Best Practices

### Code Organization

1. **Keep components small and focused**
2. **Use TypeScript for type safety**
3. **Follow naming conventions**:
   - Components: PascalCase (`SearchBar.tsx`)
   - Hooks: camelCase with `use` prefix (`useUsers.ts`)
   - Utilities: camelCase (`formatDate.ts`)

### Performance

1. **Use Next.js Image component** for optimized images
2. **Lazy load components** with `dynamic()`
3. **Implement pagination** for large lists
4. **Use React.memo** for expensive components
5. **Optimize bundle size** with tree-shaking

### Security

1. **Never expose secrets** in client-side code
2. **Use HTTPS** in production
3. **Sanitize user input** before rendering
4. **Implement CSRF protection**
5. **Use Content Security Policy**

## Troubleshooting

### Common Issues

**1. Module not found errors**
```bash
# Clear cache and reinstall
rm -rf node_modules .next
npm install
```

**2. TypeScript errors**
```bash
# Check types
npm run type-check
```

**3. API connection issues**
```bash
# Verify .env.local has correct API URLs
# Check backend is running
curl http://localhost:8000/health
```

**4. Build failures**
```bash
# Clean and rebuild
make clean
npm run build
```

## Additional Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [shadcn/ui Components](https://ui.shadcn.com)
- [Apollo Client Docs](https://www.apollographql.com/docs/react/)
- [Socket.io Client Docs](https://socket.io/docs/v4/client-api/)
