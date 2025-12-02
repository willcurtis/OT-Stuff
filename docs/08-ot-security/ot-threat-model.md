# OT Threat Model  
**Adversaries, Entry Points, Protocol Weaknesses, Attack Chains, MITRE ICS Mapping, Likelihood & Impact Analysis**

OT networks traditionally operated in isolation. Modern smart buildings expose OT systems through IP networks, cloud portals, and remote access channels—creating new, critical security risks.

This threat model outlines the major adversaries, attack vectors, protocol-level vulnerabilities, and systemic weaknesses that affect building automation systems today.

---

# 1. OT Threat Landscape Overview

### OT systems are attractive targets because:
- They control environmental and safety systems  
- They are often poorly secured  
- They use legacy protocols without authentication  
- Outages cause significant disruption  
- They provide a stepping stone into corporate IT  

### OT has unique constraints:
- Controllers cannot be easily patched  
- Systems must remain operational 24/7  
- High uptime and safety requirements  
- Vendors often require remote access  
- Long lifecycle (20+ years)  

OT security is about *risk minimisation* and *blast radius reduction*, not zero risk.

---

# 2. Adversary Categories

### 2.1 Opportunistic Attackers
- Internet-wide scans (Shodan, Censys)  
- Automated malware  
- Credential-stuffing bots  
- Ransomware operators  

### 2.2 Targeted Attackers
- Nation-state actors  
- Advanced persistent threats (APTs)  
- Professional cybercriminal groups  

### 2.3 Insider Threats
- Facilities staff  
- Contractors and vendors  
- Misconfigured access by junior personnel  

### 2.4 Physical Attackers
- Tampering with riser cabinets  
- Connecting rogue devices  
- Removing UPS power  
- Triggering fail-open pathways  

### 2.5 Supply Chain / Vendor Compromise
- Compromised cloud vendor  
- Malicious firmware update  
- Vendor remote access breach  
- Backdoor in third-party library  

---

# 3. OT Attack Surfaces

## 3.1 Network Attack Surfaces
- Exposed BACnet/IP  
- Modbus TCP without ACLs  
- KNX IP multicast leakage  
- MQTT brokers without authentication  
- OPC-UA without TLS  
- VLAN misconfiguration  
- Flat networks  
- Rogue wireless gateways  
- Default SNMP community strings  

## 3.2 Server/Application Attack Surfaces
- Outdated BMS supervisors  
- SQL/InfluxDB without access controls  
- Web UIs without MFA  
- Hardcoded credentials  
- Vendor software with known CVEs  
- Weak TLS configurations  

## 3.3 Remote Access Attack Surfaces
- Insecure VPN portals  
- TeamViewer/AnyDesk backdoors  
- Jump hosts without MFA  
- No session recording  
- Password reuse across vendors  

## 3.4 Physical Attack Surfaces
- Unlocked risers  
- Accessible patch panels  
- USB ports on OT servers  
- Physical console on controllers  
- Unprotected plant rooms  

---

# 4. Common Weaknesses in BMS/OT Deployments

### 4.1 Flat Networks (“Everything in one VLAN”)
- Complete lack of broadcast containment  
- Malware propagates easily  
- BACnet storms cripple entire systems  
- Cross-system compromise trivial  

### 4.2 Default Credentials
- BACnet devices with vendor defaults  
- KNX IP routers without passwords  
- Modbus gateways with admin/admin  
- UPS/web consoles with default creds  

### 4.3 Legacy Protocols with No Security
- BACnet/IP unauthenticated  
- Modbus TCP unauthenticated, unencrypted  
- KNX without KNX Secure  
- DALI/DMX have no authentication at all  
- LoRaWAN gateways misconfigured  

### 4.4 Cloud Dependencies
- Vendor cloud outages stop OT control  
- Cloud agents bypass firewalls  
- Unencrypted telemetry  
- Vendor compromise becomes building compromise  

