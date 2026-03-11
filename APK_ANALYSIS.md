# 📱 Canaan Avalon App Analysis

## 📲 App Information

**Package:** `com.canaan.avalon`
**Source:** Google Play Store
**URL:** https://play.google.com/store/apps/details?id=com.canaan.avalon

---

## 🔍 How to Download & Analyze

### 1. Download APK

**Option A: From Phone**
```bash
# Connect phone via USB
adb pull /data/app/com.canaan.avalon*/base.apk /home/smile/avalon_app.apk
```

**Option B: Online**
```
https://apkpure.com/search?q=com.canaan.avalon
https://apkmirror.com/apk/canaan/
```

### 2. Extract APK

```bash
# APK is just a ZIP file!
unzip avalon_app.apk -d avalon_app_extracted/

# List contents
ls -la avalon_app_extracted/
```

### 3. Decompile with JADX

```bash
# Download: https://github.com/skylot/jadx
jadx -d avalon_src avalon_app.apk

# Now browse Java source code
ls avalon_src/com/canaan/avalon/
```

---

## 🎯 What to Look For

### API Commands

Search in decompiled code:

```bash
grep -r "privileged" avalon_src/
grep -r "ascset" avalon_src/
grep -r "setconfig" avalon_src/
grep -r "set_test_mode" avalon_src/
grep -r "4028" avalon_src/  # API port
grep -r "get_minerinfo" avalon_src/
```

### Network Configuration

```bash
grep -r "http://" avalon_src/
grep -r "websocket" avalon_src/
grep -r "socket" avalon_src/
grep -r "192.168" avalon_src/
```

### Hidden Features

```bash
grep -r "debug" avalon_src/
grep -r "test.*mode" avalon_src/
grep -r "admin" avalon_src/
grep -r "factory" avalon_src/
grep -r "overclock\|freq\|voltage" avalon_src/
```

---

## 🔬 Expected Findings

### App Probably Uses:

1. **Port 4028** - cgminer API
2. **Port 80** - Web interface (get_minerinfo.cgi)
3. **Port 9090** - SWUpdate (firmware updates)

### API Commands App Uses:

```json
{"command":"version"}
{"command":"summary"}
{"command":"devs"}
{"command":"privileged","arg":"ascset=0,750,1350"}
{"command":"privileged","arg":"setconfig=..."}
```

---

## 📋 Action Plan

### Step 1: Download APK

```bash
# Use adb if you have the app installed
adb backup -apk com.canaan.avalon
# Or download from APKPure
```

### Step 2: Analyze

```bash
jadx -d avalon_src avalon_app.apk
cd avalon_src

# Search for API calls
find . -name "*.java" -exec grep -l "privileged\|ascset\|4028" {} \;
```

### Step 3: Document

- What commands does app send?
- What parameters does it use?
- Are there hidden settings?
- What's the max frequency/voltage?

### Step 4: Integrate

- Add found commands to `advanced.html`
- Create presets based on app settings
- Update documentation

---

## 🎁 What We'll Learn

1. **Official privileged commands** from Canaan
2. **Safe parameters** for overclocking
3. **Hidden features** not in web interface
4. **API endpoints** we didn't know about

---

## 🔗 Tools & Links

- **JADX:** https://github.com/skylot/jadx
- **APKPure:** https://apkpure.com/
- **APKMirror:** https://www.apkmirror.com/
- **Bytecode Viewer:** https://github.com/Konloch/bytecode-viewer

---

*Created: 2026-03-11*
*Package: com.canaan.avalon*
