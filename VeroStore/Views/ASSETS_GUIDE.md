# Working with Images in Assets.xcassets

## How to Add Images to Your Xcode Project

### Step 1: Add Image to Assets Catalog

1. **Open Assets.xcassets** in Xcode (in the Project Navigator)
2. **Right-click** in the empty space and select **"New Image Set"** (or click the `+` button at the bottom)
3. **Rename** the image set (e.g., "logo", "banner", "product-placeholder")
4. **Drag and drop** your image file into the appropriate slot:
   - **1x** - Base resolution (e.g., 100x100px)
   - **2x** - Retina resolution (e.g., 200x200px) ⭐️ Most common
   - **3x** - Super Retina resolution (e.g., 300x300px)

### Step 2: Use the Image in SwiftUI

**✅ CORRECT WAY:**
```swift
Image("logo")  // No .png or .jpg extension!
    .resizable()
    .frame(width: 120, height: 120)
```

**❌ WRONG WAY:**
```swift
Image("logo.png")  // DON'T include extension
Image(uiImage: UIImage(named: "logo.png") ?? UIImage())  // Unnecessarily complex
```

---

## Common Image Use Cases

### 1. Logo in Splash Screen
```swift
Image("logo")
    .resizable()
    .aspectRatio(contentMode: .fit)
    .frame(width: 120, height: 120)
    .cornerRadius(24)
    .shadow(color: .appPrimary.opacity(0.3), radius: 20, x: 0, y: 10)
```

### 2. App Icon / Brand Logo
```swift
Image("app-icon")
    .resizable()
    .aspectRatio(contentMode: .fit)
    .frame(width: 60, height: 60)
    .clipShape(Circle())
```

### 3. Placeholder Image
```swift
Image("placeholder")
    .resizable()
    .aspectRatio(contentMode: .fill)
    .frame(width: 200, height: 200)
    .clipped()
```

### 4. Icon/Symbol (with tint color)
```swift
Image("custom-icon")
    .resizable()
    .renderingMode(.template)  // Makes it tintable
    .foregroundColor(.appPrimary)
    .frame(width: 24, height: 24)
```

### 5. Background Image
```swift
ZStack {
    Image("background")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .ignoresSafeArea()
    
    // Your content here
}
```

---

## Image Resolution Guide

### Recommended Sizes for Different Use Cases:

| Use Case | 1x | 2x (Recommended) | 3x |
|----------|----|-----------------|----|
| App Icon | 60x60 | 120x120 | 180x180 |
| Tab Bar Icon | 25x25 | 50x50 | 75x75 |
| Navigation Bar Icon | 22x22 | 44x44 | 66x66 |
| Small Icon | 20x20 | 40x40 | 60x60 |
| Logo | 50x50 | 100x100 | 150x150 |
| Product Thumbnail | 100x100 | 200x200 | 300x300 |
| Banner | 400x150 | 800x300 | 1200x450 |
| Full Screen | 375x667 | 750x1334 | 1125x2001 |

**Pro Tip:** Usually you only need to provide **@2x** version. iOS will scale it automatically.

---

## Image Formats Supported

- ✅ **PNG** - Best for logos, icons, images with transparency
- ✅ **JPEG/JPG** - Best for photos, backgrounds
- ✅ **PDF** (Vector) - Scalable, great for icons (check "Preserve Vector Data")
- ✅ **HEIC** - High efficiency image format
- ❌ SVG - Not directly supported (convert to PDF first)

---

## Asset Catalog Features

### 1. Preserve Vector Data (for PDF images)
- Check "Preserve Vector Data" in Attributes Inspector
- Image scales perfectly to any size
- Great for icons and logos

### 2. Dark Mode Support
Right-click image set → Show in Finder → Add "Dark Appearance":
```
- logo (Light mode)
- logo-dark (Dark mode)
```

Then in code:
```swift
Image("logo")  // Automatically switches based on appearance
```

### 3. Localization
Add localized versions for different languages:
- Select image set
- Attributes Inspector → Localization
- Add languages

---

## Troubleshooting

### Problem: Image Not Showing

**Check 1: Correct Name**
```swift
// If your asset is named "logo" (without extension)
Image("logo")  // ✅ Correct
Image("logo.png")  // ❌ Wrong
```

**Check 2: Target Membership**
- Click on Assets.xcassets in Project Navigator
- File Inspector → Target Membership
- Make sure your app target is checked ✅

**Check 3: Build**
- Clean Build Folder: `Cmd + Shift + K`
- Rebuild: `Cmd + B`

**Check 4: Asset Name**
- No spaces (use dashes: "app-logo" not "app logo")
- Lowercase recommended
- No special characters except dash `-` and underscore `_`

### Problem: Image is Blurry

**Solution 1: Use @2x or @3x versions**
```
logo.png → 100x100 (1x)
logo@2x.png → 200x200 (2x) ⭐️ Use this
logo@3x.png → 300x300 (3x)
```

