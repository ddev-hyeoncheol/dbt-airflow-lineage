ARG AIRFLOW_BASE_IMAGE=apache/airflow:3.2.2
FROM ${AIRFLOW_BASE_IMAGE}

USER root
# Install OpenJDK 17 JRE for PySpark runtime compatibility
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       openjdk-17-jre-headless \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a symbolic link to default-java directory to support both amd64 and arm64 architectures
RUN ln -s /usr/lib/jvm/java-17-openjdk-* /usr/lib/jvm/default-java
# Set JAVA_HOME pointing to the default path automatically mapped by the debian package manager
ENV JAVA_HOME=/usr/lib/jvm/default-java

# Download PostgreSQL JDBC driver for Spark Ingestion to avoid real-time network downloads
ADD https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.11/postgresql-42.7.11.jar /opt/airflow/postgresql-42.7.11.jar
RUN chmod 644 /opt/airflow/postgresql-42.7.11.jar

USER airflow
# Install PySpark and dbt-postgres for local spark and transform processing
RUN pip install --no-cache-dir pyspark dbt-postgres
