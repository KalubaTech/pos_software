# 🧪 Testing KalooMoney Wallet in Checkout

## Quick Test Guide

### ✅ Prerequisites
- [ ] App is running
- [ ] Logged in as cashier
- [ ] Wallet is enabled (Settings → Wallet → Enable)

---

## 🎯 Test Scenario: Mobile Money Checkout

### Step 1: Add Items to Cart
1. Navigate to **POS** view
2. Add any products to cart
3. Verify items appear in cart with prices

### Step 2: Start Checkout
1. Click **"Checkout"** button
2. Checkout dialog opens
3. See payment methods: Cash, Card, **Mobile**, Other

### Step 3: Select Mobile Payment
1. Click on **"Mobile"** payment method
2. Mobile payment option should be highlighted
3. Click **"Complete Payment"** button
4. **NEW: Mobile Money Payment dialog appears!** ✨

### Step 4: Fill Payment Details

You should see a beautiful dialog with:

```
┌─────────────────────────────────────────┐
│ 📱 Mobile Money Payment                 │
│    Pay with KalooMoney Wallet           │
├─────────────────────────────────────────┤
│                                         │
│        Amount to Pay                    │
│           K 1,250.00                    │
│      (Large, centered, blue box)        │
│                                         │
│  Customer Name: [____________]          │
│  Phone Number:  [____________] *        │
│  Payment Method: [Airtel Money ▼]      │
│                                         │
│  ℹ️  Payment will be processed through  │
│     your KalooMoney business wallet     │
│                                         │
│  [Cancel]           [Pay Now]           │
└─────────────────────────────────────────┘
```

**Fill in:**
- Customer Name: `John Doe` (optional)
- Phone Number: `0977123456` (required)
- Payment Method: Select from dropdown
  - Airtel Money
  - MTN Mobile Money
  - Zamtel Kwacha

### Step 5: Process Payment
1. Click **"Pay Now"** button
2. Brief "Processing payment..." dialog appears
3. Payment is processed through wallet
4. Success dialog should appear with green checkmark

### Step 6: Verify Results

**Check 1: Transaction Completed**
- [ ] Success message displayed
- [ ] Cart is cleared
- [ ] Back to POS view

**Check 2: Wallet Transaction**
1. Go to **Settings** → **Wallet**
2. Click **"View Transactions"**
3. See new transaction with:
   - Type: Deposit
   - Amount: Sale total
   - Customer Phone: 0977123456
   - Payment Method: Airtel Money (or selected)
   - Status: Completed
   - Charge: (1.5% or 2.0% or 1.8%)

**Check 3: POS Sale Record**
1. Go to **Reports** → **Transactions**
2. Find the recent transaction
3. Verify:
   - Payment Method: Mobile
   - Items match cart
   - Total is correct
   - Customer phone saved

---

## 🧪 Test Cases

### Test Case 1: Happy Path ✅
**Steps:**
1. Add items to cart
2. Select Mobile payment
3. Fill valid phone (0977123456)
4. Select Airtel Money
5. Click Pay Now

**Expected:**
- ✅ Payment processes successfully
- ✅ Transaction recorded in wallet
- ✅ Sale recorded in POS
- ✅ Cart cleared

---

### Test Case 2: Missing Phone Number ❌
**Steps:**
1. Add items to cart
2. Select Mobile payment
3. Leave phone number empty
4. Click Pay Now

**Expected:**
- ❌ Red error notification
- ❌ Message: "Please enter a phone number"
- ❌ Payment does not process

---

### Test Case 3: Wallet Not Enabled ⚠️
**Steps:**
1. Disable wallet (if enabled)
2. Add items to cart
3. Select Mobile payment
4. Fill valid details
5. Click Pay Now

**Expected:**
- ⚠️ Orange warning notification
- ⚠️ Message: "KalooMoney wallet is not set up. Please enable it in Settings."
- ❌ Payment does not process

---

### Test Case 4: Different Payment Methods 💳
**Test with each operator:**

**4a. Airtel Money (1.5% charge)**
- Phone: 0977123456
- Expected charge: Amount × 0.015

**4b. MTN Mobile Money (2.0% charge)**
- Phone: 0966123456
- Expected charge: Amount × 0.020

**4c. Zamtel Kwacha (1.8% charge)**
- Phone: 0955123456
- Expected charge: Amount × 0.018

---

### Test Case 5: Optional Customer Name 📝
**Test 5a: With Name**
- Name: John Doe
- Phone: 0977123456
- Expected: Both saved in transaction

**Test 5b: Without Name**
- Name: (empty)
- Phone: 0977123456
- Expected: Only phone saved

---

## 📊 Verification Checklist

### Visual Checks:
- [ ] Mobile Money dialog is responsive
- [ ] Amount display is large and clear
- [ ] Form fields have proper labels
- [ ] Icons show correctly
- [ ] Colors match app theme (dark/light mode)
- [ ] Info box with blue background appears
- [ ] Buttons are properly styled

### Functional Checks:
- [ ] Phone validation works
- [ ] Dropdown selection works
- [ ] Cancel button closes dialog
- [ ] Pay Now processes payment
- [ ] Loading indicator appears during processing
- [ ] Success/error messages show correctly

### Data Checks:
- [ ] Wallet balance increases by net amount
- [ ] Charge calculated correctly for each operator
- [ ] Transaction timestamp is accurate
- [ ] Reference ID is unique
- [ ] Customer info saved correctly

---

## 🎓 What to Look For

### ✅ Good Signs:
- Dialog opens instantly when Mobile selected
- Form fields are clear and labeled
- Amount is prominently displayed
- Processing indicator shows during payment
- Success message appears after payment
- Wallet transaction recorded
- POS sale recorded

### ❌ Red Flags:
- Dialog doesn't open
- Form fields missing or broken
- Amount not showing
- Payment hangs indefinitely
- No success/error message
- Transaction not recorded
- Error messages unclear

---

## 💡 Tips

1. **Enable wallet first** - Go to Settings → Wallet before testing
2. **Use realistic data** - Phone numbers like 0977123456
3. **Check both records** - Wallet transactions AND POS sales
4. **Test all operators** - Verify charges are different
5. **Try edge cases** - Empty fields, invalid data, etc.

---

## 🐛 Troubleshooting

### Issue: Dialog doesn't appear
**Solution:** Check that import was added: `import '../../controllers/wallet_controller.dart';`

### Issue: "WalletController not found"
**Solution:** Verify wallet is initialized in main.dart (it should be!)

### Issue: Payment succeeds but transaction not recorded
**Solution:** Check wallet transactions - should be there even if POS record fails

### Issue: Charges not calculating
**Solution:** Check WalletService.calculateCharge() - should return different % for each operator

---

## 📝 Expected Console Output

When you make a payment, watch the console for:

```
[WALLET] Processing deposit...
[WALLET] Amount: 1250.00
[WALLET] Charge: 18.75 (1.5%)
[WALLET] Net: 1231.25
[WALLET] New balance: 5231.25
[CART] Checkout initiated
[CART] Payment method: PaymentMethod.mobile
[CART] Transaction saved: t1700123456789
[PRINT] Receipt generated
✅ Transaction completed successfully
```

---

## 🎉 Success Criteria

You'll know it's working when:
1. ✅ Dialog appears when Mobile is selected
2. ✅ Form is easy to fill
3. ✅ Payment processes smoothly
4. ✅ Success message shows
5. ✅ Wallet balance updates
6. ✅ Transaction appears in history
7. ✅ No errors in console

---

**Happy Testing!** 🚀

If everything works as described above, the KalooMoney wallet integration is complete and functional!
