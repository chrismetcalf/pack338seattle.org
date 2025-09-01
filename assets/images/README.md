# Images Directory

This directory contains images and icons for the Pack 338 website.

## Recommended Images

- **Hero Banner**: A high-quality banner image (1920x1080 or larger) for the top of the homepage
- **Favicon**: A 16x16 or 32x32 pixel icon file (`.ico` format recommended)
- **Pack Photos**: Images of scouts in action, camping trips, activities, etc.
- **Logo**: Pack 338 logo or branding images

## Image Guidelines

- **Formats**: Use `.jpg`, `.png`, or `.webp` for photos, `.svg` for icons
- **Optimization**: Compress images for web use to improve loading speed
- **Dimensions**: Use appropriate sizes for different sections
- **Alt Text**: Always provide descriptive alt text for accessibility

## Adding Images

1. Place your image files in this directory
2. Reference them in your HTML/CSS using relative paths:
   ```html
   <img src="{{ '/assets/images/your-image.jpg' | relative_url }}" alt="Description">
   ```
3. For CSS backgrounds:
   ```css
   background-image: url('../images/your-image.jpg');
   ```

## Current Images

- `favicon.ico` - Website favicon (if added)
- Add your images here!

## Tips

- Use descriptive filenames (e.g., `pack-camping-trip-2024.jpg`)
- Consider creating different sizes for responsive design
- Keep file sizes under 500KB for optimal performance

