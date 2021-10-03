# cafeteria-server-deploy

**Cafeteria API 서버 배포 스크립트**

> #### Cafeteria 관련 저장소 일람
>
> ##### 서비스
> - API 서버: [cafeteria-server](https://github.com/inu-appcenter/cafeteria-server)
> - 모바일 앱: [cafeteria-mobile](https://github.com/inu-appcenter/cafeteria-mobile)
>
> ##### 운영 관리
> - 콘솔 API 서버: [cafeteria-console-server](https://github.com/inu-appcenter/cafeteria-console-server)
> - 콘솔 웹 인터페이스: [cafeteria-console-web](https://github.com/inu-appcenter/cafeteria-console-web)
>
> ##### 배포 관리
> - **API 서버 배포 스크립트**: [cafeteria-server-deploy](https://github.com/inu-appcenter/cafeteria-server-deploy)

## 개요

cafateria-server 및 cafeteria-console-server 배포를 위한 스크립트 & 가이드입니다.

## 목차

- [요구 사항](#요구-사항)
- [사전 준비](#사전-준비)
- [배포](#배포)

## 요구 사항

Ubuntu 20.04 LTS가 설치된, 메모리 용량이 2GB 이상이고 디스크 용량이 30GB 이상인 인스턴스.

## 사전 준비

### 서버 시간 설정

서버 timezone을 맞추지 않은 경우, 이 과정이 필요합니다.

> 할인 가능 시간대를 판단해야 하기 때문에 중요합니다.

다음 명령으로 시간대를 설정합니다.

~~~bash
$ sudo dpkg-reconfigure tzdata
~~~

`Asia/Seoul`로 설정해 주세요.

### MySQL 설치 및 설정

#### 설치

> 설치에 앞서 패키지를 모두 최신으로 업데이트합니다.

~~~bash
$ sudo apt update
$ sudo apt upgrade
~~~

~~~bash
$ sudo apt install mysql-server
~~~

#### 보안 설정

아래 명령으로 보안 설정을 간단하게 수정할 수 있습니다. 설치 환경에 따라 적절한 선택지를 골라 주세요.
~~~bash
$ sudo mysql_secure_installation
~~~

#### 기본 문자 세트 설정

MySQL 설정 파일(`/etc/mysql/mysql.conf.d/mysqld.cnf`)에 다음을 추가합니다.

~~~
collation-server = utf8mb4_unicode_ci
character-set-server = utf8mb4
skip-character-set-client-handshake
~~~

#### MySQL CLI 시작

다음 명령을 실행하여 데이터베이스 관리자로 로그인합니다.

~~~bash
$ mysql -uroot -p
~~~

MySQL을 설치할 때에 사용한 관리자 비밀번호를 입력합니다.

#### 데이터베이스 생성

다음 명령어를 사용하여 `cafeteria` 데이터베이스를 생성합니다.

~~~
mysql> CREATE DATABASE cafeteria;
~~~

#### 사용자 생성

다음 명령어로 사용자를 생성합니다.

~~~
mysql> CREATE USER '[사용자 이름]'@'%' IDENTIFIED BY '[비밀번호]';
~~~

예시:

~~~
mysql> CREATE USER 'potados'@'%' IDENTIFIED BY '1234';
~~~

#### 권한 부여

방금 생성한 사용자에게 `cafeteria` 데이터베이스에 대한 모든 권한을 부여합니다.

~~~
mysql> GRANT ALL PRIVILEGES ON cafeteria.* TO '[사용자 이름]'@'%';
~~~

예시:

~~~
mysql> GRANT ALL PRIVILEGES ON cafeteria.* TO 'potados'@'%';
~~~

### Docker 설치 및 설정

> 다음 링크에서 가져온 내용입니다: https://docs.docker.com/engine/install/ubuntu/

#### 기존에 설치된 구 버전 제거

~~~bash
$ sudo apt remove docker docker-engine docker.io containerd runc
~~~

> 패키지를 찾을 수 없다고 나와도 괜찮습니다. 없게 만드는게 목적이에요.

#### 패키지 저장소 설정

1. `apt`가 HTTPS 상에서 저장소를 사용할 수 있도록 패키지 인덱스를 업데이트하고 패키지를 설치합니다.
~~~bash
$ sudo apt update
$ sudo apt install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
~~~

2. Docker 공식 GPG 키를 추가합니다.
~~~bash
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
~~~

3. 아래 명령으로 stable 저장소를 설정합니다.
~~~bash
$ echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
~~~

#### Docker 엔진 설치

~~~bash
$ sudo apt update
$ sudo apt install docker-ce docker-ce-cli containerd.io
~~~

#### 사용자 권한 설정

> 일반 사용자로 Docker를 사용하려면 이 단계를 진행해야 합니다.

```bash
$ sudo usermod -aG docker $USER
```

## 배포

총 세 개의 스택으로 이루어져 있습니다. 차례대로 배포(또는 업데이트)해주면 됩니다.

```bash
$ ./deploy-traefik # 에지 라우터
$ ./deploy-app-api # 앱 서버
$ ./deploy-console-server # 콘솔 서버
```
