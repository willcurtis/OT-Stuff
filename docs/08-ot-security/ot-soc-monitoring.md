# OT SOC Monitoring  
**Designing a Security Operations Strategy for OT/BMS Networks — Detection Rules, Log Sources, Alert Prioritisation**

An OT SOC (Security Operations Centre) must detect malicious behaviour without breaking building systems.  
The primary purpose is **early anomaly detection** and **alert triage**, not heavy automated response.

---

# 1. Objectives of OT SOC Monitoring

1. Detect protocol abuse  
2. Identify rogue devices  
3. Detect unauthorised writes  
4. Detect abnormal broadcast or multicast activity  
5. Monitor remote access and vendor behaviour  
6. Validate system integrity and availability  

OT SOC must provide **context-rich**, safety-aware monitoring.

---

# 2. OT SOC Data Sources (Log Inputs)

### 2.1 Network Infrastructure
- Switch syslog  
- Firewall logs (DMZ + OT boundary)  
- NetFlow/sFlow  

### 2.2 OT Gateways
- BACnet/SC hub logs  
- Modbus gateway logs  
- KNX router logs  
- MQTT broker logs  
- OPC-UA aggregator logs  
- LoRaWAN / wireless gateway logs  

### 2.3 Supervisors / Servers
- Application logs  
- Authentication logs  
- BACnet write logs  
- Modbus write logs  
- MQTT topic logs  
- OPC-UA session logs  

### 2.4 Remote Access / Identity
- Jump host logs  
- VPN logs  
- MFA provider logs  
- Session recording metadata  

### 2.5 Physical Security
- Riser access logs  
- Cabinet door sensors  
- CCTV integration (optional)  

---

# 3. Log Normalisation for OT

OT protocols produce non-standard, non-JSON logs.  
Normalisation creates consistency:

### Common Fields to Extract:

timestamp
device_id
protocol
src_ip
dst_ip
src_port
dst_port
object_type
object_name
function_code
write_value
read_value
session_id
auth_result

### Example normalised message:

2025-01-12T10:33:22Z level=warning
protocol=ModbusTCP
src_ip=10.0.45.22
dst_ip=10.0.50.10
function=WRITE_SINGLE_REGISTER
register=3012
value=99
result=success

Now the SOC can query OT protocol events just like syslog.

---

# 4. OT-Specific SIEM Use-Cases (Detection Rules)

These are the **must-have** OT SOC detection rules.

---

## 4.1 BACnet Write Detection

**Rule:** Alert on BACnet WriteProperty outside approved source list.

**Trigger Fields:**
- protocol="BACnet/IP"
- function="WriteProperty"
- src_ip !in (SUPERVISORS)

**Severity:** HIGH  
**Action:** Triage / containment

---

## 4.2 BACnet Broadcast Surge

**Rule:** Alert when broadcast packets > baseline + 50%

**Trigger Fields:**
- protocol="BACnet/IP"
- traffic_type="broadcast"
- pps > (baseline_pps * 1.5)

**Severity:** CRITICAL  
**Action:** Investigate storm source immediately

---

## 4.3 Modbus Unauthorized Writes

**Rule:** Alert on any Modbus write not from supervisor address.

**Trigger Fields:**
- protocol="ModbusTCP"
- function in (WriteSingleRegister, WriteMultipleRegisters)
- src_ip !in (SUPERVISORS)

**Severity:** CRITICAL  

---

## 4.4 MQTT Unauthorized Publish

**Rule:** Alert if any unknown client publishes to critical topics.

**Trigger Fields:**
- protocol="MQTT"
- action="publish"
- topic matches "building/+/critical/#"
- client_id !in (AUTHORIZED_CLIENTS)

**Severity:** HIGH  

---

## 4.5 OPC-UA Bad Session

**Rule:** Detect session creation with unknown certificate.

**Trigger Fields:**
- protocol="OPCUA"
- auth="certificate"
- cert_status="untrusted"

**Severity:** HIGH  

---

## 4.6 KNX Tunnel Exhaustion

**Rule:** Alert if KNX tunnelling session count > threshold.

**Trigger Fields:**
- protocol="KNX"
- session_count > configured_max

**Severity:** MEDIUM  

---

## 4.7 Lighting Protocol Flood Detection (Art-Net / sACN)

**Rule:** Alert if lighting multicast packets > baseline.

**Trigger Fields:**
- protocol in ("ArtNet","sACN")
- pps > (baseline_pps * 3)

**Severity:** HIGH  

---

## 4.8 Remote Access Anomaly

**Rule:** Vendor VPN login outside approved maintenance window.

**Trigger Fields:**
- src_ip in (VENDOR_POOL)
- timestamp not_between (08:00–18:00)
- action="login"

**Severity:** HIGH  

---

## 4.9 Unseen Device on OT Network

**Rule:** Alert if new MAC/IP discovered in OT VLAN.

**Trigger Fields:**
- device_new=true
- vlan in (OT_VLANS)

**Severity:** HIGH  

---

# 5. SIEM Dashboarding for OT

