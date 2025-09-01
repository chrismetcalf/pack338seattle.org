# Cub Scout Pack 338 Seattle - Website

A modern, responsive Jekyll website for Cub Scout Pack 338 in Seattle, WA. Built with Bootstrap 5, Font Awesome icons, and custom CSS animations.

## 🏕️ About Pack 338

Cub Scout Pack 338 is open to kids of any gender from Kindergarten through 5th grade. We meet at Our Lady of the Lake Catholic School in Seattle, WA, and offer exciting activities including rocket launches, Pinewood Derby racing, camping trips, and more!

## 🚀 Features

- **Responsive Design**: Mobile-first design that works on all devices
- **Modern UI**: Clean, professional design with smooth animations
- **Newsletter Signup**: Integrated Groups.io signup form
- **Interactive Elements**: Hover effects, smooth scrolling, and dynamic navigation
- **SEO Optimized**: Proper meta tags and semantic HTML structure
- **Fast Loading**: Optimized CSS and JavaScript for performance

## 🛠️ Local Development Setup

### Prerequisites

- **Ruby** (version 2.6 or higher)
- **RubyGems**
- **Bundler** (install with `gem install bundler`)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/pack338seattle.org.git
   cd pack338seattle.org
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Start the local server**
   ```bash
   bundle exec jekyll serve
   ```

4. **View your site**
   Open your browser and navigate to `http://localhost:4000`

### Development Commands

```bash
# Build the site
bundle exec jekyll build

# Build and serve with live reload
bundle exec jekyll serve --livereload

# Build for production
JEKYLL_ENV=production bundle exec jekyll build

# Clean build cache
bundle exec jekyll clean
```

## 📁 Project Structure

```
pack338seattle.org/
├── _config.yml          # Jekyll configuration
├── _layouts/            # HTML layout templates
│   └── default.html     # Main layout template
├── assets/              # Static assets
│   ├── css/            # Stylesheets
│   │   └── style.css   # Custom CSS
│   ├── js/             # JavaScript files
│   │   └── main.js     # Main JavaScript
│   └── images/         # Images and icons
├── index.html           # Homepage content
├── Gemfile             # Ruby dependencies
└── README.md           # This file
```

## 🎨 Customization

### Colors
The website uses CSS custom properties for easy color customization. Edit the `:root` section in `assets/css/style.css`:

```css
:root {
    --primary-color: #1e3a8a;    /* Main brand color */
    --secondary-color: #3b82f6;  /* Secondary brand color */
    --accent-color: #f59e0b;     /* Accent/highlight color */
    --success-color: #10b981;    /* Success/green color */
    --danger-color: #ef4444;     /* Danger/error color */
}
```

### Content Updates
- **Homepage**: Edit `index.html` to modify sections and content
- **Styling**: Modify `assets/css/style.css` for visual changes
- **Functionality**: Update `assets/js/main.js` for interactive features

### Adding New Pages
1. Create a new `.html` or `.md` file in the root directory
2. Add front matter with layout and metadata
3. Add navigation links in `_layouts/default.html`

## 🌐 GitHub Pages Deployment

### Automatic Deployment (Recommended)

1. **Push to main branch**: The site will automatically build and deploy
2. **GitHub Actions**: Uses the default GitHub Pages build process
3. **Custom domain**: Set `pack338seattle.org` in repository settings

### Manual Deployment

1. **Build the site**
   ```bash
   bundle exec jekyll build
   ```

2. **Deploy to GitHub Pages**
   ```bash
   # Add, commit, and push changes
   git add .
   git commit -m "Update website content"
   git push origin main
   ```

3. **Wait for deployment**: GitHub Pages will automatically rebuild and deploy

## 📱 Responsive Design

The website is built with a mobile-first approach and includes:

- **Bootstrap 5**: Responsive grid system and components
- **Custom Media Queries**: Optimized for various screen sizes
- **Touch-Friendly**: Optimized for mobile devices
- **Performance**: Fast loading on all devices

## 🔧 Troubleshooting

### Common Issues

**Jekyll build errors**
```bash
# Clear Jekyll cache
bundle exec jekyll clean
# Reinstall dependencies
bundle install
```

**Port conflicts**
```bash
# Use a different port
bundle exec jekyll serve --port 4001
```

**Dependency issues**
```bash
# Update bundler
gem update bundler
# Reinstall dependencies
bundle install
```

### Windows-Specific Notes

- Install Ruby with [RubyInstaller](https://rubyinstaller.org/)
- Use PowerShell or Command Prompt (not Git Bash)
- Install the MSYS2 development toolchain when prompted

## 📧 Newsletter Integration

The website includes a Groups.io newsletter signup form. To modify:

1. **Update form action**: Edit the form action URL in `index.html`
2. **Styling**: Modify the CSS in the newsletter section
3. **Form fields**: Add/remove fields as needed

## 🚀 Performance Optimization

- **Minified CSS/JS**: Consider minifying for production
- **Image optimization**: Compress images before adding to `assets/images/`
- **CDN usage**: Bootstrap and Font Awesome are loaded from CDNs
- **Lazy loading**: Consider implementing for images if needed

## 📄 License

This project is for Cub Scout Pack 338 Seattle. All rights reserved.

## 🤝 Contributing

To contribute to the website:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `bundle exec jekyll serve`
5. Submit a pull request

## 📞 Support

For questions about the website or Pack 338:

- **Email**: [leadership@pack338seattle.org](mailto:leadership@pack338seattle.org)
- **Website**: [pack338seattle.org](https://pack338seattle.org)
- **Location**: Our Lady of the Lake Catholic School, 3520 NE 89th St, Seattle, WA 98115

---

**Built with ❤️ for Cub Scout Pack 338 Seattle**
