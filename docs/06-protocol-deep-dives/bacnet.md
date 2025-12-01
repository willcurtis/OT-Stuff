# BACnet Deep Dive  
**Building Automation and Control Network – ASHRAE 135**

This chapter provides a comprehensive technical reference for BACnet (Building Automation and Control Network), including protocol internals, addressing, services, discovery behaviour, object modelling, performance characteristics, and deployment considerations for modern IP-based BMS networks.

BACnet is the dominant protocol for HVAC automation worldwide and is widely used across commercial buildings, data centres, industrial sites, retail, hospitality, and mixed-use developments.

---

# 1. BACnet Architecture Overview

BACnet defines:
- A **device and object model**
- A set of **services** for reading/writing data
- A **networking layer** supporting multiple media types
- A **transport mechanism** for carrying messages between devices

BACnet is not tied to TCP/IP; it operates across multiple datalinks:

| Datalink | Description | Notes |
|----------|-------------|-------|
| **BACnet/IP** | BACnet over UDP/IP | Most common today |
| **MS/TP** | Master-Slave / Token Passing over RS-485 | Still widely used for FCUs/VAVs |
| **BACnet/Ethernet** | Raw Ethernet frames | Legacy only |
| **BACnet/IPv6** | BACnet over IPv6 | Rare |
| **BACnet/SC (Secure Connect)** | BACnet over TLS/WebSockets | Modern secure transport |

BACnet is object-oriented: everything is an object with properties (read/write).

---

# 2. BACnet Device Model

Every BACnet device must implement:

- A **Device Object** (with unique Device ID)
- Mandatory properties (e.g., object-identifier, object-name)
- Optional additional objects depending on function

Example Device Object:

object-identifier: device, 12345
object-name: AHU-01
system-status: operational
vendor-identifier: 117
protocol-version: 1
protocol-revision: 15
max-apdu-length-accepted: 1476
segmentation-supported: no-segmentation
apdu-timeout: 3000 ms
number-of-APDU-retries: 3

---

# 3. BACnet Object Types

Common HVAC objects:

| Object Type | Purpose |
|-------------|---------|
| **analog-input** | Sensors (temp, humidity, CO2) |
| **analog-output** | Setpoints / modulating valves |
| **analog-value** | Computed values |
| **binary-input** | Status signals (on/off) |
| **binary-output** | Equipment start/stop |
| **binary-value** | Software flags |
| **multi-state-value** | Modes (auto/cool/heat/off) |
| **schedule / calendar** | Time-based automation |
| **trend-log** | Historical data |
| **loop** | PID control loops |
| **device** | Represents the controller |

---

# 4. BACnet Addressing

## 4.1 Device Identifiers (Device IDs)
- Must be **globally unique within a BACnet internetwork**
- Range: **0 to 4,194,302**
- Collisions cause devices to disappear or misbehave
- Poor installers often reuse Device IDs

## 4.2 Network Numbers
BACnet internetworks use **Network Numbers** to identify routing boundaries.

- Valid range: **1 – 65534**
- **0** = local network (special meaning)
- Must be unique across entire internetwork
- VLANs typically map to one network number each

## 4.3 MAC Addresses
BACnet MACs depend on medium:

| Medium | MAC Form |
|--------|----------|
| BACnet/IP | 6-byte MAC (IP + Port), but effectively uses UDP 0xBAC0 |
| MS/TP | 1-byte address (0–127) |
| Ethernet | 6-byte Ethernet MAC |

---

# 5. BACnet Packet Structure

BACnet frames contain:

### **BVLL (BACnet Virtual Link Layer)** — BACnet/IP only  
Handles broadcasting/multicast and forwarding through BBMDs.

### **NPDU (Network Protocol Data Unit)**  
Routing Layer:
- Message priority
- Destination and source network
- Hop count
- Routing flags

