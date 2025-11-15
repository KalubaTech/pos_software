# Payment Dialog Auto-Scroll Feature

## Feature Overview
When payment is initiated, the payment dialog closes and the page automatically scrolls to the top to show the status checking card with a loading animation.

---

## What Was Implemented

### 1. Changed SubscriptionView to StatefulWidget
**Before:** `StatelessWidget`
**After:** `StatefulWidget`

**Reason:** Need to manage ScrollController lifecycle properly

```dart
class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});
  
  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  // ... rest of code
}
```

### 2. Added ScrollController to SingleChildScrollView
```dart
body: SingleChildScrollView(
  controller: _scrollController,  // Added this
  padding: EdgeInsets.all(24),
  child: Column(...),
)
```

### 3. Auto-Scroll on Payment Check Start
```dart
Future<void> _checkPaymentStatus({...}) async {
  // Show loading UI
  isCheckingPayment.value = true;
  checkingReference.value = lencoReference ?? reference;
  checkingAttempt.value = 0;
  maxAttempts.value = 5;
  
  // Scroll to top to show the checking status card
  await Future.delayed(Duration(milliseconds: 100)); // Small delay
  if (_scrollController.hasClients) {
    _scrollController.animateTo(
      0,  // Scroll to top (position 0)
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
  
  // Continue with status checking...
}
```

---

## User Flow

### Complete Flow Visualization

```
1. User fills payment details and clicks "Pay K500"
   ↓
2. Payment API called
   ↓
3. Payment Dialog CLOSES immediately ✅
   ↓
4. Orange snackbar: "Approval Required"
   ↓
5. Page SCROLLS TO TOP (animated) ✅
   ↓
6. Status Checking Card appears at top:
   ┌────────────────────────────────────┐
   │  🔄 Checking Payment Status        │
   │  ━━━━━━━━━━░░░░░░░░░░ 40%        │
   │  Attempt 2 of 5                    │
   │  Ref: 2531808060                   │
   └────────────────────────────────────┘
   ↓
7. Card updates in real-time:
   - Progress bar fills up
   - Attempt counter increases
   - Spinner animates
   ↓
8. After 5 attempts (25 seconds):
   
   Option A: Payment Found & Completed
   → Green success message
   → Subscription activates
   → Status card disappears
   
   Option B: Payment Found & Failed
   → Red error message with reason
   → Status card disappears
   
   Option C: Transaction Not Found
   → Dialog with manual check button
   → User can check manually
```

---

## Technical Details

### Scroll Animation Parameters
- **Target Position:** 0 (top of page)
- **Duration:** 500 milliseconds
- **Curve:** `Curves.easeInOut` (smooth acceleration/deceleration)
- **Delay Before Scroll:** 100ms (ensures UI state updates first)

### Safety Check
```dart
if (_scrollController.hasClients) {
  // Only scroll if controller is attached to a scrollable widget
  _scrollController.animateTo(...);
}
```

**Why:** Prevents errors if the widget is disposed before scrolling

---

## Benefits

### 1. Better User Experience ✨
- **No Manual Scrolling:** User doesn't need to scroll up to see status
- **Immediate Feedback:** Dialog closes → status card appears instantly
- **Focus on Important Info:** Auto-focus on the checking status

### 2. Clear Visual Flow 📱
```
Payment Dialog (bottom/center)
         ↓ CLOSES
Page View (scrolls up)
         ↓ SHOWS
Status Card (top)
```

### 3. Professional Feel 💼
- Smooth animations
- Coordinated UI transitions
- Predictable behavior

---

## Testing Scenarios

### Test 1: Normal Payment Flow
1. Open Subscription tab
2. Scroll down to any plan
3. Click "Pay K500"
4. Enter phone number
5. Click Pay button
6. **Verify:**
   - ✅ Dialog closes immediately
   - ✅ Orange snackbar appears
   - ✅ Page scrolls to top smoothly (500ms animation)
   - ✅ Status checking card visible at top
   - ✅ Progress bar animates
   - ✅ Attempt counter updates (1/5, 2/5, etc.)

### Test 2: Scroll Position Maintained if Not Checking
1. Open Subscription tab
2. Scroll to middle of page
3. Don't initiate payment
4. **Verify:**
   - ✅ Scroll position stays where it is
   - ✅ No unexpected scrolling

### Test 3: Already at Top
1. Open Subscription tab (already at top)
2. Click Pay button
3. **Verify:**
   - ✅ Page doesn't jump
   - ✅ Status card appears smoothly
   - ✅ No jarring movements

