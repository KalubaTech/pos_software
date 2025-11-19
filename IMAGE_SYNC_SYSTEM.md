# 📸 Image Sync System - Complete Guide

## Overview

The Image Sync System automatically uploads local product images to your remote server (kalootech.com) before syncing to Firestore. This ensures:

✅ Images are accessible from any device
✅ Proper offline/online functionality  
✅ Reduced Firestore storage costs (images stored on your server)
✅ Fast image loading with cached_network_image

---

## 🔄 How It Works

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Product Creation                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │  Image Selected?     │
          └──────────┬───────────┘
                     │
         ┌───────────┴───────────┐
         │ YES                   │ NO
         ▼                       ▼
┌──────────────────┐    ┌──────────────────┐
│ Save Locally     │    │ Use Placeholder  │
│ (File Path)      │    │                  │
└────────┬─────────┘    └────────┬─────────┘
         │                       │
         └───────────┬───────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │  Sync Triggered      │
          └──────────┬───────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │  Is Local Image?     │
          └──────────┬───────────┘
                     │
         ┌───────────┴───────────┐
         │ YES                   │ NO (Already URL)
         ▼                       ▼
┌──────────────────────┐    ┌──────────────────┐
│ Upload to Server     │    │ Skip Upload      │
│ kalootech.com/       │    │                  │
│ image_upload.php     │    │                  │
└────────┬─────────────┘    └────────┬─────────┘
         │                           │
         ▼                           │
┌──────────────────────┐            │
│ Get Remote URL       │            │
│ https://kalootech    │            │
│ .com/uploads/        │            │
│ img_xxx.jpg          │            │
└────────┬─────────────┘            │
         │                           │
         ▼                           │
┌──────────────────────┐            │
│ Update Local DB      │            │
│ with Remote URL      │            │
└────────┬─────────────┘            │
         │                           │
         └───────────┬───────────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │  Push to Firestore   │
          │  (with Remote URL)   │
          └──────────┬───────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │  Other Devices       │
          │  Download Image      │
          │  (Cached)            │
          └──────────────────────┘
```

---

## 🛠️ Implementation Details

### 1. ImageSyncService

**Location:** `lib/services/image_sync_service.dart`

**Key Methods:**

```dart
// Upload a single local image to server
Future<String?> uploadImage(String localPath)

// Process image URL (upload if local, return if remote)
Future<String> processImageUrl(String imageUrl)

// Check if URL is a local file path
bool isLocalImage(String imageUrl)

// Upload multiple images in batch
Future<Map<String, String>> uploadMultipleImages(List<String> localPaths)
```

**Usage Example:**

```dart
final imageSyncService = Get.find<ImageSyncService>();

// Upload single image
String localPath = '/path/to/image.jpg';
String? remoteUrl = await imageSyncService.uploadImage(localPath);

if (remoteUrl != null) {
  print('Image uploaded: $remoteUrl');
  // Update product with remote URL
}
```

---

### 2. Server-Side Upload

**Endpoint:** `https://kalootech.com/image_upload.php`

**Request:**
- Method: POST (multipart/form-data)
- Field: `image` (file)

**Response:**
```json
{
  "success": true,
  "path": "uploads/img_673a1f2e8d4c7_1731883822.jpg"
}
```

**Full URL:**
```
https://kalootech.com/uploads/img_673a1f2e8d4c7_1731883822.jpg
```

---

### 3. Product Sync with Image Upload

**Location:** `lib/controllers/universal_sync_controller.dart`

**Flow:**

```dart
/// When syncing a product
Future<void> syncProduct(ProductModel product) async {
  // 1. Check if image is local
  String imageUrl = product.imageUrl;
  if (_imageSyncService.isLocalImage(imageUrl)) {
    
    // 2. Upload to server
    print('📸 Uploading image for product: ${product.name}');
    final remoteUrl = await _imageSyncService.uploadImage(imageUrl);
    
    if (remoteUrl != null) {
      // 3. Update local database with remote URL
      imageUrl = remoteUrl;
      final updatedProduct = product.copyWith(imageUrl: imageUrl);
      await _dbService.updateProduct(updatedProduct);
      print('✅ Image uploaded and product updated');
    }
  }
  
  // 4. Push to Firestore with remote image URL
  await _syncService.pushToCloud('products', product.id, product.toJson());
}
```

---

### 4. Displaying Images

Use `CachedNetworkImage` for optimal performance:

