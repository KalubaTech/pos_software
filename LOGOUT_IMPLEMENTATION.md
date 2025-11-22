# Logout Button Implementation

## Overview
Added a functional logout button to the bottom of the sidebar navigation with proper confirmation dialog and navigation handling.

## Implementation Details

### Files Modified
- **lib/components/navigations/main_side_navigation_bar.dart**

### Changes Made

#### 1. Added Imports
```dart
import 'package:pos_software/controllers/auth_controller.dart';
import '../../views/auth/login_view.dart';
```

#### 2. Created Logout Confirmation Dialog
```dart
Future<void> _showLogoutDialog(BuildContext context) async {
  final authController = Get.find<AuthController>();
  
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context); // Close dialog
            await authController.logout();
            Get.offAll(() => const LoginView()); // Navigate to login and clear stack
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('Logout'),
        ),
      ],
    ),
  );
}
```

#### 3. Updated Logout Button Section
Replaced the placeholder button with fully functional logout buttons for both desktop and mobile modes:

**Desktop Mode (Icon-only):**
- Icon button with tooltip
- Red colored logout icon
- Shows confirmation dialog on click

**Mobile Mode (Drawer):**
- Full ListTile with icon and label
- Red colored text and icon
- Separator line at top
- Closes drawer before showing confirmation

## Features

### User Experience
1. **Confirmation Dialog**: Prevents accidental logout with a confirmation dialog
2. **Visual Feedback**: Red colored logout button/text to indicate destructive action
3. **Responsive Design**: 
   - Desktop: Icon-only button with tooltip
   - Mobile: Full-width item with label
4. **Navigation**: Automatically navigates to login screen after logout
5. **Session Clearing**: Uses AuthController to properly clear session data

### Technical Details
- **Session Management**: Calls `authController.logout()` which:
  - Clears current cashier
  - Updates authentication state
  - Removes session from GetStorage
  - Shows success snackbar
- **Navigation**: Uses `Get.offAll()` to navigate to login and clear navigation stack
- **Drawer Handling**: Closes mobile drawer before showing dialog for better UX

## Testing Checklist

### Desktop Mode
- [ ] Logout icon appears at bottom of collapsed sidebar
- [ ] Tooltip shows "Sign out" on hover
- [ ] Clicking icon shows confirmation dialog
- [ ] Clicking Cancel closes dialog and stays logged in
- [ ] Clicking Logout logs out and navigates to login screen
- [ ] Cannot navigate back to app without logging in again

### Mobile Mode
- [ ] Logout item appears at bottom of drawer
- [ ] Item has separator line at top
- [ ] Tapping item closes drawer and shows confirmation dialog
- [ ] Clicking Cancel closes dialog and stays logged in
- [ ] Clicking Logout logs out and navigates to login screen
- [ ] Cannot navigate back to app without logging in again

### Session Management
- [ ] After logout, GetStorage session is cleared
- [ ] Relaunching app shows login screen (no auto-login)
- [ ] Success snackbar appears after logout

## User Guide

### How to Logout

**On Desktop:**
1. Look at the bottom of the left sidebar
2. Click the red logout icon (arrow pointing out of door)
3. Confirm logout in the dialog

**On Mobile:**
1. Open the navigation drawer (tap hamburger menu)
2. Scroll to bottom
3. Tap "Logout" item (red text)
4. Confirm logout in the dialog

### After Logout
- You will be automatically redirected to the login screen
- Your session will be cleared
- You'll need to enter your cashier PIN to access the app again

## Color Scheme
- **Logout Icon/Text**: Uses theme's error color (typically red)
- **Separator**: Uses theme's outline color with 20% opacity
- **Dialog Buttons**: 
  - Cancel: Default text button
  - Logout: Red text for destructive action

## Future Enhancements (Optional)
- Add user info display above logout button (cashier name, role)
- Add logout animation
- Add option to logout all devices (cloud session management)
- Add "remember me" option to skip PIN for trusted devices