### 4.5 Remote Access Failures
- Always-on vendor accounts  
- Weak VPN  
- Single-factor RDP  
- No user separation  
- No logging or accountability  

---

# 5. Protocol-Level Threats & Attack Scenarios

---

## 5.1 BACnet/IP Threats

### Weaknesses:
- No authentication  
- Cleartext  
- Broadcast-heavy  
- Easy device impersonation  

### Attacks:
- Rogue “I-Am” device impersonation  
- Who-Is flood / broadcast storm  
- Forced point writes (e.g., disable AHU)  
- Change of schedule or setpoints  
- Discovery-based reconnaissance  

### Impact:
- HVAC outage  
- Energy waste  
- Safety system malfunction  
- Lateral movement via BMS server  

---

## 5.2 Modbus TCP Threats

### Weaknesses:
- No authentication  
- No integrity checking  
- No confidentiality  
- Simple function codes  

### Attacks:
- Unauthorized register writes  
- Overwriting coil states  
- Spoofed responses  
- Man-in-the-middle altering values  

### Impact:
- Pumps, valves misoperate  
- Incorrect readings (e.g., metering fraud)  
- Equipment damage  

---

## 5.3 KNX IP Threats

### Weaknesses:
- Multicast broadcast by default  
- No encryption unless KNX Secure is used  
- Rogue tunnelling sessions possible  

### Attacks:
- Switch lighting scenes  
- Disable safety lighting  
- Eavesdrop motion sensor data  

### Impact:
- Privacy breach  
- Lighting outages  
- Security failures  

---

## 5.4 MQTT Threats

### Weaknesses:
- Brokers often misconfigured  
- Anonymous publish allowed  
- Retained messages abused  
- No TLS  

### Attacks:
- Inject false sensor data  
- Control messages to actuators  
- Topic wildcard takeover  
- Persistent retained payload injection  

### Impact:
- Manipulated environmental data  
- Cross-system malfunction  
- “Data poisoning” of analytics  

---

## 5.5 OPC-UA Threats

### Weaknesses:
- Self-signed certificates  
- Outdated cipher suites  
- Misconfigured access control  

### Attacks:
- Node browsing (information leak)  
- Altering exposed variables  
- MITM on insecure deployment  

### Impact:
- Bad decisions from analytics  
- Incorrect supervisory actions  

---

## 5.6 Lighting System Threats (DALI, DMX, sACN)

### Weaknesses:
- No authentication at all  
- DMX allows frame injection  
- Art-Net broadcast storm risk  
- sACN multicast floods  

### Attacks:
- Blackout of lighting  
- Flickering to annoy occupants  
- Scene manipulation  
- Distracting lighting in safety areas  

Impact mostly operational but can become safety-related.

---

# 6. Attack Chains (End-to-End Exploitation Examples)

---

## 6.1 Attack Chain A: HVAC → BMS → OT → IT

1. Exploit BACnet write access  
2. Modify AHU points to disrupt HVAC  
3. Gain access to BMS supervisor credentials (weak auth)  
4. Pivot to OT servers  
5. Use shared AD trust or SMB vulnerabilities  
6. Move into IT corporate network  

### Result:
Full compromise of IT from HVAC system.

---

## 6.2 Attack Chain B: Vendor Remote Access → Jump Host Bypass → Controller Rewrite

1. Vendor account leaked  
2. VPN access granted automatically  
3. Vendor uses RDP without MFA  
4. Uploads malicious firmware onto controller  
5. Controller bricks or misbehaves  
6. System outage  

### Result:
Loss of control, long lead-time remediation.

---

## 6.3 Attack Chain C: MQTT Data Poisoning → Analytics → HVAC Misoperation

1. Attacker publishes fake occupancy/CO₂ data  
2. Supervisor believes building is empty/full  
3. Ventilation changes  
4. Energy waste or poor IAQ  
5. Automated optimisation layer exploits false inputs  

---

