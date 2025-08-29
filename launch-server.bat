@echo off
echo Starting Pack 338 Jekyll Server...
echo.

REM Check if we're in the right directory
if not exist "_config.yml" (
    echo Error: Please run this script from the Pack 338 project directory
    echo Current directory: %CD%
    echo Expected files: _config.yml, Gemfile
    echo.
    echo Navigate to your project first:
    echo cd C:\Users\hones\Source\pack338seattle.org
    pause
    exit /b 1
)

if not exist "Gemfile" (
    echo Error: Gemfile not found
    echo Please run this script from the Pack 338 project directory
    pause
    exit /b 1
)

echo Starting Jekyll server...
echo Server will be available at: http://localhost:4000
echo Press Ctrl+C to stop the server
echo.

REM Start the server
bundle exec jekyll serve --livereload

pause
