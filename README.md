# PulseRelay

> **Privacy-first · Zero-login · Real-time velocity trends across 12 niches**

A SwiftUI iOS application that aggregates velocity-based trends using a stateless, privacy-first architecture. No server-side user profiles. No login. No tracking.

---

## Architecture Overview

| Layer | Technology |
|---|---|
| UI | SwiftUI + Swift Concurrency (Async/Await) |
| State | `@Observable` (Observation framework) |
| Local Storage | SwiftData (`SelectedNiche` model) |
| Networking | `URLSession` via `PulseClient` |
| Background | `BackgroundTasks` framework |
| Subscriptions | StoreKit 2 (`SubscriptionStoreView`) |
| Relay | Cloudflare Worker (production) / bundled JSON mock (debug) |

---

## Project Structure

```
PulseRelay/
├── PulseRelayApp.swift              # @main entry point, SwiftData container, BG task registration
├── Info.plist                       # BGTaskSchedulerPermittedIdentifiers, ATS config
│
├── Models/
│   ├── Niche.swift                  # NicheCategory enum (12 niches) + SelectedNiche @Model
│   └── VelocityTrend.swift          # VelocityTrend, PulseFeedResponse, SourcePlatform
│
├── ViewModels/
│   └── PulseFeedViewModel.swift     # @Observable feed state, filtering, pinning
│
├── Views/
│   ├── ContentView.swift            # TabView shell, toolbar (Human toggle, view-mode toggle)
│   ├── PulseCardView.swift          # Dual-mode feed (.visualCards / .minimalistList)
│   ├── PulseCardItemView.swift      # Full visual card + compact list row
│   ├── NicheSelectorView.swift      # Horizontal chip selector with SF Symbols
│   └── SettingsView.swift           # Webhook config, velocity threshold, StoreKit sheet
│
├── Managers/
│   └── NicheManager.swift           # SwiftData CRUD wrapper for SelectedNiche
│
├── Networking/
│   └── PulseClient.swift            # URLSession async/await relay client + WebhookClient
│
├── BackgroundTasks/
│   └── PulseBackgroundTaskManager.swift  # BGAppRefreshTask registration + local notifications
│
└── Resources/
    └── mock_velocity_trends.json    # 12-item mock feed used during development
```

---

## The 12 Niche Categories

| # | Category | SF Symbol | Description |
|---|---|---|---|
| 1 | Space/Celestial | `star.fill` | Comet/Aurora alerts & mission telemetry |
| 2 | Additive Fab | `cube.fill` | Viral STL files & 3D hardware breakthroughs |
| 3 | Privacy/Sec | `lock.shield.fill` | Zero-day vulnerabilities & encryption news |
| 4 | E-Mobility | `bolt.car.fill` | Micromobility mods & battery tech |
| 5 | Experience Design | `theatermasks.fill` | Theme park anomalies & resort openings |
| 6 | Outdoor Frontier | `mountain.2.fill` | Trail alerts & gear innovations |
| 7 | Data Heritage | `server.rack` | NAS/Home-lab infrastructure & self-hosting |
| 8 | Longevity | `heart.fill` | Biohacking & metabolic health trends |
| 9 | Repair Economy | `wrench.and.screwdriver.fill` | DIY vehicle maintenance & Right-to-Repair |
| 10 | Agentic AI | `cpu.fill` | Real-world autonomous agent use cases |
| 11 | Serialized Media | `books.vertical.fill` | Manga, indie game & niche series drops |
| 12 | Legal Tech | `building.columns.fill` | E-filing shifts & municipal tech updates |

---

## Key Features

### Dual-View Toggle
- **Visual Cards** — Full-width `ScrollView` cards with gradient backgrounds, velocity score, signal-strength meter, source platform icon, and Human-Verified / Breaking Pulse badges.
- **Minimalist List** — Compact `List` rows with niche icon bubble, headline, velocity label, and source.

### Human-Verified Filter
A persistent, haptic-enabled toggle in the navigation bar. When active, only trends with `is_human: true` are displayed.

### Velocity Algorithm
```
velocityScore = mentionsLastHour / mentionsPrevious24h
```
Scores ≥ the user-configured threshold (default 80%) trigger **Breaking Pulse** notifications.

### Outbound Webhook (Pulse Tier)
Pinned trends are dispatched as JSON to any HTTPS endpoint (Discord, Slack, IFTTT) via `WebhookClient`.

### Background Refresh
`BGAppRefreshTask` fetches trends every ≥15 minutes and fires local `UNNotification` for Breaking Pulse events.

### Privacy Model
- Zero login / zero account creation
- User preferences (`SelectedNiche`) stored exclusively in a local SwiftData container
- No analytics, no third-party SDKs, no server-side user profiles

---

## Requirements

- Xcode 15.4+
- iOS 17.0+ deployment target
- Swift 5.9+

---

## Getting Started

1. Open `PulseRelay.xcodeproj` in Xcode.
2. Select a simulator or device.
3. Build & Run (`⌘R`).

The app ships with `mock_velocity_trends.json` so it works fully offline. To connect to a live relay, set `useMockData: false` in `PulseClient.init` and point `relayEndpoint` at your Cloudflare Worker URL.
