# OT Network Discovery Using Nmap

This guide provides a structured, low-risk approach for discovering and enumerating Operational Technology (OT) and Building Management Systems (BMS) controllers using Nmap and the Nmap Scripting Engine (NSE).

It focuses on:
- BACnet
- Modbus/TCP
- Siemens S7
- Niagara Fox
- SNMP telemetry
- TLS configuration assessment
- Host fingerprinting and service inventory

---

## ⚠️ Operational Warning

OT networks are *fragile* by design.

**DO NOT** use intrusive or brute scripts without approval.

Use:
- read-only enumeration
- minimal packet load
- narrow scope
- limited parallelism
- safe NSE script categories

---

# 1) Install Nmap

macOS (Homebrew):
```bash
brew install nmap
```

Ubuntu / Debian:
```bash
sudo apt install nmap
```

---

# 2) Core OT Discovery Strategy

1. Identify industrial protocol endpoints  
2. Profile hosts / firmware / vendors  
3. Enumerate BMS controllers at protocol level  
4. Export results for analysis

Nmap is ideal for stage **1–3**.

---

# 3) Recommended Scan Settings

### Common OT ports

| Protocol            | Port     |
|---------------------|----------|
| BACnet              | 47808/UDP|
| Modbus/TCP          | 502/TCP  |
| Siemens S7comm      | 102/TCP  |
| SNMP                | 161/UDP  |
| Niagara Fox         | 1911/TCP |
| Niagara HTTPS       | 4911/TCP |
| Ethernet/IP (CIP)   | 44818/TCP|
| DNP3                | 20000/TCP/UDP |

---

# 4) Low-Risk OT Discovery Scan

```bash
sudo nmap -sS -sU   -p 47808,502,102,161,1911,4911,44818,20000   -sV   --script=safe   <CIDR>
```

Outputs:
- device detection
- vendor info
- service fingerprints
- firmware hints
- SNMP banners

This is the recommended starting point.

---

# 5) BACnet Enumeration

### BACnet Device Info
```bash
sudo nmap -sU -p 47808 --script bacnet-info <target>
```

### BACnet Object Enumeration
```bash
sudo nmap -sU -p 47808 --script bacnet-discover <target>
```

**Note:** `bacnet-discover` may be intrusive on legacy devices.

---

# 6) Modbus Enumeration

### Discover Modbus Devices
```bash
sudo nmap -sT -p 502 --script modbus-discover <target>
```

Outputs:
- vendor
- slave IDs
- supported function codes

---

# 7) Siemens S7 PLC Discovery

```bash
sudo nmap -sT -p 102 --script s7-info <target>
```

Useful for:
- product family
- module type
- firmware

---

# 8) Niagara Fox Enumeration

```bash
sudo nmap -sT -p 1911 --script fox-info <target>
```

---

# 9) Full OT Discovery Command Pack

### Command Pack (copy/paste)

```bash
sudo nmap -sS -sU   -p 47808,502,102,161,1911,4911,44818,20000   -sV   -O   --script=safe,discovery   --reason   --stats-every=30s   <CIDR>
```

---

# 10) Exporting Results

### Normal
```
-oN ot_scan.txt
```

### JSON
```
-oJ ot_scan.json
```

### XML
```
-oX ot_scan.xml
```

Example combined:
```bash
sudo nmap -sV --script=safe   -p47808,502   -oA ot_discovery   10.10.0.0/16
```

Produces:
- ot_discovery.nmap
- ot_discovery.xml
- ot_discovery.gnmap

---

# 11) Tips for OT Safety

- scan off-peak only
- do not use brute scripts
- avoid writing Modbus coils
- avoid BACnet-write-property
- avoid parallel scan overload (`--min-parallelism`)
- never assume resilience

---

# 12) Analyst Workflow

**Phase 1**
- OT-safe scan
- reduce false positives
- identify scope

**Phase 2**
- enumerate BACnet
- enumerate Modbus
- inspect SNMP

**Phase 3**
- document endpoints
- classify devices
- isolate OT broadcast domains
- plan segmentation improvements

---

# 13) Useful NSE Script List

| Script                   | Protocol  |
|--------------------------|-----------|
| bacnet-info              | BACnet    |
| bacnet-discover          | BACnet    |
| modbus-discover          | Modbus    |
| modbus-read-*            | Modbus    |
| s7-info                  | Siemens   |
| fox-info                 | Niagara   |
| snmp-info                | SNMP      |

---

# License

MIT
