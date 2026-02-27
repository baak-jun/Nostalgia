# shared_preferences MissingPlugin 방어 처리

## 변경 파일
- lib/features/home/data/home_state_store.dart
- lib/main.dart

## 작업 내용
- `HomeStateStore.load/save`에 `MissingPluginException` 방어 추가.
- 플러그인 채널 미등록 상태에서도 앱이 크래시하지 않고 기본 상태로 동작하도록 처리.
- `main()`에 `WidgetsFlutterBinding.ensureInitialized()` 추가로 초기 바인딩 보강.

## 결정 사항
- 플러그인 문제로 영구 저장이 일시 불가해도 이미지 로딩/분류 UI는 계속 동작하도록 우선 안정성 확보.

## 다음 작업
- TODO 참조
