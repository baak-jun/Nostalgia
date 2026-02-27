# 홈 AppBar 화면 이동 버튼 위치 하향 조정

## 변경 파일
- lib/features/home/presentation/home.screen.dart
- todo/todo.md
- worklog/2026-02-27-home-move-button-offset.md

## 작업 내용
- 홈 AppBar의 `화면 이동` 버튼 패딩을 조정해 버튼을 약간 아래로 내렸다.
- 기존 `vertical: 8` 패딩을 `top: 12, bottom: 4`로 변경해 타이틀(`Nostalgia`) 잘림 체감을 완화했다.

## 결정 사항
- 레이아웃 변경은 버튼 하나의 위치만 최소 수정으로 적용했다.
- 나머지 AppBar 아이콘/동작은 유지한다.

## 다음 작업
- 태그 AND 검색 쿼리 구현
- 빈 입력/공백 입력 엔터 시 태그 창 닫기 동작 보강
