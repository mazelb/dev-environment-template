"""Document ingestion DAG for RAG system.

This DAG demonstrates how to:
1. Fetch documents from a source
2. Process and chunk documents
3. Generate embeddings
4. Index in OpenSearch
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
import logging

logger = logging.getLogger(__name__)

# Default arguments
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

# Create DAG
dag = DAG(
    'document_ingestion',
    default_args=default_args,
    description='Ingest and index documents for RAG',
    schedule_interval=timedelta(days=1),  # Daily
    catchup=False,
    tags=['rag', 'ingestion', 'documents'],
)


def fetch_documents(**context):
    """Fetch documents from source."""
    logger.info("Fetching documents...")
    
    # Example: Fetch from database
    # In production, this would fetch from your data source
    documents = [
        {
            "id": "doc1",
            "title": "Machine Learning Basics",
            "content": "Machine learning is a subset of artificial intelligence..."
        },
        {
            "id": "doc2",
            "title": "Deep Learning Introduction",
            "content": "Deep learning uses neural networks with multiple layers..."
        }
    ]
    
    logger.info(f"Fetched {len(documents)} documents")
    
    # Push to XCom for next task
    context['task_instance'].xcom_push(key='documents', value=documents)
    return len(documents)


def process_documents(**context):
    """Process and chunk documents."""
    logger.info("Processing documents...")
    
    # Pull documents from previous task
    documents = context['task_instance'].xcom_pull(
        task_ids='fetch_documents',
        key='documents'
    )
    
    # Example processing (in production, use chunking service)
    processed_docs = []
    for doc in documents:
        # Simple chunking by character count
        content = doc['content']
        chunk_size = 200
        chunks = [content[i:i+chunk_size] for i in range(0, len(content), chunk_size)]
        
        for idx, chunk in enumerate(chunks):
            processed_docs.append({
                'doc_id': doc['id'],
                'chunk_id': f"{doc['id']}_chunk_{idx}",
                'title': doc['title'],
                'content': chunk,
                'chunk_index': idx
            })
    
    logger.info(f"Processed {len(processed_docs)} document chunks")
    
    # Push processed documents
    context['task_instance'].xcom_push(key='processed_docs', value=processed_docs)
    return len(processed_docs)


def generate_embeddings(**context):
    """Generate embeddings for document chunks."""
    logger.info("Generating embeddings...")
    
    # Pull processed documents
    processed_docs = context['task_instance'].xcom_pull(
        task_ids='process_documents',
        key='processed_docs'
    )
    
    # Example: Generate mock embeddings
    # In production, use embedding service
    import random
    
    for doc in processed_docs:
        # Mock 384-dimensional embedding
        doc['embedding'] = [random.random() for _ in range(384)]
    
    logger.info(f"Generated embeddings for {len(processed_docs)} chunks")
    
    # Push documents with embeddings
    context['task_instance'].xcom_push(key='embedded_docs', value=processed_docs)
    return len(processed_docs)


def index_documents(**context):
    """Index documents in OpenSearch."""
    logger.info("Indexing documents...")
    
    # Pull documents with embeddings
    embedded_docs = context['task_instance'].xcom_pull(
        task_ids='generate_embeddings',
        key='embedded_docs'
    )
    
    # Example: Index in OpenSearch
    # In production, use OpenSearch client
    indexed_count = 0
    failed_count = 0
    
    for doc in embedded_docs:
        try:
            # Mock indexing operation
            logger.debug(f"Indexing chunk: {doc['chunk_id']}")
            indexed_count += 1
        except Exception as e:
            logger.error(f"Failed to index {doc['chunk_id']}: {e}")
            failed_count += 1
    
    logger.info(f"Indexing complete: {indexed_count} successful, {failed_count} failed")
    
    return {
        'indexed': indexed_count,
        'failed': failed_count
    }


def update_metadata(**context):
    """Update document metadata in PostgreSQL."""
    logger.info("Updating metadata...")
    
    # Get ingestion results
    index_result = context['task_instance'].xcom_pull(task_ids='index_documents')
    
    # Example: Update database
    # In production, use database service
    logger.info(f"Metadata updated with results: {index_result}")
    
    return "Metadata updated"


# Define tasks
task_fetch = PythonOperator(
    task_id='fetch_documents',
    python_callable=fetch_documents,
    provide_context=True,
    dag=dag,
)

task_process = PythonOperator(
    task_id='process_documents',
    python_callable=process_documents,
    provide_context=True,
    dag=dag,
)

task_embed = PythonOperator(
    task_id='generate_embeddings',
    python_callable=generate_embeddings,
    provide_context=True,
    dag=dag,
)

task_index = PythonOperator(
    task_id='index_documents',
    python_callable=index_documents,
    provide_context=True,
    dag=dag,
)

task_metadata = PythonOperator(
    task_id='update_metadata',
    python_callable=update_metadata,
    provide_context=True,
    dag=dag,
)

# Set dependencies: fetch -> process -> embed -> index -> metadata
task_fetch >> task_process >> task_embed >> task_index >> task_metadata
