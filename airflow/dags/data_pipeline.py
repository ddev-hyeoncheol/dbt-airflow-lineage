from datetime import datetime
from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.standard.operators.python import PythonOperator

# PostgreSQL Connection Settings
JDBC_URL = "jdbc:postgresql://postgres:5432/airflow"
DB_PROPERTIES = {"user": "airflow", "password": "airflow", "driver": "org.postgresql.Driver"}


def run_pyspark_ingestion(file_name: str, target_table: str):
    from pyspark.sql import SparkSession

    spark = (
        SparkSession.builder.appName(f"Ingest_{target_table}")
        .config("spark.extraListeners", "io.openlineage.spark.agent.OpenLineageSparkListener")
        .config("spark.openlineage.transport.type", "http")
        .config("spark.openlineage.transport.url", "http://marquez:5000")
        .config("spark.openlineage.namespace", "spark-ingest")
        .master("local[*]")
        .getOrCreate()
    )

    try:
        source_path = f"/opt/airflow/data/{file_name}"

        df = spark.read.option("header", "true").option("inferSchema", "true").csv(source_path)
        df.show(5)
        df.write.mode("overwrite").jdbc(url=JDBC_URL, table=target_table, properties=DB_PROPERTIES)
    finally:
        spark.stop()


with DAG(
    dag_id="data_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    tags=["pyspark", "dbt", "openlineage", "marquez"],
) as dag:

    staging_customers = PythonOperator(
        task_id="staging_customers",
        python_callable=run_pyspark_ingestion,
        op_kwargs={"file_name": "customers.csv", "target_table": "staging.customers"},
    )

    staging_orders = PythonOperator(
        task_id="staging_orders",
        python_callable=run_pyspark_ingestion,
        op_kwargs={"file_name": "orders.csv", "target_table": "staging.orders"},
    )

    staging_order_items = PythonOperator(
        task_id="staging_order_items",
        python_callable=run_pyspark_ingestion,
        op_kwargs={"file_name": "order_items.csv", "target_table": "staging.order_items"},
    )

    dw_customer_orders = BashOperator(
        task_id="dw_customer_orders",
        bash_command="""
            dbt docs generate --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --target-path target/dw/customer_orders &&
            dbt-ol run --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --select customer_orders --target-path target/dw/customer_orders
        """,
    )

    dm_daily_sales_summary = BashOperator(
        task_id="dm_daily_sales_summary",
        bash_command="""
            dbt docs generate --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --target-path target/dm/daily_sales_summary &&
            dbt-ol run --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --select daily_sales_summary --target-path target/dm/daily_sales_summary
        """,
    )

    dm_customer_rfm_analysis = BashOperator(
        task_id="dm_customer_rfm_analysis",
        bash_command="""
            dbt docs generate --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --target-path target/dm/customer_rfm_analysis &&
            dbt-ol run --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --select customer_rfm_analysis --target-path target/dm/customer_rfm_analysis
        """,
    )

    _ = (
        [staging_customers, staging_orders, staging_order_items]
        >> dw_customer_orders
        >> [dm_daily_sales_summary, dm_customer_rfm_analysis]
    )
