# Untill

A beautifully simple **countdown** app that lives in your Mac's menu bar. See at
a glance how many days remain until the moments that matter — birthdays,
holidays, trips, launches, deadlines — right from your menu bar.

**Privacy first** — Untill stores all your events locally on your Mac. Nothing
leaves your device.

## Features
- Live countdown to your next important day, right in the menu bar
- Beautiful cards with emoji, accent colors and a big day count
- **Untill Pro** (one-time purchase): unlimited events, the full emoji & color
  set, menu-bar pin (choose which countdown shows up top), launch at login,
  and all themes

## Build
The Xcode project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
brew install xcodegen
xcodegen generate
open Untill.xcodeproj
```

CI/CD: built & signed for the Mac App Store on Codemagic (`codemagic.yaml`).
Monetization via [RevenueCat](https://www.revenuecat.com) (entitlement `pro`).

- Bundle ID: `app.untill.Untill`
- Minimum macOS: 13.0
