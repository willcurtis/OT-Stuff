# BACnet/IP Deployment Pattern

BACnet/IP is the dominant protocol used in Building Management Systems (BMS).  
It offers flexible object modelling, multi-vendor interoperability, support for supervisory systems, and a rich ecosystem of controllers and gateways.

However, BACnet/IP is also one of the most commonly misconfigured OT protocols due to its reliance on broadcast discovery, historical legacy behaviour, BBMD complexity, and vendor-autodetection quirks.

This chapter provides a complete, production-ready deployment blueprint for BACnet/IP in OT/BMS networks.

---

# BACnet/IP Architecture Overview

BACnet/IP operates over UDP/47808 and uses:

- **Broadcast** for discovery (Who-Is / I-Am)  
- **Unicast** for property reads/writes  
- **Optional COV (Change of Value) subscriptions**  
- **Optional BBMD for multi-subnet forwarding**  

A typical deployment includes:

- One or more supervisory servers  
- Multiple BACnet/IP controllers  
- Gateways for MS/TP, Modbus RTU, or LON devices  
- Optional BBMDs  
- Trend and historian systems  
- Optional analytics platform  

---

# Design Principles for BACnet/IP Deployments

### Principle 1 — Minimise Broadcast Domains  
Place controllers into manageable VLANs (usually /24 or smaller).

### Principle 2 — Avoid BBMD unless absolutely required  
BBMD is powerful but dangerous when misused.

### Principle 3 — Ensure all devices have stable, static IPs  
BACnet devices do not handle IP renumbering well.

### Principle 4 — Supervisors must have reliable, routed paths  
Supervisors frequently poll, subscribe to COVs, and push schedules.

### Principle 5 — BACnet Network Numbers must be unique  
Conflicts cause routing loops and invisible devices.

### Principle 6 — Contain BACnet traffic within OT  
Never allow BACnet broadcasts into IT networks.

---

# Recommended BACnet/IP VLAN Structure

A clean VLAN design is essential.

Example blueprint:

VLAN 100 – BMS Supervisors
VLAN 110 – BACnet Controllers (Plant Room)
VLAN 120 – BACnet Controllers (Floor 1)
VLAN 130 – BACnet Controllers (Floor 2)
VLAN 140 – BACnet Gateways (MS/TP, Modbus, LON)
VLAN 170 – OT DMZ (Optional)

Benefits:
- Broadcast domains remain small  
- Clear functional separation  
- Supervisors route to controllers predictably  
- Gateways isolated from BACnet broadcast storms  

---

# IP Addressing Strategy for BACnet/IP

BACnet devices should use:
- **Static IP addresses**  
- **Documented address allocation**  
- **Consistent subnet masks**  

Recommended addressing format:

10.20..x

Example:
- 10.20.110.10 – Plant Room Controller 1  
- 10.20.110.11 – Plant Room Controller 2  
- 10.20.120.10 – Floor 1 Controller 1  

### Do not change IPs after commissioning  
Many BACnet stacks cache IP → device mappings internally.

---

# BACnet Network Numbers

BACnet network numbers are **not** VLAN numbers nor IP subnets.

Typical scheme:

| VLAN | BACnet Network Number |
|------|------------------------|
| 110  | 10110 |
| 120  | 10120 |
| 130  | 10130 |
| 140  | 10140 |

Rules:
- Unique per broadcast domain  
- Documented in version control  
- Never reused across sites  
- Must match BBMD configuration if deployed  

---

# Supervisor Design

The supervisor performs:

- Device discovery  
- Trend collection  
- Alarm routing  
- Scheduling  
- COV subscription management  
- Historian integration  

### Supervisor Requirements:

- Routable to all BACnet VLANs  
- Stable NTP (critical)  
- CPU and RAM sized for number of controllers  
- Hosted in OT DMZ or OT core  

### Scaling Rule of Thumb:
- 1,000–2,000 BACnet objects per CPU core  
- 100–150 controllers per supervisory engine  
- 5–10 MB/s network capacity for large polling systems  

---

# Controller Grouping and Sizing

Group BACnet controllers by:
- Physical location  
- System type  
- Broadcast domain constraints  
- COV load  

Typical plant room VLAN:
- 20–30 controllers  
- 1–3 gateways  
- 3–10k BACnet objects  

Floor-level VLAN:
- 10–20 VAVs/FCUs  
- Optional gateway per floor  

---

# COV (Change of Value) Strategy

COV significantly reduces polling load.

Guidelines:
- Enable COV where supported  
- Use supervisory-level COV subscriptions  
- Tune increments (e.g., 0.1°C, 1%)  
- Avoid over-aggressive COV on rapidly changing points  
- Monitor COV traffic for storm conditions  

Bad COV configuration = heavy CPU load on controllers.

---

# Polling Strategy

Not all devices support COV.  
Polling guidelines:

- Do not exceed 5–10 polls/sec per controller  
- Stagger polling across supervisor threads  
- Prioritise critical points  
- Reduce polling for static metadata (device status, description fields)  
- Trend polling should be minimal — use COV or controller-based trending instead  

Polling storms are one of the biggest causes of BACnet slowdowns.

---

# Gateway Integration

Gateways commonly link legacy fieldbuses:

- BACnet MS/TP  
- Modbus RTU  
- LON  
- Older vendor-specific buses  

### Gateway VLAN Requirements:
- Dedicated VLAN  
- Isolated from controller VLANs  
- Broadcast traffic filtered  
- Static IP addressing  
- Supervisory routing allowed  

Gateways are prone to:
- CPU overload  
- Queue exhaustion  
- Conversion delays  
- Firmware instability  

Isolating gateways improves stability.

---

# BBMD Design (Summary)

If BBMD is required:

- Only **one BBMD per VLAN**  
- Keep BBMD count minimal  
- Ensure identical BDT tables  
- Avoid BBMDs across VPNs or NAT  
- Use Foreign Device Registration sparingly  
- Prefer BACnet/SC for cross-site connectivity  

BBMD misuse is the #1 cause of BACnet instability.

---

# Firewall Requirements

Supervisors require:
- Outbound UDP/47808 to controllers  
- Inbound UDP/47808 from controllers  
- Outbound TCP/443 for UI or cloud connectors (optional)  
- Outbound/inbound for historian database  

Controllers require:
- Access to supervisors ONLY  
- No access to vendor VLAN  
- No access to IT networks  

Typical rule:

permit udp supervisor_IP any eq 47808
permit udp any supervisor_IP eq 47808
deny udp any any eq 47808

---

# BACnet/IP Discovery Behaviour

### Who-Is
Broadcast by supervisor or tool  
→ All BACnet devices respond with I-Am

### I-Am  
Response containing:
- Instance number  
- Device ID  
- Network number  

### Issue:
Excessive Who-Is requests create storms.

### Recommendation:
- Limit discovery windows  
- Use structured device trees rather than auto-discovery  

---

# Multi-Building / Multi-Site BACnet/IP

Challenges:
- Cross-site broadcast propagation is dangerous  
- Weaker controllers cannot handle WAN jitter  
- VPN latency disrupts services  

Recommended:
- Use BACnet/SC for secure routing  
- Deploy site-level supervisors  
- Federate multiple supervisors into enterprise-level analytics  

---

# Time Synchronisation Requirements

BACnet schedules, COV sequences, and alarms all rely on correct time.

Requirements:
- Local NTP servers in OT  
- No reliance on internet NTP  
- Remove time drift from controllers  
- Supervisors must serve time to devices if supported  

---

# Performance Considerations

### Broadcast Load
Limit VLAN size to <50 controllers to contain broadcast fan-out.

### COV Load
Tune thresholds to reduce flooding.

### Trend Data
Prefer controller-based trending with periodic upload rather than constant polling.

### Supervisor Load
Scale CPU/RAM with number of objects, not device count.

---

# Troubleshooting BACnet/IP Deployments

### Symptom: Devices appear online/offline frequently  
Cause:  
- Duplicate BACnet instance numbers  
- Poor time sync  
- BBMD misconfiguration  
- Gateway overload  
- VLAN broadcast storm  

### Symptom: Slow UI / lag in graphics  
Cause:  
- Excessive polling  
- Controller CPU saturation  
- Poorly tuned COV  

### Symptom: Supervisor cannot discover devices  
Cause:  
- Wrong BACnet network number  
- Blocked broadcast  
- Incorrect BBMD table  
- Firewall drop  

### Symptom: Trend gaps  
Cause:  
- Controller time drift  
- Network jitter  
- Supervisor overloaded  

---

# Deployment Blueprint (Realistic Example)

**Scenario:**  
A 12-storey commercial office building with HVAC controls, energy metering, and lighting integration.

### VLAN Plan

VLAN 100 – Supervisors (10.20.100.0/24)
VLAN 110 – Plant BACnet Controllers (10.20.110.0/24)
VLAN 120 – Floor 1 BACnet Controllers (10.20.120.0/24)
VLAN 130 – Floor 2 BACnet Controllers (10.20.130.0/24)
…
VLAN 220 – KNX Routers
VLAN 240 – Modbus Gateways

### BACnet Network Numbers

| VLAN | Network Number |
|------|----------------|
| 110  | 30110 |
| 120  | 30120 |
| 130  | 30130 |

### BBMD  
Only one BBMD in VLAN 100 and one in VLAN 110 — ONLY because integration across those two VLANs is required.

### Supervisor  
- Hosted in OT DMZ  
- Runs 4 CPU cores, 16 GB RAM  
- Local historian + enterprise connector  

### Controller Groups  
- Plant: 26 controllers  
- Each floor: 10–15 controllers  
- All controllers have static IP  

### Access Control  
- No vendor access to BACnet VLAN  
- Read/write permitted only from supervisors  
- Firewall blocks UDP/47808 outside OT core  

---

# Summary

A well-designed BACnet/IP deployment requires carefully planned VLANs, static addressing, minimal BBMD usage, controlled discovery, tuned COV behaviour, and tightly enforced firewall boundaries.

Key principles:

- Keep broadcast domains small  
- Avoid BBMD unless absolutely necessary  
- Use unique BACnet network numbers  
- Provide stable NTP  
- Isolate gateways  
- Limit polling and tune COV  
- Prevent vendor laptops from reaching controller VLANs  

BACnet/IP is powerful and reliable when engineered correctly — and disastrous when misconfigured.

