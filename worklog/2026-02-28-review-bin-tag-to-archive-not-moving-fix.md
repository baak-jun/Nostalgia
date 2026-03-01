# 보류함 태그 후 보관 이동 미반영 버그 수정

## 변경 파일
- lib/features/home/presentation/collection_tabs.screen.dart
- test/features/home/presentation/collection_tabs_screen_test.dart
- todo/todo.md
- worklog/2026-02-28-review-bin-tag-to-archive-not-moving-fix.md

## 작업 내용
- `CollectionTabsScreen`를 Stateless에서 Stateful로 변경해 탭 내부에서 로컬 컬렉션 상태를 관리하도록 수정.
- 보류함 사진 탭 시 상위 콜백 결과가 `true`(보관 이동)일 때, 로컬 상태에서 보류함 목록 제거 + 보관함 목록 추가 + 전체 목록 `inReviewBin` 갱신 처리.
- 보관함 길게누름 이동/보류함 전체/선택 보관·삭제 동작도 탭 내부 상태에 즉시 반영되도록 동기화 로직 추가.
- 회귀 방지를 위해 "보류함 사진 탭 후 보관함 탭에서 즉시 보이는지"를 검증하는 위젯 테스트 추가.

## 결정 사항
- 원인은 화면 이동 탭이 진입 시점 리스트 스냅샷을 그대로 사용해, 상위 상태 변경이 동일 라우트의 다른 탭에 즉시 반영되지 않는 구조로 판단.
- 따라서 child 화면의 임시 hide 처리에 의존하지 않고, 컬렉션 탭 레벨에서 상태를 직접 갱신하는 방식으로 일관되게 처리.

## 다음 작업
- TODO 참고
