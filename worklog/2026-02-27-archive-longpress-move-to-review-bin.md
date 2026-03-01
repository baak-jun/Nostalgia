# 보관함 길게 눌러 보류함 이동

## 변경 파일
- lib/features/gallery/presentation/widgets/photo_card.dart
- lib/features/archive/presentation/archive.screen.dart
- lib/features/home/presentation/collection_tabs.screen.dart
- lib/features/home/presentation/home.screen.dart
- todo/todo.md
- worklog/2026-02-27-archive-longpress-move-to-review-bin.md

## 작업 내용
- `PhotoCard`에 `onLongPress` 콜백을 추가했다.
- 보관함 화면에서 카드 길게 누름 이벤트를 받을 수 있도록 연결했다.
- 홈 상태에 `보관함 -> 보류함` 이동 로직을 추가했다.
  - 길게 누른 사진의 `keptIds`에서 제거
  - `deferredIds`에 추가
  - 상태 영구 저장

## 결정 사항
- 보관함에서 길게 누르면 즉시 보류함으로 이동하는 단일 동작으로 처리한다.
- 기존 탭 동작(태그 수정)은 그대로 유지한다.

## 다음 작업
- 태그 AND 검색 쿼리 구현
- 빈 입력/공백 입력 엔터 시 태그 창 닫기 동작 보강
