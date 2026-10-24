# DBP_DOCS

Design documents for project: Oracle Data Modeler files, domain class diagrams, request flow specs, and UI drafts.

## 작업 방법

1. `main`에서 작업 브랜치를 만든다.
2. 작업 후 `main`으로 PR을 올린다.
3. 다른 팀원 1명이 **Approve**하면 머지한다. (댓글만으로는 머지 불가)

## 브랜치 이름 규칙

`종류/작업내용` 형식으로 만든다. 작업내용은 영어 소문자와 `-`로 쓴다.

| 종류 | 용도 | 예시 |
| --- | --- | --- |
| `ui/` | UI 시안 | `ui/login-screen` |
| `diagram/` | 클래스 다이어그램 | `diagram/safezone-chat` |
| `flow/` | 요청처리흐름 | `flow/request-flow` |
| `database/` | Data Modeler | `database/model-v1` |

## 폴더 구조

브랜치 종류와 같은 이름의 폴더에 파일을 저장한다.

```text
docs/
├── ui/          # UI 시안 (PDF, 이미지)
├── diagrams/    # draw.io 클래스 다이어그램
├── flows/       # 요청처리흐름 엑셀
└── database/    # Oracle Data Modeler (.dmd + 같은 이름 폴더)
```

> `database/`의 Data Modeler 파일과 엑셀은 동시에 수정하면 합칠 수 없으니, 한 번에 한 명만 작업한다.

## 편집 규칙

### 공통
- 작업 전에 반드시 `main` 최신 버전을 받는다. (Code → Download ZIP, 또는 GitHub Desktop의 Pull)
- 파일 이름은 바꾸지 않는다. 같은 이름으로 덮어써서 올린다.
- 엑셀(.xlsx), draw.io, Data Modeler 파일은 **두 사람이 동시에 수정하면 합칠 수 없다.**
  작업 시작 전에 단톡방에 "○○ 파일 작업 시작"을 알리고, PR이 머지된 뒤 다음 사람이 받는다.

### Data Modeler (`database/`)
- `campusmarket.dmd`와 `campusmarket/` 폴더는 항상 **같이** 올린다. 둘 중 하나만 있으면 열리지 않는다.
- 열기: SQL Developer → 파일 → Data Modeler → 열기 → `database/campusmarket.dmd`
- 저장: 파일 → Data Modeler → 저장 (일반 "파일 → 저장"이 아님)
- 수정은 **논리 모델(ER)에서** 하고 "관계형 모델로 엔지니어링"으로 반영한다.
  - 엔지니어링 비교 창에서 이미 이름을 바꾼 FK 컬럼(`BUYER_ID`, `SENDER_ID`, `RECORDER_ID` 등)의 이름 항목은 **체크 해제**한다.
- `MEMBER`, `POST`, `TRADE`는 FK 연결용으로 PK만 있는 엔티티다.
  새로 만들지 말고 **같은 엔티티에 속성을 추가**한다.
- 물리 모델은 **Oracle Database 12cR2** (학과 서버 버전)
- DDL은 `database/campusmarket_ddl.ddl`로 덮어써서 저장한다.

### 팀 계정 DB (dbp260102)
- DDL 실행 전 `SELECT table_name FROM user_tables;`로 이미 있는 테이블을 확인한다.
- DDL 생성 시 "DROP 문 포함"은 체크하지 않는다. (다른 팀원 테이블이 지워질 수 있음)
- 스크립트는 **F5(스크립트 실행)**로 실행한다. Ctrl+Enter는 한 문장만 실행된다.
- INSERT 후에는 반드시 `COMMIT`한다.