```dart
import 'package:cached_network_image/cached_network_image.dart';

// In your widget
CachedNetworkImage(
  imageUrl: product.imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  fit: BoxFit.cover,
)
```

**Benefits:**
- ✅ Caches images locally for offline viewing
- ✅ Shows placeholder while loading
- ✅ Handles errors gracefully
- ✅ Reduces bandwidth usage

---

## 📊 Sync Scenarios

### Scenario 1: New Product with Local Image

```
1. User adds product
2. Selects image from file picker
3. Image saved locally: C:\Users\...\image.jpg
4. Product saved to local DB with local path
5. Sync triggered
6. Image uploaded to kalootech.com
7. Local DB updated with remote URL
8. Product pushed to Firestore with remote URL
9. Other devices download remote image
```

**Console Output:**
```
➕ Adding product: Test Product
💾 Saved locally with image: C:\Users\...\image.jpg
📸 Uploading image for product: Test Product
📤 Uploading image: C:\Users\...\image.jpg
✅ Image uploaded successfully: https://kalootech.com/uploads/img_xxx.jpg
🔄 Updated product with remote URL
☁️ Product Test Product synced
```

---

### Scenario 2: Product Already Has Remote Image

```
1. Product received from cloud
2. Image URL: https://kalootech.com/uploads/img_xxx.jpg
3. Sync triggered
4. Check: Already remote? YES
5. Skip upload
6. Push to Firestore as-is
```

**Console Output:**
```
ℹ️ Image already remote: https://kalootech.com/uploads/img_xxx.jpg
☁️ Product Test Product synced
```

---

### Scenario 3: Image Upload Fails

```
1. Sync triggered
2. Attempt upload
3. Network error OR server error
4. Upload returns null
5. Keep local path (or use placeholder)
6. Push to Firestore with local path
7. Image added to offline queue for retry
```

**Console Output:**
```
📸 Uploading image for product: Test Product
❌ Upload failed with status: 500
⚠️ Using original URL after upload failure
☁️ Product Test Product synced (with local path)
```

---

## 🔍 Image URL Detection Logic

```dart
bool isLocalImage(String imageUrl) {
  // Check if it's a remote URL
  if (imageUrl.startsWith('http://') || 
      imageUrl.startsWith('https://')) {
    return false; // It's remote
  }
  
  // Check if it's a placeholder
  if (imageUrl.contains('placeholder')) {
    return false; // Don't upload placeholders
  }
  
  // Otherwise, it's a local path
  return true;
}
```

**Examples:**

| Image URL | isLocalImage? | Action |
|-----------|---------------|--------|
| `https://kalootech.com/uploads/img_xxx.jpg` | ❌ NO | Skip upload |
| `https://via.placeholder.com/300` | ❌ NO | Skip upload |
| `C:\Users\...\image.jpg` | ✅ YES | Upload |
| `/storage/emulated/0/image.jpg` | ✅ YES | Upload |
| `file:///data/user/0/.../image.jpg` | ✅ YES | Upload |

---

## 🎯 Performance Optimization

### 1. Batch Upload During Full Sync

```dart
Future<void> _syncProducts() async {
  final localProducts = await _dbService.getAllProducts();
  
  // Collect all local images
  List<String> imagesToUpload = [];
  for (var product in localProducts) {
    if (_imageSyncService.isLocalImage(product.imageUrl)) {
      imagesToUpload.add(product.imageUrl);
    }
  }
  
  // Upload all at once (parallelized)
  final uploadResults = await _imageSyncService.uploadMultipleImages(
    imagesToUpload,
  );
  
  // Update products with remote URLs
  for (var product in localProducts) {
    if (uploadResults.containsKey(product.imageUrl)) {
      final remoteUrl = uploadResults[product.imageUrl]!;
      final updatedProduct = product.copyWith(imageUrl: remoteUrl);
      await _dbService.updateProduct(updatedProduct);
    }
  }
}
```

### 2. Cached Network Image

- First load: Downloads from server
- Subsequent loads: Uses cached version
- Offline: Shows cached image
- Updates: Refreshes cache automatically

---

## 📝 Server Requirements

### PHP Upload Script

**File:** `image_upload.php`
**Location:** `https://kalootech.com/image_upload.php`

**Features:**
- ✅ Accepts multipart/form-data
- ✅ Validates file upload
- ✅ Generates unique filenames
- ✅ Stores in `uploads/` directory
- ✅ Returns JSON response with path

**Permissions:**
```bash
chmod 755 image_upload.php
chmod 777 uploads/
```

