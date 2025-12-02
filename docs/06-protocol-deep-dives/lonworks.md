# LonWorks (LON) Deep Dive  
**LON / LON/IP / TP/FT-10 / IP-852 – Addressing, Domains, SNVTs, Routers, Gateways, Design & Troubleshooting**

LonWorks (commonly LON) is a building automation protocol heavily used in older BMS deployments and still found in many large campuses, mixed-use estates, and industrial sites.  
Although less common than BACnet today, LON remains important in:

- Legacy HVAC systems  
- VAV/FCU control  
- AHUs and older chillers  
- Lighting  
- Lab & campus HVAC  
- Interfacing to proprietary systems  

This chapter provides a deep technical reference for LON internals and modern integration patterns.

---

# 1. LonWorks Architecture Overview

LON is based on **Neuron chips** running the LONTalk protocol.

A complete LON system includes:

- **Devices** (controllers, VAV boxes, sensors, actuators)  
- **Network variables (NVs)**  
- **Domains, subnets, and node addresses**  
- **Routers** connecting channels  
- **FT-10 twisted pair channels** (most common)  
- **LON/IP** using IP-852 channels  
- **Network management tools** (Niagara, Loytec LNS tools, NL220, etc.)

Unlike Modbus, LON is **event-driven** and more structured.

---

# 2. LON Addressing Model

LON uses a hierarchical addressing system:

Domain → Subnet → Node

### 2.1 Domain
Defines the top-level building/installation boundary.

- 0–255 (size varies)
- Devices must share a domain to communicate
- Typically one domain per building or per VLAN

### 2.2 Subnet
Groups devices logically:

- 1–255
- Used for bandwidth control
- Subnets often represent floors or zones

### 2.3 Node ID
Identifies a specific device within a subnet:

- 1–127

---

# 3. Neuron IDs

A Neuron ID is a **unique 48-bit hardware identifier** embedded in every LON device.

Example:

00:21:22:05:8F:13

Neuron IDs:
- Are globally unique  
- Used during commissioning  
- Map to logical addresses (Domain/ Subnet / Node)  

---

# 4. Network Variables (NVs)

NVs are LON's equivalent of BACnet objects or OPC-UA variables.

Two types:
- **SNVT** – Standard Network Variable Type  
- **UNVT** – User-defined Network Variable Type  

Examples of SNVTs:
- `SNVT_temp_f` – temperature (°F)  
- `SNVT_temp_p` – temperature (precision)  
- `SNVT_lev_percent` – percentage  
- `SNVT_switch` – on/off + level (2-byte structure)

NVs are either:

- **Input NVs** (receive data)
- **Output NVs** (transmit data)

Binding NVs creates relationships between devices (e.g., a sensor feeding a controller).

---

# 5. Communication Channels

### 5.1 TP/FT-10 (Free Topology) – Most Common
- 78 kbit/s  
- Supports star, bus, daisy-chain, or mixed  
- Requires terminators (varies by topology)  
- Very resilient for old buildings  

### 5.2 FTT-10 Limitations
- Limited bandwidth  
- Long networks = propagation delays  
- Broadcast-heavy under bad tuning  
- Sensitive to large electrical interference

### 5.3 IP-852 (LON/IP)
Uses UDP multicast for forwarding LONTalk messages over IP.

LON/IP allows:
- High-speed backbones  
- Multi-building interconnect  
- Integration into IT networks (if properly segmented)  

---

# 6. LON Routers

Router types:
- **Repeater** – layer 1 extension  
- **Router** – separates traffic (recommended)  
- **Bridge** — legacy term  

Routers prevent network overload and segment traffic into channels.

### Router Behaviours:
- Forward NV updates across channels  
- Filter traffic to reduce load  
- Map addresses between subnet domains  
- Support IP-852 tunnelling  

---

# 7. IP-852 (LON/IP) Deep Dive

LON/IP encapsulates LON frames inside UDP/IP.

Key components:

- **Channel** – a virtual LON network over IP  
- **Channel ID** – used to group devices  
- **Configuration Server** – distributes channel configuration  
- **IP-852 Router** – links between IP and TP/FT-10

### Multicast usage:
- Uses multicast groups for forwarding NV events  
- Requires **IGMP snooping** and VLAN containment  
- High risk of flooding without VLAN isolation  

### Best Practices:
- One IP channel per VLAN  
- Never bridge LON/IP across subnets without routers  
- Use unicast where vendor supports  
- DO NOT run IP-852 on corporate IT networks  

---

# 8. LON vs BACnet vs Modbus vs OPC-UA

| Feature | LON | BACnet/IP | Modbus | OPC-UA |
|---------|-----|-----------|--------|--------|
| Security | None | None | None | Strong |
| Data Model | NVs | Objects | Registers | Objects/Types |
| Scalability | Good (with routers) | Fair | Poor (polling) | Excellent |
| Speed | Slow (TP) | Medium | Medium | Fast |
| Longevity | Legacy-heavy | Modern | Legacy | Modern |
| WAN capable | No | No | Partial | Yes |
| Multicast risk | High (IP-852) | Medium | Low | Medium |

