# GitHub CLI 설치 및 푸시 시도 (환경 블로커)

## 변경 파일
- worklog/2026-02-27-github-cli-install-blocked.md
- todo/todo.md

## 작업 내용
- `gh` 설치를 위해 `choco install gh -y`를 재시도했다.
- 비관리자 권한 환경에서 `C:\ProgramData\chocolatey\lib` 잠금/쓰기 권한 오류로 설치가 실패했다.
- 대체 경로로 GitHub 릴리스 ZIP 다운로드를 시도했지만 외부 네트워크 접속이 차단되어 실패했다.
- `git ls-remote https://github.com/cli/cli.git HEAD`로 확인한 결과 `github.com:443` 연결 실패를 재현했다.

## 결정 사항
- 현재 실행 환경에서는 `gh` 설치와 GitHub 원격 작업(레포 생성/푸시)을 완료할 수 없다.
- 사용자 로컬 관리자 PowerShell 또는 외부망 가능한 터미널에서 1회 설치/인증 후 이어서 진행한다.

## 다음 작업
- 사용자 환경에서 `gh` 설치 후 `gh auth login`, `gh repo create`를 실행한다.
- 이후 현재 로컬 저장소를 원격에 `git push -u origin master`로 연결한다.
