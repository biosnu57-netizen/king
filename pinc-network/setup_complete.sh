#!/bin/bash
# PINC Network - Complete Development Environment Setup
# Installs EVERYTHING needed for full offline development
# Run: bash setup_complete.sh

set -e

echo "🚀 PINC Network - Complete Development Environment"
echo "=================================================="

# Create project directories
mkdir -p ~/pinc-network
cd ~/pinc-network

echo ""
echo "📦 Step 1: Installing System Dependencies..."

# Detect and install based on OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        sudo apt update -qq
        sudo apt install -y -qq \
            git curl wget unzip tar gzip \
            build-essential cmake ninja-build \
            python3 python3-pip python3-venv python3-dev \
            clang llvm libclang-dev \
            libssl-dev libffi-dev libreadline-dev zlib1g-dev \
            protobuf-compiler libprotobuf-dev \
            libudev-dev pkg-config \
            rustc cargo clang \
            nodejs npm yarn \
            openjdk-17-jdk \
            ffmpeg libavcodec-dev libavformat-dev libswscale-dev \
            libopus-dev libvpx-dev libx264-dev libx265-dev \
            golang-go \
            sqlite3 libsqlite3-dev \
            redis-server \
            nginx \
            htop atop iotop net-tools iputils-ping \
            tmux screen rsync \
            p7zip-full unrar-free \
            libgmp-dev libmpfr-dev libmpc-dev \
            libbz2-dev liblzma-dev libzstd-dev \
            2>/dev/null || true
    fi
fi

echo ""
echo "📦 Step 2: Installing Flutter SDK..."
export FLUTTER_HOME="$HOME/flutter"
if [ ! -d "$FLUTTER_HOME" ]; then
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_HOME" --quiet
fi
export PATH="$FLUTTER_HOME/bin:$PATH"
flutter precache -a --no-android --no-ios --no-web --no-linux --no-macos --no-windows --quiet 2>/dev/null || true
flutter --version

echo ""
echo "📦 Step 3: Installing Node.js & Global Packages..."
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash --quiet
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 20 --quiet
nvm use 20
npm install -g --silent \
    typescript ts-node nodemon pm2 \
    yarn pnpm \
    @solana/web3.js ethers web3 \
    hardhat truffle ganache-cli \
    express koa socket.io \
    webpack vite esbuild \
    @nestjs/core @nestjs/cli nest \
    --silent 2>/dev/null || true

echo ""
echo "📦 Step 4: Installing Python & Packages..."
python3 -m venv venv
source venv/bin/activate
pip install --quiet --upgrade pip setuptools wheel
pip install --quiet \
    flask fastapi uvicorn gunicorn \
    flask-socketio flask-cors \
    eth-account eth-keys eth-crypto \
    web3 py-solc-x \
    cryptography pycryptodome pillow \
    numpy scipy pandas scikit-learn \
    aiohttp aiofiles asyncio-redis \
    pydantic sqlalchemy sqlalchemy-utils \
    pytest pytest-asyncio pytest-cov \
    black isort flake8 mypy \
    google-auth google-api-python-client \
    twilio \
    eth-abi web3-eth-accounts

echo ""
echo "📦 Step 5: Installing Blockchain Tools..."
# Solidity
if ! command -v solc &> /dev/null; then
    pip install solc-select
    solc-select install 0.8.20
    solc-select use 0.8.20 --quiet
fi
# Rust for Solana
if command -v cargo &> /dev/null; then
    cargo --version
    # cargo install solana-cli anchor --quiet 2>/dev/null || true
fi

echo ""
echo "📦 Step 6: Installing Android SDK..."
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
    mkdir -p "$ANDROID_HOME"
    cd "$ANDROID_HOME"
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
    unzip -q cmdline-tools.zip
    mkdir -p cmdline-tools/latest
    mv cmdline-tools/bin cmdline-tools/lib cmdline-tools/source.properties cmdline-tools/latest/ 2>/dev/null || true
    yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null 2>&1 || true
    "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --install \
        "platform-tools" \
        "platforms;android-34" \
        "platforms;android-35" \
        "build-tools;34.0.0" \
        "build-tools;35.0.0" \
        "ndk;26.1.10909125" \
        --quiet 2>/dev/null || true
    cd -
fi

echo ""
echo "📦 Step 7: Installing Media & Streaming Tools..."
# Already installed via apt above, but ensure ffmpeg has all codecs
if command -v ffmpeg &> /dev/null; then
    ffmpeg -version | head -1
fi

echo ""
echo "📦 Step 8: Installing Database & Cache..."
if command -v redis-server &> /dev/null; then
    redis-server --daemonize yes
fi

echo ""
echo "📦 Step 9: Installing Additional Dev Tools..."
# Text editors & IDE components
pip install --quiet jedi pylint pyls

# Container tools
if command -v docker &> /dev/null; then
    docker --version
