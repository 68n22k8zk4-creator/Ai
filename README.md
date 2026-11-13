# Flamio — iOS app

Flamio is a SwiftUI companion app for weather, work shifts, a streak pet, games, and spending/income analytics. The UI follows the supplied references: midnight gradients, glass cards, violet glow, and warm orange accent.

## Open in Xcode

1. Open `Flamio.xcodeproj`.
2. Select both targets (`Flamio` and `FlamioWidget`) and set your Apple Developer Team.
3. The project uses the shared App Group `group.com.flamio.app`. Create/enable this exact group for both bundle identifiers in Apple Developer, or replace it in `Config/Flamio.entitlements`, `Config/FlamioWidget.entitlements`, and `Shared/AppGroup.swift`.
4. Enable Push/Notifications only if you want scheduled pet reminders. The app works without an account or backend.

## Codemagic

`codemagic.yaml` contains an iOS workflow using automatic code signing. Add your App Store Connect API key or signing certificate/profile in Codemagic. If you use manual signing, upload profiles for:

- `com.flamio.app`
- `com.flamio.app.widget`

Both profiles must include `group.com.flamio.app`.

## Weather

Weather uses Open-Meteo (no API key) for geocoding and forecast. The app gracefully falls back to a local demo forecast when offline. Replace `WeatherService.swift` with your preferred provider before production if you need commercial SLA or attribution requirements.

## Product / Flamio+

The paywall is ready for StoreKit 2. Add a subscription product in App Store Connect with ID `com.flamio.plus.monthly` and the app will use the localized App Store price. The visible reference price is €2.49 / $2.49 / 99 грн as requested; the store price remains authoritative.

## Included

- Russian/English UI switch, light/dark/system theme and accent colors
- Weather city search, multiple saved cities, 7-day forecast, hourly day detail, readable metric explanations
- Manual and automatic shifts, live up/down timers, editable breaks, emoji labels, monthly calendar and filters
- Flamio pet: feed quality table, play, streak, name, clothing, history and playable games (Tic-tac-toe, 21, mini Durak)
- Expense/income ledger with emoji keyboard input, editing/deleting, date/type filters and currency selection
- WidgetKit small/medium/large/family widgets with timeline refresh and App Group storage
- Local notification reminders for pet care and work encouragement
- Animated starfield and smooth tab transitions with a reduced-motion setting
