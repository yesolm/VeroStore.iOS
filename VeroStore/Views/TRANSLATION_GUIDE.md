# Product & Category Translation Guide

## Overview
This guide explains how the iOS app handles translations for backend content (product names, category names, descriptions) to match the Android app's behavior.

---

## 🌐 Translation Architecture

### **Two Types of Translations**

1. **UI Text Translation** (Already implemented)
   - Button labels, error messages, placeholders
   - Stored in `Localizable.strings` files
   - Managed by `LocalizationHelper`
   - Uses `.localized` extension

2. **Backend Content Translation** (Now implemented)
   - Product names, descriptions
   - Category names, descriptions
   - Variation attribute names/values
   - Comes from API backend
   - Uses `Accept-Language` HTTP header

---

## 🔧 How It Works

### **1. Language Header in API Requests**

All API requests now automatically include the current language:

```swift
// In NetworkService.swift
let currentLanguage = LocalizationHelper.shared.currentLanguage
request.setValue(currentLanguage, forHTTPHeaderField: "Accept-Language")
```

**Headers sent:**
```
Accept-Language: en    // English
Accept-Language: am    // Amharic
```

---

### **2. Backend Translation Patterns**

The backend can implement translations in two ways:

#### **Pattern A: Pre-Localized Response** (Simpler)
Backend returns already-translated content based on `Accept-Language` header:

```json
// Request with Accept-Language: am
{
  "id": 1,
  "name": "ቡና",           // Pre-translated to Amharic
  "description": "የኢትዮጵያ ቡና"
}
```

#### **Pattern B: Translation Objects** (More flexible)
Backend returns translations as a separate object:

```json
{
  "id": 1,
  "name": "Coffee",        // Default/English
  "description": "Ethiopian Coffee",
  "translations": {
    "en": {
      "name": "Coffee",
      "description": "Ethiopian Coffee"
    },
    "am": {
      "name": "ቡና",
      "description": "የኢትዮጵያ ቡና"
    }
  }
}
```

---

## 📱 iOS Models Support Both Patterns

### **Category Model**

```swift
struct Category {
    let name: String                                  // Default name
    let description: String?                          // Default description
    let translations: [String: CategoryTranslation]? // Optional translations
    
    // Automatically returns localized content
    var localizedName: String {
        let currentLang = LocalizationHelper.shared.currentLanguage
        return translations?[currentLang]?.name ?? name
    }
    
    var localizedDescription: String? {
        let currentLang = LocalizationHelper.shared.currentLanguage
        return translations?[currentLang]?.description ?? description
    }
}
```

### **Product Model**

```swift
struct Product {
    let name: String                                 // Default name
    let description: String?                         // Default description
    let translations: [String: ProductTranslation]? // Optional translations
    
    // Automatically returns localized content
    var localizedName: String {
        let currentLang = LocalizationHelper.shared.currentLanguage
        return translations?[currentLang]?.name ?? name
    }
    
    var localizedDescription: String? {
        let currentLang = LocalizationHelper.shared.currentLanguage
        return translations?[currentLang]?.description ?? description
    }
}
```

### **Variation Attributes**

```swift
struct VariationAttribute {
    let name: String   // e.g., "Size" or "Color"
    let value: String  // e.g., "Large" or "Red"
    let translations: [String: VariationAttributeTranslation]?
    
    var localizedName: String { /* returns translated name */ }
    var localizedValue: String { /* returns translated value */ }
}
```

---

## 🎨 Using Translations in Views

### **Option 1: If Backend Uses Pattern A (Pre-Localized)**

Just use the fields directly - they're already in the correct language:

```swift
Text(category.name)           // Already in correct language
Text(product.name)            // Already in correct language
Text(product.description ?? "")
```

### **Option 2: If Backend Uses Pattern B (Translation Objects)**

Use the computed properties:

```swift
Text(category.localizedName)        // Returns translated name
Text(product.localizedName)         // Returns translated name
Text(product.localizedDescription ?? "")
```

### **Option 3: Safe Approach (Works with Both)**

```swift
// Use localized properties - they fall back to default if no translations exist
Text(category.localizedName)
Text(product.localizedName)
Text(attribute.localizedName)
Text(attribute.localizedValue)
```

---

## 🔄 When Language Changes

### **Automatic Refresh**

When user changes language:

1. `LocalizationHelper.shared.setLanguage("am")` is called
2. All new API requests include new `Accept-Language` header
3. Backend returns content in new language
4. Views refresh automatically with `@ObservedObject` pattern

### **Force Refresh (if needed)**

