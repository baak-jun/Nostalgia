# 메타데이터 비파괴 안전 동기화 및 웹드라이브(Google Drive/OneDrive) 통합 연동

## 작업 일자
- 2026-09-07

## 작업 내용 요약
1. **코드베이스 엄밀 점검 및 위험 요소 완전 제거**
   - 기존 `MetadataSyncService`에서 원본을 앱 내부 비공개 디렉토리(`metadata_synced_copies`)로 복제하여 저장 공간을 낭비(중복 저장)하고, 원본을 보류함으로 이동시켜 일괄 삭제 시 원본이 유실되던 위험 결함을 완전히 제거.
   - 복제본 생성 없는 **제자리(In-place) 비파괴 EXIF 기록** (`UserComment`, `ImageDescription`) 구현.
   - 동기화 완료 후 원본 사진이 보관함(`_keptIds`)에 유지되도록 수정.
   - 기존 앱 버전에서 생성되었을 수 있는 레거시 복제본 디렉토리 자동 정리(`cleanupLegacyCopies`) 추가.

2. **삼성 갤러리 검색 연동 최적화**
   - 삼성 갤러리 `#태그`는 시스템 비공개 DB에만 저장되고 EXIF 텍스트를 인덱싱하지 않는 기술적 제약을 파악.
   - 삼성 갤러리 및 기본 '내 파일' 앱에서 완벽하게 인덱싱되는 **파일명 태그 추가(Rename)** 기능 도입 (예: `photo_#여행_#고양이.jpg`).
   - 설정 화면에서 삼성 갤러리 파일명 태깅 연동 및 표준 EXIF 기록 여부를 켜고 끌 수 있도록 옵션화.

3. **삭제 안전성 대폭 강화**
   - 보류함(Review Bin) 삭제 확인 다이얼로그에 총 대상 개수, 예상 확보 용량, 복원 불가 경고를 명시하고 시각적 안전장치(위험 경고 배너, 삭제 확정 버튼) 적용.

4. **웹드라이브(Google Drive, OneDrive) 통합 개발**
   - `lib/features/cloud/domain/cloud_drive_models.dart`: 클라우드 계정, 폴더, 파일 모델 구축 (`toPhotoItem()` 어댑터로 기존 UI와 완벽 호환).
   - `lib/features/cloud/data/google_drive_client.dart`: Google Drive v3 REST API 클라이언트 구현 (사진 검색, 태그 기록, 폴더 이동, 휴지통 처리).
   - `lib/features/cloud/data/onedrive_client.dart`: Microsoft Graph API v1.0 클라이언트 구현 (OneDrive 사진 검색, 태그 기록, 휴지통 처리).
   - `lib/features/cloud/data/cloud_drive_repository.dart`: 계정 세션 저장/복원 및 즉시 체험 가능한 데모 클라우드 샌드박스 데이터 지원.
   - `lib/features/cloud/presentation/cloud_drive_screen.dart`: Nostalgia 고유의 스와이프(보관/보류/스킵/태그) 인터페이스를 클라우드 사진에 그대로 적용한 전용 뷰 구현. 클라우드 보류함 및 휴지통 이동 안전 다이얼로그 제공.
   - 홈 화면 AppBar에 '웹드라이브 정리' 바로가기 아이콘 및 메뉴 추가.

5. **빌드/테스트 환경 정상화**
   - Dart SDK 버전 제약(`^3.9.2` -> `'>=3.8.0 <4.0.0'`) 수정으로 Flutter 3.32.8 (Dart 3.8.1) 호환성 확보.
   - `AndroidManifest.xml`에 `INTERNET` 권한 추가.
   - 태그 AND 검색 다중 토큰(콤마/공백) 파싱 개선.
   - 단위/위젯 테스트 23개 전체 100% 통과 및 정적 분석 0 warning/0 error 달성.

