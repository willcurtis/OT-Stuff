# Network Segmentation for OT and BMS

Segmentation is the single most important architectural principle in any OT or BMS network. Without proper segmentation, broadcast storms, misconfigured controllers, insecure legacy protocols, and vendor remote-access pathways can easily compromise operational stability and security.

This chapter explains how to design segmentation models tailored for BMS workloads, including VLAN design, zoning, IP addressing, traffic isolation, broadcast control, and placement of supervisory systems.

---

## Why Segmentation Matters

BMS systems use a mix of protocols with varying characteristics:

- **Broadcast-heavy:** BACnet/IP  
- **Polling-based:** Modbus TCP  
- **Multicast-based:** KNX routing  
- **Legacy protocols:** LON, MS/TP  
- **Secure but latency-sensitive:** OPC-UA  

Segmentation ensures:

- Predictable network performance  
- Protection from noisy or unstable subsystems  
- Containment of faults  
- Isolation of insecure devices  
- Clear boundary for vendor access  
- Compliance with OT security standards (NIS2, IEC 62443)  
- Reduced broadcast domains  
- Easier troubleshooting and documentation  

---

## OT Network Segmentation Principles

Effective segmentation requires a layered approach:

### 1. Separate OT from IT  
OT systems must reside in dedicated networks separate from corporate IT.

### 2. Zone by function  
Group systems based on criticality and similarity:
- Plant control  
- HVAC controllers  
- Lighting systems  
- Energy metering  
- Security systems  
- Vendor remote access  

### 3. Minimise broadcast domains  
BACnet/IP and KNX routing both require careful containment.

### 4. Enforce least privilege  
Only required flows should be permitted between zones.

### 5. Avoid shared VLANs across unrelated systems  
Each subsystem should be isolated unless explicitly integrated.

### 6. Restrict east-west traffic  
Cross-controller communication is rarely needed.

---

## Common OT/BMS Zones

A typical OT architecture includes:

### **1. BMS Supervisor Zone**
Contains:
- BMS supervisory server  
- Historian/trend database  
- Global schedule engine  
- API integration services  

This zone is usually a small VLAN or subnet.

### **2. Controller Zones**
Separate VLANs per controller group, for example:
- AHU controllers  
- Plant room controllers  
- Floor-level controllers  
- Lighting controllers  
- Power monitoring controllers  

### **3. Vendor Access Zone**
A VLAN dedicated to remote-engineer access.

> This VLAN must **not** share address space or routing paths with controllers except through a firewall.

### **4. Management/OOB Zone**
Contains:
- Out-of-band switches  
- Management interfaces  
- OT jump hosts  

### **5. Integration Zone**
Used for:
- BACnet gateways  
- LON/IP routers  
- Modbus TCP gateways  
- OPC-UA servers  

Keeping gateways separate reduces noise in controller networks.

### **6. OT DMZ**
Provides a boundary between OT and IT:
- Data brokers  
- MQTT servers  
- Reporting/analytics  
- Secure API endpoints  

---

## VLAN Design for BMS

A BMS VLAN plan typically includes:

- A **supervisor VLAN**  
- Multiple **controller VLANs** based on system type or location  
- VLANs for:
  - Plant equipment  
  - Lighting  
  - Metering  
  - Security systems  
  - Vendor Wi-Fi or wired access  
  - KNX IP routing  
  - Gateway devices  

### Example VLAN Allocation (Conceptual)

- VLAN 100: BMS Supervisor  
- VLAN 110: AHU Controllers  
- VLAN 120: FCU/VAV Controllers  
- VLAN 130: Plant Room 1 Controllers  
- VLAN 140: Modbus TCP Gateways  
- VLAN 150: KNX IP Routers  
- VLAN 160: Energy Meters  
- VLAN 170: Vendor Access  
- VLAN 180: OT DMZ  

### Benefits of this model:
- Limits broadcast impact  
- Isolates protocols with differing behaviour  
- Enables per-system QoS or firewalling  
- Simplifies troubleshooting  

---

## Segmentation and BACnet/IP

BACnet/IP is especially sensitive to broadcast domain size. Poor segmentation leads to:

- Excessive Who-Is traffic  
- Controllers overwhelmed by broadcast storms  
- BBMD misconfiguration across too many subnets  

