# 보관함 미태그 사진 모아보기

## 변경 파일
- lib/features/archive/presentation/archive.screen.dart
- test/features/archive/presentation/archive_screen_test.dart

## 작업 내용
- 보관함 화면에 `전체` / `미태그` SegmentedButton 필터를 추가.
- `미태그` 선택 시 태그가 비어 있는 사진만 리스트에 표시.
- 미태그 대상이 없으면 `미태그 사진이 없습니다.` 안내 메시지 표시.
- 필터 동작 확인용 위젯 테스트를 추가.

## 결정 사항
- 별도 화면 추가 대신 보관함 내부 필터 방식으로 분리 조회를 제공.

## 다음 작업
- TODO 참조
