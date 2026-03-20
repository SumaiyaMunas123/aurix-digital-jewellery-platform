# 🚀 FRONTEND RUNNING - LOGIN GUIDE

## ✅ App Status
- **Status**: Running in Chrome
- **URL**: Should appear in Chrome tab (usually http://localhost:XXXX)
- **Backend**: Connected to `http://localhost:5000/api`

---

## 🧪 TEST LOGIN

### Customer Account
1. **Email**: `customer@aurix.com`
2. **Password**: `123456`
3. **Click**: Login
4. **Expected**: Should navigate to customer dashboard

### Jeweller Account  
1. **Email**: `jeweller@aurix.com`
2. **Password**: `123456`
3. **Click**: Login
4. **Expected**: Should navigate to jeweller dashboard

---

## 🔧 TROUBLESHOOTING

### Issue: "Invalid Login Credentials"
**Cause**: Backend not connected or password mismatch
**Fix**:
1. Verify backend is running: `http://localhost:5000/api/auth/login`
2. Check credentials are correct (copy-paste to avoid typos)
3. Ensure customer@aurix.com user exists in database

### Issue: "Connection Refused"
**Cause**: Backend not running
**Fix**:
1. Open new terminal
2. Run: `cd backend; node server.js`
3. Verify port 5000 is listening

### Issue: Token not saving
**Cause**: Flutter SecureStorage or file system issue
**Fix**:
1. Check browser console (F12 → Console tab)
2. Look for storage errors
3. Try clearing browser cache: `Ctrl+Shift+Delete`

### Issue: Products not loading
**Cause**: Products endpoint not responding OR not returning data
**Fix**:
1. Test manually in browser: `http://localhost:5000/api/products`
2. Ensure backend has products in database
3. Check backend console for errors

### Issue: Gold rate not updating
**Cause**: Gold rate service (port 6000) not running
**Fix**:
1. Open new terminal
2. Run: `cd gold-rate; node src/index.js`
3. Test: `http://localhost:6000/gold-rate`

---

## 📱 WHAT SHOULD WORK NOW

✅ **Login** - Enter email and password  
✅ **Product Browsing** - See products after login  
✅ **Gold Rates** - Should show current rates  
✅ **JWT Token** - Automatically saved and sent with requests  
✅ **Logout** - Clears token from secure storage  

---

## 🔍 Debug Console

To see what's happening:
1. Press **F12** in Chrome
2. Go to **Console** tab
3. Look for:
   - API requests being logged
   - Token storage messages
   - Any error messages

---

## 📊 Backend Ports Reference

| Service | Port | URL |
|---------|------|-----|
| Main Backend | 5000 | `http://localhost:5000` |
| AI Backend | 7000 | `http://localhost:7000` |
| Gold Rate | 6000 | `http://localhost:6000` |

---

## ⚠️ IF LOGIN FAILS

1. First, verify backend is running on port 5000
2. Check that setup script created users:
   - `node setupTestUsers.js` (if needed to recreate)
3. Verify credentials match exactly
4. Check browser network tab (F12 → Network) to see actual error response

---

**Need to restart?**
- Press `R` in terminal running Flutter to hot reload
- Press `Q` to quit
- Run `flutter run -d chrome` again to restart
