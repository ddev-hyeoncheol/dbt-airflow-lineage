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
ENV JAVA_HOME=/usr/lib/jvm/default-java

USER airflow
# Install PySpark for local spark processing
RUN pip install --no-cache-dir pyspark
