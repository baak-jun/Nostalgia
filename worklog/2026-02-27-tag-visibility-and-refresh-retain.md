# 태그 가시성 개선 및 새로고침 시 태그 유지

## 변경 파일
- lib/features/home/presentation/home.screen.dart
- lib/features/home/presentation/widgets/swipe_classification_card.dart

## 작업 내용
- 새로고침 시 커스텀 태그를 전부 삭제하던 로직을 제거.
- 새로 로드된 사진 ID에 해당하는 태그만 유지하고, 목록에서 사라진 ID 태그만 정리하도록 변경.
- 스와이프 카드 하단에 현재 사진의 태그 칩을 표시해 태그 반영 여부를 즉시 확인 가능하게 개선.

## 결정 사항
- 태그는 사용자가 새로고침해도 유지되어야 하므로 로딩 시 무조건 초기화하지 않음.
- 현재 분류 화면에서 태그 상태를 직접 확인할 수 있도록 카드에 태그 미리보기 제공.

## 다음 작업
- TODO 참조
