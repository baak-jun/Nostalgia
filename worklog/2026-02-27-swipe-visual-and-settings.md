# 스와이프 시각 피드백 개선 + 설정 페이지/색약 모드 추가

## 변경 파일
- lib/features/home/presentation/home.screen.dart
- lib/features/home/presentation/widgets/swipe_classification_card.dart
- lib/features/settings/presentation/settings.screen.dart
- test/features/home/presentation/widgets/swipe_classification_card_test.dart

## 작업 내용
- 분류 카드 스와이프를 Dismissible 중심 구조에서 pan 기반 드래그 구조로 변경.
- 좌/우뿐 아니라 위/아래 드래그 시에도 카드가 실제로 따라 움직이도록 시각 피드백 추가.
- 좌/우 분류 색상 직관화: 보관은 초록, 보류함은 붉은색으로 표시.
- 설정 페이지를 추가하고 색약 모드 토글을 제공.
- 색약 모드 ON 시 보관/보류 색상을 색약 친화 조합(청색/갈색 계열)으로 변경.
- 홈 상단에 설정 버튼을 추가해 설정 페이지로 진입 가능하게 연결.

## 결정 사항
- 스킵(위/아래)은 기존 정책대로 상태 변경이 아닌 순서 지연으로 유지.
- 색약 모드는 현재 분류 카드 색상에 우선 반영하고, 추후 전체 화면으로 확장 가능하도록 분리.

## 다음 작업
- TODO 참조
