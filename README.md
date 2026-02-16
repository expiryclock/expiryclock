# expiryclock

만료기한 관리 앱

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

### 데이터 모델 빌드 하는 방법

```
flutter pub run build_runner build --delete-conflicting-outputs
```

- 충돌나면 깔끔하게 지우고 빌드하게끔 명령어 실행
- .g.dart 만들기 위해서는 빌드하고자 하는 파일에 해당 파일명.g.dart가 import 되어 있어야 함

### 패키지 추가 후 설치하는 방법
```
flutter pub get
```

- pubspec.yaml에 패키지를 추가한 후에 설치하려면 위 명령어를 실행하면 됨

### 앱 아이콘 변경 적용하는 방법
```
flutter pub run flutter_launcher_icons
```

- 앱 아이콘을 변경한 후에 적용하려면 위 명령어를 실행해야 함
- flutter_launcher_icons.yaml 파일에 아이콘 설정이 정의되어 있어야 함
- 현재 Android와 iOS만 아이콘 생성되도록 설정됨 (web, windows, macos는 `generate: false`)

## Screens

- Splash → Camera (default)
- Capture Review (after taking a photo)
- Item List
- Item Detail/Edit

## Notes

- Camera/OCR/Notifications are stubs. Buttons simulate the behavior and generate mock data.
- Data is stored in-memory and resets on hot restart.
- No external packages are used to keep setup minimal.

## Run

1. Ensure Flutter SDK is installed.
2. If this folder wasn't created by `flutter create`, generate platform folders:
   - `flutter create .`
3. Get packages: `flutter pub get`
4. Run: `flutter run`

## Next Steps (handoff)

- Replace stubs in `lib/services/*` with real implementations.
- Swap repository to local storage or remote API.
- Hook local push notifications.