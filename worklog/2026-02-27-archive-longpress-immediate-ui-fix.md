# 보관함 길게누름 즉시 반영 보정

## 변경 파일
- lib/features/archive/presentation/archive.screen.dart
- todo/todo.md
- worklog/2026-02-27-archive-longpress-immediate-ui-fix.md

## 작업 내용
- 보관함에서 길게 누른 사진이 즉시 보류함 이동된 것처럼 보이도록 로컬 숨김 상태를 추가했다.
- `onLongPress` 실행 시:
  - 현재 보관함 리스트에서 해당 카드 즉시 숨김
  - 기존 홈 콜백으로 실제 상태 저장/이동 실행

## 결정 사항
- 컬렉션 탭이 스냅샷 데이터로 열리는 구조를 유지하되, 보관함 화면에서 즉시 UX 반영을 보장한다.

## 다음 작업
- 태그 AND 검색 쿼리 구현
- 빈 입력/공백 입력 엔터 시 태그 창 닫기 동작 보강
