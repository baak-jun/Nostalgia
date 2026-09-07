# 삼성 갤러리 네이티브 태그 시트 UX 정렬 및 동적 추천 태그 반영

## 변경 파일
- [lib/features/tags/presentation/widgets/tag_editor_dialog.dart](file:///c:/github/Nostalgia/lib/features/tags/presentation/widgets/tag_editor_dialog.dart)
- [lib/features/home/presentation/home.screen.dart](file:///c:/github/Nostalgia/lib/features/home/presentation/home.screen.dart)
- [lib/features/cloud/presentation/cloud_drive_screen.dart](file:///c:/github/Nostalgia/lib/features/cloud/presentation/cloud_drive_screen.dart)
- [test/features/tags/presentation/widgets/tag_editor_dialog_test.dart](file:///c:/github/Nostalgia/test/features/tags/presentation/widgets/tag_editor_dialog_test.dart)

## 작업 내용
1. **삼성 갤럭시 One UI 태그 편집 UX 정렬**:
   - 다이얼로그 타이틀을 '태그'로 단일화 및 모서리 24dp 둥근 라운딩 적용.
   - 활성 태그 칩: `#태그` 뱃지 스타일(Primary Container 색상 및 삭제 아이콘).
   - 추천 태그 칩: `+ 태그` 스타일(터치 한 번으로 즉시 활성 태그로 추가).
   - 태그 입력창: `# 새 태그 추가` 플레이스홀더 적용 및 입력 시 `#` 접두사 자동 정규화.
2. **동적 추천 태그 연동**:
   - `HomeScreen`: 현재 갤러리의 모든 사진에서 추출된 고유 태그 중 미선택된 태그를 추천 목록으로 주입.
   - `CloudDriveScreen`: 클라우드 드라이브 사진 목록의 태그를 추천 목록으로 주입.
3. **단위 테스트 추가 및 검증**:
   - 추천 칩 클릭 시 활성 태그 추가 및 추천 목록 제거 검증.
   - 입력란에 `#` 포함 입력 시 이중 샵 방지 및 클린 태그 등록 검증.
   - 총 25개 테스트 전체 통과 (100%), `flutter analyze` 무경고.