### Recommended Dashboards:

#### 5.1 Protocol Overview
- BACnet writes per hour  
- Modbus write events  
- MQTT client activity  
- OPC-UA session count  

#### 5.2 Network Health
- Broadcast pps per VLAN  
- Multicast pps per VLAN  
- Top talkers  
- Storm control hits  

#### 5.3 Remote Access
- VPN sessions  
- Jump host access  
- Time-of-day login heatmap  

#### 5.4 Device Integrity
- Firmware version distribution  
- Device uptime charts  
- Unauthorized service enumeration (if applicable)  

#### 5.5 MITRE ICS Mapping
- Alerts categorized by MITRE ATT&CK ICS tactic/technique  

---

# 6. Alert Prioritisation for OT

Not all alerts are equal.  
We categorise by **impact** and **safety risk**.

### Priority 1 – Immediate Action
- BACnet or Modbus writes from unauthorised IP  
- Excessive broadcast causing system instability  
- New unknown MAC on OT VLAN  
- Remote vendor login outside window  

### Priority 2 – Same-Day Review
- MQTT publish to restricted topics  
- OPC-UA cert untrusted events  
- KNX tunnelling limit exceeded  

### Priority 3 – Scheduled Review
- Excessive supervisor login failures  
- Low-level multicast anomalies  
- QoS drops, CRC error spikes  

---

# 7. OT Escalation Procedures

### Escalation Path

SOC Analyst → OT Engineer → OT Manager → Facilities → IT Security

### When to escalate to Facilities:
- HVAC outage  
- Lighting outage  
- Fire or lift integration fault  

### When to escalate to IT Security:
- Remote access misuse  
- Malware on supervisor  
- Cloud API compromise  

---

# 8. Daily / Weekly / Monthly SOC Tasks (OT Specific)

### Daily:
- Review Priority 1 alerts  
- Check new devices seen  
- Validate BACnet write logs  

### Weekly:
- Validate remote access patterns  
- Review broadcast/multicast summaries  
- Update risk dashboard  

### Monthly:
- Patch status review (servers)  
- Vulnerability exception audit  
- Test SIEM rule set changes  

---

# 9. OT SOC Integration with IT SOC

### OT SOC must be:
- Protocol-aware  
- Broadcast-aware  
- Safety-aware  

### IT SOC contributes:
- SIEM infrastructure  
- Identity/MFA logs  
- Firewall log correlation  
- Threat intel feed  

### Joint Responsibilities:
- Incident response  
- Threat hunting  
- Post-incident remediation  
- Quarterly review meetings  

---

# 10. OT SIEM Event Taxonomy

We categorise OT events for consistent handling:

| Category | Description |
|---------|------------|
| CONTROL_WRITE | BACnet/Modbus/OPC write detected |
| CONTROL_READ | Normal read activity |
| PROTOCOL_STORM | Broadcast/multicast flood |
| REMOTE_ACCESS | Login or session from vendor or engineer |
| DEVICE_NEW | Unknown MAC/IP detected |
| CERT_FAILURE | Certificate untrusted/rejected |
| CONFIG_CHANGE | Gateway/supervisor config updated |
| ANOMALY | Any deviation from baseline |

Use these categories in SIEM dashboards and alerting.

---

# 11. Sample SIEM Query Examples (Vendor Neutral)

### BACnet Rogue Write Query

WHERE protocol=“BACnet/IP”
AND action=“WriteProperty”
AND src_ip NOT IN SUPERVISORS

### Modbus Threat Query

WHERE protocol=“ModbusTCP”
AND function IN (“WRITE_SINGLE”, “WRITE_MULTIPLE”)
AND src_ip NOT IN ALLOWED_CLIENTS

### MQTT Poisoning Query

WHERE protocol=“MQTT”
AND action=“publish”
AND topic LIKE “building/%/critical/%”
AND client_id NOT IN AUTHORIZED_CLIENTS

### New Device Query

WHERE device_new=true
AND vlan IN OT_VLANS

---

# 12. Implementation Checklist

### Logging
- [ ] Switch syslog enabled  
- [ ] Firewall logs to SIEM  
- [ ] BACnet write logs normalised  
- [ ] MQTT broker logs forwarded  
- [ ] OPC-UA session logs collected  

### Detection Rules
- [ ] BACnet rogue write  
- [ ] Modbus unauthorized write  
- [ ] MQTT unauthorized publish  
- [ ] OPC-UA untrusted node access  
- [ ] New device detection  

### Dashboards
- [ ] Protocol overview  
- [ ] Network health  
- [ ] Remote access  
- [ ] MITRE ICS mapping  

### Escalation
- [ ] OT escalation runbook documented  
- [ ] Facilities escalation runbook documented  

---

# Summary

An OT SOC must:

- Know OT protocol behaviours  
- Monitor writes, not just connectivity  
- Detect broadcast and multicast anomalies  
- Track remote access granularity  
- Integrate physical + cyber data  

A mature OT SOC bridges the gap between **network security** and **building operations**, preventing disruption and catching threats early.
