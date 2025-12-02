# KNX Deep Dive  
**KNX TP / KNX RF / KNX IP – Architecture, Addressing, Routing, Tunnelling, VLAN Design, Security**

KNX is a widely used building automation standard for lighting, blinds, sensors, user interfaces, and room automation.  
It is especially common in:
- Commercial offices  
- Hotels  
- Mixed-use developments  
- High-end residential properties  
- Campus environments  

This chapter provides a complete technical reference for KNX, focusing on KNX IP behaviour, routing, addressing, and best practices for integration with enterprise OT/BMS networks.

---

# 1. KNX Architecture Overview

KNX is built on three transport layers:

| KNX Variant | Medium | Notes |
|-------------|---------|-------|
| **KNX TP (Twisted Pair)** | 9600 baud bus | Most common fieldbus-type deployment |
| **KNX RF** | Wireless | Low-power IoT-style devices |
| **KNX IP** | Ethernet/IP multicast | Used for backbone, routing, tunnelling |

A KNX installation typically includes:
- Sensors (push buttons, PIRs, CO2, brightness sensors)  
- Actuators (lighting relays, dimmers, blind actuators)  
- Room controllers  
- Logic modules  
- KNX IP routers  
- KNX IP interfaces (tunnelling)

The topology can be hierarchical and very large when using KNX IP as a backbone.

---

# 2. KNX Addressing Model

KNX uses **two completely different address types**:

## 2.1 Physical Address (Individual Address)
Format:  

Area.Line.Device

Example:

Purpose:
- Identifies the device itself  
- Used for commissioning  
- Used for routing on TP lines  
- Must be unique within the installation  

## 2.2 Group Addresses
Used for runtime communication.

Two common formats:

### Three-level (recommended):

Main / Middle / Sub
1 / 2 / 33

### Two-level:

Main / Sub
1 / 45

Group addresses represent **functional** communication, e.g.:

1/0/1 – Office Floor 1 / Corridor / Lights ON
1/0/2 – Office Floor 1 / Corridor / Lights OFF
1/1/20 – Meeting Room / Blinds / Down

A device may listen to many GA’s and send to one or more GA’s depending on logic.

---

# 3. KNX Telegrams

KNX messages are called **telegrams**.

A telegram includes:
- Source individual address  
- Destination group or individual address  
- APCI (Application Control Information)  
- Data payload (e.g., 1-bit switch, 1-byte dimming, 2-byte temperature, etc.)  

Common Data Point Types (DPTs):
- **1-bit** (boolean): switching, open/close  
- **1-byte**: dimming, scenes  
- **2-byte float**: temperature  
- **4-byte float**: CO2, humidity, lux  
- **Byte arrays**: complex payloads  

DPT consistency is critical — mismatched types = unpredictable behaviour.

---

# 4. KNX TP (Twisted Pair)

KNX TP is a 9600 baud, half-duplex bus.

### Properties:
- Supports 64–256 devices per line (depending on topology)  
- Lines connect to **KNX line couplers**  
- Every line requires its own power supply  
- Noise-resistant but slow  
- Deterministic and very reliable  

KNX TP is common in:
- Hotels  
- Offices  
- Residential projects  

But large buildings often migrate to KNX IP for backbone.

---

# 5. KNX IP — The Backbone for Modern Buildings

KNX IP is used for:
- Inter-line routing  
- ETS programming  
- Backbone for large systems  
- Integration with BMS platforms  
- Tunnelling for engineering tools  
- Routing of group telegrams using **multicast**

## 5.1 KNXnet/IP Routing
Routing uses multicast:

IP Multicast Address: 224.0.23.12
UDP Port: 3671

Routers forward group telegrams between lines.

### Behaviour:
- All routing devices must join multicast group  
- Multicast must be delivered to all KNX IP routers  
- **High risk of storming** if multicast leaks between VLANs  
- Flooding can occur on networks without IGMP snooping  

## 5.2 KNXnet/IP Tunnelling
Provides *unicast* point-to-point communication between ETS/clients and an IP interface.

Advantages:
- Isolated  
- Predictable  
- Easier to firewall  
- Preferred for commissioning  
- No multicast required

---

# 6. KNX IP Routing vs Tunnelling — Critical Differences

| Feature | Routing | Tunnelling |
|---------|---------|------------|
| Multicast required | Yes | No |
| Used for runtime GA traffic | Yes | No |
| Used for commissioning | Rare | Yes |
| Flood risk | High without IGMP snooping | None |
| Ideal for | Large installations with many lines | Programming and integrations |

**Best practice:**  
Use **KNX IP Routing** for backbone if needed, but keep it inside a small, well-contained VLAN.  
Use **Tunnelling** for BMS and supervisor integrations.

---

# 7. KNX in VLAN and Enterprise Networks

## 7.1 VLAN Containment Rules
- KNX must stay within its own VLAN  
- Never bridge KNX across buildings  
- Never share VLAN with BACnet or Modbus  
- Enable IGMP snooping to avoid multicast flooding  
- Gateways should NOT leak KNX traffic into corporate networks  

## 7.2 Recommended VLAN Design

VLAN 200 – KNX Lighting Backbone
VLAN 201 – KNX Floor 1
VLAN 202 – KNX Floor 2
VLAN 203 – KNX Floor 3
…
VLAN 210 – KNX Gateways / Supervisors

