# Incident Response for OT  
**Response Playbooks for BACnet Storms, Modbus Attacks, MQTT Poisoning, Lighting Outages, Remote Access Breaches, and OT Server Compromise**

OT incident response is unique:  
systems cannot simply be “turned off,” and changes during an incident can worsen conditions (e.g., shutting down HVAC on a warm day).

This chapter provides structured, real-world OT incident response procedures.

---

# 1. OT Incident Response Priorities

### OT vs IT difference:
IT prioritises *containment first*, then *integrity*, then *availability*.  
OT prioritises *safety and availability first*, then *integrity*, then *containment*, with **strict change control during incidents**.

### OT priorities are:
1. **Protect life & safety**  
2. **Keep essential building systems online**  
3. **Contain malicious or unstable behaviour**  
4. **Preserve forensic evidence**  
5. **Recover service with minimal disruption**  
6. **Harden the environment to prevent recurrence**

---

# 2. OT Incident Categories

| Category | Examples | Severity |
|----------|----------|----------|
| Protocol Storm | BACnet Who-Is flood, KNX multicast flood | High |
| Control Tampering | Modbus write attack, BACnet point writes | Critical |
| Device Compromise | Controller malware, gateway exploit | Critical |
| Server Compromise | Supervisor breach, ransomware | Critical |
| Remote Access Breach | Leaked vendor creds, bypassed jump host | Critical |
| Cloud Failure | Vendor outage causing building instability | Medium/High |
| Physical Tampering | Patch panel access, rogue device | High |
| Data Poisoning | MQTT/OPC falsified sensor data | High |

---

# 3. Common OT Failure Patterns

### 3.1 Protocol Storms
- BACnet broadcast floods  
- KNX multicast loops  
- Art-Net / sACN flooding  

### 3.2 Rogue Writes
- Modbus writes modifying coil/register  
- BACnet WriteProperty changes  
- OPC-UA node modification  

### 3.3 Gateways Failing Open
- Dual-stack gateway bridging unintended VLANs  
- DMX/DALI controller loops  

### 3.4 Supervisors Compromised
- Malware  
- Ransomware  
- Credentials stolen  

### 3.5 Vendor Remote Access Abuse
- VPN compromise  
- Misuse of RDP  
- Lack of session isolation  

---

# 4. High-Level OT Incident Response Framework

	1.	Detect
	2.	Triage
	3.	Contain (safely)
	4.	Preserve evidence
	5.	Eradicate threat
	6.	Recover & stabilise
	7.	Post-incident hardening
	8.	Lessons learned

This framework must be adapted to OT safety constraints.

---

# 5. Incident Response Playbooks (Protocol-Specific)

---

# 5.1 BACnet/IP Storm (Who-Is / I-Am Flood)

### Indicators:
- High CPU on controllers  
- HVAC system bogging down  
- BACnet read/write failures  
- Switch broadcast utilisation > threshold  

### Immediate Actions:
1. **Identify storm VLAN** via NetFlow/sFlow  
2. **Temporarily isolate** affected BACnet VLAN at distribution (shut VLAN→core route)  
3. Disable or rate-limit BACnet broadcast on edge ports  
4. Locate rogue device (MAC table + port tracing)  

### Containment:
- Shut rogue port  
- If storm source is unknown, rate-limit BACnet broadcasts on entire VLAN  

### Recovery:
- Bring VLAN back online  
- Validate system schedules & setpoints  
- Review controller logs  

### Forensics:
- Capture packet samples  
- Export switch logs  
- Confirm no external origin  

---

# 5.2 Modbus Write Attack

### Indicators:
- Unexpected coil/register value changes  
- Gateway logs unknown client  
- Sudden equipment behaviour changes  

### Immediate Actions:
1. **Block Modbus TCP** at firewall (DMZ → OT) except known supervisors  
2. **Place gateway in read-only mode** (if available)  
3. **Check recent writes** in gateway logs  

### Containment:
- Identify source IP of rogue writes  
- Disable or quarantine offending host  

### Recovery:
- Reload known-good register maps  
- Validate equipment state manually  

### Forensics:
- Packet capture from gateway  
- Timeline reconstruction of register changes  

---

# 5.3 MQTT Broker Compromise / Data Poisoning

### Indicators:
- Sensor values inconsistent with reality  
- Supervisors reacting to fake data  
- Retained topics replaced with malicious payloads  

### Immediate Actions:
1. **Switch broker to read-only** for non-critical devices  
2. **Purge retained messages** on affected topics  
3. **Stop inbound sensor ingestion** if necessary  

### Containment:
- Revoke credentials  
- Regenerate broker certificates  
- Validate ACL rules  

### Recovery:
- Reload known-good data flows  
- Re-enable ingestion with ACLs enforced  

### Forensics:
- Review broker logs  
- Identify rogue client ID  
- Inspect all retained topics  

---

# 5.4 KNX Multicast Flood

### Indicators:
- KNX routers overloaded  
- Lighting becomes unresponsive  
- High multicast traffic on switch  

