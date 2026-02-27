# 보류함 사진 보관함 이동(복구) 기능 추가

## 변경 파일
- lib/features/review_bin/presentation/review_bin.screen.dart
- lib/features/home/presentation/collection_tabs.screen.dart
- lib/features/home/presentation/home.screen.dart
- todo/todo.md
- worklog/2026-02-27-review-bin-restore-to-archive.md

## 작업 내용
- 보류함 상단 카드 버튼을 `모두 보관`으로 변경했다.
- `모두 보관` 클릭 시 보류함 사진 전체를 보관함으로 이동하는 콜백을 연결했다.
- 홈 상태에서 `deferredIds -> keptIds` 일괄 이동 후 영구 저장되도록 구현했다.

## 결정 사항
- 보류함 일괄 복구는 즉시 반영/저장 방식으로 처리한다.
- 기존의 보류함 사진 탭 동작(태그 수정 + 복구)은 유지한다.

## 다음 작업
- 태그 AND 검색 쿼리 구현
- 빈 입력/공백 입력 엔터 시 태그 창 닫기 동작 보강
