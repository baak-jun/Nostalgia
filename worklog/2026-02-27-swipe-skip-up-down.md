# 위/아래 스와이프로 사진 스킵 기능 추가

## 변경 파일
- lib/features/home/presentation/home.screen.dart
- lib/features/home/presentation/widgets/swipe_classification_card.dart
- test/features/home/presentation/widgets/swipe_classification_card_test.dart

## 작업 내용
- 분류 카드에서 위/아래 스와이프를 감지해 `스킵` 동작을 추가.
- 스킵한 사진은 즉시 다음 사진으로 넘어가되, 완전히 제외하지 않고 목록 뒤로 미뤄 나중에 다시 분류 가능하도록 처리.
- 기존 좌/우 스와이프 동작(좌: 보류함, 우: 보관)은 그대로 유지.
- 화면 안내 문구를 `위/아래: 스킵` 포함하도록 업데이트.
- 위 스와이프 시 스킵 콜백이 호출되는 위젯 테스트 추가.

## 결정 사항
- 스킵은 삭제/보관 상태 변경이 아닌 순서 지연(뒤로 보내기)로 정의.

## 다음 작업
- TODO 참조