### Immediate Actions:
1. **Enable IGMP querier** on VLAN if missing  
2. **Limit multicast rate** on distribution switches  
3. **Identify flooding device** via port statistics  

### Containment:
- Disable offending port  
- Remove or reconfigure rogue KNX router  

### Recovery:
- Rebuild routing table if corrupted  
- Validate group addresses  

---

# 5.5 Lighting Protocol (Art-Net / sACN) Flood

### Indicators:
- Lighting flicker or freeze  
- CPU spike on lighting controller  
- Multicast spikes  

### Actions:
- Rate-limit lighting multicast  
- Trace rogue Art-Net node  
- Quarantine misconfigured lighting desk  

---

# 5.6 Remote Access Breach

### Indicators:
- Unknown vendor logged in  
- Session occurring outside approved window  
- Unapproved RDP/SSH activity  
- Firewall logs showing unexpected source  

### Immediate Actions:
1. **Kill VPN session**  
2. **Revoke vendor account**  
3. **Disable OT jump host access** if needed  
4. **Disable temporary firewall rules**  

### Containment:
- Block vendor’s IP ranges temporarily  
- Review jump host recordings  

### Recovery:
- Reset all credentials used  
- Validate integrity of controllers and supervisors  

### Forensics:
- Retrieve jump host logs  
- Export firewall logs  
- Review executed commands  

---

# 5.7 OT Server / Supervisor Compromise

### Indicators:
- Unexpected processes  
- Malware alerts  
- Suspicious network connections  
- Dropped services (MQTT, BACnet/SC)  

### Immediate Actions:
1. **Isolate server** at firewall  
2. **Failover to backup supervisor** if available  
3. **Capture memory snapshot (VM environments)**  

### Containment:
- Disable compromised credentials  
- Block external communication  

### Recovery:
- Rebuild supervisor from golden image  
- Restore database from clean backup  
- Reapply hardening and patches  

### Forensics:
- Disk imaging  
- Log correlation through SIEM  

---

# 5.8 Physical Tampering

### Indicators:
- Open riser doors  
- Rogue device on switch  
- Unexpected MAC addresses  
- Loss of power to OT switch  

### Immediate Actions:
1. **Isolate port** with rogue MAC  
2. **Dispatch engineer to site immediately**  
3. **Review CCTV logs**  

### Forensics:
- Collect physical evidence  
- Tag device for analysis  

---

# 6. Communication & Escalation Workflow

OT incidents require coordination across multiple teams.

### Stakeholders:
- OT engineering  
- Facilities management  
- Security operations (SOC)  
- IT networking/security  
- Vendors  
- Building occupants (if outage impacts comfort/safety)  

### Communication Flow:

OT Engineer → OT Manager → Facilities → IT Security → Vendor (if applicable)

### Rules:
- Never change configuration without notifying OT/Facilities  
- Always communicate impact clearly  
- Document every action in incident timeline  

---

# 7. Evidence Preservation

### Collect:
- Firewall logs  
- Switch logs  
- BACnet/KNX/MQTT logs  
- Supervisor logs  
- Jump host session recordings  
- Packet captures (PCAPs)  
- Controller audit trails (if available)  

### Never:
- Reboot devices prematurely  
- Wipe logs  
- Apply patches before evidence captured  

---

# 8. Post-Incident Recovery & Hardening

### Recovery Steps:
- Validate all OT services  
- Restore from golden configs  
- Re-enable monitoring  
- Confirm remote access functioning securely  

### Hardening Steps:
- Apply missing ACLs  
- Enforce stricter VLAN segmentation  
- Upgrade to BACnet/SC  
- Add MQTT ACLs  
- Update firewall rules  
- Improve monitoring baselines  

---

# 9. OT Incident Response Playbook Template (Copy/Paste)

	1.	Incident Identification
	•	Who raised it?
	•	What system/VLAN impacted?
	•	Visible symptoms?
	2.	Safety Validation
	•	Any life-safety systems affected?
	•	Building impact?
	3.	Initial Containment
	•	VLAN isolation?
	•	Block suspicious traffic?
	•	Disable rogue port?
	4.	Evidence Collection
	•	Logs, PCAPs, screenshots
	•	Supervisor logs
	•	Jump host recordings
	5.	Root Cause Analysis
	•	Protocol issue?
	•	Device failure?
	•	Malicious activity?
	•	Misconfiguration?
	6.	Remediation
	•	Firewall changes
	•	Controller reconfigs
	•	Firmware fixes
	7.	Verification
	•	Test functionality
	•	Validate network stability
	•	Check alarms cleared
	8.	Documentation
	•	Timeline
	•	Actions taken
	•	Lessons learned

---

# Summary

Incident response in OT is about safety, stability, and containment—not just shutting things down.  
OT incidents often stem from protocol storms, misconfigurations, remote access misuse, or vulnerable gateways.

This playbook provides actionable guidance to:

- Detect  
- Contain  
- Investigate  
- Recover  
- Harden  

Following this model ensures that OT systems remain resilient, predictable, and secure during and after security or operational incidents.
