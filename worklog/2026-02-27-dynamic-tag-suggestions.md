# 태그 화면 추천칩을 실제 사용자 태그 기반으로 표시

## 변경 파일
- lib/features/tags/presentation/tag_search.screen.dart
- test/features/tags/presentation/tag_search_screen_test.dart

## 작업 내용
- 태그 검색 화면의 추천칩을 하드코딩 목록에서 실제 사진 태그 집계 기반으로 변경.
- 추천칩은 사용 빈도 순(동률 시 사전순)으로 최대 12개 표시.
- 숨김 메타태그(`nostalgia`)는 추천칩 계산에서 제외.
- 추천칩 클릭 시 검색어에 자동 반영되도록 연결.

## 결정 사항
- 추천칩은 현재 데이터에 존재하는 태그만 보여주고, 임의 샘플 태그는 제거.

## 다음 작업
- TODO 참조
