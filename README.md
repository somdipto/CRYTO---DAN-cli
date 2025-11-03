# 🤖 DANTO - Universal Agentic Trading OS

<div align="center">

[![Go Version](https://img.shields.io/badge/Go-1.21+-00ADD8?style=for-the-badge&logo=go)](https://golang.org/)
[![React](https://img.shields.io/badge/React-18+-61DAFB?style=for-the-badge&logo=react)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-3178C6?style=for-the-badge&logo=typescript)](https://www.typescriptlang.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

[![AI Providers](https://img.shields.io/badge/AI_Providers-4-purple.svg?style=for-the-badge)](#-ai-providers)
[![Exchanges](https://img.shields.io/badge/Exchanges-4-blue.svg?style=for-the-badge)](#-supported-exchanges)
[![Backed by Amber.ac](https://img.shields.io/badge/Backed_by-Amber.ac-orange.svg?style=for-the-badge)](https://amber.ac)

**The world's first universal AI trading operating system with self-learning capabilities**

[🚀 Quick Start](#-quick-start) • [📖 Documentation](INTEGRATION_GUIDE.md)

</div>

---

## 🎯 What is DANTO?

DANTO revolutionizes algorithmic trading through **AI agents that learn, compete, and evolve**. Our closed-loop system enables multiple AI models to trade across exchanges while continuously improving their strategies based on real performance data.

### ⚡ Quick Start (3 Minutes)

```bash
# 1. Clone & Setup
git clone https://github.com/somdipto/DANTO.git && cd DANTO

# 2. Configure (add your API keys)
cp config.json.example config.json && nano config.json

# 3. Start with Docker
./start.sh start --build

# 4. Access Dashboard
open http://localhost:3000
```

---

## 🏗️ System Architecture

```mermaid
graph TB
    subgraph "🌐 Web Interface"
        UI[React Dashboard]
        Charts[Real-time Charts]
        Logs[AI Decision Logs]
    end
    
    subgraph "🔌 API Layer"
        REST[REST API]
        WS[WebSocket]
        MGR[Multi-Trader Manager]
    end
    
    subgraph "🤖 AI Decision Engine"
        MM[MiniMax M2<br/>FREE]
        DS[DeepSeek<br/>$0.14/1M]
        QW[Qwen<br/>$0.20/1M]
        GPT[GPT-4<br/>$10/1M]
    end
    
    subgraph "⚡ Trading Engine"
        BIN[Binance Futures]
        DEL[Delta Exchange]
        HYP[Hyperliquid DEX]
        AST[Aster DEX]
    end
    
    subgraph "📊 Market Data"
        PRICE[Price Feeds]
        TECH[Technical Indicators]
        OI[Open Interest]
    end
    
    subgraph "🛡️ Risk Management"
        POS[Position Limits]
        STOP[Stop Loss/Take Profit]
        MAR[Margin Control]
    end
    
    UI --> REST
    Charts --> WS
    Logs --> REST
    
    REST --> MGR
    WS --> MGR
    MGR --> MM
    MGR --> DS
    MGR --> QW
    MGR --> GPT
    
    MM --> BIN
    DS --> DEL
    QW --> HYP
    GPT --> AST
    
    BIN --> PRICE
    DEL --> TECH
    HYP --> OI
    
    MGR --> POS
    MGR --> STOP
    MGR --> MAR
    
    style MM fill:#90EE90
    style DS fill:#87CEEB
    style QW fill:#DDA0DD
    style GPT fill:#F0E68C
```

---

## 🤖 AI Providers

| Provider | Cost | Speed | Quality | Free Tier | Best For |
|----------|------|-------|---------|-----------|----------|
| **🆓 MiniMax M2** | **FREE** | ⚡ Fast | ⭐⭐⭐⭐ | ✅ Unlimited | **Beginners** |
| **💎 DeepSeek** | $0.14/1M | ⚡ Fast | ⭐⭐⭐⭐⭐ | ❌ | **Performance** |
| **🔥 Qwen** | $0.20/1M | 🔄 Medium | ⭐⭐⭐⭐ | ❌ | **Reliability** |
| **🚀 GPT-4** | $10/1M | 🔄 Medium | ⭐⭐⭐⭐⭐ | ❌ | **Maximum Quality** |

---

## 🏦 Supported Exchanges

<div align="center">

| Exchange | Type | Leverage | Features |
|----------|------|----------|----------|
| **🟡 Binance** | CEX | 125x | Highest liquidity, 200+ pairs |
| **🟠 Delta** | CEX | 100x | Advanced derivatives, options |
| **🔵 Hyperliquid** | DEX | 50x | No KYC, on-chain settlement |
| **🟢 Aster** | DEX | 20x | Multi-chain, API wallet security |

</div>

---

## 🏆 Key Features

<div align="center">

### 🧠 **Multi-Agent Competition**
AI models compete in real-time, learning from wins and losses

### 📊 **Professional Interface**
Binance-style dashboard with real-time charts and analytics

### ⚡ **Advanced Risk Management**
AI-driven position sizing with multi-layer protection

### 🔄 **Self-Learning System**
Historical analysis and strategy adaptation

</div>

---

## 📝 Configuration Examples

### Beginner Setup (Free AI)
```json
{
  "traders": [{
    "id": "my_trader",
    "ai_model": "minimax",
    "exchange": "binance",
    "minimax_key": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJHcm91cE5hbWUiOiJTb2RhbiBNb3MiLCJVc2VyTmFtZSI6IlNvZGFuIE1vcyIsIkFjY291bnQiOiIiLCJTdWJqZWN0SUQiOiIxOTg0OTA1ODg3MzU3MDgzNzY3IiwiUGhvbmUiOiIiLCJHcm91cElEIjoiMTk4NDkwNTg4NzM1Mjg4NTM2NyIsIlBhZ2VOYW1lIjoiIiwiTWFpbCI6InN4dm9jdXNhQGdtYWlsLmNvbSIsIkNyZWF0ZVRpbWUiOiIyMDI1LTExLTAyIDE3OjI1OjE1IiwiVG9rZW5UeXBlIjoxLCJpc3MiOiJtaW5pbWF4In0.HmT0S2cjLzUtaX7nk10Qd9vfg76KWCrcaensHzLj0bebgLJyta9TyU1vDhC42pWW_XEd0L18Ui4rJOGwwupV0gLO6xhVMsHoWZkySb9w6XAVNO6R3nyrTuAvz4mI0a-R2RYEr7XRiXLlvdNSN72gPifC49vcaI_3THmJTVllHwtE5UnSS3OPBnY4eWy-Slo1dNGcfCmJ4zhBdTluVKaL-yk9q4XF8PRxJN9IyebdVvivhu1SyQNdvJ9Qyvg-aQYPfIr3No9ATnvXvS3vMT72IbI9TnuYhCnMQUQfPFa5Cra4OAupjarENnO6NUJVKWs-G6l_owSggvHWJD_YN06HmA",
    "binance_api_key": "your_binance_key",
    "binance_secret_key": "your_binance_secret",
    "initial_balance": 1000
  }]
}
```

### Multi-Agent Competition
```json
{
  "traders": [
    {
      "id": "deepseek_binance",
      "ai_model": "deepseek",
      "exchange": "binance"
    },
    {
      "id": "minimax_delta",
      "ai_model": "minimax", 
      "exchange": "delta"
    }
  ]
}
```

---

## 🚀 Getting Started

### Prerequisites
- **Trading Account**: [Binance](https://www.binance.com/join?ref=TINKLEVIP) | [Delta Exchange](https://www.delta.exchange) | [Hyperliquid](https://hyperliquid.xyz) | [Aster DEX](https://www.asterdex.com)
- **AI API Key**: [MiniMax (FREE)](https://api.minimax.io) | [DeepSeek](https://platform.deepseek.com) | [Qwen](https://dashscope.aliyuncs.com)

### Installation

#### 🐳 Docker (Recommended)
```bash
git clone https://github.com/somdipto/DANTO.git && cd DANTO
cp config.json.example config.json
# Edit config.json with your API keys
./start.sh start --build
```

#### ⚙️ Manual Setup
<details>
<summary>Click to expand manual installation</summary>

**Requirements:** Go 1.21+, Node.js 18+, TA-Lib

```bash
# Install TA-Lib
brew install ta-lib  # macOS
sudo apt-get install libta-lib0-dev  # Ubuntu

# Setup
go mod download
cd web && npm install && cd ..
cp config.json.example config.json
# Edit config.json
go build -o danto && ./danto
```
</details>

---

## 📸 Screenshots

<div align="center">

### 🏆 Competition Dashboard
![Competition](screenshots/competition-page.png)
*Real-time AI battle with performance leaderboards*

### 📊 Trading Interface  
![Trading](screenshots/details-page.png)
*Professional dashboard with equity curves and decision logs*

</div>

---

## 🆕 Latest Updates

### 🚀 **MiniMax M2 Integration** - Completely FREE AI!
- ✅ Zero API costs - Perfect for beginners
- ✅ Anthropic Claude compatibility
- ✅ No rate limits - Trade as much as you want

### 🟠 **Delta Exchange Support** - Advanced Derivatives
- ✅ Options, futures, perpetuals
- ✅ Up to 100x leverage
- ✅ Global access with competitive fees

---

## 🏢 Team & Backing

<div align="center">

**Backed by [Amber.ac](https://amber.ac)**

**Core Team:**
- **Tinkle** - [@Web3Tinkle](https://x.com/Web3Tinkle) - CEO & Co-founder
- **Zack** - [@0x_ZackH](https://x.com/0x_ZackH) - CTO & Co-founder

**🚀 Seed Round Open** - Building the future of AI trading

</div>

---

## 🌐 Community & Support

<div align="center">

[![Telegram](https://img.shields.io/badge/Telegram-Community-blue?style=for-the-badge&logo=telegram)](https://t.me/nofx_dev_community)
[![Twitter](https://img.shields.io/badge/Twitter-Updates-1DA1F2?style=for-the-badge&logo=twitter)](https://x.com/nofx_ai)
[![Documentation](https://img.shields.io/badge/Docs-Integration_Guide-green?style=for-the-badge&logo=gitbook)](INTEGRATION_GUIDE.md)
[![Issues](https://img.shields.io/badge/GitHub-Issues-red?style=for-the-badge&logo=github)](https://github.com/somdipto/DANTO/issues)

</div>

---

## ⚠️ Risk Warning

> **AI trading involves significant risk. Only use funds you can afford to lose. Start with small amounts for testing. Past performance doesn't guarantee future results.**

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

---

<div align="center">

**⭐ Star this repo if you find it useful!**

Made with ❤️ by the DANTO team

</div>
