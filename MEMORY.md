# MEMORY.md

이 파일은 에이전트가 다음 작업에서도 기억하면 좋은 현재 상태와 임시 합의를 담습니다. 오래가는 규칙은 `.agents/rules/`로 옮깁니다.

## Current Focus

- Airflow 3.x 로컬 구동 환경 구성 완료 (docker-compose-airflow.yml, run.sh 도입)
- Java 17 및 PySpark가 내장된 커스텀 에어플로우 이미지 빌드 환경 구성 완료 (Debian 12 패키지 호환 고려)
- Postgres 단일 인스턴스 내 스키마 분리(staging, dw, dm) 및 가짜 데이터(CSV) 구성 완료
- Spark JDBC 드라이버(42.7.11)의 이미지 빌드 타임 다운로드 내장 및 docker-compose 환경변수(PYSPARK_SUBMIT_ARGS)를 통한 로딩 구성 완료
- dbt 프로젝트 생성 및 `staging -> dw -> dm` 순차 변환 흐름 구성 완료
- Marquez 연동 복구 완료: 사용자의 `docker-compose-marquez.yml` 사양을 원본 그대로 보존한 상태로 Airflow/Spark OpenLineage 설정 및 run.sh 타겟 구동 로직 복원 완료

## Temporary Notes

- Airflow는 로컬 편의를 위해 webserver_config.py를 통해 로그인 없이 최고 관리자(Admin) 권한으로 접속하도록 설정됨.
- 에어플로우는 커스텀 빌드 이미지인 `custom-airflow:latest`를 사용하며, 추가 패키지가 생기면 `Dockerfile`을 수정하고 `./run.sh build`로 재빌드함.
- `docker-compose-airflow.yml` 내의 UID 설정은 `50000:0`을 기본값으로 사용하되 필요시 환경변수 `AIRFLOW_UID`로 제어함.
- Postgres DB는 Named Volume 마운트를 제거하여 완전 휘발성(Transient)으로 구동되며, 기동 시 `postgres/init.sql`이 마운트되어 스키마가 항상 새로 자동 개설됨.
- PySpark의 JDBC 드라이버 로드 시 발생하는 외부 네트워크 지연 및 다운로드 실패 문제를 차단하기 위해, 드라이버 Jar를 Dockerfile 내장 방식으로 이관하고 파이썬 코드 내의 명시적 config 호출을 제거함.
- `data_pipeline` DAG의 의존성을 `[ingest_customers, ingest_orders, ingest_order_items] >> customer_orders >> daily_sales_summary` 로 일자형 연계하여 `staging -> dw -> dm`의 정방향 계보 수집이 보장되도록 설정함.
- 기존 `product_sales_summary.sql` 모델은 dbt 프로젝트 내에 보존되어 있으나, Airflow `data_pipeline` 에서는 `daily_sales_summary`로 완전히 대체되어 제외됨.
