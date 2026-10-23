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
| `db/` | Data Modeler | `db/model-v1` |

## 폴더 구조

브랜치 종류와 같은 이름의 폴더에 파일을 저장한다.

```text
docs/
├── ui/          # UI 시안 (PDF, 이미지)
├── diagrams/    # draw.io 클래스 다이어그램
├── flows/       # 요청처리흐름 엑셀
└── db/          # Oracle Data Modeler (.dmd + 같은 이름 폴더)
```

> `db/`의 Data Modeler 파일과 엑셀은 동시에 수정하면 합칠 수 없으니, 한 번에 한 명만 작업한다.
