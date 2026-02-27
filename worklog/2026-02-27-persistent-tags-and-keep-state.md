# 태그/보관 상태 영구 저장 (새로고침/재실행 유지)

## 변경 파일
- pubspec.yaml
- lib/features/home/data/home_state_store.dart
- lib/features/home/presentation/home.screen.dart

## 작업 내용
- `shared_preferences` 의존성을 추가.
- 홈 상태 저장소(`HomeStateStore`)를 추가해 다음 데이터를 로컬 영구 저장:
  - 보관 ID 목록
  - 보류 ID 목록
  - 사진별 커스텀 태그
- 앱/화면 로드 시 저장된 상태를 로드해 현재 디바이스 사진 ID와 매칭되는 항목만 복원.
- 분류(보관/보류/스킵) 변경 시 상태 자동 저장.
- 태그 저장(태그 붙이기) 시 상태 자동 저장.
- `home.screen.dart` 300줄 제한 준수를 위해 구조를 압축 정리(기능 동일).

## 결정 사항
- 영구 저장 범위는 사용자 요구에 맞춰 태그 + 보관/보류 상태로 정의.
- 스킵 상태는 임시 흐름으로 유지하고 영구 저장 대상에서 제외.

## 다음 작업
- TODO 참조