### Test 4: Quick Completion
1. Initiate payment
2. Approve immediately on phone (completes within 5 seconds)
3. **Verify:**
   - ✅ Page scrolled to top
   - ✅ Status card appears briefly
   - ✅ Success message shows
   - ✅ Status card disappears

---

## Code Locations

### File: `lib/views/settings/subscription_view.dart`

**Key Changes:**
1. **Lines 13-31:** Changed to StatefulWidget with ScrollController
2. **Line 46:** Added `controller: _scrollController` to SingleChildScrollView
3. **Lines 820-827:** Auto-scroll logic in `_checkPaymentStatus()`

---

## Visual Flow Diagram

```
┌─────────────────────────────────────────┐
│  Subscription Plans (Header)             │ ← Target scroll position (0)
├─────────────────────────────────────────┤
│  🔄 Checking Payment Status (NEW)       │ ← Appears when checking
│     ━━━━━━░░░░░░░░░░░░░░ 30%          │
│     Attempt 2 of 5                      │
│     Ref: 2531808060                     │
├─────────────────────────────────────────┤
│  Current Subscription (if any)           │
├─────────────────────────────────────────┤
│  Plan Cards                              │
│  • Monthly - K500                        │
│  • Yearly - K1,500                       │
│  • 2-Year - K2,400                       │
│                                          │
│  [Click Pay opens dialog] ────┐         │
└────────────────────────────────│─────────┘
                                 │
                                 ↓
                    ┌────────────────────────┐
                    │  Payment Dialog        │
                    │  • Phone: _______      │
                    │  • Method: [v]         │
                    │  [Cancel] [Pay K500]   │
                    └────────────────────────┘
                                 │
                    User clicks "Pay K500"
                                 │
                                 ↓
                    Dialog CLOSES & Page SCROLLS UP
                                 ↓
┌─────────────────────────────────────────┐
│  Subscription Plans (Header)             │ ← User sees this
├─────────────────────────────────────────┤
│  🔄 Checking Payment Status             │ ← And this (NEW)
│     ━━━━━━━━━━░░░░░░░░░░ 50%          │
│     Attempt 3 of 5                      │
│     Ref: 2531808060                     │
└─────────────────────────────────────────┘
```

---

## Animation Timing

| Event | Timing | Duration |
|-------|--------|----------|
| Payment API call | 0ms | ~500-1000ms |
| Dialog closes | ~500ms | Instant |
| Orange snackbar appears | ~500ms | 5 seconds |
| Scroll to top starts | ~600ms (100ms delay) | 500ms |
| Status card appears | ~600ms | Instant (FadeInDown: 300ms) |
| First status check | ~5600ms | ~1000ms |
| Total before first check | ~6-7 seconds | - |

---

## Edge Cases Handled

### 1. ScrollController Not Ready
```dart
if (_scrollController.hasClients) {
  // Only scroll if controller attached
}
```

### 2. Widget Disposed During Scroll
- `dispose()` method properly cleans up ScrollController
- Prevents memory leaks

### 3. Multiple Rapid Payments
- Previous status checking completes before new one starts
- `isCheckingPayment` flag prevents overlaps

### 4. User Scrolls While Checking
- User can still manually scroll
- Status card stays at top
- User can scroll back down to see plans

---

## Configuration

### Adjust Scroll Animation Speed
```dart
_scrollController.animateTo(
  0,
  duration: Duration(milliseconds: 500),  // Change this (default: 500ms)
  curve: Curves.easeInOut,                // Change curve if needed
);
```

**Options for duration:**
- Fast: 300ms
- Normal: 500ms (current)
- Slow: 800ms

**Curve options:**
- `Curves.easeInOut` - Smooth (current)
- `Curves.linear` - Constant speed
- `Curves.fastOutSlowIn` - Quick start, slow end
- `Curves.bounceOut` - Bouncy effect

---

## Summary

### What Happens Now ✅

1. **User clicks Pay** → Payment dialog shown
2. **User clicks Pay button** → Payment initiated
3. **Dialog closes immediately** → User not blocked
4. **Page scrolls to top** → Smooth 500ms animation
5. **Status card appears** → Shows real-time checking progress
6. **Progress updates** → Every 5 seconds for 5 attempts
7. **Result shown** → Success/Failed/Manual check dialog

### Benefits
- ✅ Dialog closes when done (not blocking)
- ✅ Auto-scroll to status card (no manual scrolling needed)
- ✅ Smooth animation (professional feel)
- ✅ Real-time progress (user knows what's happening)
- ✅ Clear visual flow (dialog → scroll → status)

---

**Implemented:** November 14, 2025
**Status:** ✅ Complete and Ready for Testing
**File:** `subscription_view.dart`
