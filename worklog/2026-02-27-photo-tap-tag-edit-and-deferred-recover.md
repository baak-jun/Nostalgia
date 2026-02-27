# 보관함/보류함/폴더 이미지 탭 시 태그 수정 + 보류함 탭 복구

## 변경 파일
- lib/features/gallery/presentation/widgets/photo_card.dart
- lib/features/gallery/presentation/gallery.screen.dart
- lib/features/archive/presentation/archive.screen.dart
- lib/features/review_bin/presentation/review_bin.screen.dart
- lib/features/gallery/presentation/folder_overview.screen.dart
- lib/features/home/presentation/collection_tabs.screen.dart
- lib/features/home/presentation/home.screen.dart

## 작업 내용
- PhotoCard에 공통 `onTap` 콜백 추가.
- Gallery/Archive/ReviewBin/Folder 화면에서 카드 탭 이벤트를 상위로 전달하도록 연결.
- 화면 이동 탭(CollectionTabsScreen)에 탭별 사진 클릭 콜백을 추가.
- HomeScreen에서 사진 탭 시 태그 편집 다이얼로그를 재사용하도록 통합.
- 보류함에서 사진 탭 후 저장하면 자동으로 보관 상태로 복구되도록 처리.
- 보관함/폴더 탭의 태그 편집은 상태 변경 없이 태그만 업데이트.

## 결정 사항
- 태그 편집 UI는 기존 TagEditorDialog를 재사용하고, 화면별 상태 전환 정책만 분기.
- 보류함 탭에서는 사용자 의도(복구 + 태그 수정)를 반영해 저장 시 보관 이동.

## 다음 작업
- TODO 참조
