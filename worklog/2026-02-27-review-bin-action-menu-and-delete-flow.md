# 보류함 액션 메뉴 및 삭제/보관 흐름 개선

## 변경 파일
- lib/features/review_bin/presentation/review_bin.screen.dart
- lib/features/home/presentation/collection_tabs.screen.dart
- lib/features/home/presentation/home.screen.dart
- lib/features/home/data/home_state_store.dart
- todo/todo.md
- worklog/2026-02-27-review-bin-action-menu-and-delete-flow.md

## 작업 내용
- 보류함 상단에 `Keep`, `Delete` 메뉴 버튼을 추가하고 펼침 메뉴를 구성했다.
- 메뉴 항목을 다음처럼 분리했다.
  - Keep all / Keep selected
  - Delete all / Delete selected
- 선택 모드를 추가해 카드 다중 선택 후 `Keep selected`, `Delete selected` 실행이 가능해졌다.
- 보류함 태그 편집 완료 시(태그가 1개 이상일 때) `이미지를 보관하시겠습니까?` 확인 다이얼로그를 추가했다.
- 삭제 동작은 앱 상태 기준 숨김(`deletedIds`)으로 처리하고 영구 저장하도록 구현했다.
  - 보관함/보류함/전체/다음 분류 목록에서 재노출되지 않음
- `shared_preferences` 저장 구조에 `deletedIds`를 추가했다.

## 결정 사항
- 실제 파일 즉시 삭제 대신 앱 내 삭제 상태를 먼저 저장하는 2단계 흐름을 유지한다.
- 보류함에서 태그 저장 후 자동 보관이 아니라 사용자 확인 후 보관으로 변경한다.

## 다음 작업
- 태그 AND 검색 쿼리 구현
- 빈 입력/공백 입력 엔터 시 태그 창 닫기 동작 보강
