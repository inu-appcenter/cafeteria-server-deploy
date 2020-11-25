# cafeteria-server-deploy

**Cafeteria API 서버 배포 스크립트**

> #### Cafeteria 관련 저장소 일람
>
> ##### 서비스
> - API 서버: [cafeteria-server](https://github.com/inu-appcenter/cafeteria-server)
> - Android 앱: [cafeteria-android](https://github.com/inu-appcenter/cafeteria-android)
>
> ##### 운영 관리
> - 관리용 API 서버: [cafeteria-management-server](https://github.com/inu-appcenter/cafeteria-management-server)
> - 웹 콘솔: [cafeteria-management-web](https://github.com/inu-appcenter/cafeteria-management-web)
>
> ##### 배포 관리
> - **API 서버 배포 스크립트**: [cafeteria-server-deploy](https://github.com/inu-appcenter/cafeteria-server-deploy)

## 개요

API 서버 배포를 위한 스크립트 & 가이드입니다.

## 목차

- [요구 사항](#요구-사항)    
- [서버 시간 설정](#서버-시간-설정)
- [설치](#설치)    
- [서버 명령어](#서버-명령어)
- [DB 설정](#DB-설정)

## 요구 사항

|-| `NodeJS` | `npm` | `MySQL Server` |
|-|-|-|-|
| 버전 | 12 이상 | 6 이상 | 5 이상 |

## 서버 시간 설정

서버 timezone을 맞추지 않은 경우, 이 과정이 필요합니다.

> 할인 가능 시간대를 판단해야 하기 때문에 중요합니다.

다음 명령으로 시간대를 설정합니다.

~~~
sudo dpkg-reconfigure tzdata
~~~

`Asia/Seoul`로 설정해 주세요.

## 설치

```
$ git clone https://github.com/inu-appcenter/cafeteria-server-deploy.git
$ cd cafeteria-server-deploy/scripts
$ ./install
```

> 설치 중 `exports.sh` 파일이 열립니다. 서버 운영에 필요한 환경 변수를 채워넣습니다.

> `install` 스크립트는 DB 설정을 포함하지 않습니다. 아직 DB를 설정하지 않으셨다면 [해당 문단](#DB-설정)을 참고해 주세요.

## 서버 명령어

### 확인을 위한 명령어

- `disabled-instance`: 프록시에 연결되지 않은(비활성화된) 인스턴스의 이름을 가져옵니다.
- `disabled-port`: 비활성화된 인스턴스가 사용하는 포트를 가져옵니다.
- `enabled-instance`: 프록시에 연결된(활성화된) 인스턴스의 이름을 가져옵니다.
- `enabled-port`: 프록시에 연결된 인스턴스가 사용하는 포트를 가져옵니다.
- `pid`: 인자로 주어진 인스턴스의 프로세스 id를 가져옵니다.

### 동작을 위한 명령어

- `start-instance`: 인자로 주어진 인스턴스를 실행합니다.
- `stop-instance`: 인자로 주어진 인스턴스를 종료합니다.
- `update-instance`: 인자로 주어진 인스턴스를 종료 후 업데이트합니다.
- `connect-to-nginx`: 인자로 주어진 인스턴스를 리버스 프록시에 연결합니다.

### 고수준 동작을 위한 명령어

- `install`: 서버 셋업 전 과정(DB 제외)을 자동으로 수행합니다.
- `deploy`: 배포 전 과정을 자동으로 수행합니다.
- `status`: 인스턴스와 프록시 연결 상태를 표시합니다.

### 기타

- `bootup`: 시스템이 시작될 때에 on shot으로 실행될 스크립트. 리버스 프록시에 연결된 인스턴스를 실행합니다.

> 서비스 운영에 중대한 영향을 끼치는 작업은 명시적인 의사 표현(y/n 입력)에 의해서만 수행될 수 있습니다.

## DB 설정

> 위의 `install` 스크립트는 DB가 준비되었음을 가정하여 작성되었습니다. DB가 설정되지 않은 상태에서 설치를 진행하면 실행 과정에서 오류가 발생하니 꼭 아래 내용을 따라주세요.

### 기본 문자 세트 설정

MySQL 설정 파일(`/etc/mysql/mysql.conf.d/mysqld.cnf`)에 다음을 추가합니다.

~~~
collation-server        = utf8_unicode_ci
init-connect            = 'SET NAMES utf8'
character-set-server    = utf8
~~~

### MySQL CLI 시작

다음 명령을 실행하여 데이터베이스 관리자로 로그인합니다.

~~~
$ mysql -uroot -p
~~~

MySQL을 설치할 때에 사용한 관리자 비밀번호를 입력합니다.

### 데이터베이스 생성

다음 명령어를 사용하여 `cafeteria` 데이터베이스를 생성하고 사용합니다.
~~~
mysql> CREATE DATABASE cafeteria;
~~~

~~~
mysql> use cafeteria
~~~

### 사용자 생성

다음 명령어로 사용자를 생성합니다.

~~~
mysql> CREATE USER '[사용자 이름]'@'localhost' IDENTIFIED BY '[비밀번호]';

~~~

> 예시:
~~~
mysql> CREATE USER 'potados'@'localhost' IDENTIFIED BY '1234';
~~~

### 권한 부여

방금 생성한 사용자에게 `cafeteria` 데이터베이스에 대한 모든 권한을 부여합니다.
~~~
mysql> GRANT ALL PRIVILEGES ON cafeteria.* TO '[사용자 이름]'@'localhost';
~~~

### 인증 방법 변경

Sequelize와의 연결을 위해 MySQL의 인증 방식을 변경합니다.

~~~
mysql> ALTER USER '[사용자 이름]'@'localhost' IDENTIFIED WITH mysql_native_password by '[비밀번호]';
~~~

> 설치가 완전히 끝나면 최초 한 번은 [`npm run setupdb`](https://github.com/inu-appcenter/cafeteria-server/blob/master/setup/setup-db.mjs)를 실행해서 DB에 기본 데이터를 추가하여 주세요.
