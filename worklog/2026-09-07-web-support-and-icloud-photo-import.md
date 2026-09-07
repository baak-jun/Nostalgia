# 웹 실행(앱 미설치) 지원 및 애플 iCloud 사진 가져오기 연동

## 변경 파일
- [pubspec.yaml](file:///c:/github/Nostalgia/pubspec.yaml)
- [lib/features/gallery/domain/photo_item.dart](file:///c:/github/Nostalgia/lib/features/gallery/domain/photo_item.dart)
- [lib/features/gallery/data/web_photo_importer.dart](file:///c:/github/Nostalgia/lib/features/gallery/data/web_photo_importer.dart)
- [lib/features/gallery/data/device_photo_loader.dart](file:///c:/github/Nostalgia/lib/features/gallery/data/device_photo_loader.dart)
- [lib/features/gallery/presentation/widgets/photo_card.dart](file:///c:/github/Nostalgia/lib/features/gallery/presentation/widgets/photo_card.dart)
- [lib/features/home/presentation/home.screen.dart](file:///c:/github/Nostalgia/lib/features/home/presentation/home.screen.dart)
- [lib/features/home/presentation/widgets/swipe_classification_card.dart](file:///c:/github/Nostalgia/lib/features/home/presentation/widgets/swipe_classification_card.dart)
- [lib/features/sync/data/metadata_sync_service.dart](file:///c:/github/Nostalgia/lib/features/sync/data/metadata_sync_service.dart)
- [test/features/gallery/data/web_photo_importer_test.dart](file:///c:/github/Nostalgia/test/features/gallery/data/web_photo_importer_test.dart)

## 작업 내용
1. **웹 브라우저 실행 지원 (Flutter Web)**:
   - `flutter build web` 빌드 검증 및 런타임 플랫폼 호환성 확보.
   - `DevicePhotoLoader` 및 `MetadataSyncService`에 `kIsWeb` 분기 적용으로 웹 브라우저에서 `MissingPluginException` 및 `dart:io` 크래시 원천 차단.
2. **웹 & 애플 iCloud 사진 가져오기 (`WebPhotoImporter`)**:
   - `file_picker` 패키지를 통해 웹 브라우저(PC, Mac, iPhone/iPad Safari)에서 사진 다중 선택 지원.
   - iOS/macOS Safari 접속 시 시스템 시트를 통해 **`[사진 보관함 (iCloud 사진)]` 및 `[파일 (iCloud Drive)]`**에서 사진을 직접 불러와 Nostalgia 스와이프 카드로 로드.
   - `PhotoItem` 및 카드 뷰어(`PhotoCard`, `SwipeClassificationCard`)에 `imageBytes` 필드를 연동하여 웹에서 불러온 실제 사진 이미지를 즉시 렌더링.
3. **UI / UX 적응형 대응**:
   - 홈 AppBar에 **[사진/iCloud 가져오기]** (`Icons.add_photo_alternate_outlined`) 및 **[웹드라이브 정리]** 아이콘 전진 배치.
   - 웹 환경 접속 시 권한 배너를 '웹 브라우저 환경 안내 및 바로가기(사진 가져오기 / 웹드라이브)'로 맞춤 노출.
4. **검증**:
   - `flutter analyze` 0 경고.
   - `flutter test` 총 26개 테스트 전체 통과 (100%).
   - `flutter build web` 프로덕션 컴파일 정상 완료.
