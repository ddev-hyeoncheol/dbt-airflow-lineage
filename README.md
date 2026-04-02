# dbt-airflow-lineage

DBT + Airflow + OpenLineage 기반 컬럼 단위 리니지 샌드박스

## 사전 준비

- Docker, Docker Compose

## 실행

```bash
# 초기화 (최초 1회)
docker compose -f docker-compose.yml -f docker-compose.airflow.yml up airflow-init

# 전체 서비스 기동 (Flower 포함)
docker compose -f docker-compose.yml -f docker-compose.airflow.yml up -d
```

## 종료

```bash
# 서비스 종료 (볼륨 유지)
docker compose -f docker-compose.yml -f docker-compose.airflow.yml down

# 서비스 종료 + 볼륨 삭제 (초기화)
docker compose -f docker-compose.yml -f docker-compose.airflow.yml down -v
```

## 접속 정보

| 서비스 | URL | 계정 |
|--------|-----|------|
| Airflow Web UI | http://localhost:8080 | airflow / airflow |
| Marquez UI | http://localhost:3000 | - |
| Marquez API | http://localhost:9000 | - |
| Flower (Celery 모니터링) | http://localhost:5555 | - |
| PostgreSQL | localhost:5432 | airflow / airflow |
