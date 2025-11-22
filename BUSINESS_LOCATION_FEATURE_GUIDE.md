# Business Location Feature - Setup & Implementation Guide

## 🗺️ Overview
Added geolocation functionality to business registration allowing businesses to pin their exact location on a map. This feature enables:
- **Interactive Map Selection**: Tap anywhere on Google Maps to set business location
- **Current Location**: One-click to use device's GPS location
- **Reverse Geocoding**: Automatically converts coordinates to readable addresses
- **Customer Navigation**: Makes it easier for customers to find your business

## 📦 New Dependencies Added

```yaml
geolocator: ^14.0.2          # Get device GPS location
geocoding: ^4.0.0            # Convert coordinates ↔ addresses
google_maps_flutter: ^2.10.0 # Interactive map widget
```

## 🏗️ Architecture Changes

### 1. BusinessModel Updated
**File**: `lib/models/business_model.dart`

Added new fields:
```dart
final double? latitude;   // Business location latitude
final double? longitude;  // Business location longitude
```

These are optional fields stored in Firestore for each business.

### 2. BusinessService Enhanced
**File**: `lib/services/business_service.dart`

Updated `registerBusiness()` method to accept:
```dart
double? latitude,
double? longitude,
```

### 3. New Location Picker Widget
**File**: `lib/widgets/location_picker_widget.dart` (NEW - 400+ lines)

**Features**:
- Full-screen Google Maps interface
- Draggable marker for precise positioning
- Current location button with GPS
- Address display with lat/lng coordinates
- Loading states for location/address fetching
- Dark mode support
- Permission handling (automatic requests)

**Key Methods**:
```dart
_getCurrentLocation()              // Get device GPS position
_getAddressFromCoordinates()       // Reverse geocoding
_onMapTap()                        // User taps map
_confirmLocation()                 // Save and return to form
```

### 4. Business Registration View Enhanced
**File**: `lib/views/auth/business_registration_view.dart`

**New State Variables**:
```dart
double? businessLatitude;
double? businessLongitude;
String locationAddress = '';
```

**New UI Section** (after website field):
- Location card with map icon
- Shows "Pick Location on Map" or "Change Location"
- Displays selected address and coordinates
- Visual feedback when location is set (colored border)

## 📱 User Flow

### For New Business Registration:

1. **Step 1: Business Information**
   - Fill in all required fields (name, email, phone, address)
   - Select Province → District
   - **(NEW)** Tap "Pick Location on Map" button
   
2. **Location Picker Opens**:
   - Shows Google Map (default: Lusaka, Zambia)
   - Options:
     - **Tap Anywhere**: Drop marker by tapping map
     - **Use Current Location**: Click GPS button (top-right)
     - **Drag Marker**: Fine-tune position by dragging
   - Address automatically appears at bottom
   - Tap "Confirm Location" to save

3. **Back to Registration Form**:
   - Location card shows:
     - ✅ Green checkmark icon
     - Full address
     - Coordinates (Lat: X.XXXXXX, Lng: Y.YYYYYY)
   - Border changes to primary color
   - Can click "Change Location" to adjust

4. **Step 3: Review**
   - GPS Location now displayed in review section
   - Shows coordinates if location was set

5. **Submit**
   - Latitude/Longitude saved to Firestore
   - Available for future features (maps, directions, etc.)

## 🔐 Permissions

### Android
**Already configured** in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Dynamos POS needs your location to set your business location on the map</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Dynamos POS needs your location to set your business location on the map</string>
```

### Windows/Desktop
- Location services use system permissions
- Automatic fallback to manual map selection if GPS unavailable

## 🗝️ Google Maps API Setup

### IMPORTANT: Configure API Key

1. **Get Google Maps API Key**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create/Select a project
   - Enable these APIs:
     - Maps SDK for Android
     - Maps SDK for iOS
     - Geocoding API
   - Create credentials → API Key
   - Copy your API key

2. **Android Configuration**:
   
   File: `android/app/src/main/AndroidManifest.xml`
   
   Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual key:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="AIzaSy..." />  <!-- Your actual key here -->
   ```

3. **iOS Configuration**:
   
   File: `ios/Runner/AppDelegate.swift`
   
   Add at the top:
   ```swift
   import GoogleMaps
   
   @main
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
       GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
   }
   ```

