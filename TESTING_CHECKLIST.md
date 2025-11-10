# ✅ Testing Checklist - Price Tag Designer New Features

## 🎯 Feature 1: Keyboard Delete

### Test Cases
- [ ] **TC1.1**: Select an element and press Delete key → Element is removed
- [ ] **TC1.2**: Select an element and press Backspace key → Element is removed
- [ ] **TC1.3**: Press Delete without selecting element → Nothing happens
- [ ] **TC1.4**: Delete notification appears after removal
- [ ] **TC1.5**: Template element count updates after deletion
- [ ] **TC1.6**: Canvas re-renders correctly after deletion

### Expected Results
✅ Selected element disappears from canvas
✅ Snackbar shows "Element Deleted" message
✅ Properties panel clears (no selection)
✅ Template is automatically updated

---

## 💾 Feature 2: Template Saving

### Test Cases
- [ ] **TC2.1**: Save button is disabled when no template selected
- [ ] **TC2.2**: Save button is enabled when template is selected
- [ ] **TC2.3**: Click Save → Success notification appears
- [ ] **TC2.4**: Close and reopen app → Templates are still there
- [ ] **TC2.5**: Create new template → Save → Appears in template list
- [ ] **TC2.6**: Modify existing template → Save → Changes persist
- [ ] **TC2.7**: First time opening app → Default templates are created

### Expected Results
✅ Templates saved to database successfully
✅ Templates reload on app restart
✅ Template modifications persist
✅ Success notification: "Template saved successfully"

### Database Verification
```sql
-- Check templates table exists
SELECT * FROM price_tag_templates;

-- Verify template data
SELECT id, name, width, height FROM price_tag_templates;
```

---

## 🖨️ Feature 3: Printer Management

### Test Cases - Basic Operations

#### Add Printer
- [ ] **TC3.1**: Click Settings icon → Dialog opens
- [ ] **TC3.2**: Click "Add Printer" → Add dialog opens
- [ ] **TC3.3**: Fill in printer name → Name is accepted
- [ ] **TC3.4**: Select Thermal type → Option is saved
- [ ] **TC3.5**: Select USB connection → Option is saved
- [ ] **TC3.6**: Select Network connection → IP and Port fields appear
- [ ] **TC3.7**: Select Bluetooth connection → Address field appears
- [ ] **TC3.8**: Set paper width to 58mm → Saved correctly
- [ ] **TC3.9**: Set paper width to 80mm → Saved correctly
- [ ] **TC3.10**: Check "Set as default" → Printer becomes default
- [ ] **TC3.11**: Click "Add Printer" → Printer added successfully
- [ ] **TC3.12**: Empty name → Error: "Please enter a printer name"

#### Printer List
- [ ] **TC3.13**: Added printer appears in list
- [ ] **TC3.14**: Default printer shows "DEFAULT" badge
- [ ] **TC3.15**: Default printer card has green accent
- [ ] **TC3.16**: Non-default printers have blue accent
- [ ] **TC3.17**: Printer details display correctly (type, connection, paper)

#### Set Default Printer
- [ ] **TC3.18**: Click ⋮ menu → "Set as Default" option appears
- [ ] **TC3.19**: Click "Set as Default" → Printer becomes default
- [ ] **TC3.20**: Previous default loses DEFAULT badge
- [ ] **TC3.21**: New default shows DEFAULT badge
- [ ] **TC3.22**: Success notification appears

#### Delete Printer
- [ ] **TC3.23**: Click ⋮ menu → "Delete" option appears (red)
- [ ] **TC3.24**: Click "Delete" → Confirmation dialog appears
- [ ] **TC3.25**: Click "Cancel" → Printer not deleted
- [ ] **TC3.26**: Click "Delete" → Printer removed from list
- [ ] **TC3.27**: Success notification appears
- [ ] **TC3.28**: Deleted printer doesn't appear after app restart

#### Empty State
- [ ] **TC3.29**: No printers configured → Empty state shows
- [ ] **TC3.30**: Empty state shows printer icon and message
- [ ] **TC3.31**: Message: "No printers configured"

### Test Cases - Connection Types

#### USB Printer
- [ ] **TC3.32**: Add USB printer → No address/port fields
- [ ] **TC3.33**: Printer saved with type = USB

#### Network Printer
- [ ] **TC3.34**: Select Network → IP and Port fields appear
- [ ] **TC3.35**: Enter IP (e.g., 192.168.1.100) → Accepted
- [ ] **TC3.36**: Enter Port (e.g., 9100) → Accepted
- [ ] **TC3.37**: Printer saved with address and port

#### Bluetooth Printer
- [ ] **TC3.38**: Select Bluetooth → Address field appears
- [ ] **TC3.39**: Enter Bluetooth address → Accepted
- [ ] **TC3.40**: Printer saved with Bluetooth address

### Test Cases - Printer Types

#### Thermal Printer
- [ ] **TC3.41**: Select Thermal → Type saved correctly
- [ ] **TC3.42**: Card shows "Type: Thermal"

#### Inkjet Printer
- [ ] **TC3.43**: Select Inkjet → Type saved correctly
- [ ] **TC3.44**: Card shows "Type: Inkjet"