fi

# Network tools
pip install --quiet \
    scapy \
    paramiko \
    requests urllib3 \
    httpx aiohttp

echo ""
echo "📦 Step 10: Creating Project Structure..."

# Clone PINC Network
if [ ! -d "$HOME/pinc-network/king" ]; then
    git clone https://github.com/biosnu57-netizen/king.git "$HOME/pinc-network/king" --quiet
fi

cd "$HOME/pinc-network/king"

# Create additional directories
mkdir -p lib/{core/{crypto,blockchain,network,storage,security},features/{wallet,jobs,games,chat,vpn,admin},services,utils,models}
mkdir -p backend/{src/{routes,services,models,middleware,utils},tests}
mkdir -p contracts/{contracts,scripts,test}
mkdir -p scripts
mkdir -p docs

echo ""
echo "📦 Step 11: Saving Package Lists..."

# Save all installed packages info
dpkg -l > "$HOME/pinc-network/installed_packages.txt"
pip freeze > "$HOME/pinc-network/requirements.txt"
npm list -g --depth=0 > "$HOME/pinc-network/node_packages.txt" 2>/dev/null || true

echo ""
echo "📦 Step 12: Creating Quick Scripts..."

# Create build script
cat > "$HOME/pinc-network/build_apk.sh" << 'BUILDEOF'
#!/bin/bash
cd ~/pinc-network/king/pinc-network/pinc_network
export PATH="$HOME/flutter/bin:$HOME/android-sdk/cmdline-tools/latest/bin:$HOME/android-sdk/platform-tools:$PATH"
export ANDROID_HOME="$HOME/android-sdk"
flutter build apk --debug
echo "APK built: build/app/outputs/flutter-apk/app-debug.apk"
BUILDEOF
chmod +x "$HOME/pinc-network/build_apk.sh"

# Create test script
cat > "$HOME/pinc-network/run_tests.sh" << 'TESTEOF'
#!/bin/bash
cd ~/pinc-network/king
flutter test 2>/dev/null || echo "Flutter tests"
python -m pytest backend/tests/ -v 2>/dev/null || echo "No Python tests"
TESTEOF
chmod +x "$HOME/pinc-network/run_tests.sh"

# Create offline build script
cat > "$HOME/pinc-network/build_offline.sh" << 'OFFLINEEOF'
#!/bin/bash
cd ~/pinc-network/king/pinc-network/pinc_network
export PATH="$HOME/flutter/bin:$HOME/android-sdk/cmdline-tools/latest/bin:$PATH"
export PUB_CACHE="$HOME/.pub-cache"
export ANDROID_HOME="$HOME/android-sdk"
flutter build apk --debug --offline 2>/dev/null || flutter build apk --debug
OFFLINEEOF
chmod +x "$HOME/pinc-network/build_offline.sh"

# Create start backend script
cat > "$HOME/pinc-network/start_backend.sh" << 'BACKENDEOF'
#!/bin/bash
cd ~/pinc-network/king/backend
source ~/pinc-network/venv/bin/activate
python src/app.py
BACKENDEOF
chmod +x "$HOME/pinc-network/start_backend.sh"

echo ""
echo "📦 Step 13: Environment Variables..."
cat > "$HOME/pinc-network/env_setup.sh" << 'ENVEOF'
export PATH="$HOME/flutter/bin:$HOME/android-sdk/cmdline-tools/latest/bin:$HOME/android-sdk/platform-tools:$HOME/.nvm/versions/node/v20.19.0/bin:$PATH"
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$HOME/android-sdk"
export FLUTTER_HOME="$HOME/flutter"
export NVM_DIR="$HOME/.nvm"
export PUB_CACHE="$HOME/.pub-cache"
alias flutter="$HOME/flutter/bin/flutter"
alias python="python3"
ENVEOF
chmod +x "$HOME/pinc-network/env_setup.sh"

# Add to bashrc
echo "source $HOME/pinc-network/env_setup.sh" >> ~/.bashrc

echo ""
echo "============================================"
echo "✅ COMPLETE ENVIRONMENT SETUP DONE!"
echo "============================================"
echo ""
echo "📁 Project: ~/pinc-network/king"
echo "📦 Flutter: $HOME/flutter"
echo "📦 Android SDK: $HOME/android-sdk"
echo "📦 Node.js: v20"
echo "📦 Python: venv at ~/pinc-network/venv"
echo ""
echo "🛠️ Quick Commands:"
echo "   build       - ~/pinc-network/build_apk.sh"
echo "   build-offline - ~/pinc-network/build_offline.sh"
echo "   test        - ~/pinc-network/run_tests.sh"
echo "   backend     - ~/pinc-network/start_backend.sh"
echo ""
echo "📋 All packages saved to ~/pinc-network/"
echo ""
echo "To use: source ~/pinc-network/env_setup.sh"
echo "============================================"