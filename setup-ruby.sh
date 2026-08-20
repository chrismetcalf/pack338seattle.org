#!/usr/bin/env bash
#
# One-time setup: install a Ruby toolchain capable of building Jekyll 4.
#
# Uses rbenv so the project's Ruby is independent of the system package
# manager's (often older) Ruby. Safe to re-run — every step is idempotent.

set -euo pipefail

cd "$(dirname "$0")"

RUBY_VERSION="${RUBY_VERSION:-3.2.2}"

echo "🚀 Setting up Ruby ${RUBY_VERSION} for the Pack 338 website..."
echo ""

install_system_deps() {
    echo "📦 Installing build dependencies..."

    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y git curl autoconf bison build-essential \
            libssl-dev libreadline-dev zlib1g-dev libyaml-dev libncurses-dev \
            libffi-dev libgdbm-dev
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y git curl autoconf bison gcc make \
            openssl-devel readline-devel zlib-devel libyaml-devel ncurses-devel \
            libffi-devel gdbm-devel
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy --needed --noconfirm git curl base-devel \
            openssl readline zlib libyaml ncurses libffi gdbm
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y git curl autoconf bison gcc make \
            libopenssl-devel readline-devel zlib-devel libyaml-devel ncurses-devel \
            libffi-devel gdbm-devel
    elif command -v brew &> /dev/null; then
        brew install openssl readline libyaml gmp
    else
        echo "⚠️  Unrecognized package manager — install Ruby build dependencies yourself."
        echo "   See https://github.com/rbenv/ruby-build/wiki#suggested-build-environment"
    fi
}

install_rbenv() {
    if command -v rbenv &> /dev/null; then
        echo "✅ rbenv already installed: $(rbenv --version)"
        return
    fi

    if [[ -d "$HOME/.rbenv" ]]; then
        echo "✅ rbenv found at ~/.rbenv"
    else
        echo "📦 Installing rbenv..."
        git clone https://github.com/rbenv/rbenv.git "$HOME/.rbenv"
        git clone https://github.com/rbenv/ruby-build.git \
            "$HOME/.rbenv/plugins/ruby-build"
    fi

    export PATH="$HOME/.rbenv/bin:$PATH"
}

configure_shell() {
    # Append the rbenv init lines to the user's shell rc, but only once.
    local rc
    case "$(basename "${SHELL:-/bin/bash}")" in
        zsh)  rc="$HOME/.zshrc" ;;
        bash) rc="$HOME/.bashrc" ;;
        *)    rc="" ;;
    esac

    if [[ -z "$rc" ]]; then
        echo "⚠️  Unknown shell — add this to your shell startup file yourself:"
        echo '     export PATH="$HOME/.rbenv/bin:$PATH"'
        echo '     eval "$(rbenv init -)"'
        return
    fi

    if grep -q 'rbenv init' "$rc" 2>/dev/null; then
        echo "✅ rbenv already configured in $rc"
        return
    fi

    echo "🔧 Adding rbenv to $rc..."
    {
        echo ''
        echo '# rbenv (added by pack338seattle.org/setup-ruby.sh)'
        echo 'export PATH="$HOME/.rbenv/bin:$PATH"'
        echo 'eval "$(rbenv init -)"'
    } >> "$rc"
}

install_system_deps
install_rbenv
configure_shell

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

if rbenv versions --bare 2>/dev/null | grep -qx "$RUBY_VERSION"; then
    echo "✅ Ruby ${RUBY_VERSION} already installed"
else
    echo "📦 Installing Ruby ${RUBY_VERSION} (this takes a few minutes)..."
    rbenv install "$RUBY_VERSION"
fi

rbenv local "$RUBY_VERSION"
echo "✅ Ruby: $(ruby --version)"

if ! command -v bundle &> /dev/null; then
    echo "📦 Installing Bundler..."
    gem install bundler
fi

echo "📦 Installing project dependencies..."
bundle install

echo ""
echo "🎉 Setup complete."
echo ""
echo "Next steps:"
echo "  1. Open a new terminal (or: exec \$SHELL) so rbenv is on your PATH"
echo "  2. ./serve.sh              → http://localhost:4000"
echo "     ./serve.sh --tailscale  → also reachable from your tailnet"
echo ""
