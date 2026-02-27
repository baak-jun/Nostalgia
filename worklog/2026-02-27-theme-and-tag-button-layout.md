# 초기 화면 태그 버튼 하단 배치 + 빛 바랜 회색 톤 테마 적용

## 변경 파일
- lib/features/home/presentation/home.screen.dart
- lib/features/home/presentation/widgets/swipe_classification_card.dart
- lib/app/nostalgia_app.dart

## 작업 내용
- 초기 진입 화면의 `태그 붙이기` 버튼을 상단 버튼 행에서 하단(스와이프 안내 문구 아래)으로 이동.
- 상단에는 `화면 이동` 버튼 중심으로 남기고, 카드 중심 UX를 유지하도록 배치 조정.
- 앱 테마를 기존 초록 계열에서 빛 바랜 사진 느낌의 웜 그레이/베이지 톤으로 변경.
- AppBar, 배경, Card 색감을 함께 조정해 전체 화면이 동일한 톤으로 보이도록 정리.
- 스와이프 배경 색상도 강한 초록/주황에서 뮤트된 회색/갈색 계열로 변경.

## 결정 사항
- Nostalgia 콘셉트에 맞춰 고채도 강조색 대신 저채도 톤을 기본 테마로 사용.
- 태그 액션은 분류 카드의 보조 동작으로 보고 하단 고정 액션으로 배치.

## 다음 작업
- TODO 참조
