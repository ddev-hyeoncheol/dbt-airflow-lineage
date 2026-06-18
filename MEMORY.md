# MEMORY.md

이 파일은 에이전트가 다음 작업에서도 기억하면 좋은 현재 상태와 임시 합의를 담습니다. 오래가는 규칙은 `.agents/rules/`로 옮깁니다.

## Current Focus

- Airflow 3.x 로컬 구동 환경 구성 완료 (docker-compose-airflow.yml, run.sh 도입)
- Java 17 및 PySpark가 내장된 커스텀 에어플로우 이미지 빌드 환경 구성 완료 (Debian 12 패키지 호환 고려)
- Postgres 단일 인스턴스 내 스키마 분리(staging, dw, dm) 및 가짜 데이터(CSV) 구성 완료
- Spark JDBC 드라이버(42.7.11)의 이미지 빌드 타임 다운로드 내장 및 docker-compose 환경변수(PYSPARK_SUBMIT_ARGS)를 통한 로딩 구성 완료
- 다음 작업 포커스: dbt 프로젝트 초기화(dbt init) 및 PySpark Ingestion DAG 실행 검증 완료 후 dbt 태스크 연동

## Temporary Notes

- Airflow는 로컬 편의를 위해 webserver_config.py를 통해 로그인 없이 최고 관리자(Admin) 권한으로 접속하도록 설정됨.
- 에어플로우는 커스텀 빌드 이미지인 `custom-airflow:latest`를 사용하며, 추가 패키지가 생기면 `Dockerfile`을 수정하고 `./run.sh build`로 재빌드함.
- `docker-compose-airflow.yml` 내의 UID 설정은 `50000:0`을 기본값으로 사용하되 필요시 환경변수 `AIRFLOW_UID`로 제어함.
- Postgres DB는 Named Volume 마운트를 제거하여 완전 휘발성(Transient)으로 구동되며, 기동 시 `postgres/init.sql`이 마운트되어 스키마가 항상 새로 자동 개설됨.
- PySpark의 JDBC 드라이버 로드 시 발생하는 외부 네트워크 지연 및 다운로드 실패 문제를 차단하기 위해, 드라이버 Jar를 Dockerfile 내장 방식으로 이관하고 파이썬 코드 내의 명시적 config 호출을 제거함.
