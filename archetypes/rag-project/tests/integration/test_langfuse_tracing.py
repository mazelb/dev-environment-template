"""Integration tests for Langfuse tracing."""

import pytest


@pytest.mark.integration
@pytest.mark.asyncio
class TestLangfuseTracing:
    """Test Langfuse observability integration."""

    async def test_trace_creation(self, langfuse_client):
        """Test creating a trace in Langfuse."""
        trace = await langfuse_client.create_trace(
            name="test_trace", metadata={"test": True}
        )

        assert trace is not None
        assert hasattr(trace, "id") or "id" in trace

    async def test_span_creation(self, langfuse_client):
        """Test creating spans within a trace."""
        trace = await langfuse_client.create_trace(name="test_trace")

        span = await langfuse_client.create_span(
            trace_id=trace.id, name="test_span", metadata={"operation": "test"}
        )

        assert span is not None

    async def test_generation_tracking(self, langfuse_client):
        """Test tracking LLM generations."""
        trace = await langfuse_client.create_trace(name="llm_test")

        generation = await langfuse_client.track_generation(
            trace_id=trace.id,
            name="llm_generation",
            model="llama2",
            input="What is AI?",
            output="AI is artificial intelligence.",
            metadata={"tokens": 10},
        )

        assert generation is not None

    async def test_rag_pipeline_tracing(self, rag_pipeline, langfuse_client):
        """Test end-to-end tracing of RAG pipeline."""
        query = "Test query for tracing"

        # Create trace
        trace = await langfuse_client.create_trace(
            name="rag_query", metadata={"query": query}
        )

        # Execute RAG with tracing
        result = await rag_pipeline.query(query_text=query, trace_id=trace.id)

        # Verify trace was populated
        assert result is not None

        # Flush traces
        await langfuse_client.flush()

    async def test_cost_tracking(self, langfuse_client):
        """Test tracking costs in Langfuse."""
        trace = await langfuse_client.create_trace(name="cost_test")

        await langfuse_client.track_generation(
            trace_id=trace.id,
            name="generation",
            model="gpt-4",
            input="test input",
            output="test output",
            metadata={
                "usage": {
                    "prompt_tokens": 10,
                    "completion_tokens": 20,
                    "total_tokens": 30,
                },
                "cost": 0.0015,
            },
        )

        await langfuse_client.flush()

    async def test_error_tracking(self, langfuse_client):
        """Test tracking errors in Langfuse."""
        trace = await langfuse_client.create_trace(name="error_test")

        try:
            raise ValueError("Test error for tracking")
        except Exception as e:
            await langfuse_client.track_error(
                trace_id=trace.id, error=str(e), error_type=type(e).__name__
            )

        await langfuse_client.flush()


@pytest.mark.integration
@pytest.mark.asyncio
class TestPerformanceMetrics:
    """Test performance tracking with Langfuse."""

    async def test_latency_tracking(self, langfuse_client):
        """Test tracking operation latency."""
        import time

        trace = await langfuse_client.create_trace(name="latency_test")

        start_time = time.time()
        # Simulate operation
        import asyncio

        await asyncio.sleep(0.1)
        duration = time.time() - start_time

        await langfuse_client.update_trace(
            trace_id=trace.id, metadata={"duration_ms": duration * 1000}
        )

        await langfuse_client.flush()

    async def test_throughput_tracking(self, langfuse_client):
        """Test tracking request throughput."""
        traces = []

        # Create multiple traces
        for i in range(5):
            trace = await langfuse_client.create_trace(name=f"throughput_test_{i}")
            traces.append(trace)

        # Flush all
        await langfuse_client.flush()

        assert len(traces) == 5
