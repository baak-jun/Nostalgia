# 화면 이동의 전체 사진을 경로(폴더) 기준 통계/진행도로 표시

## 변경 파일
- lib/features/gallery/domain/photo_item.dart
- lib/features/gallery/data/device_photo_loader.dart
- lib/features/gallery/presentation/folder_overview.screen.dart
- lib/features/home/presentation/collection_tabs.screen.dart
- lib/features/archive/presentation/archive.screen.dart
- test/features/home/presentation/collection_tabs_screen_test.dart
- test/features/gallery/presentation/folder_overview_screen_test.dart

## 작업 내용
- PhotoItem에 `sourcePath` 필드를 추가하고, 로더에서 Android 경로(relativePath) 기반으로 채우도록 구현.
- `화면 이동` 첫 탭을 기존 전체 갤러리에서 `폴더` 요약 화면으로 교체.
- 폴더 카드에 `폴더명 / 총 개수 / 미태그 개수 / 진행도(LinearProgressIndicator)` 표시.
- 폴더 카드를 누르면 해당 폴더 사진만 그리드로 확인 가능.
- 숨김 메타태그(`nostalgia`)는 미태그 판단 시 태그 없는 것으로 간주하도록 유지.
- 탭 라벨 테스트 및 폴더 통계 UI 테스트 추가.

## 결정 사항
- 경로 기반 표시를 위해 소스 경로는 파일명(title)이 아닌 asset 경로(relativePath) 우선 사용.
- 폴더명은 경로의 마지막 세그먼트를 사용해 사용자 친화적으로 표시.

## 다음 작업
- TODO 참조
