# Nostalgia 숨김 메타태그 처리(앱 미표시/미태그 포함)

## 변경 파일
- lib/core/utils/tag_rules.dart
- lib/features/sync/data/metadata_sync_service.dart
- lib/features/archive/presentation/archive.screen.dart
- lib/features/home/presentation/home.screen.dart
- test/features/archive/presentation/archive_screen_test.dart

## 작업 내용
- 메타데이터 동기화 시 `Nostalgia` 마커 태그를 마지막에 자동 추가하도록 변경.
- 앱 내부 표시/판단에서는 `nostalgia`를 숨김 태그로 처리하는 규칙 추가.
- 보관함 `미태그` 필터에서 `nostalgia`만 있는 이미지는 미태그로 간주하도록 변경.
- 홈 화면 태그 병합 시 숨김 태그는 노출되지 않도록 필터링.
- 숨김 마커 태그 단독 케이스에 대한 보관함 필터 테스트 추가.

## 결정 사항
- `Nostalgia`는 메타데이터 추적 마커이며 사용자 태그/필터의 가시 태그로는 취급하지 않음.

## 다음 작업
- TODO 참조