**Solution 2: Use PDF for vector images**
- Export your logo as PDF
- Drag into Assets
- Check "Preserve Vector Data"

### Problem: Image is Stretched/Distorted

**Solution: Use correct aspect ratio mode**
```swift
Image("logo")
    .resizable()
    .aspectRatio(contentMode: .fit)  // Fits within frame, keeps ratio
    // or
    .aspectRatio(contentMode: .fill) // Fills frame, may crop
    .frame(width: 120, height: 120)
    .clipped()  // Prevents overflow
```

---

## Best Practices

### 1. Naming Convention
```
✅ Good Names:
- logo
- app-icon
- banner-home
- product-placeholder
- icon-cart
- background-gradient

❌ Bad Names:
- Logo.png
- app icon (spaces)
- banner_1 (not descriptive)
- image1, image2 (generic)
```

### 2. Organization
Create folders in Assets:
```
Assets.xcassets/
  ├── Logos/
  │   ├── logo
  │   └── logo-text
  ├── Icons/
  │   ├── icon-cart
  │   ├── icon-profile
  │   └── icon-search
  ├── Banners/
  │   └── banner-home
  └── Placeholders/
      ├── product-placeholder
      └── user-placeholder
```

Right-click in Assets → New Folder

### 3. Optimize Images

**Before adding:**
- Compress images (use tools like ImageOptim, TinyPNG)
- Use appropriate format (PNG for transparency, JPEG for photos)
- Don't include unnecessarily large images
- Remove metadata (EXIF data)

**Image sizes:**
- Icons: < 10 KB
- Logos: < 50 KB
- Banners: < 200 KB
- Backgrounds: < 500 KB

### 4. Fallback Images

Always have a fallback for missing images:
```swift
// Remote image with local fallback
AsyncImage(url: URL(string: imageUrl)) { phase in
    switch phase {
    case .success(let image):
        image.resizable()
    case .failure, .empty:
        Image("product-placeholder")  // Fallback
            .resizable()
    @unknown default:
        Image("product-placeholder")
    }
}
```

---

## Advanced Usage

### 1. System Symbols (SF Symbols)
Use Apple's built-in icons when possible:
```swift
Image(systemName: "cart.fill")
Image(systemName: "person.circle")
Image(systemName: "magnifyingglass")
```

**Benefits:**
- Automatic dark mode support
- Automatic accessibility scaling
- Consistent with iOS design
- No file size overhead

### 2. Conditional Images
```swift
// Different image based on condition
Image(isSelected ? "icon-selected" : "icon-unselected")

// Different image based on platform
#if os(iOS)
Image("logo-ios")
#elseif os(macOS)
Image("logo-macos")
#endif
```

### 3. Image Modifiers
```swift
Image("logo")
    .resizable()
    .renderingMode(.template)  // Makes tintable
    .interpolation(.high)      // Better quality scaling
    .antialiased(true)         // Smooth edges
    .foregroundColor(.appPrimary)
    .frame(width: 100, height: 100)
    .clipShape(Circle())
    .overlay(Circle().stroke(Color.white, lineWidth: 2))
    .shadow(radius: 5)
```

---

## SplashView Implementation

Here's your complete splash screen with logo:

```swift
struct SplashView: View {
    @State private var isReady = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.white, Color.appPrimary.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // App Logo with animation
                VStack(spacing: 20) {
                    Image("logo")  // ⭐️ Your logo from Assets
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .cornerRadius(24)
                        .shadow(color: .appPrimary.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Text("VeroStore")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.appPrimary)
                }
                .scaleEffect(isReady ? 1.0 : 0.8)
                .opacity(isReady ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isReady)
                
                Spacer()
                
                // Loading indicator
                if !isReady {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .appPrimary))
                        .scaleEffect(1.5)
                        .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            withAnimation {
                isReady = true
            }
        }
    }
}
```

---

## Quick Reference

**Load from Assets:**
```swift
Image("logo")  // ✅
```

**Load System Icon:**
```swift
Image(systemName: "star.fill")  // ✅
```

**Load from URL (async):**
```swift
AsyncImage(url: URL(string: "https://..."))  // ✅
```

**Load from UIImage (if needed):**
```swift
Image(uiImage: UIImage(named: "logo")!)  // Only if you must
```

---

## Checklist

When adding images to your project:

- [ ] Image added to Assets.xcassets (not just dragged into project)
- [ ] Image set properly named (no spaces, lowercase)
- [ ] At least @2x version provided
- [ ] Image optimized/compressed
- [ ] Target membership set correctly
- [ ] Using correct name in code (no extension)
- [ ] Build project after adding
- [ ] Test on device/simulator

---

## Resources

- [SF Symbols Browser](https://developer.apple.com/sf-symbols/)
- [Human Interface Guidelines - Images](https://developer.apple.com/design/human-interface-guidelines/images)
- [Asset Catalog Documentation](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/)
