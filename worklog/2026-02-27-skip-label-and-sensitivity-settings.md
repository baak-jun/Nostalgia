# 스킵 라벨 위/아래 배치 + 스와이프 감도 조절 추가

## 변경 파일
- lib/features/home/presentation/widgets/swipe_classification_card.dart
- lib/features/home/presentation/home.screen.dart
- lib/features/settings/domain/app_settings.dart
- lib/features/settings/presentation/settings.screen.dart
- test/features/home/presentation/widgets/swipe_classification_card_test.dart

## 작업 내용
- 스킵 안내를 카드 배경 중앙 고정에서 상단(`위로 스킵`) / 하단(`아래로 스킵`) 분리 표시로 변경.
- 수직 드래그 양에 따라 위/아래 스킵 안내가 점진적으로 보이도록 opacity 기반 피드백 적용.
- 설정에 스와이프 감도(쉬움/보통/정밀) 옵션 추가.
- 감도 설정값을 카드 스와이프 판정 임계값(거리/플링 속도)에 연동.
- 설정 구조를 `AppSettings` 모델로 정리해 색약 모드 + 감도 값을 함께 저장/전달.

## 결정 사항
- 감도는 거리 임계값과 플링 속도 임계값을 동시에 조정하는 방식으로 구현.
- 스킵 시각 피드백은 위/아래 방향 힌트를 명확히 주는 방향으로 배치 변경.

## 다음 작업
- TODO 참조
