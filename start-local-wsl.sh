#!/bin/bash

# WSL script to start Jekyll local development server
echo "🚀 Starting Jekyll server from WSL..."
echo ""

# Check if we're in WSL
if [[ ! -f /proc/version ]] || ! grep -q microsoft /proc/version; then
    echo "❌ This script is designed for WSL (Windows Subsystem for Linux)"
    echo "   Please run this from within WSL"
    exit 1
fi

# Check if Ruby is installed    
if ! command -v ruby &> /dev/null; then
    echo "📦 Ruby not found. Installing Ruby..."
    sudo apt update
    sudo apt install -y ruby-full build-essential
    echo "✅ Ruby installed successfully!"
else
    echo "✅ Ruby found: $(ruby --version)"
fi

# Check if Bundler is installed
if ! command -v bundle &> /dev/null; then
    echo "📦 Bundler not found. Installing Bundler..."
    gem install bundler
    echo "✅ Bundler installed successfully!"
else
    echo "✅ Bundler found: $(bundle --version)"
fi

echo ""
echo "📥 Installing dependencies..."
bundle install

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully!"
    echo ""
    echo "🌐 Starting Jekyll server..."
    echo "   Server will be available at: http://localhost:4000"
    echo "   Press Ctrl+C to stop the server"
    echo ""
    
    # Start Jekyll with localhost configuration
    bundle exec jekyll serve --host localhost --livereload
else
    echo "❌ Failed to install dependencies. Please check the error above."
    exit 1
fi
