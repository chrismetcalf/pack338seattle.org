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

Developed and deployed on Linux. macOS works too; the setup script covers both.

### Prerequisites

- **Ruby 3.2** (Jekyll 4.3 needs 2.7+; CI builds on 3.2)
- **Bundler** (`gem install bundler`)

If you don't already have a suitable Ruby, `./setup-ruby.sh` installs one via
rbenv along with the build dependencies for your distro (apt, dnf, pacman,
zypper, or Homebrew).

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/pack338seattle.org.git
   cd pack338seattle.org
   ```

2. **Install Ruby and dependencies**
   ```bash
   ./setup-ruby.sh        # only needed once, per machine
   ```
   Already have Ruby 3.2 and Bundler? Just run `bundle install`.

3. **Start the local server**
   ```bash
   ./serve.sh
   ```

4. **View your site**
   Open `http://localhost:4000`

### Viewing from another device

```bash
./serve.sh --tailscale   # reachable from any device on your tailnet
./serve.sh --lan         # reachable from anything on the local network
```

`--tailscale` prints the MagicDNS URL (e.g. `http://my-box.your-tailnet.ts.net:4000/`)
so you can pull the site up on a phone to check the mobile layout. It requires
the `tailscale` CLI and an active connection (`tailscale up`).

### Development Commands

```bash
# Serve with live reload (default)
./serve.sh
PORT=4001 ./serve.sh          # different port

# Build the site
bundle exec jekyll build

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
├── signup.html          # Standalone mailing-list signup page
├── serve.sh             # Dev server (localhost / --tailscale / --lan)
├── setup-ruby.sh        # One-time Ruby + rbenv install
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
PORT=4001 ./serve.sh
```

**Dependency issues**
```bash
# Update bundler
gem update bundler
# Reinstall dependencies
bundle install
```

**`bundle install` fails to build native gems**

You're missing build headers. Re-run `./setup-ruby.sh`, which installs them for
your distro, or see the
[ruby-build wiki](https://github.com/rbenv/ruby-build/wiki#suggested-build-environment).

**`--tailscale` says Tailscale isn't connected**
```bash
tailscale status    # check state
tailscale up        # connect
```

## 📧 Newsletter Integration

The Groups.io signup form lives in `_includes/signup-form.html` and is used by
both the homepage and `/signup/`. Its URLs come from `_data/pack.yml`, so
changing the group or the signup link is a one-line edit there.

The hidden `b_...` field is an anti-bot honeypot — leave it in place.

## 📅 Upcoming Events

Events on the homepage are pulled from the Groups.io calendar **at build time**,
not in the visitor's browser:

1. `.github/workflows/update-events.yml` runs daily and calls
   `script/fetch-events.rb`
2. That script fetches the `.ics` feed and writes `_data/events.yml`
3. `_includes/upcoming-events.html` renders it — no JavaScript, no CORS proxies

To refresh events locally:

```bash
TZ=America/Los_Angeles ruby script/fetch-events.rb
```

When the calendar has no future events (typical over the summer, between
scouting years), the widget shows the regular meeting pattern from
`_data/pack.yml` and points families at the mailing list. **Posting the coming
year's dates in Groups.io is what makes events appear** — no code change needed.

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
