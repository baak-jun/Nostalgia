# 태그 검색 추천칩 토글/강조 개선

## 변경 파일
- lib/features/tags/presentation/tag_search.screen.dart
- todo/todo.md
- worklog/2026-02-27-tag-search-chip-toggle-highlight.md

## 작업 내용
- 추천 태그 칩을 `ActionChip`에서 `FilterChip`으로 변경했다.
- 선택된 태그를 다시 누르면 선택 해제되도록 토글 동작을 추가했다.
- 선택된 칩에 강조 스타일을 적용했다.
  - 선택 색상(`primaryContainer`)
  - 라벨 굵기 증가
  - 강조 테두리 색상
  - 번개 아이콘(`bolt`) 표시

## 결정 사항
- 태그 추천칩은 입력창 문자열을 단일 소스로 사용해 토글 상태를 동기화한다.

## 다음 작업
- 태그 AND 검색 쿼리 구현
- 빈 입력/공백 입력 엔터 시 태그 창 닫기 동작 보강
