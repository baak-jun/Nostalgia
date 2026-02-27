# 기본 브랜치 master -> main 전환

## 변경 파일
- todo/todo.md
- worklog/2026-02-27-rename-default-branch-to-main.md

## 작업 내용
- 로컬 브랜치를 `master`에서 `main`으로 변경했다.
- `main`을 원격에 푸시하고 upstream 추적을 설정했다.
- GitHub 저장소 기본 브랜치를 `main`으로 변경했다.
- 기존 원격 `master` 브랜치를 삭제했다.

## 결정 사항
- 저장소 기본 브랜치는 `main`을 사용한다.
- 이후 작업/PR 기준 브랜치는 `main`으로 통일한다.

## 다음 작업
- 태그 AND 검색 쿼리 구현
- 빈 입력/공백 입력 엔터 시 태그 창 닫기 동작 검증
