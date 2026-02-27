# 홈 상단 UI 재배치 (화면 이동 버튼/햄버거 메뉴/정렬 축소)

## 변경 파일
- lib/features/home/presentation/home.screen.dart
- todo/todo.md
- worklog/2026-02-27-home-header-menu-relayout.md

## 작업 내용
- AppBar 우측 아이콘들을 햄버거 메뉴(`PopupMenuButton`)로 통합했다.
- 메뉴 항목 3개를 아래 드롭다운으로 제공하도록 구성했다.
  - 설정
  - 메타 동기화
  - 다시 불러오기
- `화면 이동` 버튼을 AppBar에서 본문 상단(`진행/정렬` 영역)으로 내렸다.
- 정렬 `SegmentedButton`의 텍스트/패딩/탭 타겟을 줄여 공간을 확보했다.

## 결정 사항
- 상단 탐색 동작은 AppBar의 메뉴 버튼 하나로 단순화한다.
- `화면 이동`은 분류 상태 정보와 함께 보이는 위치(본문 상단)로 유지한다.

## 다음 작업
- 태그 AND 검색 쿼리 구현
- 빈 입력/공백 입력 엔터 시 태그 창 닫기 동작 보강
