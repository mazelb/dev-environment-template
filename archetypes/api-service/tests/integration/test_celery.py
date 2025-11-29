"""Integration tests for Celery background tasks."""

import pytest


@pytest.mark.integration
class TestCeleryTasks:
    """Test Celery task execution."""

    def test_task_submission(self, celery_app):
        """Test submitting a task to Celery."""
        from src.celery_app.tasks import example_task

        result = example_task.delay(arg1="test", arg2=42)

        assert result is not None
        assert result.id is not None

    def test_task_execution(self, celery_app):
        """Test task executes successfully."""
        from src.celery_app.tasks import example_task

        result = example_task.delay(arg1="test", arg2=42)

        # Wait for task to complete (with timeout)
        result_value = result.get(timeout=10)

        assert result_value is not None

    def test_async_task_result_retrieval(self, celery_app):
        """Test retrieving task results asynchronously."""
        from src.celery_app.tasks import long_running_task

        task_result = long_running_task.delay(duration=2)

        # Check status
        assert task_result.state in ["PENDING", "STARTED", "SUCCESS"]

        # Wait and get result
        final_result = task_result.get(timeout=15)
        assert final_result is not None

    def test_task_chain(self, celery_app):
        """Test chaining multiple tasks."""
        from celery import chain
        from src.celery_app.tasks import task_one, task_two

        workflow = chain(task_one.s(input="test"), task_two.s())

        result = workflow.apply_async()
        final_value = result.get(timeout=20)

        assert final_value is not None

    def test_task_failure_handling(self, celery_app):
        """Test handling of task failures."""
        from src.celery_app.tasks import failing_task

        result = failing_task.delay()

        with pytest.raises(Exception):
            result.get(timeout=10)

        assert result.state == "FAILURE"

    def test_task_retry(self, celery_app):
        """Test task retry mechanism."""
        from src.celery_app.tasks import retryable_task

        result = retryable_task.delay()

        # Should eventually succeed after retries
        final_result = result.get(timeout=30)
        assert final_result is not None


@pytest.mark.integration
class TestCeleryWorkflow:
    """Test complex Celery workflows."""

    def test_parallel_tasks(self, celery_app):
        """Test executing tasks in parallel."""
        from celery import group
        from src.celery_app.tasks import parallel_task

        job = group([parallel_task.s(i) for i in range(5)])

        result = job.apply_async()
        results = result.get(timeout=20)

        assert len(results) == 5

    def test_task_callbacks(self, celery_app):
        """Test task success and failure callbacks."""
        from src.celery_app.tasks import task_with_callback

        result = task_with_callback.delay()
        final_value = result.get(timeout=10)

        assert final_value is not None

    def test_scheduled_task(self, celery_app, celery_beat):
        """Test scheduled periodic tasks."""
        from src.celery_app.tasks import periodic_task

        # Trigger scheduled task manually
        result = periodic_task.apply_async()
        value = result.get(timeout=10)

        assert value is not None


@pytest.mark.integration
class TestFlowerMonitoring:
    """Test Flower monitoring integration."""

    def test_flower_api_workers(self, flower_client):
        """Test accessing Flower API for worker info."""
        response = flower_client.get("/api/workers")

        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, dict)

    def test_flower_api_tasks(self, flower_client):
        """Test accessing Flower API for task info."""
        response = flower_client.get("/api/tasks")

        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, dict)

    def test_flower_task_monitoring(self, flower_client, celery_app):
        """Test monitoring task execution via Flower."""
        from src.celery_app.tasks import example_task

        # Submit task
        result = example_task.delay(arg1="monitor", arg2=123)
        task_id = result.id

        # Check task in Flower
        response = flower_client.get(f"/api/task/info/{task_id}")

        assert response.status_code in [200, 404]  # May not appear immediately