#### Laser Printer
- [ ] **TC3.45**: Select Laser → Type saved correctly
- [ ] **TC3.46**: Card shows "Type: Laser"

### Expected Results
✅ All printer types can be added
✅ All connection types work correctly
✅ Default printer is marked clearly
✅ Printers persist after app restart
✅ Soft delete (isActive = 0)

### Database Verification
```sql
-- Check printers table exists
SELECT * FROM printers;

-- Verify printer data
SELECT id, name, type, connectionType, isDefault, isActive FROM printers;

-- Check default printer
SELECT * FROM printers WHERE isDefault = 1;

-- Check active printers only
SELECT * FROM printers WHERE isActive = 1;
```

---

## 🔄 Integration Testing

### Test Cases - Workflow
- [ ] **TC4.1**: Open designer → Templates load automatically
- [ ] **TC4.2**: Select template → Canvas displays template
- [ ] **TC4.3**: Add element → Element appears on canvas
- [ ] **TC4.4**: Select element → Press Delete → Element removed
- [ ] **TC4.5**: Click Save → Template saved
- [ ] **TC4.6**: Close and reopen → Template still has changes
- [ ] **TC4.7**: Open printer settings → Printers listed
- [ ] **TC4.8**: Add printer → Printer appears in list
- [ ] **TC4.9**: Set as default → Badge appears
- [ ] **TC4.10**: Close settings → Settings icon still accessible

### Expected Results
✅ All features work together seamlessly
✅ No conflicts between features
✅ UI remains responsive
✅ Data persists correctly

---

## 🐛 Edge Cases

### Test Cases - Error Handling
- [ ] **TC5.1**: Database error → User-friendly error message
- [ ] **TC5.2**: Delete last element → No errors
- [ ] **TC5.3**: Save without template → Button disabled
- [ ] **TC5.4**: Add printer with missing name → Error shown
- [ ] **TC5.5**: Duplicate printer name → Allowed (different IDs)
- [ ] **TC5.6**: Delete default printer → Another can be set as default
- [ ] **TC5.7**: Network error during save → Error notification

### Test Cases - Performance
- [ ] **TC5.8**: Many templates (50+) → Load time < 2 seconds
- [ ] **TC5.9**: Many printers (20+) → List scrolls smoothly
- [ ] **TC5.10**: Large template (100+ elements) → Saves in < 1 second
- [ ] **TC5.11**: Rapid keyboard delete → No lag or crashes

### Expected Results
✅ Graceful error handling
✅ No crashes or freezes
✅ Good performance with large datasets
✅ User-friendly error messages

---

## 📱 Platform Testing

### Desktop (Windows/macOS/Linux)
- [ ] **TC6.1**: Keyboard shortcuts work correctly
- [ ] **TC6.2**: Database created in correct location
- [ ] **TC6.3**: USB printer detection works
- [ ] **TC6.4**: Network printer connection works

### Mobile (Android/iOS)
- [ ] **TC6.5**: Touch interactions work
- [ ] **TC6.6**: Bluetooth printer scanning works
- [ ] **TC6.7**: Network printer discovery works
- [ ] **TC6.8**: Database syncs correctly

### Web
- [ ] **TC6.9**: IndexedDB used for storage
- [ ] **TC6.10**: Browser printing APIs work
- [ ] **TC6.11**: Keyboard shortcuts work in browser

---

## ✅ Acceptance Criteria

### Must Have
- [x] Keyboard delete removes selected elements
- [x] Templates save to database
- [x] Templates load on app startup
- [x] Can add printers with all connection types
- [x] Can set default printer
- [x] Printers persist after restart
- [x] Database auto-migrates from v1 to v2

### Should Have
- [x] Success notifications for all actions
- [x] Empty states with helpful messages
- [x] Visual indicators for default printer
- [x] Confirmation dialogs for destructive actions
- [x] Input validation on all forms

### Nice to Have
- [ ] Edit printer functionality (future)
- [ ] Test print button (future)
- [ ] Printer status indicators (future)
- [ ] Template export/import (future)

---

## 📊 Test Results Summary

| Category | Total Tests | Passed | Failed | Skipped |
|----------|-------------|--------|--------|---------|
| Keyboard Delete | 6 | - | - | - |
| Template Saving | 7 | - | - | - |
| Printer Management | 46 | - | - | - |
| Integration | 10 | - | - | - |
| Edge Cases | 11 | - | - | - |
| Platform | 11 | - | - | - |
| **TOTAL** | **91** | **-** | **-** | **-** |

---

## 🚀 Sign-Off

### Developer Sign-Off
- [ ] All code written and reviewed
- [ ] No compilation errors
- [ ] All files committed
- [ ] Documentation complete

### QA Sign-Off
- [ ] All test cases executed
- [ ] Critical bugs fixed
- [ ] Performance acceptable
- [ ] Ready for production

### Product Owner Sign-Off
- [ ] Features meet requirements
- [ ] User experience is satisfactory
- [ ] Documentation is adequate
- [ ] Approved for release

---

**Version**: 1.2.0
**Date**: November 9, 2025
**Status**: Ready for Testing
