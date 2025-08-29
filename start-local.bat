@echo off
echo Starting Jekyll local development server...
echo.
echo This will start the website at http://localhost:4000
echo Press Ctrl+C to stop the server
echo.
echo Installing dependencies first...
bundle install
echo.
echo Starting server...
bundle exec jekyll serve --livereload
pause
