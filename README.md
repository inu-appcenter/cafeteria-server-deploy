# cafeteria-server-deploy

INU 카페테리아 서버 배포 스크립트입니다.

## 사용법

### 설치

```
cd scripts
./install
```

설치 중 `exports.sh` 파일이 열립니다. 서버 운영에 필요한 환경 변수를 채워넣습니다.

### 운영

- `status`: 서버 전반 상태를 확인합니다.
- `start-instance`: 인스턴스를 시작합니다.
- `stop-instance`: 인스턴스를 중단합니다.

서비스 운영에 중대한 영향을 끼치는 작업은 명시적인 의사 표현(y/n 입력)에 의해서만 수행될 수 있습니다.
