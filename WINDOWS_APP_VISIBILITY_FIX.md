# Windows App Visibility Troubleshooting

## Issue
Flutter app console shows "running" but the window is not visible on Windows.

## Common Causes & Solutions

### 1. App Running in Background
**Problem:** The app window opened off-screen or minimized

**Solution:**
- Press `Alt + Tab` to cycle through open windows
- Check Windows taskbar for the app icon
- Right-click taskbar icon → "Maximize" or "Move"
- Use Windows key + Arrow keys to reposition window

### 2. Multiple Instances
**Problem:** Old instance was running in background

**Solution Applied:**
```powershell
# Kill existing process
taskkill /F /IM pos_software.exe

# Restart fresh
flutter run -d windows --release
```

### 3. Window Positioned Off-Screen
**Problem:** App window coordinates are outside visible screen area

**Solution:**
1. Alt + Tab to the app
2. Press Alt + Space (opens window menu)
3. Press M (for Move)
4. Use arrow keys to move window back on screen
5. Press Enter when visible

### 4. Debug vs Release Mode
**Problem:** Debug mode sometimes has window visibility issues

**Solution:**
```bash
# Use release mode for better performance and stability
flutter run -d windows --release

# Or debug mode with verbose
flutter run -d windows -v
```

### 5. Graphics/Display Issues
**Problem:** Windows display scaling or multiple monitors

**Solution:**
- Check display settings: Settings → System → Display
- Set scaling to 100% temporarily
- Disconnect secondary monitors and retry
- Update graphics drivers

## Quick Commands

### Check Running App
```powershell
# Check if app process is running
Get-Process | Where-Object {$_.ProcessName -like "*pos_software*"}

# List all Flutter processes
Get-Process | Where-Object {$_.ProcessName -like "*flutter*"}
```

### Kill and Restart
```powershell
# Kill app process
taskkill /F /IM pos_software.exe

# Clean and rebuild
flutter clean
flutter pub get
flutter run -d windows --release
```

### Force Window to Foreground
```powershell
# Find window and bring to front (if running)
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@
```

## Current Action

✅ **Killed existing process** that was running in background
🔄 **Building fresh release version** - this will take 1-2 minutes
⏳ **Window should appear** when build completes

## What to Watch For

When the build completes, you should see:
```
Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

💪 Running with sound null safety 💪

An Observatory debugger and profiler on Windows is available at: http://...
The Flutter DevTools debugger and profiler on Windows is available at: http://...
```

And most importantly: **The app window will appear!**

## If Window Still Not Visible

### Check Taskbar
1. Look at Windows taskbar (bottom of screen)
2. Find "POS Software" or "pos_software" icon
3. Click it to bring window to front
4. If minimized, it will restore

### Use Task Manager
1. Press `Ctrl + Shift + Esc`
2. Look for "pos_software.exe" in Processes
3. Right-click → "Bring to front" or "Maximize"

### Restart with Debug Info
```bash
# Stop current run (if running)
# Press 'q' in terminal or Ctrl+C

# Run with verbose output
flutter run -d windows -v

# This shows more info about window creation
```

## Window Configuration (for developers)

If you want to ensure window always appears correctly, check these files:

### windows/runner/main.cpp
```cpp
// Window size and position
const int window_width = 1280;
const int window_height = 720;

// Center window on screen
int x = (screen_width - window_width) / 2;
int y = (screen_height - window_height) / 2;
```

### windows/runner/flutter_window.cpp
```cpp
// Make sure window is created with SW_SHOW flag
ShowWindow(window, SW_SHOW);
SetForegroundWindow(window);
```

## Prevention Tips

### 1. Always Use Release Mode on Windows
```bash
flutter run -d windows --release
```
- Better performance
- Fewer visibility issues
- More stable

### 2. Clean Between Builds
```bash
flutter clean
flutter pub get
flutter run -d windows --release
```

### 3. Check for Multiple Instances
Before running:
```powershell
tasklist | findstr "pos_software"
```

### 4. Use Hot Restart (r) Instead of Stopping
When developing:
- Press `r` for hot reload
- Press `R` for hot restart
- Don't stop/start repeatedly

## Current Status

**Action:** Building Windows app in release mode
**Expected:** Window will appear when build completes (1-2 minutes)
**Next:** If window doesn't appear, try Alt+Tab or check taskbar

## Wait for Build to Complete

The console will show:
```
Building Windows application...    [progress bar]
```

When done:
```
✓ Built build\windows\x64\runner\Release\pos_software.exe
```

Then the window will launch automatically!

## If All Else Fails

### Nuclear Option - Full Rebuild
```bash
# Stop app
# Ctrl+C in terminal

# Clean everything
flutter clean
rm -rf build/
rm -rf .dart_tool/

# Get dependencies
flutter pub get

# Rebuild
flutter build windows --release

# Run the executable directly
./build/windows/x64/runner/Release/pos_software.exe
```

This will create a fresh build and launch the executable directly.

---

**Current Status:** ⏳ Building release version...
**Expected Time:** 1-2 minutes
**What to Do:** Wait for build to complete, window will appear automatically
