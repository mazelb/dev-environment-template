# Frontend Archetype

Production-ready TypeScript frontend archetype with Next.js 14, GraphQL, and WebSocket support.

## Features

- **Next.js 14+** - React framework with App Router
- **TypeScript** - Type-safe development
- **Tailwind CSS** - Utility-first CSS framework
- **shadcn/ui** - Re-usable component library
- **Apollo Client** - GraphQL client with caching
- **Axios** - HTTP client with retry logic
- **Socket.io** - WebSocket for real-time updates
- **Zustand** - Lightweight state management
- **TanStack Query** - Server state management
- **Vitest** - Fast unit testing framework
- **React Testing Library** - Component testing

## Prerequisites

- Node.js 20+
- npm 10+

## Quick Start

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env.local

# Start development server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## Available Scripts

```bash
# Development
npm run dev              # Start dev server
npm run build            # Build for production
npm run start            # Start production server

# Code Quality
npm run lint             # Run ESLint
npm run type-check       # TypeScript type checking
npm run format           # Format code with Prettier
npm run format:check     # Check code formatting

# Testing
npm test                 # Run tests
npm run test:ui          # Run tests with UI
npm run test:coverage    # Run tests with coverage
```

## Project Structure

```
src/
├── app/                 # Next.js App Router pages
│   ├── layout.tsx      # Root layout
│   ├── page.tsx        # Home page
│   └── ...
├── components/          # React components
│   ├── ui/             # shadcn/ui components
│   ├── layout/         # Layout components
│   └── features/       # Feature-specific components
├── lib/                 # Utility libraries
│   ├── http-client.ts  # REST API client
│   ├── graphql-client.ts # GraphQL client
│   ├── websocket.ts    # WebSocket handler
│   └── utils.ts        # Helper functions
├── hooks/               # Custom React hooks
│   ├── use-api.ts      # API hooks
│   ├── use-graphql.ts  # GraphQL hooks
│   └── use-websocket.ts # WebSocket hooks
├── types/               # TypeScript types
│   ├── api.ts          # API types
│   └── graphql.ts      # GraphQL types
└── styles/              # Global styles
    └── globals.css     # Global CSS
```

## API Integration

### REST API

```typescript
import { apiClient } from '@/lib/http-client';

// GET request
const data = await apiClient.get('/api/users');

// POST request with retry
const result = await apiClient.post('/api/users', { name: 'John' });
```

### GraphQL

```typescript
import { useQuery, useMutation } from '@apollo/client';
import { GET_USERS, CREATE_USER } from '@/lib/graphql-queries';

function Users() {
  const { data, loading } = useQuery(GET_USERS);
  const [createUser] = useMutation(CREATE_USER);

  // ...
}
```

### WebSocket

```typescript
import { useWebSocket } from '@/hooks/use-websocket';

function StreamingComponent() {
  const { socket, isConnected } = useWebSocket();

  useEffect(() => {
    socket?.on('message', (data) => {
      console.log('Received:', data);
    });
  }, [socket]);
}
```

## Docker Deployment

```bash
# Build image
docker build -t frontend-archetype .

# Run container
docker run -p 3000:3000 frontend-archetype
```

## Environment Variables

See `.env.example` for all available environment variables.

Required variables:
- `NEXT_PUBLIC_API_URL` - Backend API URL
- `NEXT_PUBLIC_GRAPHQL_URL` - GraphQL endpoint
- `NEXT_PUBLIC_WS_URL` - WebSocket URL

## Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm test -- --watch

# Generate coverage report
npm run test:coverage
```

## Contributing

1. Follow TypeScript best practices
2. Use ESLint and Prettier for code quality
3. Write tests for new features
4. Update documentation

## License

MIT
