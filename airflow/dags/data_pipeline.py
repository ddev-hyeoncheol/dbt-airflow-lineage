from datetime import datetime
from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.standard.operators.python import PythonOperator

# PostgreSQL Connection Settings
JDBC_URL = "jdbc:postgresql://postgres:5432/airflow"
DB_PROPERTIES = {
    "user": "airflow",
    "password": "airflow",
    "driver": "org.postgresql.Driver",
}


def run_pyspark_ingestion(file_name: str, target_table: str):
    """
    Spark Session을 열어 CSV 파일을 읽고 Postgres staging 스키마에 적재하는 함수
    """
    from pyspark.sql import SparkSession

    print(f"Starting Spark session to ingest {file_name} into {target_table}...")

    # Build Spark Session (JDBC driver loaded via PYSPARK_SUBMIT_ARGS)
    spark = (
        SparkSession.builder.appName(f"Ingest_{target_table}")
        .config(
            "spark.extraListeners",
            "io.openlineage.spark.agent.OpenLineageSparkListener",
        )
        .config("spark.openlineage.transport.type", "http")
        .config("spark.openlineage.transport.url", "http://marquez:5000")
        .config("spark.openlineage.namespace", "spark-ingest")
        .master("local[*]")
        .getOrCreate()
    )

    try:
        source_path = f"/opt/airflow/data/{file_name}"
        print(f"Reading source CSV file: {source_path}")

        # Load CSV source
        df = (
            spark.read.option("header", "true")
            .option("inferSchema", "true")
            .csv(source_path)
        )

        df.show(5)
        print(f"Writing to database table: {target_table}")

        # Write to Postgres staging tables (Overwrite)
        df.write.mode("overwrite").jdbc(
            url=JDBC_URL, table=target_table, properties=DB_PROPERTIES
        )

        print(f"Ingestion completed successfully for {target_table}!")

    finally:
        spark.stop()
        print("Spark session stopped.")


# DAG Definition
with DAG(
    dag_id="data_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    tags=["pyspark", "dbt", "poc"],
) as dag:

    # PySpark Ingestion Tasks
    ingest_customers = PythonOperator(
        task_id="ingest_customers",
        python_callable=run_pyspark_ingestion,
        op_kwargs={"file_name": "customers.csv", "target_table": "staging.customers"},
    )

    ingest_orders = PythonOperator(
        task_id="ingest_orders",
        python_callable=run_pyspark_ingestion,
        op_kwargs={"file_name": "orders.csv", "target_table": "staging.orders"},
    )

    ingest_order_items = PythonOperator(
        task_id="ingest_order_items",
        python_callable=run_pyspark_ingestion,
        op_kwargs={
            "file_name": "order_items.csv",
            "target_table": "staging.order_items",
        },
    )

    # Run dbt DW models
    customer_orders = BashOperator(
        task_id="customer_orders",
        bash_command="dbt-ol run --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --select customer_orders",
    )

    # Run dbt DM models
    daily_sales_summary = BashOperator(
        task_id="daily_sales_summary",
        bash_command="dbt-ol run --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --select daily_sales_summary",
    )

    # Define pipeline dependencies (Ingest -> DW -> DM)
    _ = (
        [ingest_customers, ingest_orders, ingest_order_items]
        >> customer_orders
        >> daily_sales_summary
    )
