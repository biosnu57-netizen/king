#!/bin/bash

# PINC Network - Complete Development Environment Setup
# This script installs everything needed for full PINC Network development

set -e

echo "🚀 PINC Network Development Environment Setup"
echo "=============================================="

# Detect OS
OS=$(uname -s)
echo "Detected OS: $OS"

# Create development directory
mkdir -p ~/pinc-dev
cd ~/pinc-dev

echo ""
echo "📦 Installing Base Dependencies..."

# Ubuntu/Debian
if [ -f /etc/debian_version ]; then
    sudo apt update
    sudo apt install -y \
        git curl wget unzip \
        build-essential cmake \
        python3 python3-pip python3-venv \
        clang llvm \
        libssl-dev libffi-dev \
        protobuf-compiler \
        libudev-dev pkg-config \
        rustc cargo \
        nodejs npm \
        openjdk-17-jdk \
        ffmpeg libavcodec-extra

# CentOS/RHEL
elif [ -f /etc/redhat-release ]; then
    sudo yum groupinstall -y "Development Tools"
    sudo yum install -y \
        git curl wget unzip \
        python3 python3-pip \
        cmake clang llvm \
        openssl-devel \
        protobuf-compiler \
        rust cargo \
        nodejs npm \
        java-17-openjdk-devel \
        ffmpeg

# macOS
elif [ "$OS" = "Darwin" ]; then
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install \
        git curl wget \
        cmake llvm rust python3 nodejs \
        openjdk@17 ffmpeg \
        protobuf
fi

echo ""
echo "📦 Installing Flutter SDK..."

# Download and install Flutter
if ! command -v flutter &> /dev/null; then
    FLUTTER_DIR="$HOME/flutter"
    if [ ! -d "$FLUTTER_DIR" ]; then
        git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
    fi
    export PATH="$FLUTTER_DIR/bin:$PATH"
    flutter precache
    flutter doctor -v
else
    echo "Flutter already installed: $(flutter --version)"
fi

echo ""
echo "📦 Installing Node.js Tools..."

# Install nvm and Node.js
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js 20 LTS
nvm install 20
nvm use 20
nvm alias default 20

# Install global Node.js tools
npm install -g \
    typescript \
    ts-node \
    nodemon \
    pm2 \
    yarn \
    pnpm \
    @solana/web3.js \
    ethers \
    web3 \
    hardhat \
    truffle

echo ""
echo "📦 Installing Python Tools..."

# Install Python 3.11+ if needed
if ! command -v python3 &> /dev/null; then
    if [ -f /etc/debian_version ]; then
        sudo apt install -y python3.11 python3.11-venv python3.11-dev
    fi
fi

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python packages
pip install --upgrade pip setuptools wheel
pip install \
    flask fastapi uvicorn \
    eth-account eth-keys eth-typing \
    web3 py-solc-x \
    cryptography pycryptodome \
    scipy numpy pandas \
    flask-socketio eventlet \
    aiohttp aiofiles \
    docker-compose \
    pytest pytest-asyncio black isort

echo ""
echo "📦 Installing Blockchain & Crypto Tools..."

# Install Solidity compiler
solc-select install 0.8.20
solc-select use 0.8.20

# Install Rust tools for Solana
if command -v cargo &> /dev/null; then
    cargo install \
        solana-cli \
        anchor
fi

echo ""
echo "📦 Installing Android Development..."

# Android SDK
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

if [ ! -d "$ANDROID_HOME" ]; then
    mkdir -p "$ANDROID_HOME"
    cd "$ANDROID_HOME"
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip
    unzip -q cmdline-tools.zip
    mkdir -p cmdline-tools/latest
    mv cmdline-tools/bin cmdline-tools/lib cmdline-tools/latest/
    yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses
    "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-34" "build-tools;34.0.0"
fi

echo ""
echo "📦 Installing Media & Streaming Tools..."

# FFmpeg with extra codecs (already installed above)
# Install additional media tools
if [ -f /etc/debian_version ]; then
    sudo apt install -y \
        ffmpeg gpac \
        libopus-dev libvpx-dev libx264-dev libx265-dev \
        srtp-utils webrtc-audio-processing
fi

echo ""
echo "📦 Cloning PINC Network Repository..."

# Clone or update PINC Network
cd ~/pinc-dev
if [ -d "king" ]; then
    cd king
    git pull origin main
else
    git clone https://github.com/biosnu57-netizen/king.git
    cd king
fi

# Install Flutter dependencies
cd pinc-network/pinc_network
flutter pub get

echo ""
echo "📦 Creating Development Scripts..."

# Create convenient scripts
mkdir -p ~/pinc-dev/scripts

# Build script
cat > ~/pinc-dev/scripts/build.sh << 'EOF'
#!/bin/bash
cd ~/pinc-dev/king/pinc-network/pinc_network
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
flutter build apk --debug
echo "APK: build/app/outputs/flutter-apk/app-debug.apk"
EOF

# Run tests
cat > ~/pinc-dev/scripts/test.sh << 'EOF'
#!/bin/bash
cd ~/pinc-dev/king/pinc-network/pinc_network
flutter test
python3 -m pytest -v
EOF

# Run backend
cat > ~/pinc-dev/scripts/backend.sh << 'EOF'
#!/bin/bash
cd ~/pinc-dev/king/pinc-network/backend
source ~/pinc-dev/venv/bin/activate
python3 server.py
EOF

# Make scripts executable
chmod +x ~/pinc-dev/scripts/*.sh

echo ""
echo "✅ Setup Complete!"
echo ""
echo "📁 Project Location: ~/pinc-dev/king"
echo "📁 Scripts Location: ~/pinc-dev/scripts"
echo "📁 Python venv: ~/pinc-dev/venv"
echo ""
echo "Quick Commands:"
echo "  build       - Build APK: ~/pinc-dev/scripts/build.sh"
echo "  test        - Run tests: ~/pinc-dev/scripts/test.sh"
echo "  backend     - Run backend: ~/pinc-dev/scripts/backend.sh"
echo "  flutter     - Flutter CLI: ~/pinc-dev/king/pinc-network/pinc_network"
echo ""

# Add to PATH permanently
echo 'export PATH="$HOME/pinc-dev/scripts:$PATH"' >> ~/.bashrc
echo 'export ANDROID_HOME="$HOME/android-sdk"' >> ~/.bashrc
echo 'export FLUTTER_HOME="$HOME/flutter"' >> ~/.bashrc

echo "✅ All tools installed and saved locally!"
echo "   Next time you can work offline with: cd ~/pinc-dev/king"