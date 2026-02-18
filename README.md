# expiryclock

만료기한 관리 앱

## 프로젝트 버전

- **Java 17**  
  Flutter 개발 시 Java 17 버전이 권장됩니다.

## 프로젝트 구조

```
lib/
├── main.dart                           # 앱 진입점
│
├── core/                               # 핵심 기능 모듈
│   ├── app/                           # 앱 설정
│   ├── constants/                     # 상수 정의
│   ├── data/                          # 데이터 저장소
│   ├── models/                        # 데이터 모델
│   └── security/                      # 보안 관련
│
├── screens/                            # 화면(UI) 모듈
│   ├── camera/                        # 카메라 화면
│   ├── item_management/               # 아이템 관리 화면
│   └── settings/                      # 설정 화면
│
└── shared/                             # 공유 모듈
    ├── ai/clients/                    # AI 클라이언트 (OpenAI, OpenRouter, Google)
    ├── models/                        # 공유 모델
    └── services/                      # 공유 서비스
```

## 개발 가이드

### 개발 환경 설정

#### 1. Java 버전 지정 (권장)

```
flutter config --jdk-dir "D:\java\jdk-17.0.0.1"
```

- Java 버전을 직접 지정하는 것을 권장합니다.
- 지정하지 않으면 `JAVA_HOME` 환경 변수의 경로를 기본으로 참고합니다.

##### 1-1. Gradle에서 Java 버전 지정

- `GRADLE_USER_HOME` 환경 변수의 경로 내에 `gradle.properties` 파일을 생성합니다.
  - 만약, 별도의 경로를 설정하지 않았다면, `C:\Users\<사용자>\.gradle`경로에 해당 파일 생성합니다.
- 아래의 내용을 추가하여 Java 버전을 직접 지정합니다.

```
org.gardle.java.home=D:\\java\\jdk-17.0.0.1
```

- 위의 Java 버전을 별도로 지정하지 않았다면 설정할 필요가 없습니다.

##### 1-2. IDE 설정 (VSCode)

- VSCode를 사용할 경우, 해당 workspace내의 `.vscode/settings.json` 파일 내에 다음의 내용을 추가합니다.
- IDE가 직접 지정한 jdk 버전을 인식하기 위함입니다.

```
{
  "java.configuration.runtimes": [
    {
      "name": "JavaSE-17",
      "path": "D:/java/jdk-17.0.0.1",
      "default": true
    }
  ],
  "terminal.integrated.env.windows": {
    "JAVA_HOME": "D:/java/jdk-17.0.0.1",
    "PATH": "D:/java/jdk-17.0.0.1/bin;${env:PATH}"
  }
}
```

#### 2. 패키지 설치

```
flutter pub get
```

- 개발 중에 pubspec.yaml에 패키지를 추가한 경우에도 위 명령어를 실행해야 합니다.

### 개발 공통 작업

#### 데이터 모델 변경 적용하는 방법

```
flutter pub run build_runner build --delete-conflicting-outputs
```

- 충돌나면 깔끔하게 지우고 빌드하게끔 명령어 실행합니다.
- .g.dart 만들기 위해서는 빌드하고자 하는 파일에 해당 파일명.g.dart가 import 되어 있어야 합니다.

#### 앱 아이콘 변경 적용하는 방법

```
flutter pub run flutter_launcher_icons
```

- 앱 아이콘을 변경한 후에 적용하려면 위 명령어를 실행해야 합니다.
- `flutter_launcher_icons.yaml` 파일에 아이콘 설정이 정의되어 있어야 합니다.
- 현재 Android와 iOS만 아이콘 생성되도록 설정됩니다. (web, windows, macos는 `generate: false`)

#### 스플래쉬 화면 적용하는 방법

```
flutter pub run flutter_native_splash:create
```

- 스플래쉬 화면을 변경한 후에 적용하려면 위 명령어를 실행해야 합니다.
- `pubspec.yaml`파일에 `flutter_native_splash`가 정의되어 있어야 합니다.

### 빌드 모드

#### Debug 모드

```
flutter run
```

- 디버깅 기능 활성화
- Hot Reload 가능
- 성능 최적화 X

#### Release 모드

```
flutter run --release
```

- 디버깅 기능 완전 제거
- 코드 최적화 및 최대 성능
- 실제 배포용과 동일한 빌드

#### Release APK 모드

```
flutter build apk --release
```

- .apk 파일 형식으로 만드는 모드