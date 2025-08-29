# PowerShell script to start Jekyll local development server
Write-Host "Starting Jekyll local development server..." -ForegroundColor Green
Write-Host ""
Write-Host "This will start the website at http://localhost:4000" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Check if Ruby is installed
try {
    $rubyVersion = ruby --version 2>$null
    if ($rubyVersion) {
        Write-Host "Ruby found: $rubyVersion" -ForegroundColor Green
    }
} catch {
    Write-Host "Ruby not found. Please install Ruby first." -ForegroundColor Red
    Write-Host "Download from: https://rubyinstaller.org/" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if Bundler is installed
try {
    $bundlerVersion = bundler --version 2>$null
    if ($bundlerVersion) {
        Write-Host "Bundler found: $bundlerVersion" -ForegroundColor Green
    }
} catch {
    Write-Host "Bundler not found. Installing..." -ForegroundColor Yellow
    gem install bundler
}

Write-Host ""
Write-Host "Installing dependencies..." -ForegroundColor Yellow
bundle install

if ($LASTEXITCODE -eq 0) {
    Write-Host "Dependencies installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Starting server..." -ForegroundColor Yellow
    bundle exec jekyll serve --livereload
} else {
    Write-Host "Failed to install dependencies. Please check the error above." -ForegroundColor Red
    Read-Host "Press Enter to exit"
}
