import sys, os
sys.path.append("/opt/airflow/backend")
sys.path.append("/opt/airflow/analytics")

from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime


## this is the whole DAG > one task that calls extract() > defined in analytics\extract_to_duckdb.py,
# the function that pulls all transactions from Postgres and loads them into the DuckDB file,
# exactly what run_extraction() in the DAG calls.

# scheduled to run once a day.

def run_extraction():
    from extract_to_duckdb import extract
    extract()

with DAG(
        dag_id="finance_analytics_daily",
        start_date=datetime(2026, 1, 1),
        schedule_interval="@daily",
        catchup=False,
) as dag:

    extract_task = PythonOperator(
        task_id="extract_transactions_to_duckdb",
        python_callable=run_extraction,
    )

