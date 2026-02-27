# 초기 진입 스와이프 허브 + 화면 이동 + 태그 붙이기 구현

## 변경 파일
- lib/features/home/presentation/home.screen.dart
- lib/features/home/presentation/collection_tabs.screen.dart
- lib/features/home/presentation/widgets/swipe_classification_card.dart
- lib/features/archive/presentation/archive.screen.dart
- lib/features/gallery/domain/photo_item.dart
- test/features/home/presentation/collection_tabs_screen_test.dart

## 작업 내용
- 초기 진입 화면에서 Reigns 스타일 좌우 스와이프 분류를 유지하고, 좌 스와이프는 보류함/우 스와이프는 보관으로 동작하도록 정리.
- 초기 화면에 `화면 이동` 버튼을 추가해 갤러리/보관함/보류함/태그 탭 화면으로 이동할 수 있도록 구현.
- 초기 화면에 `태그 붙이기` 버튼을 추가해 현재 카드에 태그를 즉시 추가할 수 있도록 구현.
- 태그는 소문자 정규화 후 저장되며, 중복 태그는 Set 기반으로 방지.
- 보관함 전용 화면(ArchiveScreen) 추가 및 분류 결과가 탭 화면에 반영되도록 연결.
- PhotoItem copyWith 추가로 상태 반영 데이터를 안전하게 생성.
- 컬렉션 탭 화면 관련 위젯 테스트 추가.

## 결정 사항
- 초기 진입 UX를 단일 허브(HomeScreen)로 통합하고, 세부 화면은 탭 화면(CollectionTabsScreen)으로 분리.
- 실제 삭제 동작은 구현하지 않고, 보류함 상태 반영까지만 처리해 2단계 삭제 원칙과 충돌하지 않도록 유지.

## 다음 작업
- TODO 참조
