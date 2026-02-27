# 태그 다이얼로그 엔터 적용 + 적용 태그 X 삭제 기능

## 변경 파일
- lib/features/home/presentation/home.screen.dart
- lib/features/tags/presentation/widgets/tag_editor_dialog.dart
- test/features/tags/presentation/widgets/tag_editor_dialog_test.dart

## 작업 내용
- 태그 붙이기 다이얼로그를 분리해 `TagEditorDialog`로 구현.
- 텍스트 입력 후 엔터를 누르면 태그가 즉시 추가되도록 `onSubmitted` 처리.
- 추가된 태그를 Chip으로 표시하고, 각 태그의 `x`(삭제 아이콘)로 즉시 제거 가능하게 구현.
- 홈 화면 태그 저장 구조를 사진별 커스텀 태그 세트로 변경해 추가/삭제 결과가 실제 화면에 반영되도록 수정.
- 태그는 소문자 정규화 및 공백 제거를 유지.

## 결정 사항
- 태그 편집 책임을 HomeScreen에서 분리해 재사용 가능한 다이얼로그 위젯으로 구성.
- 태그 수정은 단순 append 방식이 아닌 사진별 전체 태그 set 저장 방식으로 변경.

## 다음 작업
- TODO 참조
