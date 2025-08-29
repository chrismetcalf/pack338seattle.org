#!/bin/bash

echo "🚀 Launching Pack 338 Jekyll Server..."
echo ""

# Check if we're in the right directory
if [[ ! -f "_config.yml" ]] || [[ ! -f "Gemfile" ]]; then
    echo "❌ Please run this script from the Pack 338 project directory"
    echo "   Current directory: $(pwd)"
    echo "   Expected files: _config.yml, Gemfile"
    echo ""
    echo "   Navigate to your project first:"
    echo "   cd /mnt/c/Users/hones/Source/pack338seattle.org"
    exit 1
fi

# Check if Ruby/rbenv is available
if ! command -v ruby &> /dev/null; then
    echo "❌ Ruby not found. Please run setup-rbenv-wsl.sh first"
    exit 1
fi

echo "✅ Ruby found: $(ruby --version)"
echo "✅ Project directory: $(pwd)"
echo ""

# Check if dependencies are installed
if [[ ! -d "vendor" ]] && [[ ! -f "Gemfile.lock" ]]; then
    echo "📦 Installing dependencies..."
    bundle install
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install dependencies"
        exit 1
    fi
    echo "✅ Dependencies installed"
    echo ""
fi

echo "🌐 Starting Jekyll server..."
echo "   Server will be available at: http://localhost:4000"
echo "   Press Ctrl+C to stop the server"
echo ""

# Start the server
bundle exec jekyll serve --host 0.0.0.0 --livereload
