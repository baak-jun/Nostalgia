# 보류함 태그 후 보관 이동 즉시 반영 버그 수정

## 변경 파일
- lib/features/home/presentation/home.screen.dart
- lib/features/home/presentation/collection_tabs.screen.dart
- lib/features/review_bin/presentation/review_bin.screen.dart
- todo/todo.md
- worklog/2026-02-27-review-bin-tag-to-archive-fix.md

## 작업 내용
- 태그 편집 함수 `_editTagsForPhoto` 반환형을 `Future<bool>`로 변경했다.
  - `true`: 태그 저장 후 보관함 이동이 실제로 발생
  - `false`: 이동 없음(취소/아니오/유지)
- 보류함 탭 콜백 타입을 `Future<bool> Function(PhotoItem)`로 변경해 결과를 전달받도록 수정했다.
- 보류함 카드 탭 후 `true`가 반환되면 해당 카드를 로컬 숨김 처리해 즉시 화면에서 제거되도록 수정했다.

## 결정 사항
- 보류함 태그 편집 후 UI 갱신 여부는 "실제 보관 이동 여부"를 기준으로 처리한다.
- 단순 태그 수정만 한 경우에는 보류함에 그대로 남긴다.

## 다음 작업
- 태그 AND 검색 쿼리 구현
- 빈 입력/공백 입력 엔터 시 태그 창 닫기 동작 보강
