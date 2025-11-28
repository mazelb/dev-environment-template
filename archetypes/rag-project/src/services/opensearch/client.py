"""OpenSearch client for search and vector operations."""

import logging
from typing import Any, Dict, List, Optional

from opensearchpy import OpenSearch, RequestError

logger = logging.getLogger(__name__)


class OpenSearchClient:
    """Client for OpenSearch operations including indexing, search, and vector search."""

    def __init__(
        self,
        host: str,
        port: int,
        use_ssl: bool = False,
        verify_certs: bool = False,
        http_auth: Optional[tuple] = None,
    ):
        """Initialize OpenSearch client.

        Args:
            host: OpenSearch host
            port: OpenSearch port
            use_ssl: Whether to use SSL
            verify_certs: Whether to verify SSL certificates
            http_auth: Tuple of (username, password) for authentication
        """
        self.client = OpenSearch(
            hosts=[{"host": host, "port": port}],
            http_compress=True,
            use_ssl=use_ssl,
            verify_certs=verify_certs,
            ssl_assert_hostname=False,
            ssl_show_warn=False,
            http_auth=http_auth,
        )
        self._ensure_rrf_pipeline()

    def health_check(self) -> bool:
        """Check if OpenSearch is healthy."""
        try:
            health = self.client.cluster.health()
            return health["status"] in ["green", "yellow"]
        except Exception as e:
            logger.error(f"OpenSearch health check failed: {e}")
            return False

    def _ensure_rrf_pipeline(self) -> None:
        """Ensure the RRF (Reciprocal Rank Fusion) search pipeline exists."""
        pipeline_name = "hybrid-rrf-pipeline"
        try:
            # Check if pipeline exists
            self.client.search_pipeline.get(id=pipeline_name)
            logger.info(f"RRF pipeline '{pipeline_name}' already exists")
        except Exception:
            # Create RRF pipeline for hybrid search
            pipeline_body = {
                "description": "Hybrid search pipeline with RRF",
                "phase_results_processors": [
                    {
                        "normalization-processor": {
                            "normalization": {"technique": "min_max"},
                            "combination": {
                                "technique": "arithmetic_mean",
                                "parameters": {"weights": [0.5, 0.5]},
                            },
                        }
                    }
                ],
            }
            try:
                self.client.search_pipeline.put(id=pipeline_name, body=pipeline_body)
                logger.info(f"Created RRF pipeline '{pipeline_name}'")
            except Exception as e:
                logger.warning(f"Could not create RRF pipeline: {e}")

    def create_index(self, index_name: str, mappings: Dict[str, Any]) -> bool:
        """Create an index with mappings.

        Args:
            index_name: Name of the index
            mappings: Index mappings and settings

        Returns:
            True if successful, False otherwise
        """
        try:
            if self.client.indices.exists(index=index_name):
                logger.info(f"Index '{index_name}' already exists")
                return True

            self.client.indices.create(index=index_name, body=mappings)
            logger.info(f"Created index '{index_name}'")
            return True
        except RequestError as e:
            logger.error(f"Failed to create index '{index_name}': {e}")
            return False

    def delete_index(self, index_name: str) -> bool:
        """Delete an index.

        Args:
            index_name: Name of the index

        Returns:
            True if successful, False otherwise
        """
        try:
            if not self.client.indices.exists(index=index_name):
                logger.warning(f"Index '{index_name}' does not exist")
                return True

            self.client.indices.delete(index=index_name)
            logger.info(f"Deleted index '{index_name}'")
            return True
        except RequestError as e:
            logger.error(f"Failed to delete index '{index_name}': {e}")
            return False

    def index_document(
        self, index_name: str, document: Dict[str, Any], doc_id: Optional[str] = None
    ) -> Optional[str]:
        """Index a single document.

        Args:
            index_name: Name of the index
            document: Document to index
            doc_id: Optional document ID

        Returns:
            Document ID if successful, None otherwise
        """
        try:
            response = self.client.index(
                index=index_name, body=document, id=doc_id, refresh=True
            )
            return response["_id"]
        except RequestError as e:
            logger.error(f"Failed to index document: {e}")
            return None

    def bulk_index(
        self, index_name: str, documents: List[Dict[str, Any]]
    ) -> Dict[str, int]:
        """Bulk index multiple documents.

        Args:
            index_name: Name of the index
            documents: List of documents to index

        Returns:
            Dictionary with success and error counts
        """
        from opensearchpy import helpers

        actions = [
            {"_index": index_name, "_source": doc, "_id": doc.get("id")}
            for doc in documents
        ]

        try:
            success, errors = helpers.bulk(self.client, actions, raise_on_error=False)
            logger.info(
                f"Bulk indexed {success} documents with {len(errors)} errors"
            )
            return {"success": success, "errors": len(errors)}
        except Exception as e:
            logger.error(f"Bulk indexing failed: {e}")
            return {"success": 0, "errors": len(documents)}

    def keyword_search(
        self,
        index_name: str,
        query: str,
        fields: List[str],
        size: int = 10,
        filters: Optional[Dict[str, Any]] = None,
    ) -> List[Dict[str, Any]]:
        """Perform BM25 keyword search.

        Args:
            index_name: Name of the index
            query: Search query
            fields: Fields to search in
            size: Number of results to return
            filters: Optional filters to apply

        Returns:
            List of search results
        """
        query_body = {
            "query": {
                "bool": {
                    "must": [{"multi_match": {"query": query, "fields": fields}}]
                }
            },
            "size": size,
        }

        # Add filters if provided
        if filters:
            query_body["query"]["bool"]["filter"] = filters

        try:
            response = self.client.search(index=index_name, body=query_body)
            return [
                {
                    "id": hit["_id"],
                    "score": hit["_score"],
                    "source": hit["_source"],
                }
                for hit in response["hits"]["hits"]
            ]
        except RequestError as e:
            logger.error(f"Keyword search failed: {e}")
            return []

    def vector_search(
        self,
        index_name: str,
        vector: List[float],
        vector_field: str = "embedding",
        size: int = 10,
        filters: Optional[Dict[str, Any]] = None,
    ) -> List[Dict[str, Any]]:
        """Perform k-NN vector search.

        Args:
            index_name: Name of the index
            vector: Query vector
            vector_field: Name of the vector field
            size: Number of results to return
            filters: Optional filters to apply

        Returns:
            List of search results
        """
        query_body = {"size": size, "query": {"knn": {vector_field: {"vector": vector, "k": size}}}}

        # Add filters if provided
        if filters:
            query_body["query"]["knn"][vector_field]["filter"] = filters

        try:
            response = self.client.search(index=index_name, body=query_body)
            return [
                {
                    "id": hit["_id"],
                    "score": hit["_score"],
                    "source": hit["_source"],
                }
                for hit in response["hits"]["hits"]
            ]
        except RequestError as e:
            logger.error(f"Vector search failed: {e}")
            return []

    def hybrid_search(
        self,
        index_name: str,
        query: str,
        vector: List[float],
        text_fields: List[str],
        vector_field: str = "embedding",
        size: int = 10,
        filters: Optional[Dict[str, Any]] = None,
    ) -> List[Dict[str, Any]]:
        """Perform hybrid search combining BM25 and vector search with RRF.

        Args:
            index_name: Name of the index
            query: Text query for BM25
            vector: Query vector for k-NN
            text_fields: Fields for text search
            vector_field: Name of the vector field
            size: Number of results to return
            filters: Optional filters to apply

        Returns:
            List of search results with normalized scores
        """
        # Multiply size for better recall before RRF
        search_size = size * 2

        # Build hybrid query
        query_body = {
            "size": size,
            "query": {
                "hybrid": {
                    "queries": [
                        # BM25 text search
                        {"multi_match": {"query": query, "fields": text_fields}},
                        # k-NN vector search
                        {"knn": {vector_field: {"vector": vector, "k": search_size}}},
                    ]
                }
            },
        }

        # Add filters if provided
        if filters:
            query_body["query"]["hybrid"]["filter"] = filters

        try:
            response = self.client.search(
                index=index_name, body=query_body, params={"search_pipeline": "hybrid-rrf-pipeline"}
            )
            return [
                {
                    "id": hit["_id"],
                    "score": hit["_score"],
                    "source": hit["_source"],
                }
                for hit in response["hits"]["hits"]
            ]
        except RequestError as e:
            logger.error(f"Hybrid search failed: {e}")
            # Fallback to keyword search
            logger.info("Falling back to keyword search")
            return self.keyword_search(index_name, query, text_fields, size, filters)

    def get_document(self, index_name: str, doc_id: str) -> Optional[Dict[str, Any]]:
        """Retrieve a document by ID.

        Args:
            index_name: Name of the index
            doc_id: Document ID

        Returns:
            Document if found, None otherwise
        """
        try:
            response = self.client.get(index=index_name, id=doc_id)
            return response["_source"]
        except Exception as e:
            logger.error(f"Failed to get document {doc_id}: {e}")
            return None

    def delete_document(self, index_name: str, doc_id: str) -> bool:
        """Delete a document by ID.

        Args:
            index_name: Name of the index
            doc_id: Document ID

        Returns:
            True if successful, False otherwise
        """
        try:
            self.client.delete(index=index_name, id=doc_id, refresh=True)
            return True
        except Exception as e:
            logger.error(f"Failed to delete document {doc_id}: {e}")
            return False

    def count_documents(self, index_name: str) -> int:
        """Count documents in an index.

        Args:
            index_name: Name of the index

        Returns:
            Number of documents
        """
        try:
            response = self.client.count(index=index_name)
            return response["count"]
        except Exception as e:
            logger.error(f"Failed to count documents: {e}")
            return 0

    def list_indices(self) -> List[str]:
        """List all indices.

        Returns:
            List of index names
        """
        try:
            response = self.client.cat.indices(format="json")
            return [index["index"] for index in response]
        except Exception as e:
            logger.error(f"Failed to list indices: {e}")
            return []

    def close(self) -> None:
        """Close the client connection."""
        try:
            self.client.close()
        except Exception as e:
            logger.error(f"Error closing OpenSearch client: {e}")
