/**
 * GraphQL Types (auto-generated types should go here)
 */

export interface GraphQLUser {
  __typename?: 'User';
  id: string;
  email: string;
  name: string;
  createdAt: string;
}

export interface GraphQLTask {
  __typename?: 'Task';
  id: string;
  name: string;
  status: string;
  createdAt: string;
}

export interface GraphQLHealthStatus {
  __typename?: 'HealthStatus';
  status: string;
  timestamp: string;
  services?: Array<{
    __typename?: 'Service';
    name: string;
    status: string;
  }>;
}

export interface GraphQLUserInput {
  email: string;
  name: string;
}

export interface GraphQLUserUpdateInput {
  email?: string;
  name?: string;
}

// Query types
export interface GetUsersQuery {
  users: GraphQLUser[];
}

export interface GetUserQuery {
  user: GraphQLUser;
}

export interface GetTasksQuery {
  tasks: GraphQLTask[];
}

export interface GetTaskQuery {
  task: GraphQLTask;
}

export interface GetHealthQuery {
  health: GraphQLHealthStatus;
}

// Mutation types
export interface CreateUserMutation {
  createUser: GraphQLUser;
}

export interface UpdateUserMutation {
  updateUser: GraphQLUser;
}

export interface DeleteUserMutation {
  deleteUser: boolean;
}

export interface SubmitTaskMutation {
  submitTask: GraphQLTask;
}

export interface CancelTaskMutation {
  cancelTask: boolean;
}