Do not mix KNX routing with guest or tenant networks.

---

# 8. ETS (Engineering Tool Software) Considerations

ETS is the official KNX programming tool.

### ETS Essentials:
- Required for all KNX programming  
- Manages physical addresses and group addresses  
- Requires tunnelling or local TP interface  
- Supports import/export of project files  
- All parameterisation depends on vendor plugins  

Bad ETS programming is one of the top causes of KNX issues.

---

# 9. KNX Integration with BMS (BACnet, OPC-UA, Modbus)

KNX does not use polling by default — it is event-driven.  
Interfacing via gateways requires careful mapping.

### 9.1 KNX → BACnet
Common mappings:
- Lighting On/Off ↔ binary-value  
- Dim level ↔ analog-value  
- Room temp ↔ analog-input  
- Blind position ↔ multi-state  

Risks:
- Incorrect DPT mapping  
- Broadcast leak from BACnet interfering with KNX gateway  
- Overloaded gateways handling too many objects  

### 9.2 KNX → OPC-UA
Ideal for:
- Smart-building analytics  
- IoT integration  
- Energy dashboards  

### 9.3 KNX → Modbus
Less common but used for:
- Metering  
- Simple IO expansion  

---

# 10. KNX Security

Traditional KNX has **no encryption**.  
This is extremely dangerous when deployed on enterprise networks.

### Threats:
- Replay attacks  
- Switching lights/blinds  
- Overriding scenes  
- Triggering HVAC events  
- Data exfiltration via multicast  

## 10.1 KNX Secure (ETS 5+)
KNX Secure adds:
- **AES-128 encryption**
- **Secure unicast**
- **Secure multicast (KNX IP Secure Routing)**
- **Authenticated devices**

Two security modes:
1. **KNX IP Secure Tunnelling**
2. **KNX IP Secure Routing**

Recommended whenever using KNX IP on routed networks.

---

# 11. KNX Performance Considerations

### 11.1 Telegram Limits
- Frequent state changes generate many telegrams  
- Dimmer feedback can saturate bus  
- Motion sensors can fire rapidly  

### 11.2 KNX IP Router Load
- Routing requires CPU  
- Too many telegrams overwhelm routers  
- Use separate routers per floor for large buildings  

### 11.3 Multicast Storm Risk
If multicast leaks:
- All switches process traffic  
- Supervisors become unstable  
- BACnet and KNX interfere with one another  

---

# 12. Troubleshooting KNX

## 12.1 Common Issues & Causes

| Symptom | Likely Cause |
|---------|--------------|
| Lighting delay | Router overloaded / multicast flood |
| ETS cannot connect | Wrong tunnelling slot / firewall problem |
| Devices wrong behaviour | Incorrect DPT mapping |
| Intermittent failures | Power supply issue / line overloaded |
| Flooding in network | KNX multicast leaking VLAN boundaries |
| Scenes failing | Incorrect group address binding |

## 12.2 Tools
- ETS Diagnostics  
- Wireshark with KNX dissector  
- KNX Monitor tools (WEINZIERL, etc.)  
- Switch IGMP statistics  
- KNX router diagnostic pages  

---

# 13. Deployment Patterns by Building Type

## 13.1 Offices
- KNX for lighting and blinds  
- Multiple floors with IP backbone  
- Integrate with meeting room systems via OPC-UA  
- Strong VLAN isolation  

## 13.2 Hospitality (Hotels)
- KNX for room lighting, scenes, blinds  
- Per-floor VLAN  
- Integration with PMS/BMS via gateway  
- Avoid cross-floor multicast  

## 13.3 Retail
- Simple KNX lighting  
- Scene-based control  
- VLAN per retail unit if multi-tenant  

## 13.4 Mixed-Use Buildings
- Complex scene management  
- Separate zones for residential, office, retail  
- KNX Secure recommended  
- Avoid mixing with BACnet/IP VLANs  

## 13.5 Universities / Labs
- Lab lighting (KNX)  
- Teaching spaces  
- Integration with occupancy & sensors  
- Strong containment between buildings  

## 13.6 Industrial
- KNX used sparingly (offices, labs, lighting)  
- Ensure isolation from PLC networks  

---

# 14. KNX Implementation Checklist

### Addressing
- [ ] Unique individual addresses  
- [ ] Group addresses organised hierarchically  
- [ ] DPTs correct across devices  

### Networking
- [ ] KNX routing constrained to VLAN  
- [ ] IGMP snooping enabled  
- [ ] No multicast leakage to corporate network  
- [ ] Tunnelling used for commissioning  

### Security
- [ ] KNX IP Secure enabled  
- [ ] Firewall rules limiting tunnelling access  
- [ ] No bridging between floors or tenants  

### Performance
- [ ] Router CPU load monitored  
- [ ] Telegram bursts avoided  
- [ ] Scene logic tested under load  

---

# Summary

KNX is a powerful, flexible building automation protocol that excels in lighting, blinds, room control, and user interfaces.  
However, its reliance on multicast and lack of default security require careful design in enterprise environments.

Key principles:

- Strong VLAN containment  
- Use KNX IP Tunnelling for BMS integration  
- Enable KNX Secure whenever possible  
- Correct group address and DPT structure  
- Avoid multicast leakage  
- Do not share VLANs across building zones  

With correct engineering, KNX becomes a stable and scalable subsystem within a modern OT/BMS architecture.