LON is powerful but aging — still present in many buildings from 1990–2015.

---

# 9. Integrating LON with Modern BMS

Common integration patterns:

### 9.1 LON → BACnet/IP Gateway
Maps SNVTs to BACnet objects:

SNVT_temp_p → analog-input
SNVT_switch → binary-value

Issues:
- Limited gateway throughput  
- Mapping must match DPTs precisely  
- Tuning required to avoid flooding  

### 9.2 LON → OPC-UA Gateway
Becoming more common for analytics/IoT:
- More scalable  
- Better data modelling  
- Works well for cloud integrations  

### 9.3 LON → Modbus
Occasional for:
- Metering  
- Simple IO consolidation  

---

# 10. VLAN Design for LON/LON-IP

LON/IP should be strongly isolated.

### Recommended VLAN Structure:

VLAN 300 – LON/IP Channel A
VLAN 301 – LON/IP Channel B
VLAN 310 – LON Routers / Gateways
VLAN 320 – BMS Supervisors

### Rules:
- Do NOT mix LON/IP with general OT devices  
- Do NOT let LON multicast escape the VLAN  
- Use routers to connect LON channels across buildings  
- No direct LON/IP on corporate networks  

---

# 11. Common LON Failure Modes

| Failure | Cause |
|--------|-------|
| Devices sporadically offline | Poor TP wiring / reflections |
| Unpredictable behaviour | Duplicate Neuron IDs / Node IDs |
| Slow network | Flooding NV updates / no routers |
| Router overload | Too many NVs passing channels |
| Supervisor timeout | LON gateway maps too many NVs |
| High CPU on switches | IP-852 multicast storm |
| Random HVAC issues | Bad SNVT type mapping |

LON is extremely sensitive to topology and signal quality.

---

# 12. Troubleshooting LON

### Tools:
- Wireshark (LonWorks dissector)  
- Loytec LPA/LAS tools  
- NL220 / LNS tools  
- Niagara LON drivers  
- Oscilloscope for TP troubleshooting  

### Steps:
1. Identify domain/subnet/node of offending devices  
2. Check NV bindings  
3. Examine router tables  
4. Validate SNVT types  
5. Check TP/FT-10 wiring integrity  
6. Check IP-852 multicast boundaries  
7. Disable bursty devices  

---

# 13. Deployment Patterns by Building Type

## 13.1 Offices
- Legacy VAV systems commonly LON  
- Slowly transitioning to BACnet/IP  
- Use IP-852 for backbone routing  

## 13.2 Hotels
- LON for older room controllers  
- Gateways to BACnet or KNX  
- VLAN-per-floor if using IP-852  

## 13.3 Shopping Centres
- LON HVAC common from 1990s/2000s  
- Integrates poorly with tenant systems  
- Gateways required for modern supervisors  

## 13.4 Mixed-Use Buildings
- Often a mix of LON legacy + modern BACnet/KNX  
- Use BMS integration servers to unify data  
- Strict VLAN separation essential  

## 13.5 University Campuses
- LON widely used in early 2000s  
- Cross-building LON networks extremely fragile  
- Must replace/segregate during upgrade projects  

## 13.6 Industrial
- Some early industrial HVAC used LON  
- Keep isolated from PLC/SCADA networks  

---

# 14. LON Implementation Checklist

### Addressing
- [ ] Unique Neuron IDs  
- [ ] Domain / Subnet / Node plan documented  
- [ ] SNVT types correct  

### Networking
- [ ] Isolated VLAN for LON/IP  
- [ ] IGMP snooping enabled  
- [ ] Channel IDs consistent  
- [ ] Routers configured and rate-limited  

### Integration
- [ ] Gateway mapping validated  
- [ ] Supervisors read-only unless necessary  
- [ ] No cross-building TP/FT-10 lines  

### Troubleshooting
- [ ] Check wiring for reflections and noise  
- [ ] Validate router filters  
- [ ] Ensure no duplicate addresses  
- [ ] Avoid flooding from misconfigured NVs  

---

# Summary

LonWorks is a flexible, event-driven automation protocol deeply embedded in legacy HVAC systems and many large estate deployments.  
It is powerful but fragile, multicast-heavy, and lacking modern security features.

Key principles:

- Strong VLAN containment for LON/IP  
- Use routers to segment traffic  
- Ensure correct SNVT mappings  
- Avoid cross-building monolithic LON networks  
- Introduce gateways (BACnet or OPC-UA) for modern integration  
- Replace aging TP networks during refurbishments where possible  

With proper design and segmentation, LON can coexist with modern BACnet/IP, Modbus, and OPC-UA systems within an enterprise OT network.

