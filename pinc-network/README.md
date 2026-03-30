# PINC Network - Development Guide

A decentralized privacy-focused platform with mesh VPN, PINC cryptocurrency, and more.

## Quick Start

### Prerequisites
- Flutter SDK (3.24+)
- Android SDK
- Node.js (for web prototyping)

### Build Steps

```bash
# Clone repository
git clone https://github.com/biosnu57-netizen/king.git
cd king

# Navigate to project
cd pinc-network

# Create Flutter project (when Flutter is available)
mkdir -p pinc_network/lib/{core,features}

# Or build web prototype
npm create vite@latest web-app -- --template react
```

### Development Roadmap

#### Day 1-2: Foundation
- [x] SPEC.md specification
- [ ] Flutter project setup
- [ ] Core UI theme
- [ ] Navigation system

#### Day 3-4: Core Features
- [ ] VPN service UI
- [ ] Wallet UI
- [ ] Authentication

#### Day 5-6: Networking
- [ ] P2P mesh networking
- [ ] Node discovery
- [ ] IP preservation

#### Day 7+: Advanced Features
- [ ] Encrypted messaging
- [ ] Voice/Video calls
- [ ] Community features
- [ ] Jobs marketplace
- [ ] Gaming platform

## Features

| Feature | Status |
|---------|--------|
| Mesh VPN | UI Ready |
| PINC Wallet | UI Ready |
| Privacy Protection | Planned |
| Encrypted Calls | Planned |
| Remote Jobs | Planned |
| Gaming & Betting | Planned |

## Tech Stack

- **Frontend**: Flutter (cross-platform)
- **Backend**: None (decentralized P2P)
- **Encryption**: AES-256, Signal Protocol
- **Networking**: libp2p

## Architecture

```
pinc-network/
├── SPEC.md           # Full specification
├── README.md         # This file
└── pinc_network/     # Flutter app (create with Flutter)
    └── lib/
        ├── main.dart
        ├── core/          # Theme, constants, widgets
        └── features/      # Feature modules
            ├── vpn/
            ├── wallet/
            ├── community/
            ├── jobs/
            ├── games/
            └── profile/
```

## Key Concepts

### IP Preservation
When user in Iran uses internet from node in Kenya:
1. Traffic routes through Kenya node
2. Websites see Kenya IP
3. User's real IP stays hidden

### PINC Coin
- Built-in cryptocurrency
- Earned by sharing bandwidth
- Used for payments in app

### Mesh Networking
- No central servers
- Every device is a node
- Global internet sharing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - Build for the community!

---

**Created by:** biosnu57-netizen (Kenya)  
**Platform:** Decentralized privacy-first network  
**Status:** MVP Specification Complete