Best practices:

1. **One BACnet network number per VLAN**  
2. **BBMD only where required**  
3. **Avoid supervisors spanning multiple VLANs unless supported**  
4. **Block inter-controller communication unless necessary**  

BACnet controllers typically do **not** need to talk to each other directly—only to the supervisor.

---

## Segmentation and Modbus TCP

Modbus TCP is simpler to segment:

- Nearly always unicast  
- No broadcast  
- Easy to firewall  
- Sensitive to polling rates  

Best practices:
- Place devices behind a firewall  
- Restrict access to port 502 only from supervisor or gateway  
- Do not expose Modbus VLANs to VPNs or corporate networks  

Segmentation helps prevent overpolling by unauthorised systems.

---

## Segmentation and KNX/IP

KNX routing (multicast) requires special handling.

### Best practices:

- Assign KNX/IP routers to a **dedicated VLAN**  
- Ensure IGMP snooping is functional  
- Block multicast at Layer 3  
- Use tunnelling instead of routing for cross-VLAN programming  

Failure to segment KNX properly results in:
- Multicast flooding  
- Lost telegrams  
- Performance degradation  

---

## Segmentation and OPC-UA

OPC-UA is the easiest OT protocol to segment:
- No broadcast  
- No multicast  
- Works well across routed networks  
- Supports encryption and authentication  

Best practice:
- Create dedicated VLANs for OPC-UA servers (chillers, energy systems)  
- Use firewalls to restrict OPC-UA traffic to specific clients  

---

## East-West Isolation

Most BMS systems require:

- Supervisory → controller communication  
- Controller → supervisory communication  

But **controller-to-controller communication is rarely needed**.  
Blocking it:

- Reduces attack surface  
- Prevents broadcast storms  
- Minimises accidental cross-system interactions  

---

## North-South Isolation (OT–IT Boundary)

A firewall is essential at the OT–IT boundary.

Allowed flows typically include:
- HTTPS for dashboards  
- OPC-UA read-only interfaces  
- MQTT data export  
- SNMP traps (if permitted)  
- Syslog to SIEM  
- Secure remote access from IT → OT jump host  

Blocked flows:
- BACnet/IP  
- Modbus TCP  
- KNX routing  
- Direct controller access  

OT protocols must remain inside OT.

---

## IP Addressing for OT Segmentation

Key rules:

1. **Static addressing for controllers**  
2. **Documented, predictable ranges**  
3. **Do not reuse subnets across sites**  
4. **Avoid DHCP on controller VLANs**  
5. **Reserve dedicated IP ranges for gateways**  

Example scheme:
- 10.10.100.0/24 – BMS Supervisors  
- 10.10.110.0/24 – Controllers (Floor 1)  
- 10.10.120.0/24 – Controllers (Floor 2)  
- 10.10.130.0/24 – Gateways  
- 10.10.140.0/24 – Energy Systems  

---

## Segmentation and Vendor Access

Vendors often require remote access to:
- Gateways  
- Controllers  
- Supervisors  

Best practices:

- Use jump hosts  
- Use VPNs terminating in vendor VLAN  
- Enforce MFA  
- Do not allow vendor traffic to traverse controller VLANs unsupervised  
- Record sessions for auditability  

Vendor access remains a major OT attack vector.

---

## Common Segmentation Failures

### 1. BACnet broadcast storms across a flat OT network  
Cause:
- All controllers placed in one VLAN  

### 2. KNX multicast leaking across VLANs  
Cause:
- No IGMP snooping or querier  
- Incorrect L3 multicast filtering  

### 3. OPC-UA exposed directly on the corporate network  
Cause:
- No DMZ or firewall boundary  

### 4. Gateways placed in the same VLAN as controllers  
Cause:
- Polling overload spilling into critical segments  

### 5. Vendor access using shared subnets  
Cause:
- Lack of remote access design  

---

## Summary

Segmentation is the foundation of reliable and secure OT/BMS network design. Proper separation of systems by function, protocol behaviour, and criticality ensures:

- Predictable performance  
- Reduced broadcast and multicast congestion  
- Contained failure domains  
- Stronger cybersecurity posture  
- Simplified troubleshooting and management  

Every OT network should adopt structured, well-documented segmentation aligned with the unique characteristics of BMS systems.
