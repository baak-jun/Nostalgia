# Android 메타데이터 수동 동기화(복제본 태깅 + 원본 보류함 이동)

## 변경 파일
- pubspec.yaml
- lib/features/sync/data/metadata_sync_service.dart
- lib/features/sync/presentation/metadata_sync_dialogs.dart
- lib/features/home/presentation/home.screen.dart
- test/features/sync/data/metadata_sync_service_test.dart

## 작업 내용
- Android 1차 범위로 메타데이터 수동 동기화 기능 추가.
- 앱바에 `메타 동기화` 버튼 추가.
- 실행 흐름: dry-run(대상/미지원/파일없음 확인) -> 사용자 확인 -> 실제 동기화 -> 결과 다이얼로그.
- 실제 동기화는 jpg/jpeg만 지원하며, 복제본 생성 후 `UserComment`에 태그 기록.
- 동기화 성공한 원본은 보관에서 제외하고 보류함으로 이동(사용자 검토 후 최종 삭제 가능).
- 확장자 지원 분기 테스트 추가.

## 결정 사항
- 원본 무결성 보호를 위해 원본 직접 수정 대신 복제본 태깅 전략 채택.
- 포맷 호환성 문제를 줄이기 위해 1차는 jpg/jpeg만 지원.

## 다음 작업
- TODO 참조
