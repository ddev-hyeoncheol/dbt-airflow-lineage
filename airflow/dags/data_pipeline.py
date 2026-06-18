from datetime import datetime
from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.standard.operators.python import PythonOperator

# PostgreSQL connection configurations
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

    # Spark Session 빌드 (드라이버는 환경 변수 PYSPARK_SUBMIT_ARGS로 자동 로드됨)
    spark = (
        SparkSession.builder.appName(f"Ingest_{target_table}")
        .master("local[*]")
        .getOrCreate()
    )

    try:
        source_path = f"/opt/airflow/data/{file_name}"
        print(f"Reading source CSV file: {source_path}")

        # CSV 파일 로드
        df = (
            spark.read.option("header", "true")
            .option("inferSchema", "true")
            .csv(source_path)
        )

        df.show(5)
        print(f"Writing to database table: {target_table}")

        # Postgres staging 스키마에 적재 (Overwrite)
        df.write.mode("overwrite").jdbc(
            url=JDBC_URL, table=target_table, properties=DB_PROPERTIES
        )

        print(f"Ingestion completed successfully for {target_table}!")

    finally:
        spark.stop()
        print("Spark session stopped.")


# DAG definition
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

    # dbt DW Model (Table Materialization)
    customer_orders = BashOperator(
        task_id="customer_orders",
        bash_command="dbt run --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --select customer_orders",
    )

    # Task dependencies: Ingestion -> DW Summary
    _ = [
        ingest_customers,
        ingest_orders,
        ingest_order_items,
    ] >> customer_orders
