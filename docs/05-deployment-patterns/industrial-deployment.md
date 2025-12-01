# Industrial OT/BMS Deployment Pattern

Industrial facilities blend traditional building management (HVAC, lighting, metering) with process control networks involving PLCs, SCADA, DCS, robotics, and safety systems.  
This creates a unique OT environment where BMS must coexist with production networks while maintaining strict segmentation and operational reliability.

This chapter provides a complete deployment pattern for BMS in industrial plants.

---

# 1. Characteristics of Industrial OT/BMS

Industrial buildings vary widely, but common characteristics include:

### • Harsh environments  
Heat, dust, vibration, and electromagnetic interference require rugged network hardware.

### • Coexistence of BMS with ICS/SCADA  
BMS handles HVAC, lighting, and utilities, while ICS handles production processes.

### • Heavy use of Modbus TCP/RTU  
Industrial equipment relies heavily on Modbus for telemetry and control.

### • Safety-critical systems  
Pressurisation, extraction, fume handling, hazardous-area classification (ATEX/NEC).

### • Strong security and segmentation requirements  
IEC 62443 compliance is often required.

### • Multiple vendors and legacy systems  
Industrial plants often operate equipment spanning decades of technology.

---

# 2. Industrial OT Architecture Overview

An industrial facility typically contains:

Enterprise IT
└── DMZ / Firewall Boundary
└── OT Core
├── BMS Supervisors
├── SCADA/DCS Servers
├── Historian
├── Domain Controllers (OT)
├── NTP
├── Syslog/SIEM
└── Remote Access Gateways

OT Network
├── BMS VLANs
├── Process Control VLANs
├── Safety System VLANs
├── Machine/Robot Networks
└── Industrial Wireless (if used)

BMS is a subset of the wider OT system and must not be allowed to interfere with production networks.

---

# 3. Segmentation Strategy for Industrial Sites

Segmentation is essential for safety and risk management.

### Recommended VLAN Groups:

BMS (Building OT):
VLAN 100–119 – HVAC Controllers
VLAN 120–139 – Lighting Controllers
VLAN 140–159 – Metering (Power/Water/Gas)
VLAN 160–169 – Gateways (Modbus, KNX, MS/TP)
VLAN 170–179 – BMS Supervisors
VLAN 180–189 – OT DMZ for BMS

Industrial Process (ICS):
VLAN 200–229 – PLCs
VLAN 230–249 – SCADA IO Gateways
VLAN 250–269 – Robot/AGV Controllers
VLAN 270–289 – Safety Systems
VLAN 290–299 – Machine HMIs

### Isolation Requirements:
- BMS and ICS must never share IP subnets.  
- BMS broadcasts must not reach PLC networks.  
- PLC traffic must remain deterministic with minimal jitter.  
- BMS networks must be routed through OT firewalls, not bridged.  

This separation enforces IEC 62443 zone/conduit principles.

---

# 4. BACnet in Industrial Environments

BACnet/IP is used more conservatively in industrial environments than in commercial buildings.

Typical use cases:
- HVAC for cleanrooms and production areas  
- Pressurisation systems  
- Office area HVAC  

### Recommendations:
- Keep BACnet VLANs small  
- Avoid BBMD entirely unless multiple buildings  
- Tune COV thresholds to reduce network noise  
- Supervisors must never sit inside PLC networks  
- Document device IDs to avoid clashes  

---

# 5. Modbus TCP in Industrial Environments

Modbus is the dominant protocol for industrial BMS integrations because:

- Most industrial devices support Modbus  
- Wide availability of registers  
- Works across low-cost gateways  
- Supported by SCADA and BMS equally  

### Best Practices:
- Separate Modbus gateways into their own VLAN  
- Poll at conservative rates (<1–2 polls/sec)  
- Limit Modbus function codes where possible  
- Log all writes (critical for compliance)  
- Document register maps carefully  
- Avoid chaining too many RTU devices on long serial runs  

### Common Failures:
- Gateway overload under aggressive polling  
- Long RTU chains causing timeouts  
- Vendors using undocumented registers  
- Polling collisions between SCADA and BMS  

SCADA and BMS must never poll the same Modbus device simultaneously without coordination.

---

# 6. OPC-UA in Industrial Facilities

OPC-UA is widely used for:

- Energy management  
- Chiller/boiler integration  
- Air quality systems  
- Vibration monitoring for rotating machinery  
- Linking BMS and SCADA  

### Requirements:
- Certificates mandatory  
- Security policies: Basic256Sha256 or stronger  
- Endpoint isolation in OT DMZ  
- SCADA/BMS connections routed via firewall  
- No anonymous access  

OPC-UA is the preferred method for modern industrial integrations.

---

