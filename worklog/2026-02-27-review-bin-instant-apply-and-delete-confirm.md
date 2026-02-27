# 보류함 즉시 반영 및 삭제 확인 다이얼로그

## 변경 파일
- lib/features/review_bin/presentation/review_bin.screen.dart
- todo/todo.md
- worklog/2026-02-27-review-bin-instant-apply-and-delete-confirm.md

## 작업 내용
- 보류함에서 `모두 보관` 실행 시 화면에서 즉시 반영되도록 로컬 숨김 상태를 추가했다.
- 보류함에서 `모두 삭제`, `선택 삭제` 실행 전에 `삭제하시겠습니까?` 확인 다이얼로그를 띄우도록 추가했다.
- 확인 후에는 삭제 대상이 즉시 목록에서 사라지도록 반영했다.

## 결정 사항
- 보류함 즉시 반영은 현재 화면 UX를 위한 로컬 상태(`_localHiddenIds`)로 처리한다.
- 실제 상태 저장/삭제 반영은 기존 홈 콜백 로직을 그대로 사용한다.

## 다음 작업
- 태그 AND 검색 쿼리 구현
- 빈 입력/공백 입력 엔터 시 태그 창 닫기 동작 보강
