# first-ticket/infra


first-ticket 개발 환경을 위한 인프라 설정 모음입니다.

---

## 📦 구성

| 서비스 | 설명 | 기본 포트 |
|--------|------|-----------|
| PostgreSQL | 데이터베이스 | 5432 |
| Redis | 캐시/분산 락 | 6379 |
| Kafka | 메시지 브로커 | 9092 (컨테이너 내부), 29092 (로컬) |
| Kafka UI | Kafka 모니터링 | 8989 |
| Keycloak | 인증/인가 서버 (Auth/JWT) | 8180 |

---

## 🗂️ 폴더 구조

```
infra/
├── .env.example
├── .gitignore
└── docker/
    ├── docker-compose.yml
    ├── postgres/
    │   └── init.sql
    └── keycloak/
        └── realm-export.json
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

# Keycloak 필수
KEYCLOAK_ADMIN=
KEYCLOAK_ADMIN_PASSWORD=

# 선택 (기본값 사용 시 생략 가능)
# POSTGRES_PORT=5432
# REDIS_PORT=6379
# KAFKA_PORT=9092
# KAFKA_UI_PORT=8989
# KEYCLOAK_PORT=8180
```

**3. 실행**

```bash
docker-compose -f docker/docker-compose.yml --env-file .env up -d
```

> ⚠️ `--env-file .env` 플래그가 필수입니다. compose 파일이 하위 디렉토리에 있어 자동으로 `.env`를 인식하지 못합니다.
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

## 🔐 Keycloak 설정

### Realm 구성

Keycloak 최초 실행 시 `realm-export.json`이 자동으로 import됩니다.

| 항목 | 값 |
|------|----|
| Realm | `first-ticket` |
| Access Token 유효기간 | 15분 |
| Clients | `gateway-client`, `user-client` |
| Roles | `CUSTOMER`, `HOST`, `ADMIN` |

> ⚠️ **보안상 테스트 유저는 export에 포함되지 않습니다.** 아래 가이드에 따라 수동으로 생성하세요.

### 테스트 유저 생성

1. 도커로 서버 실행 후 `http://localhost:8180` 접속 → Admin Console 로그인
2. `first-ticket` Realm 선택
3. **Users → Create new user**

| Username | Email | Role |
|----------|-------|------|
| testadmin001 | testadmin001@test.com | ADMIN |
| testcustomer001 | testcustomer001@test.com | CUSTOMER |
| testhost001 | testhost001@test.com | HOST |

4. 각 유저 생성 후 **Credentials 탭 → Set password** (Temporary: OFF)
5. **Role mapping 탭 → Assign role** → `first-ticket` Realm의 해당 Role 부여
6. **Details 탭 → Email verified: ON**

> 💡 테스트 유저는 `keycloak-data` 볼륨에 저장됩니다. `docker-compose down`해도 유지됩니다.
> `realm-export.json`이 변경된 경우 볼륨을 초기화하세요: `docker-compose -f docker/docker-compose.yml down -v`

### 토큰 발급 테스트 (Postman)

```http
POST http://localhost:8180/realms/first-ticket/protocol/openid-connect/token
Content-Type: application/x-www-form-urlencoded

grant_type=password
client_id=user-client
client_secret={user-client Secret 확인 필요 — Clients → user-client → Credentials 탭}
username=testcustomer001
password={설정한 비밀번호}
```

응답의 `expires_in: 900` (15분) 확인.

---

## 🌐 접속 정보

| 서비스             | URL                     |
|-----------------|-------------------------|
| PostgreSQL      | `localhost:5432`        |
| Redis           | `localhost:6379`        |
| Kafka           | `localhost:29092`       |
| Kafka UI        | `http://localhost:8989` |
| Keycloak | `http://localhost:8180` |

---

### 최종 수정 : 20260422
### 최종 수정자 : 박동진

수정 이력
- 20260422 : 최초 작성 (PostgreSQL / Redis / Kafka / Kafka UI)
- 20260422 : Keycloak 설정 추가