"""
GraphQL schema definition.
"""

import strawberry
from strawberry.fastapi import GraphQLRouter

from src.graphql.mutations import Mutation
from src.graphql.queries import Query

# Create schema
schema = strawberry.Schema(query=Query, mutation=Mutation)


# Create GraphQL router for FastAPI
def get_graphql_router() -> GraphQLRouter:
    """Get GraphQL router for FastAPI."""
    return GraphQLRouter(schema, path="/graphql")
