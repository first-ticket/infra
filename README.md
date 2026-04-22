# first-ticket/infra

first-ticket 개발 환경을 위한 인프라 설정 모음입니다.

---

## 📦 구성

| 서비스 | 설명        | 기본 포트 |
|--------|-----------|-----------|
| PostgreSQL | 데이터베이스    | 5432 |
| Redis | 캐시/분산 락   | 6379 |
| Kafka | 메시지 브로커 | 9092 (컨테이너 내부), 29092 (로컬) |
| Kafka UI | Kafka 모니터링 | 8989 |

---

## 🗂️ 폴더 구조

```
infra/
├── .env.example
├── .gitignore
└── docker/
    ├── docker-compose.yml
    └── postgres/
        └── init.sql
```

---

## 🚀 실행 방법

**1. `.env` 파일 생성**

```bash
cp .env.example .env
```

**2. `.env` 값 설정**

```
# 필수
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=

# 선택 (기본값 사용 시 생략 가능)
# POSTGRES_PORT=5432
# REDIS_PORT=6379
# KAFKA_PORT=9092
# KAFKA_UI_PORT=8989
```

**3. 실행**

```bash
docker-compose -f docker/docker-compose.yml --env-file .env up -d
```

> ⚠️ 각 서비스 실행 전 반드시 infra를 먼저 실행해야 합니다.
> `first-ticket-network`가 생성된 후 각 서비스가 해당 네트워크에 참여할 수 있습니다.

**4. 종료**

```bash
docker-compose -f docker/docker-compose.yml --env-file .env down
```

---

## 🗄️ 스키마

PostgreSQL 컨테이너 최초 실행 시 `init.sql`이 자동으로 실행되어 아래 스키마가 생성됩니다.

| 스키마 | 서비스 |
|--------|--------|
| `user_schema` | user-service |
| `program_schema` | program-service |
| `booking_schema` | booking-service |
| `payment_schema` | payment-service |
| `queue_schema` | queue-service |

---

## 🌐 접속 정보

| 서비스 | URL |
|--------|-----|
| PostgreSQL | `localhost:5432` |
| Redis | `localhost:6379` |
| Kafka | `localhost:29092` |
| Kafka UI | `http://localhost:8989` |