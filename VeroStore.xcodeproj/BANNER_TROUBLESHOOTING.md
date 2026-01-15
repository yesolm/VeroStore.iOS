# Banner Troubleshooting Guide

## Issue: Banners Not Showing on Home Page

### Quick Checklist

1. **Check Console Logs**
   Look for these messages:
   ```
   🎪 Fetching banners from: Banners/active?deviceType=2&storeId=X
   🎪 Received X banners from API (deviceType=2)
   ✅ Loaded X banners successfully
   ```

2. **Common Issues & Solutions**

### Problem 1: No Banners in Database
**Symptom:** Console shows "Received 0 banners"

**Solution:**
- Check if banners exist in backend database
- Verify banners have `isActive = true`
- Check if banners have correct `deviceType` (2 for iOS)
- Verify banners are assigned to your store

**Test with BannerDebugView:**
```swift
// Add to your app temporarily
NavigationLink("Debug Banners", destination: BannerDebugView())
```

---

### Problem 2: Wrong Device Type Filter
**Symptom:** Banners exist but not loading

**Current Fix:** App now tries two approaches:
1. First: Load iOS-specific banners (`deviceType=2`)
2. Fallback: Load all banners if iOS-specific not found

**Device Type Values:**
- `1` = Android
- `2` = iOS ⭐️
- `3` = Web

**Backend Query:**
```sql
SELECT * FROM Banners 
WHERE isActive = 1 
  AND deviceType = 2  -- iOS
  AND (storeId IS NULL OR storeId = @storeId)
ORDER BY displayOrder;
```

---

### Problem 3: Store Not Selected
**Symptom:** "No banners available" message shows

**Check:**
```swift
// Look for this in console
⚠️ No banners loaded. Count: 0
```

**Solution:**
- Make sure a store is selected in StoreService
- Check `StoreService.shared.selectedStore`
- HomeViewModel waits up to 1 second for store selection

---

### Problem 4: API Endpoint Error
**Symptom:** Network error in console

**Expected Endpoint:**
```
https://api.cartbyvero.com/api/Banners/active?deviceType=2&storeId=1
```

**Check:**
1. Backend has `/api/Banners/active` endpoint
2. Endpoint accepts `deviceType` and `storeId` query parameters
3. Returns JSON array of Banner objects

**Test with curl:**
```bash
curl "https://api.cartbyvero.com/api/Banners/active?deviceType=2&storeId=1"
```

Expected response:
```json
[
  {
    "id": 1,
    "title": "Banner Title",
    "imageUrl": "https://...",
    "linkType": "product",
    "linkProductId": 123,
    "deviceType": 2,
    "isActive": true,
    "displayOrder": 1
  }
]
```

---

### Problem 5: Image Loading Issues
**Symptom:** Banners load but images don't show

**Check:**
1. `imageUrl` is valid HTTPS URL
2. Images are accessible (not blocked by CORS)
3. Image files actually exist on server

**Test:**
```swift
// Check in BannerDebugView or console
print("Image URL: \(banner.imageUrl)")
```

---

## Debugging Steps

### Step 1: Enable Debug Mode

The app now has extensive logging. Check console for:

```
🎪 Fetching banners from: [endpoint]
🎪 Received X banners from API (deviceType=2)
🎪 No iOS-specific banners found, trying without deviceType filter...
🎪 Received X banners without device filter
✅ Loaded X banners successfully
❌ Failed to load banners: [error]
⚠️ No banners loaded. Count: 0
```

### Step 2: Use BannerDebugView

I've created a debug view to test banner loading:

```swift
// Add to your test navigation
NavigationLink("🔍 Debug Banners", destination: BannerDebugView())
```

**Features:**
- Shows selected store info
- Test loading with iOS filter
- Test loading all banners
- Display detailed banner information
- Shows image loading status

### Step 3: Check Backend Data

Run these SQL queries:

```sql
-- Check if banners exist
SELECT COUNT(*) FROM Banners WHERE isActive = 1;

-- Check iOS banners
SELECT * FROM Banners 
WHERE isActive = 1 AND deviceType = 2;

-- Check banners for specific store
SELECT * FROM Banners 
WHERE isActive = 1 
  AND deviceType = 2 
  AND (storeId IS NULL OR storeId = 1);

-- Check all active banners (any device)
SELECT * FROM Banners WHERE isActive = 1 ORDER BY displayOrder;
```

### Step 4: Test API Directly

```bash
# Test iOS banners with store
curl "https://api.cartbyvero.com/api/Banners/active?deviceType=2&storeId=1"

# Test iOS banners without store filter
curl "https://api.cartbyvero.com/api/Banners/active?deviceType=2"

# Test all banners (no device filter)
curl "https://api.cartbyvero.com/api/Banners/active?storeId=1"

# Test all banners (no filters)
curl "https://api.cartbyvero.com/api/Banners/active"
```

### Step 5: Verify Banner Model

Make sure your Banner model matches API response:

```swift
struct Banner: Codable, Identifiable, Hashable {
    let id: Int
    let title: String?
    let imageUrl: String
    let linkType: String?
    let linkUrl: String?
    let linkCategoryId: Int?
    let linkProductId: Int?
    let deviceType: Int
    let isActive: Bool
    let displayOrder: Int
}
```

