/**
 * API Types
 */

export interface User {
  id: string;
  email: string;
  name: string;
  createdAt: string;
}

export interface Task {
  id: string;
  name: string;
  status: 'PENDING' | 'PROGRESS' | 'SUCCESS' | 'FAILURE';
  createdAt: string;
  result?: any;
  error?: string;
}

export interface HealthStatus {
  status: string;
  timestamp: string;
  services?: Array<{
    name: string;
    status: string;
  }>;
}

export interface SearchResult {
  id: string;
  title: string;
  content: string;
  score: number;
  metadata?: Record<string, any>;
}

export interface RAGResponse {
  answer: string;
  sources: SearchResult[];
  model: string;
  tokensUsed?: number;
}

export interface StreamChunk {
  text: string;
  done: boolean;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface ApiError {
  message: string;
  code: string;
  details?: any;
}

export interface UserInput {
  email: string;
  name: string;
}

export interface UserUpdateInput {
  email?: string;
  name?: string;
}

export interface TaskSubmission {
  name: string;
  payload?: string;
}
