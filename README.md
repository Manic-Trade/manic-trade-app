# Manic Trade

**Decentralized fixed-time options trading on Solana — built mobile-first.** Predict whether an asset's price will go Higher or Lower within a set timeframe — every trade is settled on-chain, fully transparent, and non-custodial.

Manic Trade is a **mobile-native dApp**. Users connect their existing Solana wallet (Jupiter, Solflare, OKX, Backpack, etc.) directly from their phone — no QR code dance, no desktop bridge, no custodial onboarding required. Leveraging Solana's **~400ms block times** and sub-cent transaction fees, the app delivers a trading experience that rivals centralized platforms while keeping all settlement logic on-chain via Anchor smart contracts. Price feeds are sourced from [**Pyth Network**](https://www.pyth.network/) — the leading Solana-native oracle providing institutional-grade, low-latency price data aggregated from 100+ first-party publishers.


## Highlights

- **Mobile-First dApp** — Built in Flutter for iOS and Android. The trading surface, charts, order flow, and wallet integration are all designed for phones from the ground up — not a responsive web port
- **Direct Wallet Login** — Connect any Solana wallet on the device with a single tap via [Reown AppKit](https://reown.com/appkit) (WalletConnect v2). Sessions are persisted, signing happens in the user's wallet app, and keys never leave it
- **Fully On-Chain Settlement** — Every position open, close, and payout is executed through Solana smart contracts (Anchor). No off-chain matching engine, no counterparty risk — the blockchain is the settlement layer
- **Pyth Oracle Price Feeds** — Real-time asset prices sourced from [Pyth Network](https://docs.pyth.network/price-feeds/core/contract-addresses/solana), delivering sub-second updates with confidence intervals directly on Solana
- **Optional Custodial Onboarding** — For users without a wallet, [Turnkey](https://www.turnkey.com/) provides a wallet-as-a-service path so they can start trading via email or Google without managing seed phrases
- **Sub-Second Trading UX** — Live candlestick charts, WebSocket price feeds, haptic feedback, and double-tap quick orders for a native mobile trading experience

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App (Dart)                    │
├──────────┬──────────┬───────────┬───────────────────────┤
│ features │ services │  domain   │        data           │
│          │          │           │                       │
│ Trading  │ AppKit   │ Premium   │ Solana RPC            │
│ Login    │ Turnkey  │ Calculator│ REST API (Dio)        │
│ Wallet   │ Wallet   │ (B-S)     │ WebSocket (prices,    │
│ Activity │ Service  │           │  game status)         │
└────┬─────┴────┬─────┴─────┬─────┴───────────┬───────────┘
     │          │           │                 │
     ▼          ▼           ▼                 ▼
┌─────────┐ ┌────────┐ ┌──────────┐  ┌──────────────────┐
│ Wallet  │ │Turnkey │ │ Solana   │  │  Manic Trade     │
│ App     │ │ API    │ │ Mainnet  │  │  Backend         │
│(Jupiter)│ │        │ │          │  │                  │
└─────────┘ └────────┘ └──────────┘  └──────────────────┘
 via AppKit   Custody    On-chain       REST + WS
```

## Key Technical Decisions

| Area | Choice | Why |
|------|--------|-----|
| **Wallet Auth** | Reown AppKit (WalletConnect v2) | Cross-wallet support out of the box (Jupiter, Solflare, OKX, Backpack…), deep-link based connection on mobile, persistent sessions |
| **Custodial Fallback** | Turnkey wallet-as-a-service | New users without a wallet get a dedicated Solana wallet via email / Google; signing happens in Turnkey's secure enclaves |
| **Pricing** | Client-side Black-Scholes | Matches the on-chain Anchor program's pricing logic, enabling instant premium previews before tx submission |
| **State Management** | ValueNotifier + store_scope | Lightweight, no heavy framework overhead; ComputedNotifier for derived state |
| **Transaction Flow** | API → presign → wallet sign → broadcast | Server constructs the transaction, client signs via the user's connected wallet (or Turnkey), then broadcasts directly to Solana RPC |

## Solana Integration Deep Dive

### Wallet Login (Reown AppKit)

The app uses `reown_appkit` to open a WalletConnect v2 session with any Solana wallet installed on the device. The connection is initiated via deep link, the user approves in their wallet app, and the session is restored across app launches.

- [web3_wallet_login_screen.dart](lib/features/login/web3_wallet_login_screen.dart) — Wallet selection and connection entry point
- [web3_login_session.dart](lib/features/login/web3_login_session.dart) — Session lifecycle and persistence
- [appkit_solana_wallet.dart](lib/services/appkit/appkit_solana_wallet.dart) — Adapter bridging AppKit ↔ the app's unified wallet interface
- [appkit_deep_link_handler.dart](lib/services/appkit/appkit_deep_link_handler.dart) — Android/iOS deep-link plumbing for the connect/sign callbacks

### On-Chain Trading

- [solana_rpc_service.dart](lib/data/network/solana_rpc_service.dart) — Solana JSON-RPC client (send, confirm, account queries)
- [solana_withdraw_builder.dart](lib/domain/crypto/solana_withdraw_builder.dart) — SPL Token transaction builder with ATA management and fee handling
- [place_order_vm.dart](lib/features/positions/vm/place_order_vm.dart) — Full order lifecycle: API → sign → broadcast

### Black-Scholes Pricing Engine

- [premium_calculator.dart](lib/domain/premium/premium_calculator.dart) — Digital option pricing using normalized call/put spreads, with bisection-based barrier solving

## Project Structure

```
lib/
├── common/          # Shared utilities and widgets
│   ├── constants/   # App-wide constants
│   ├── utils/       # Utility classes
│   └── widgets/     # Reusable widgets (Touchable, EmptyView, etc.)
├── core/            # Core infrastructure
│   ├── error/       # Centralized error handling
│   ├── notifier/    # Reactive primitives (ComputedNotifier, multi-listeners)
│   └── state/       # UI state abstractions (UiState<T>)
├── data/            # Data layer
│   ├── network/     # REST API (Dio + Retrofit) & Solana RPC
│   ├── socket/      # WebSocket clients (prices, game events)
│   └── drift/       # Local database (SQLite via Drift)
├── di/              # Dependency injection (GetIt)
├── domain/          # Domain layer
│   ├── auth/        # Authentication logic
│   ├── crypto/      # Solana transaction building
│   ├── options/     # Trading entities & mappers
│   └── premium/     # Black-Scholes pricing engine
├── features/        # Feature modules (UI + ViewModels)
│   ├── highlow/     # Main trading screen & chart
│   ├── login/       # Auth screens (Web3 wallet, email, Google)
│   ├── positions/   # Position management
│   └── ...
├── services/        # Global services
│   ├── appkit/      # Reown AppKit (WalletConnect) integration
│   ├── turnkey/     # Turnkey wallet-as-a-service
│   └── wallet/      # Unified wallet management
├── routes/          # Navigation (GetX router)
└── theme/           # Dark/Light theme, typography, spacing
```

## Getting Started

### Prerequisites

| Dependency | Version |
|------------|---------|
| Flutter    | >= 3.19.0 |
| Dart       | >= 3.3.0 |
| Java JDK   | >= 18 |
| Android SDK | >= 34 |
| Xcode      | >= 15.0 (iOS) |

### 1. Clone & install dependencies

```bash
git clone https://github.com/Manic-Trade/manic-trade-app.git
cd manic-trade-app
flutter pub get
```

### 2. Configure environment

```bash
cp .env.json.example .env.json
```

Edit `.env.json` with your credentials:

```json
{
  "TURNKEY_ORGANIZATION_ID": "YOUR_TURNKEY_ORGANIZATION_ID",
  "TURNKEY_AUTH_PROXY_CONFIG_ID": "YOUR_TURNKEY_AUTH_PROXY_CONFIG_ID",
  "GOOGLE_CLIENT_ID": "YOUR_GOOGLE_OAUTH_CLIENT_ID"
}
```

| Variable | Description | Where to get it |
|----------|-------------|-----------------|
| `TURNKEY_ORGANIZATION_ID` | Turnkey organization ID | [Turnkey Dashboard](https://app.turnkey.com) |
| `TURNKEY_AUTH_PROXY_CONFIG_ID` | Auth proxy config ID | [Turnkey Dashboard](https://app.turnkey.com) |
| `GOOGLE_CLIENT_ID` | Google OAuth Web Client ID | [Google Cloud Console](https://console.cloud.google.com/) |

> `.env.json` is gitignored and will not be committed.

### 3. Run code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run the app

```bash
# Development
flutter run --dart-define-from-file=.env.json

# Production
flutter run --release --dart-define-from-file=.env.json --dart-define=APP_ENV=release
```

### Google OAuth Setup (Optional)

1. Create an OAuth Client ID in [Google Cloud Console](https://console.cloud.google.com/)
2. Set the authorized redirect URI to:
   ```
   https://oauth-redirect.turnkey.com?scheme=manic-trade-app
   ```
3. Add the Client ID to `.env.json`

See [Turnkey Flutter SDK docs](https://docs.turnkey.com/sdks/flutter) for more details.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter (Dart) — iOS & Android |
| **State Management** | ValueNotifier + [store_scope](https://pub.dev/packages/store_scope) + ComputedNotifier |
| **DI** | GetIt |
| **Network** | Dio + Retrofit (code-gen) |
| **Database** | Drift (SQLite ORM) |
| **Blockchain** | Solana (`solana` package) |
| **Wallet Connect** | [Reown AppKit](https://reown.com/appkit) (WalletConnect v2) |
| **Wallet Custody** | Turnkey SDK |
| **Charts** | deriv_chart (custom fork) |
| **Serialization** | json_serializable + build_runner |

## License

This project is licensed under the [GNU Affero General Public License v3.0](LICENSE).