## 6.4 Attack Chain D: KNX Multicast Flood → Lighting Failure

1. Rogue device floods KNX multicast  
2. IP router overloaded  
3. Building lighting becomes unresponsive  

---

## 6.5 Attack Chain E: Cloud Dependency Failure

1. Vendor cloud outage  
2. Controllers unable to retrieve logic or schedules  
3. Lighting/HVAC stops operating  
4. No local override available  

---

# 7. MITRE ATT&CK for ICS Mapping (Relevant Techniques)

### Initial Access
- T0814 – Valid Accounts  
- T0807 – Wireless Compromise  
- T0819 – Remote Services  

### Execution
- T0853 – Modify Controller Tasking  
- T0829 – Abuse of Functionality  

### Persistence
- T0857 – Modify Authentication Process  

### Privilege Escalation
- T0890 – Brute Force  
- T0891 – Credential Stuffing  

### Lateral Movement
- T0884 – Remote File Transfer  
- T0881 – Pass-Through Authentication  

### Collection
- T0835 – Network Sniffing  
- T0842 – Input Capture  

### Impact
- T0820 – Loss of Safety  
- T0828 – Manipulation of Control  
- T0855 – Shutdown/Blackout  

---

# 8. Likelihood vs Impact Assessment for OT Threats

| Threat | Likelihood | Impact | Notes |
|--------|------------|--------|-------|
| BACnet unauthorised write | High | High | Most common OT weakness |
| Modbus register manipulation | Medium | High | Gateways often unprotected |
| MQTT broker compromise | Medium | High | Growing IoT risk |
| Vendor remote access abuse | Medium | Very High | Past incidents repeatedly |
| KNX multicast flood | Medium | Medium | Operational outage |
| Lighting injection | Medium | Low–Medium | Annoying but not catastrophic |
| OT → IT pivot | Low–Medium | Very High | Major corporate breach |
| Cloud vendor compromise | Low | Very High | Hard to detect, systemic |
| Physical tampering | Medium | Medium | Often overlooked |

---

# 9. Risk Themes

### 9.1 Lack of Segmentation
Broadcast domains become attack domains.

### 9.2 Insecure Default Protocols  
Many OT protocols were not designed for IP-era threats.

### 9.3 Poor Remote Access Controls  
One of the most exploited weaknesses.

### 9.4 Weak Vendor Ecosystem  
Small vendors often lack secure development practices.

### 9.5 Visibility Gaps  
Without monitoring, attacks look like “faults”.

---

# 10. Implementation Checklist (Threat Mitigation)

### Network Hardening
- [ ] L3 segmentation between buildings  
- [ ] VLAN per system  
- [ ] Firewalls with strict ACLs  
- [ ] No routing of lighting multicast  

### Protocol Security
- [ ] BACnet/SC preferred  
- [ ] MQTT over TLS + ACLs  
- [ ] Modbus TCP firewalled  
- [ ] KNX Secure for future deployments  

### Remote Access Security
- [ ] Jump host mandated  
- [ ] MFA everywhere  
- [ ] Vendor access time-boxed  
- [ ] Session recording enabled  

### Server/Application Security
- [ ] Hardened OS builds  
- [ ] Certificate management  
- [ ] Patch windows established  
- [ ] Remove default credentials  

### Physical Security
- [ ] Locked risers  
- [ ] Cable routes secured  
- [ ] Tamper sensors monitored  

---

# Summary

Modern OT/BMS environments face a wide spectrum of cyber threats, from opportunistic attackers scanning the Internet to targeted adversaries exploiting protocol weaknesses.

Key risk factors:
- Legacy unauthenticated protocols  
- Poor segmentation  
- Insecure vendor access  
- Lack of monitoring  
- Overreliance on cloud services  

The recommended architecture across this manual—L3 segmentation, OT DMZ, BACnet/SC, zero-trust access, and strong monitoring—directly addresses the vulnerabilities identified in this threat model.