```swift
// In views that should refresh on language change
.observeLocalization()

// Or listen to language change notification
NotificationCenter.default.addObserver(
    forName: NSNotification.Name("LanguageChanged"),
    object: nil,
    queue: .main
) { _ in
    // Reload data
    await loadCategories()
    await loadProducts()
}
```

---

## 📋 Implementation Checklist

### **Frontend (iOS) - ✅ Complete**
- [✅] Add `Accept-Language` header to all API requests
- [✅] Update models to support translation objects
- [✅] Add computed properties for localized content
- [✅] Make models backward-compatible (works with or without translations)

### **Backend (API) - Required**
- [ ] Accept `Accept-Language` header in requests
- [ ] Store translations in database
  - Option A: Category/Product translation tables
  - Option B: JSON translation columns
- [ ] Return localized content based on language header
- [ ] Support language fallback (if translation missing, return default)

---

## 🗄️ Backend Database Schema Examples

### **Option 1: Translation Tables**

```sql
-- Categories table (default language)
CREATE TABLE Categories (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    description TEXT,
    ...
);

-- Category translations
CREATE TABLE CategoryTranslations (
    id INT PRIMARY KEY,
    category_id INT REFERENCES Categories(id),
    language_code VARCHAR(5),  -- 'en', 'am', etc.
    name VARCHAR(255),
    description TEXT,
    UNIQUE(category_id, language_code)
);
```

### **Option 2: JSON Translation Column**

```sql
CREATE TABLE Categories (
    id INT PRIMARY KEY,
    name VARCHAR(255),          -- Default/English
    description TEXT,
    translations JSONB,         -- { "am": { "name": "...", "description": "..." } }
    ...
);
```

---

## 🌍 Supported Languages

Current app languages:
- **en** - English (default)
- **am** - አማርኛ (Amharic)

To add more languages:
1. Add to `LanguageSelectionView.swift`
2. Create Localizable.strings file
3. Backend must support the language code

---

## 🔍 Testing Translations

### **Test Cases:**

1. **Change language and browse categories**
   - Categories should show in new language
   
2. **Change language and search products**
   - Product names should be in new language
   
3. **Change language on product detail page**
   - Product name, description, attributes should update

4. **API fallback**
   - If translation missing, should show default (English)

### **Debug Logging:**

Add to NetworkService to see headers:
```swift
print("🌐 Accept-Language: \(currentLanguage)")
print("📡 Request: \(request.url?.absoluteString ?? "")")
```

---

## 🐛 Troubleshooting

### **Translations not appearing:**
1. ✅ Check if `Accept-Language` header is sent
2. ✅ Verify backend supports translations
3. ✅ Check if API returns translation objects
4. ✅ Ensure using `localizedName` instead of `name`

### **Wrong language showing:**
1. Check `LocalizationHelper.shared.currentLanguage`
2. Verify UserDefaults stores correct language
3. Test API directly with Postman/curl

### **Example curl test:**
```bash
curl -H "Accept-Language: am" \
     https://api.cartbyvero.com/api/Categories?storeId=1
```

---

## 📊 Translation Flow Diagram

```
┌─────────────────────┐
│  User Changes       │
│  Language in App    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ LocalizationHelper  │
│ .setLanguage("am")  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  NetworkService     │
│  Adds Header:       │
│  Accept-Language:am │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Backend API        │
│  Returns Content    │
│  in Amharic        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  iOS Decodes JSON   │
│  Models with        │
│  Translations       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Views Display      │
│  Localized Content  │
└─────────────────────┘
```

---

## 💡 Best Practices

1. **Always use `localizedName`/`localizedDescription`** in views
2. **Handle missing translations gracefully** (fall back to default)
3. **Test with both language patterns** (Pattern A and B)
4. **Log translation issues** for debugging
5. **Cache translated content** when possible
6. **Provide English fallback** for all content

---

## 🎯 Android App Comparison

| Feature | Android | iOS (Now) |
|---------|---------|-----------|
| Language header | `Accept-Language` | `Accept-Language` |
| Storage | SharedPreferences | UserDefaults |
| UI translations | strings.xml | Localizable.strings |
| Backend translations | API response | API response |
| Fallback language | English | English |
| Translation caching | Yes (Room DB) | Can implement |

---

## 📚 Related Files

- `NetworkService.swift` - Adds Accept-Language header
- `Category.swift` - Category translation model
- `Product.swift` - Product translation model
- `LocalizationHelper.swift` - Language management
- `LanguageSelectionView.swift` - Language picker UI

---

## 🚀 Next Steps (Optional Enhancements)

1. **Translation caching** - Store translations locally
2. **RTL support** - For Arabic, Hebrew, etc.
3. **Translation fallback chain** - am → en → default
4. **Offline translations** - Bundle common translations
5. **Translation analytics** - Track missing translations