**Security Considerations:**
- Add file type validation (images only)
- Add file size limits (e.g., max 5MB)
- Sanitize filenames
- Add rate limiting
- Implement authentication (optional)

---

## 🧪 Testing

### Test 1: Upload Local Image

1. Add new product with image
2. Check console:
   ```
   📸 Uploading image for product: Test Product
   📤 Uploading image: C:\Users\...\image.jpg
   ✅ Image uploaded successfully
   ```
3. Check Firestore: Product has remote URL
4. Open on another device: Image loads

### Test 2: Cached Image Display

1. Load product with image (online)
2. Turn off WiFi
3. Navigate away and back
4. Image still displays (from cache)

### Test 3: Sync Without Images

1. Add product without image (use placeholder)
2. Sync
3. Check: No upload attempted
4. Firestore has placeholder URL

---

## 🚨 Error Handling

### Upload Errors

**Network Error:**
```dart
try {
  final remoteUrl = await uploadImage(localPath);
} catch (e) {
  print('❌ Network error: $e');
  // Keep local path, will retry on next sync
}
```

**Server Error (500):**
```dart
if (response.statusCode != 200) {
  print('❌ Server error: ${response.statusCode}');
  return null;
}
```

**Invalid Response:**
```dart
if (jsonResponse['success'] != true) {
  print('❌ Upload failed: ${jsonResponse['message']}');
  return null;
}
```

---

## 🔐 Security Best Practices

### 1. Validate File Types

Add to PHP script:
```php
$allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
if (!in_array($_FILES["image"]["type"], $allowedTypes)) {
    echo json_encode(["success" => false, "message" => "Invalid file type"]);
    exit;
}
```

### 2. Limit File Size

```php
if ($_FILES["image"]["size"] > 5000000) { // 5MB
    echo json_encode(["success" => false, "message" => "File too large"]);
    exit;
}
```

### 3. Add Authentication

```php
$apiKey = $_POST['api_key'] ?? '';
if ($apiKey !== 'your_secret_key') {
    http_response_code(401);
    echo json_encode(["success" => false, "message" => "Unauthorized"]);
    exit;
}
```

---

## 📊 Monitoring

### Console Messages to Watch

**Success:**
- ✅ `Image uploaded successfully`
- ☁️ `Product synced`
- 🔄 `Updated product with remote URL`

**Warnings:**
- ⚠️ `Using original URL after upload failure`
- ℹ️ `Image already remote`

**Errors:**
- ❌ `Upload failed with status: XXX`
- ❌ `Image file not found`
- ❌ `Error uploading image`

---

## 🎯 Future Enhancements

### 1. Image Compression

Before upload, compress images:
```dart
import 'package:image/image.dart' as img;

Future<File> compressImage(File file) async {
  final image = img.decodeImage(await file.readAsBytes());
  final compressed = img.encodeJpg(image, quality: 85);
  return File(file.path)..writeAsBytesSync(compressed);
}
```

### 2. Progress Tracking

```dart
Future<String?> uploadImageWithProgress(
  String localPath,
  Function(double) onProgress,
) async {
  // Implement with StreamedResponse
}
```

### 3. Image Optimization

- Resize to max 1024x1024
- Convert to WebP format
- Generate thumbnails
- Use CDN for faster delivery

### 4. Retry Logic

```dart
Future<String?> uploadWithRetry(String path, {int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    final result = await uploadImage(path);
    if (result != null) return result;
    await Future.delayed(Duration(seconds: 2 * (i + 1)));
  }
  return null;
}
```

---

## ✅ Implementation Checklist

Setup:
- [x] Create ImageSyncService
- [x] Add to UniversalSyncController
- [x] Update product sync methods
- [x] Add http dependency
- [ ] Test upload endpoint
- [ ] Implement CachedNetworkImage in UI

Security:
- [ ] Add file type validation
- [ ] Add file size limits
- [ ] Implement authentication (optional)
- [ ] Set proper directory permissions

UI Updates:
- [ ] Replace Image.file() with CachedNetworkImage
- [ ] Add image upload progress indicator
- [ ] Handle upload failures gracefully
- [ ] Show cached/remote indicator

Testing:
- [ ] Test local image upload
- [ ] Test remote image sync
- [ ] Test offline cached display
- [ ] Test cross-device sync
- [ ] Test error scenarios

---

**Status:** ✅ Core implementation complete
**Last Updated:** November 17, 2025
**Version:** 1.0.1
