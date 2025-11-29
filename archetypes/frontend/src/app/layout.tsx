import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { ApolloProvider } from '@apollo/client';
import { getApolloClient } from '@/lib/graphql-client';
import '@/styles/globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: process.env.NEXT_PUBLIC_APP_NAME || 'Frontend Archetype',
  description:
    process.env.NEXT_PUBLIC_APP_DESCRIPTION ||
    'Production-ready TypeScript frontend',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const apolloClient = getApolloClient();

  return (
    <html lang="en">
      <body className={inter.className}>
        <ApolloProvider client={apolloClient}>{children}</ApolloProvider>
      </body>
    </html>
  );
}