# 7. SCADA, DCS, and BMS Interoperability

SCADA/DCS handle:

- Production logic  
- Safety systems  
- Alarms  
- Real-time control  

BMS handles:

- HVAC  
- Lighting  
- Environmental conditions  
- Utility metering  

### Integration SHOULD be:
- Through OT DMZ  
- Read-only from BMS to SCADA unless explicitly allowed  
- Performed via OPC-UA, MQTT, or REST API  
- Logged at the firewall  

### Integration MUST NOT:
- Allow BMS to write to PLC networks directly  
- Allow PLC-to-BACnet/IP bridging  
- Use Modbus bridging without strict controls  

Safety and production must be protected from non-critical automation.

---

# 8. Hazardous Areas & ATEX Zones

Industrial sites often contain ATEX/NEC hazardous zones.

### Requirements:

- Use certified equipment for network hardware (Zone 1/2 rated where required)  
- Fibre preferred over copper due to sparking risk  
- No standard Ethernet hardware allowed in Zone 0  
- Gateways must be placed outside hazardous zones  
- Controllers located in safe areas with intrinsically safe barriers  

Network design must align with site hazardous area classification drawings.

---

# 9. Remote Access in Industrial Sites

Remote access in industrial plants is highly regulated.

### Mandatory:
- MFA  
- Jump host  
- Session logging  
- No direct vendor access to BMS or PLC networks  
- No cloud-based vendor tools unless permitted by policy  
- OT firewall between all vendor access and BMS/ICS networks  

### Remote Access Flow:
Vendor → VPN → DMZ → Jump Host → OT Firewall → BMS or ICS (read-only unless approved)

### Additional Controls:
- Portable engineering laptops must be security-checked  
- USB blocking policies recommended  
- Vendor access must be time-bound  

---

# 10. Monitoring Requirements

Industrial monitoring must include both BMS and ICS signals.

### BMS Monitoring:
- HVAC control loops  
- Cleanroom parameters  
- Pressurisation states  
- Metering data  
- Gateway performance  

### ICS Monitoring:
- PLC communications  
- Modbus error rates  
- Network jitter  
- Redundancy path state  
- Asset health  

### Network Monitoring:
- Broadcast anomalies (BACnet)  
- Modbus polling failures  
- KNX routing events  
- Switch temperature thresholds  
- Power supply status in plant rooms  

Monitoring is essential for safety, compliance, and productivity.

---

# 11. High Availability in Industrial Plants

### BMS-level HA:
- Redundant supervisors  
- Redundant network switches in core  
- UPS on all OT equipment  
- Local fallback controls in HVAC controllers  

### ICS-level HA (more stringent):
- PLC redundancy pairs  
- Redundant IO networks  
- Separate A/B comms paths  
- Hot standby SCADA servers  

BMS must not compromise ICS availability.

---

# 12. Common Industrial Deployment Failures

### ❌ BMS and PLC networks merged at Layer 2  
Causes non-deterministic traffic and potential safety impacts.

### ❌ BMS polling too aggressively on shared Modbus devices  
Slows down SCADA polling or breaks equipment.

### ❌ Gateways installed inside hazardous zones  
Safety compliance violation.

### ❌ SCADA writing to BMS BACnet points without governance  
Risk of unintended HVAC behaviour.

### ❌ Vendor plugging unmanaged switch into PLC or BMS network  
Breaks segmentation and redundancy.

### ❌ Remote access bypassing OT firewall  
Regulatory violation (IEC 62443).

---

# 13. Industrial Deployment Checklist

### Segmentation
- [ ] BMS and ICS physically or logically isolated  
- [ ] VLANs per system type  
- [ ] No broadcast propagation between networks  

### Security
- [ ] No vendor access without MFA and jump host  
- [ ] No inbound internet-facing ports  
- [ ] Modbus writes logged  
- [ ] Access time-bounded  

### Performance
- [ ] Polling rates tuned  
- [ ] Gateways monitored  
- [ ] PLC networks protected from unsolicited traffic  

### Safety
- [ ] Hazardous area requirements followed  
- [ ] Controllers mounted in safe zones  
- [ ] Fibre used where required by ATEX  

---

# Summary

Industrial OT/BMS deployments require careful separation of building automation from production control.  
Safety, compliance, and deterministic operation are paramount.

Key principles:

- Isolate BMS from PLC/SCADA networks  
- Follow IEC 62443 segmentation  
- Treat Modbus networks carefully to avoid overload  
- Use OPC-UA for integration, not raw fieldbus bridging  
- Provide secure, logged, time-bound remote access  
- Ensure monitoring across BMS, ICS, and network layers  

A correctly engineered industrial OT architecture ensures safe, compliant, efficient operation across complex facilities.