### **APDU (Application Protocol Data Unit)**  
Carries service requests/responses:
- Confirmed services
- Unconfirmed services
- Segmented messages
- Acknowledgements

---

# 6. BACnet Services

BACnet services are divided into:

## 6.1 Confirmed Services  
Require a response:

- **ReadProperty**
- **ReadPropertyMultiple**
- **WriteProperty**
- **SubscribeCOV**
- **ConfirmedCOVNotification**
- **CreateObject**
- **DeleteObject**

## 6.2 Unconfirmed Services  
Fire-and-forget:

- **I-Am**
- **I-Have**
- **Who-Is**
- **Who-Has**
- **UnconfirmedCOVNotification**
- **TimeSynchronization**

## 6.3 File Services  
Used for firmware loading and configuration—rare today.

---

# 7. Device Discovery Behaviour

BACnet discovery relies on broadcasting.

## 7.1 Who-Is / I-Am Sequence

### Controller:

Who-Is (broadcast)

### Every responding device:

I-Am device, , , 

If broadcasts leak across VLANs, devices from one area appear in others.

## 7.2 Typical Discovery Problems
- Devices vanish when duplicate IDs exist  
- BACnet storms caused by Who-Is > 1/sec  
- Supervisors crash under high discovery load  
- Fogging of gateways in VRF/VRV systems  

---

# 8. COV (Change of Value) Subscription Mechanics

COV reduces polling load.

### Workflow:
1. Supervisor sends **SubscribeCOV** to controller.  
2. Controller sends **COVNotification** only when value changes.  

### Benefits:
- Dramatically reduces network noise  
- Essential for large sites  
- Recommended for temperature, CO2, humidity

### Common Failures:
- Vendor disables COV support  
- Supervisor drops subscriptions after reboot  
- Controller restarts wiping subscription lists  
- COV flooding from noisy sensors  

---

# 9. Routing & Broadcast Behaviour

BACnet/IP uses:

- **Broadcast UDP 0xBAC0**
- **Foreign Device Registration (FDR)**
- **BBMDs** for crossing subnets

Broadcasts do NOT cross routers unless BBMDs are configured.

## 9.1 BBMD (BACnet Broadcast Management Device)

A BBMD forwards broadcast packets between subnets based on a table of BDT entries.

### Issues:
- Misconfigured BBMD = building-wide storm  
- Duplicate BBMDs = routing loops  
- BBMDs across WAN = catastrophic performance  
- BBMDs in cloud = security disaster  

Only use BBMDs when absolutely necessary.

---

# 10. BACnet/SC (Secure Connect)

BACnet/SC replaces the broadcast-based BVLL with:

- TLS 1.3  
- WebSockets (WS/WSS)  
- Star or mesh topologies  
- Hub/Node architecture  
- Certificate-based authentication

### Benefits:
- No broadcasts  
- Works across WANs  
- Zero BBMDs  
- Secure by default  
- Cloud-friendly  
- Reduced attack surface

### Drawbacks:
- Requires PKI  
- Not universally supported yet  
- Harder for legacy integrators  

BACnet/SC is recommended for new large-scale deployments.

---

# 11. VLAN & Network Design for BACnet/IP

## 11.1 Per-System or Per-Zone VLANs
Avoid building-wide BACnet VLANs.

## 11.2 BACnet VLAN Examples

VLAN 120 – Plant
VLAN 121 – AHUs
VLAN 122 – VAV/FCUs
VLAN 130 – VRF/VRV Gateways
VLAN 140 – Lighting (BACnet)

## 11.3 Rules:
- Do NOT allow BACnet broadcasts across VLANs  
- Supervisors route by **unicast**, not broadcast  
- Unique BACnet network number per VLAN  
- No BACnet between tenants in mixed-use buildings  

---

# 12. Tuning BACnet for Performance

