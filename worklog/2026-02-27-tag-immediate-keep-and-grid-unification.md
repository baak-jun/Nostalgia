# 태그 후 즉시 보관 + 보관함/보류함/태그검색 이미지 타일 개선

## 변경 파일
- lib/features/home/presentation/home.screen.dart
- lib/features/archive/presentation/archive.screen.dart
- lib/features/review_bin/presentation/review_bin.screen.dart
- lib/features/tags/presentation/tag_search.screen.dart

## 작업 내용
- 태그 붙이기 저장 시 현재 사진을 즉시 보관 처리하도록 변경.
- 보관함 화면을 리스트 타일에서 갤러리형 이미지 그리드 타일로 변경.
- 태그 검색 결과를 텍스트 리스트에서 이미지 카드 그리드로 변경.
- 보류함(검토함)도 체크박스 리스트에서 이미지 카드 그리드로 변경.
- 각 화면에서 빈 상태 메시지는 유지하고, 미태그 필터/통계 카드 기능은 기존 흐름 유지.

## 결정 사항
- 태그 편집은 단순 메타데이터 수정이 아니라 '보관 의사결정'으로 간주해 즉시 보관 처리.
- 시각 일관성을 위해 갤러리/보관함/보류함/태그검색을 동일한 카드형 이미지 레이아웃으로 통일.

## 다음 작업
- TODO 참조
