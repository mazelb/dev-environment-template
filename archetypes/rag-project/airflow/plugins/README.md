# Airflow Plugins Directory

This directory is for custom Airflow operators, sensors, and hooks.

## Structure

```
plugins/
├── operators/    # Custom operators
├── sensors/      # Custom sensors
└── hooks/        # Custom hooks
```

## Creating Custom Operators

Example custom operator:

```python
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults

class CustomOperator(BaseOperator):
    @apply_defaults
    def __init__(self, param1, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.param1 = param1
    
    def execute(self, context):
        self.log.info(f"Executing with param: {self.param1}")
        # Your logic here
        return "Success"
```

## Using Custom Plugins in DAGs

```python
from plugins.operators.custom_operator import CustomOperator

task = CustomOperator(
    task_id='custom_task',
    param1='value',
    dag=dag
)
```

## References

- [Airflow Plugins](https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/plugins.html)
- [Custom Operators](https://airflow.apache.org/docs/apache-airflow/stable/howto/custom-operator.html)
