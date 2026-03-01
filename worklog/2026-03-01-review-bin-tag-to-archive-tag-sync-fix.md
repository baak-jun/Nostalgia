# 보류함 태그 후 보관 이동 시 태그 동기화 수정

## 변경 파일
- lib/features/home/presentation/home.screen.dart
- lib/features/home/presentation/collection_tabs.screen.dart
- lib/features/review_bin/presentation/review_bin.screen.dart
- test/features/home/presentation/collection_tabs_screen_test.dart
- todo/todo.md
- worklog/2026-03-01-review-bin-tag-to-archive-tag-sync-fix.md

## 작업 내용
- 보류함 사진 탭 콜백의 반환 타입을 `bool`에서 `PhotoItem?`로 변경해, 태그 편집 결과가 포함된 최신 객체를 탭 화면으로 전달하도록 수정.
- `HomeScreen`에 보류함 전용 태그 편집 래퍼를 추가해, 보관 이동이 확정된 경우 최신 태그/상태가 반영된 `PhotoItem`을 반환하도록 구현.
- `CollectionTabsScreen`에서 보류함 -> 보관함 이동 시 기존 item이 아닌 콜백이 반환한 최신 item으로 로컬 목록을 갱신하도록 수정.
- `ReviewBinScreen`도 동일 시그니처를 사용하도록 반영.
- 위젯 테스트를 업데이트해 "보류함에서 태그 저장 후 보관함 카드에 새 태그가 보이는지"를 검증하도록 보강.

## 결정 사항
- 원인은 탭 로컬 상태 업데이트 시 편집 전 `item`으로 이동 처리를 해 최신 태그가 유실되는 구조로 판단.
- 해결 방식은 부모 상태를 강제 재주입하는 대신, 콜백에서 최신 `PhotoItem`을 반환해 현재 탭 상태를 즉시 동기화하는 것으로 결정.

## 다음 작업
- TODO 참고