### Recommendations:
- Enable COV for sensors  
- Reduce polling to 5–30 sec for slow objects  
- Avoid ReadPropertyMultiple > 50 objects per call  
- Avoid oversized trend histories  
- Isolate VRF gateways—they overload easily  
- Limit number of BACnet/IP devices per VLAN (< 200 recommended)  

---

# 13. Troubleshooting BACnet

## 13.1 Common Symptoms and Causes

| Symptom | Likely Cause |
|---------|--------------|
| Device not appearing | Duplicate Device ID / wrong VLAN |
| High latency | Storms / oversized broadcasts |
| Supervisor slow | Excess polling / misconfigured RMP |
| VRF gateway crashing | Too many objects or polling load |
| AHU or FCU offline | BBMD misconfig / foreign device timeout |
| Random alarms | COV flood or unstable sensors |

---

# 14. BACnet Security Weaknesses

BACnet/IP has **no built-in security**:

- No encryption  
- No authentication  
- Anyone can send a WriteProperty  
- Discovery exposes all devices  
- Firmware download often unauthenticated  

### Attack Scenarios:
- Rogue device issues WriteProperty to switch off plant  
- Attacker impersonates controller  
- Device enumeration from corporate network  
- Replay attacks on COV notifications  

---

# 15. Securing BACnet Deployments

### Mandatory Controls:
- VLAN isolation  
- Firewall deny-all between BACnet networks  
- Supervisors only allowed to write properties  
- No vendor direct access  
- OT DMZ for all integrations  
- Jump host for vendor access  
- Use BACnet/SC where possible  
- Disable unneeded services (File Transfer, WriteProperty on sensors)  

### Recommended:
- Block UDP 0xBAC0 at all L3 boundaries  
- Log WriteProperty requests  
- Implement rate limiting  
- Strict device-ID management  
- Intrusion detection for BACnet anomalies  

Security must be layered around BACnet—not inside it.

---

# 16. BACnet Deployment Patterns by Building Type

### 16.1 Tier III/IV Data Centres  
- No BBMDs  
- Per-zone VLANs  
- Strict broadcast containment  
- COV for all sensors  
- VRF isolated VLANs  

### 16.2 Shopping Centres  
- Per-tenant VLANs  
- No BACnet between tenants  
- Limit polling on VRF  

### 16.3 Hospitality  
- Per-floor VLANs  
- Strict BACnet device ID discipline  
- Room controllers isolated  

### 16.4 Industrial  
- Avoid mixing BACnet with PLC networks  
- No broadcast across industrial VLANs  
- Low COV and polling load  

### 16.5 University Campus  
- Per-building VLANs  
- No campus-wide broadcast domains  
- Use BACnet/SC for cross-building links  

### 16.6 Mixed-Use Buildings  
- VLAN per zone  
- Tenant segregation enforced  
- Strict firewall boundaries  

---

# 17. BACnet Implementation Checklist

### Addressing
- [ ] Unique Device IDs across entire site  
- [ ] Unique network numbers  
- [ ] Static addressing  

### Networking
- [ ] VLAN per zone  
- [ ] Firewalls between VLANs  
- [ ] No unnecessary BBMDs  
- [ ] COV subscriptions enabled  

### Performance
- [ ] Polling under control  
- [ ] VRF gateways isolated  
- [ ] Trend logs sized correctly  

### Security
- [ ] WriteProperty restricted  
- [ ] DMZ for IT integrations  
- [ ] No direct vendor access  
- [ ] BACnet/SC where possible  

---

# Summary

BACnet is powerful, flexible, and interoperable—but also noisy, fragile, and insecure by design.  
Correct architecture, segmentation, and access control are essential for stability and safety.

Key principles:

- Strict broadcast containment  
- No BBMDs unless absolutely required  
- Unique device IDs and network numbers  
- Per-zone/per-system VLANs  
- COV > polling  
- Firewall everything  
- Use BACnet/SC for cross-site or cloud-connected deployments  

A well-designed BACnet network is predictable, scalable, secure, and maintainable for decades.
