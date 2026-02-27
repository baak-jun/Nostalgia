# 테스트 전 전체 변경사항 요약 및 푸시

## 변경 파일
- lib/features/home/presentation/home.screen.dart
- lib/features/home/presentation/collection_tabs.screen.dart
- lib/features/review_bin/presentation/review_bin.screen.dart
- lib/features/archive/presentation/archive.screen.dart
- lib/features/home/data/home_state_store.dart
- todo/todo.md
- worklog/2026-02-27-home-move-button-offset.md
- worklog/2026-02-27-home-header-menu-relayout.md
- worklog/2026-02-27-archive-filter-fix.md
- worklog/2026-02-27-review-bin-restore-to-archive.md
- worklog/2026-02-27-review-bin-action-menu-and-delete-flow.md
- worklog/2026-02-27-review-bin-instant-apply-and-delete-confirm.md
- worklog/2026-02-27-pretest-handoff-summary.md

## 작업 내용
- 홈 상단 UI를 재배치했다.
  - AppBar 액션을 햄버거 메뉴(설정/메타 동기화/다시 불러오기)로 통합
  - `화면 이동` 버튼을 본문 상단으로 이동
  - 정렬 버튼 크기 축소
- 보관함 필터를 보정했다.
  - `전체/미태그` 필터를 명확히 분리
  - 필터별 개수 노출
- 보류함 관리 기능을 확장했다.
  - `모두 보관` 지원
  - `보관/삭제` 메뉴 펼침 + `모두/선택` 액션 지원
  - 선택 모드에서 카드 다중 선택 가능
  - `모두 보관/삭제` 즉시 반영
  - 삭제 계열 액션 전 `삭제하시겠습니까?` 확인 다이얼로그 추가
- 보류함 태그 편집 플로우를 개선했다.
  - 태그가 있는 상태에서 저장 시 `이미지를 보관하시겠습니까?` 확인
- 삭제 상태 영구 저장을 추가했다.
  - `deletedIds`를 앱 상태에 추가하고 `shared_preferences`에 저장/복원
  - 삭제된 항목은 전체/보관함/보류함/분류 대상에서 재노출되지 않음
- GitHub 레포 운영 정리
  - 기본 브랜치 `master -> main` 전환 완료
  - 원격 레포명 `baak-jun/Nostalgia` 반영

## 결정 사항
- 삭제는 실제 파일 즉시 삭제가 아니라 앱 상태 기준 1차 삭제(숨김)로 유지한다.
- 보류함에서 태그 저장 후 보관 여부는 사용자 확인을 거치도록 유지한다.
- 테스트 전 상태 공유를 위해 변경사항을 worklog+todo에 누적 기록한다.

## 다음 작업
- 실제 테스트 실행(분류/태그/보관함/보류함/삭제 플로우 회귀 점검)
- 태그 AND 검색 쿼리 구현