4. **Restrict API Key** (Recommended for security):
   - In Google Cloud Console → Credentials
   - Edit your API key
   - Set Application Restrictions:
     - Android: Add your package name + SHA-1 fingerprint
     - iOS: Add your bundle identifier
   - Set API Restrictions: Only allow Maps & Geocoding APIs

## 📊 Data Structure

### Firestore Schema
```json
{
  "business_registrations": {
    "BUS_1234567890": {
      "id": "BUS_1234567890",
      "name": "Kaloo Tech Shop",
      "address": "Cairo Road, Shop 45",
      "city": "Lusaka",
      "country": "Zambia",
      "latitude": -15.416667,      // ← NEW
      "longitude": 28.283333,      // ← NEW
      "status": "pending",
      ...
    }
  }
}
```

## 🎨 UI Features

### Location Card States

**1. No Location Set**:
- Gray background
- Gray border
- "Pick Location on Map" button
- Icon: Standard map icon

**2. Location Set**:
- Primary color background (light)
- Primary color border (2px)
- Green checkmark icon
- Shows full address
- Shows coordinates in monospace font
- "Change Location" button

### Dark Mode Support
All UI elements adapt to dark mode:
- Card backgrounds
- Text colors
- Map controls
- Dialog styling

## 🚀 Future Enhancements

### Potential Features:
1. **Customer App Integration**:
   - Show business location on map
   - "Get Directions" button → Opens Google/Apple Maps
   
2. **Delivery Radius**:
   - Set delivery coverage area
   - Calculate distance to customers
   
3. **Multi-Location Businesses**:
   - Add multiple branch locations
   - Branch selector on map
   
4. **Analytics**:
   - Track customer locations (with permission)
   - Heatmap of orders by location
   
5. **Geofencing**:
   - Special offers when customers are nearby
   - Automatic check-in at business location

## 🐛 Troubleshooting

### Map not showing?
- Check if Google Maps API key is configured
- Verify Maps SDK is enabled in Google Cloud Console
- Check internet connection
- Look for API key restrictions

### "Location Services Disabled" error?
- User needs to enable GPS on their device
- Guide them: Settings → Location → Enable

### Permission Denied?
- App automatically requests permission
- If denied forever: Guide user to Settings → Apps → Dynamos POS → Permissions

### Reverse geocoding not working?
- Check if Geocoding API is enabled
- Verify internet connection
- Fallback: Shows coordinates only

### iOS Crashes?
- Ensure Info.plist has location usage descriptions
- Check API key is configured in AppDelegate.swift

## 📝 Testing Checklist

- [ ] Tap map to select location
- [ ] Use current location button
- [ ] Drag marker to adjust position
- [ ] Address appears correctly
- [ ] Coordinates display properly
- [ ] Confirm button works
- [ ] Location shows in review step
- [ ] Data saves to Firestore
- [ ] Change location works
- [ ] Works on Android
- [ ] Works on iOS (if applicable)
- [ ] Works on Windows (manual only)
- [ ] Dark mode looks good
- [ ] Permission requests work
- [ ] Error handling graceful

## 💡 Tips for Users

**Best Practices**:
1. Use "Current Location" if you're at the business location
2. Zoom in for precise marker placement
3. Verify address matches before confirming
4. You can always change location later (future feature)

**Business Benefits**:
- Customers can find you easily
- Shows up on maps in future updates
- Enables delivery radius features
- Professional appearance
- Better customer experience

## 🔗 Related Files

**Models**:
- `lib/models/business_model.dart`

**Services**:
- `lib/services/business_service.dart`

**Views**:
- `lib/views/auth/business_registration_view.dart`

**Widgets**:
- `lib/widgets/location_picker_widget.dart` (NEW)

**Constants**:
- `lib/constants/zambia_locations.dart`

**Config**:
- `android/app/src/main/AndroidManifest.xml`
- `pubspec.yaml`

## 🎯 Summary

✅ **What's Working**:
- Complete location picker UI
- GPS current location
- Reverse geocoding
- Map selection
- Dark mode support
- Permission handling
- Data persistence

⏳ **What Needs Setup**:
- Google Maps API key configuration
- iOS Info.plist updates (if deploying to iOS)

🚀 **Ready to Use**:
Once you add your Google Maps API key, the feature is fully functional!

---

**Note**: This feature is optional during registration. Businesses can skip it and still register successfully. Location can potentially be added later via settings (future enhancement).
