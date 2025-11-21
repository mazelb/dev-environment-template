"""
Example: API Usage

This example shows how to interact with the composite system via HTTP API.
"""

import requests
import json
import time


BASE_URL = "http://localhost:8000"


def upload_document(filepath: str) -> dict:
    """Upload a document to the system."""
    print(f"📄 Uploading document: {filepath}")
    
    with open(filepath, 'rb') as f:
        files = {'file': f}
        metadata = json.dumps({"source": "example"})
        data = {'metadata': metadata}
        
        response = requests.post(
            f"{BASE_URL}/documents/upload",
            files=files,
            data=data
        )
        response.raise_for_status()
        
    result = response.json()
    print(f"✅ Uploaded: {result['num_chunks']} chunks")
    return result


def semantic_search(query: str, limit: int = 5) -> dict:
    """Perform semantic search."""
    print(f"\n🔍 Searching: {query}")
    
    response = requests.post(
        f"{BASE_URL}/search",
        json={"query": query, "limit": limit}
    )
    response.raise_for_status()
    
    result = response.json()
    print(f"✅ Found {len(result['results'])} results")
    return result


def rag_query(query: str, k: int = 3) -> dict:
    """Query using RAG (retrieval + generation)."""
    print(f"\n💬 RAG Query: {query}")
    
    response = requests.post(
        f"{BASE_URL}/rag/query",
        json={"query": query, "k": k}
    )
    response.raise_for_status()
    
    result = response.json()
    print(f"✅ Generated answer with {len(result['sources'])} sources")
    return result


def agent_query(query: str) -> dict:
    """Query using agent (multi-step reasoning)."""
    print(f"\n🤖 Agent Query: {query}")
    
    response = requests.post(
        f"{BASE_URL}/agents/query",
        json={"query": query}
    )
    response.raise_for_status()
    
    result = response.json()
    print(f"✅ Agent completed in {result['iterations']} iteration(s)")
    return result


def check_health() -> bool:
    """Check if services are healthy."""
    try:
        response = requests.get(f"{BASE_URL}/health")
        response.raise_for_status()
        print("✅ API is healthy")
        
        response = requests.get(f"{BASE_URL}/agents/health")
        response.raise_for_status()
        print("✅ Agents are healthy")
        
        return True
    except Exception as e:
        print(f"❌ Health check failed: {e}")
        return False


def main():
    """Run the API example."""
    
    print("\n" + "="*60)
    print("Composite RAG + Agents System - API Example")
    print("="*60 + "\n")
    
    # Check health
    if not check_health():
        print("\n❌ Services not ready. Run: docker-compose up -d")
        return
    
    # Example 1: Upload document
    print("\n" + "="*60)
    print("Example 1: Upload Document")
    print("="*60)
    
    try:
        # Create a sample document
        sample_doc = """
        Machine Learning Best Practices
        
        1. Data Quality: Ensure your training data is clean and representative
        2. Model Selection: Choose appropriate models for your problem
        3. Validation: Use cross-validation to assess model performance
        4. Monitoring: Continuously monitor model performance in production
        5. Documentation: Document your models and their assumptions
        """
        
        with open("/tmp/sample.txt", "w") as f:
            f.write(sample_doc)
        
        upload_result = upload_document("/tmp/sample.txt")
        print(f"   Document ID: {upload_result['document_id']}")
        
        # Give the system time to process
        print("\n⏳ Waiting for indexing to complete...")
        time.sleep(2)
        
    except Exception as e:
        print(f"⚠️  Upload failed: {e}")
    
    # Example 2: Semantic Search
    print("\n" + "="*60)
    print("Example 2: Semantic Search")
    print("="*60)
    
    search_result = semantic_search("best practices for ML models")
    for i, result in enumerate(search_result['results'][:3], 1):
        print(f"\n{i}. Similarity: {result['similarity']:.3f}")
        print(f"   Content: {result['content'][:100]}...")
    
    # Example 3: RAG Query
    print("\n" + "="*60)
    print("Example 3: RAG Query (Retrieval + Generation)")
    print("="*60)
    
    rag_result = rag_query("What are the key best practices mentioned?")
    print(f"\nAnswer:\n{rag_result['answer']}")
    print(f"\nSources used: {len(rag_result['sources'])}")
    
    # Example 4: Agent Query
    print("\n" + "="*60)
    print("Example 4: Agent Query (Multi-Step Reasoning)")
    print("="*60)
    
    agent_result = agent_query(
        "Analyze the best practices and explain which one is most important and why"
    )
    print(f"\nAnswer:\n{agent_result['answer']}")
    
    print("\n" + "="*60)
    print("✅ All examples completed!")
    print("="*60 + "\n")


if __name__ == "__main__":
    main()
