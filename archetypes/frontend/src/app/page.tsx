export default function HomePage() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <div className="z-10 max-w-5xl w-full items-center justify-between font-mono text-sm">
        <h1 className="text-4xl font-bold text-center mb-8">
          Welcome to Frontend Archetype
        </h1>

        <div className="grid text-center lg:max-w-5xl lg:w-full lg:mb-0 lg:grid-cols-3 lg:text-left gap-4">
          <a
            href="/search"
            className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 hover:dark:border-neutral-700 hover:dark:bg-neutral-800/30"
          >
            <h2 className="mb-3 text-2xl font-semibold">
              Search{' '}
              <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
                -&gt;
              </span>
            </h2>
            <p className="m-0 max-w-[30ch] text-sm opacity-50">
              Powerful search interface with filters and pagination
            </p>
          </a>

          <a
            href="/rag"
            className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 hover:dark:border-neutral-700 hover:dark:bg-neutral-800/30"
          >
            <h2 className="mb-3 text-2xl font-semibold">
              RAG Q&A{' '}
              <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
                -&gt;
              </span>
            </h2>
            <p className="m-0 max-w-[30ch] text-sm opacity-50">
              Ask questions with streaming RAG responses
            </p>
          </a>

          <a
            href="/dashboard"
            className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 hover:dark:border-neutral-700 hover:dark:bg-neutral-800/30"
          >
            <h2 className="mb-3 text-2xl font-semibold">
              Dashboard{' '}
              <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
                -&gt;
              </span>
            </h2>
            <p className="m-0 max-w-[30ch] text-sm opacity-50">
              Analytics and monitoring dashboard
            </p>
          </a>
        </div>

        <div className="mt-16 text-center">
          <h3 className="text-xl font-semibold mb-4">Features</h3>
          <ul className="text-sm text-gray-600 dark:text-gray-400 space-y-2">
            <li>✅ TypeScript with strict type checking</li>
            <li>✅ REST API client with retry logic</li>
            <li>✅ GraphQL client with Apollo</li>
            <li>✅ WebSocket support for real-time updates</li>
            <li>✅ Responsive design with Tailwind CSS</li>
            <li>✅ Component library with shadcn/ui</li>
          </ul>
        </div>
      </div>
    </main>
  );
}