---

## Solutions Implemented

### 1. Fallback Loading Strategy

```swift
// BannerService now tries multiple approaches:
1. Load iOS-specific banners (deviceType=2)
2. If empty, try loading all banners (no device filter)
```

### 2. Better Error Logging

```swift
// HomeViewModel logs banner loading
print("✅ Loaded \(banners.count) banners successfully")
print("❌ Failed to load banners: \(error)")
```

### 3. Debug Message in UI

```swift
// Shows when banners don't load
else {
    Text("No banners available")
        .font(.caption)
        .foregroundColor(.gray)
}
```

### 4. Graceful Failure

```swift
// Banners fail silently - app continues to work
catch {
    print("❌ Failed to load banners: \(error)")
    banners = []  // Don't crash, just show no banners
}
```

---

## Quick Fixes

### Fix 1: Force Load All Banners (No Device Filter)

In `BannerService.swift`, change:
```swift
func getActiveBanners(storeId: Int?, deviceType: Int? = nil) async throws -> [Banner] {
    var endpoint = "Banners/active"
    
    var params: [String] = []
    if let storeId = storeId {
        params.append("storeId=\(storeId)")
    }
    if let deviceType = deviceType {
        params.append("deviceType=\(deviceType)")
    }
    
    if !params.isEmpty {
        endpoint += "?" + params.joined(separator: "&")
    }
    
    return try await networkService.request([Banner].self, endpoint: endpoint)
}
```

Then in `HomeViewModel.swift`:
```swift
private func loadBanners(storeId: Int?) async throws {
    // Load all banners regardless of device type
    banners = try await bannerService.getActiveBanners(storeId: storeId, deviceType: nil)
}
```

### Fix 2: Test with Hardcoded Banners

In `HomeView.swift`, temporarily:
```swift
.onAppear {
    // TEST: Add fake banner
    viewModel.banners = [
        Banner(
            id: 1,
            title: "Test Banner",
            imageUrl: "https://via.placeholder.com/800x300",
            linkType: nil,
            linkUrl: nil,
            linkCategoryId: nil,
            linkProductId: nil,
            deviceType: 2,
            isActive: true,
            displayOrder: 1
        )
    ]
}
```

---

## Backend Requirements

### Database Schema

```sql
CREATE TABLE Banners (
    id INT PRIMARY KEY,
    title NVARCHAR(255),
    imageUrl NVARCHAR(500) NOT NULL,
    linkType NVARCHAR(50),        -- 'product', 'category', 'url', etc.
    linkUrl NVARCHAR(500),
    linkCategoryId INT,
    linkProductId INT,
    deviceType INT NOT NULL,       -- 1=Android, 2=iOS, 3=Web
    storeId INT,                   -- NULL = all stores
    isActive BIT NOT NULL,
    displayOrder INT NOT NULL,
    createdAt DATETIME DEFAULT GETDATE(),
    updatedAt DATETIME
);
```

### API Endpoint

```csharp
[HttpGet("active")]
public async Task<ActionResult<List<Banner>>> GetActiveBanners(
    [FromQuery] int? storeId = null,
    [FromQuery] int? deviceType = null)
{
    var query = _context.Banners
        .Where(b => b.IsActive);
    
    if (storeId.HasValue)
    {
        query = query.Where(b => !b.StoreId.HasValue || b.StoreId == storeId);
    }
    
    if (deviceType.HasValue)
    {
        query = query.Where(b => b.DeviceType == deviceType);
    }
    
    var banners = await query
        .OrderBy(b => b.DisplayOrder)
        .ToListAsync();
    
    return Ok(banners);
}
```

---

## Testing Checklist

- [ ] Check console logs for banner loading
- [ ] Verify store is selected
- [ ] Test with BannerDebugView
- [ ] Check if banners exist in database
- [ ] Verify `isActive = true`
- [ ] Check `deviceType = 2` (or try without filter)
- [ ] Test API endpoint with curl
- [ ] Verify image URLs are accessible
- [ ] Check network connection
- [ ] Try hardcoded test banner

---

## Contact Points

**Files to check:**
- `HomeView.swift` - UI display
- `HomeViewModel.swift` - Data loading logic
- `BannerService.swift` - API calls
- `BannerCarouselView` - Carousel component
- `Banner.swift` - Data model

**Console keywords to search for:**
- `🎪` - Banner loading
- `✅` - Success
- `❌` - Errors
- `⚠️` - Warnings

---

## Expected Result

When working correctly, you should see:

**Console output:**
```
🎪 Fetching banners from: Banners/active?deviceType=2&storeId=1
🎪 Received 3 banners from API (deviceType=2)
✅ Loaded 3 banners successfully
```

**Home screen:**
```
┌─────────────────────────────┐
│      [Banner Image]         │  ← Auto-scrolling
└─────────────────────────────┘
        ● ○ ○                    ← Page indicators
```

**Auto-scroll:**
- Changes every 3.5 seconds
- Smooth animations
- Shows page indicators
- Clickable navigation
