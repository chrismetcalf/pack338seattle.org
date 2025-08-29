#!/bin/bash

echo "🚀 Setting up rbenv and Ruby for Pack 338 website..."
echo ""

# Check if we're in WSL (more flexible detection)
if [[ -f /proc/version ]] && grep -q Microsoft /proc/version; then
    echo "✅ WSL detected: $(grep -o 'Microsoft.*' /proc/version)"
elif [[ -f /proc/version ]] && grep -q WSL /proc/version; then
    echo "✅ WSL detected: $(grep -o 'WSL.*' /proc/version)"
elif [[ -f /proc/version ]] && grep -q microsoft /proc/version; then
    echo "✅ WSL detected: $(grep -o 'microsoft.*' /proc/version)"
elif [[ -n "$WSL_DISTRO_NAME" ]]; then
    echo "✅ WSL detected: $WSL_DISTRO_NAME"
else
    echo "⚠️  WSL detection unclear, but continuing anyway..."
    echo "   If you're sure you're in WSL, this should work fine"
fi

# Install system dependencies
echo "📦 Installing system dependencies..."
sudo apt update
sudo apt install -y git curl libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev

# Install rbenv
echo "📦 Installing rbenv..."
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

# Add rbenv to PATH
echo "🔧 Configuring rbenv..."
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc.local
echo 'eval "$(rbenv init -)"' >> ~/.zshrc.local

# Reload shell configuration
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Install Ruby
echo "📦 Installing Ruby 3.2.2..."
rbenv install 3.2.2
rbenv global 3.2.2

# Verify installation
echo "✅ Ruby installed: $(ruby --version)"

# Install Bundler
echo "📦 Installing Bundler..."
gem install bundler

echo ""
echo "🎉 rbenv setup complete!"
echo ""
echo "Next steps:"
echo "1. Close and reopen your terminal (or run: source ~/.zshrc.local)"
echo "2. Navigate to your project: cd /mnt/c/Users/hones/Source/pack338seattle.org"
echo "3. Install dependencies: bundle install"
echo "4. Start the server: bundle exec jekyll serve --host 0.0.0.0 --livereload"
echo ""
echo "Your Pack 338 website will be available at: http://localhost:4000"
