# MiniClock

항상 위에 떠 있는 macOS 데스크톱 시계 앱. Xcode 없이 `swiftc` 로 빌드한다.

## 빌드·실행

```bash
./build.sh && open MiniClock.app
```

## 파일

- `MiniClock.swift`: 앱 본체 (SwiftUI, `-parse-as-library` 로 컴파일)
- `make_icon.swift`: `AppIcon.icns` 생성기. 아이콘을 바꾸려면 `AppIcon.icns` 를 지우고 다시 빌드한다.
- `build.sh`: `.app` 번들 생성, Info.plist 작성, ad-hoc 서명

## 참고

- SourceKit 이 `'main' attribute cannot be used ...` 를 표시하지만, 빌드는 `-parse-as-library` 플래그로 정상 동작한다.
- 창 레벨은 `.floating` (항상 위), 날짜 형식은 `yyyy년 M월 d일, EEEE`.
- `MiniClock.app` 은 빌드 산출물이므로 git 에서 제외한다.
