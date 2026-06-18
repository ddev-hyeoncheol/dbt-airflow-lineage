# MEMORY.md

이 파일은 에이전트가 다음 작업에서도 기억하면 좋은 현재 상태와 임시 합의를 담습니다. 오래가는 규칙은 `.agents/rules/`로 옮깁니다.

## Current Focus

- Airflow 3.x 로컬 구동 환경 구성 완료 (docker-compose-airflow.yml, run.sh 도입)
- 다음 작업 포커스: dbt 설치 및 환경 구성, 이후 OpenLineage 기반 컬럼 리니지 수집 파이프라인 개발

## Temporary Notes

- Airflow는 로컬 편의를 위해 webserver_config.py를 통해 로그인 없이 최고 관리자(Admin) 권한으로 접속하도록 설정됨.
