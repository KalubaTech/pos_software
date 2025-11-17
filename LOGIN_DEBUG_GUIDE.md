# Login Debug Guide

## Issue
Unable to login with PIN 1234

## Debug Steps Added

I've added comprehensive debug logging to help identify the issue:

### 1. **AuthController Initialization**
The app now prints:
- Number of cashiers loaded from database
- Each cashier's name, PIN, and active status
- Any errors during initialization

### 2. **Login Process**
The app now prints:
- PIN entered
- Number of cashiers in memory
- Database query result
- Whether cashier was found
- Success/failure status

## How to Debug

### Step 1: Restart the App
1. Close the currently running app completely
2. Run: `flutter run -d windows`

### Step 2: Check Console Output
Look for these messages in the console:

```
=== INITIALIZING CASHIERS ===
Cashiers from DB: X
Loaded cashiers:
  - Admin User (PIN: 1234, Active: true)
  - John Cashier (PIN: 1111, Active: true)
  ...
```

### Step 3: Try to Login
Enter PIN 1234 and look for:

```
=== LOGIN ATTEMPT ===
PIN entered: 1234
Cashiers count: X
Cashier data from DB: {id: c1, name: Admin User, ...}
Successfully loaded cashier: Admin User
Login successful!
```

## Common Issues & Solutions

### Issue 1: No Cashiers Loaded
**Symptom**: `Cashiers from DB: 0` or `No cashiers found, creating defaults...`
**Solution**: Database table might be empty. The app will auto-create default cashiers.

### Issue 2: Cashier Found But Not Active
**Symptom**: `Cashier data from DB: null` but cashiers exist
**Solution**: Check if `isActive = 1` in the database query

### Issue 3: PIN Mismatch
**Symptom**: `No cashier found with PIN: 1234`
**Solution**: Verify the PIN in the database matches what you're entering

### Issue 4: Database Connection Error
**Symptom**: `Error initializing cashiers: ...`
**Solution**: Check if the database file is accessible and not corrupted

## Fallback Solution

If the database query fails, the app will attempt to find the cashier in memory:
- Checks the `cashiers` list loaded during initialization
- Matches PIN and `isActive` status
- Allows login even if database query fails

## Default Cashiers

The app creates these default accounts if the database is empty:

| Name | PIN | Role | Active |
|------|-----|------|--------|
| Admin User | 1234 | Admin | ✓ |
| John Cashier | 1111 | Cashier | ✓ |
| Sarah Manager | 2222 | Manager | ✓ |
| Mike Sales | 3333 | Cashier | ✓ |

## Next Steps

After restarting the app:
1. Copy the console output showing the initialization
2. Copy the console output when you try to login
3. Share both outputs so I can identify the exact issue

## Quick Test

Try these PINs to isolate the issue:
- **1234** - Admin User
- **1111** - John Cashier
- **2222** - Sarah Manager
- **3333** - Mike Sales

If none work, there's likely a database initialization issue.
If some work but not others, there's a data inconsistency.
