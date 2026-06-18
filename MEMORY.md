# MEMORY.md

이 파일은 에이전트가 다음 작업에서도 기억하면 좋은 현재 상태와 임시 합의를 담습니다. 오래가는 규칙은 `.agents/rules/`로 옮깁니다.

## Current Focus

- Airflow 3.x 로컬 구동 환경 구성 완료 (docker-compose-airflow.yml, run.sh 도입)
- Java 17 및 PySpark가 내장된 커스텀 에어플로우 이미지 빌드 환경 구성 완료 (Debian 12 패키지 호환 고려)
- 다음 작업 포커스: dbt 설치 및 환경 구성, 이후 OpenLineage 기반 컬럼 리니지 수집 파이프라인 개발

## Temporary Notes

- Airflow는 로컬 편의를 위해 webserver_config.py를 통해 로그인 없이 최고 관리자(Admin) 권한으로 접속하도록 설정됨.
- 에어플로우는 커스텀 빌드 이미지인 `custom-airflow:latest`를 사용하며, 추가 패키지가 생기면 `Dockerfile`을 수정하고 `./run.sh build`로 재빌드함.
- `docker-compose-airflow.yml` 내의 UID 설정은 `50000:0`을 기본값으로 사용하되 필요시 환경변수 `AIRFLOW_UID`로 제어함.
