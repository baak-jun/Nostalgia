# 태그 엔터 추가 후 텍스트필드 포커스 유지

## 변경 파일
- lib/features/tags/presentation/widgets/tag_editor_dialog.dart
- test/features/tags/presentation/widgets/tag_editor_dialog_test.dart

## 작업 내용
- TagEditorDialog에 FocusNode를 추가.
- 엔터(onSubmitted)로 태그를 추가한 뒤 `requestFocus`를 호출해 텍스트필드 포커스를 유지.
- 포커스 유지 동작 검증 테스트 케이스를 추가했지만, 요청에 따라 테스트 실행은 생략.

## 결정 사항
- 입력 반복 UX를 위해 태그 추가 직후 키보드/입력 포커스 유지.

## 다음 작업
- TODO 참조
