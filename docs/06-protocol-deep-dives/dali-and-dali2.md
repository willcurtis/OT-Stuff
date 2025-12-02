# DALI / DALI-2 / D4i Deep Dive  
**Digital Addressable Lighting Interface – Architecture, Addressing, Control Gear, Emergency Lighting, Gateways, IP Integration**

DALI (Digital Addressable Lighting Interface) is one of the most common control protocols for commercial lighting.  
It is widely used for:

- Office lighting  
- Retail lighting  
- Hotel room lighting  
- Corridors and common areas  
- Emergency lighting systems  
- Daylight harvesting and presence-based control  

DALI-2 and D4i introduce more structure, certified interoperability, advanced sensors, and IoT readiness.

---

# 1. DALI Architecture Overview

DALI is a **two-wire, polarity-agnostic**, low-voltage control bus.

### Key properties:
- 16 V DC (approx.)  
- Up to **64 devices per DALI line**  
- Typically one line per floor/zone  
- 2, 3, or 5-core cable depending on emergency/monitoring requirements  
- Maximum cable length: **300 m** (depending on topology and cross-section)  
- Multi-master (multiple controllers allowed)  
- Manchester-encoded signals  

DALI is NOT an IP protocol — all logic occurs on the bus unless a gateway exposes it.

---

# 2. DALI Device Types

### 2.1 Control Gear (Drivers)
- LED drivers  
- Fluorescent ballasts (legacy)  
- Emergency drivers (self-test & reporting)  
- Tunable white and RGB drivers  
- D4i drivers with integrated sensors & memory banks  

### 2.2 Control Devices
- Sensors (PIR, lux, occupancy)  
- Push-button interfaces  
- Application controllers (central logic units)  

### 2.3 Application Controllers
Manage:
- Scenes  
- Groups  
- Sensor logic  
- Emergency lighting tests  

---

# 3. DALI Addressing

Each DALI line contains up to:

- **64 Short Addresses**  
- **16 Groups**  
- **16 Scenes**  

### 3.1 Short Address (0–63)
Unique per device on a line.

### 3.2 Group Addressing
Devices may belong to multiple groups (bitmask-based).

Example:

Group 1 – Open Plan Left
Group 2 – Open Plan Right
Group 3 – Corridor

### 3.3 Broadcast
Commands addressed to all devices on a line.

### 3.4 DALI-2 Improvements
- Mandatory certification  
- Better device discovery  
- More consistent addressing behaviours  
- Support for multi-master arbitration  

---

# 4. DALI Control Types

### 4.1 Direct Arc Power Control (DAPC)
Sets dimming level:

0–254  (0%–100%)
255    (MASK/IGNORE)

### 4.2 Relays / Switching
On/off commands.

### 4.3 Scene Management
Up to 16 scenes stored in drivers.

### 4.4 Colour Control (DALI Device Type 8)
- Tunable white  
- RGB  
- RGBWAF  
- Tc (colour temperature)  

---

# 5. DALI-2 (IEC 62386-101/103/207/xxx)

DALI-2 is a major improvement over original DALI.

### New Capabilities:
- Certified interoperability (DiiA)  
- Standardised input devices  
- Defined data structures for sensors  
- Multi-master arbitration improvements  
- Better emergency test sequences  

### Standardised Input Devices include:
- Occupancy sensors  
- Light level (lux) sensors  
- Push-button interfaces  

---

# 6. D4i – DALI for IoT

D4i extends DALI-2 for **luminaire-level IoT / smart luminaires**.

Adds:
- **Memory banks** storing energy, usage, and diagnostics  
- Asset management data  
- Power monitoring  
- Integrated sensors  
- Ready for PoE/IoT node controllers  

D4i is increasingly used in smart office and smart city deployments.

---

# 7. Emergency Lighting on DALI

Emergency lighting is one of the most important DALI applications.

### Supported Functions:
- Automatic self-test  
- Function tests  
- Duration tests  
- Reporting of failures  
- Battery condition  
- Lamp condition  

### BMS Integration:
Gateways expose:
- Emergency test status  
- Battery condition  
- Inverter condition  
- Test timestamps  

### Common Issues:
- Incorrect addressing of EM drivers  
- Missing test scheduling  
- BMS misinterpreting EM status registers  
- Large networks polling too frequently  

---

# 8. DALI Bus Topology & Cabling

### Rules:
- No need for screened cable  
- Polarity-free  
- Tree, star, and line topologies allowed  
- Total cable length ≤ 300 m  
- Maximum 64 devices per line  

### Typical Cable Types:
- 5-core (L, N, E, DA+, DA–) for emergency-enabled luminaires  
- 2-core for pure DALI control bus  

---

# 9. DALI Gateways & BMS Integration

Since DALI is NOT an IP protocol, gateways are required.

Common gateway outputs:
- BACnet/IP  
- Modbus TCP  
- KNX  
- OPC-UA  
- MQTT  

### 9.1 Gateway Responsibilities:
- Represent each DALI driver as objects/registers  
- Aggregate status from all devices  
- Provide grouping and scene control  
- Provide EM test triggering  
- Rate-limit polling  
- Abstract DALI bus timing from supervisor  

### 9.2 Gateway Failure Modes:
- Too many DALI devices mapped (overloaded CPU)  
- BMS polling too fast  
- Mapping mismatch (scene vs DAPC confusion)  
- Emergency test commands not passed correctly  
- DALI power supplies overloaded  

---

# 10. DALI on IP (DALI-2 Gateways)

DALI still operates on a bus, but IP-connected devices allow:

- Multi-line controllers with Ethernet backhaul  
- Distributed DALI loops per floor  
- Seamless integration into VLANs  
- Cloud-connected analytics for D4i data  

DALI is NOT multicast-heavy like KNX unless the gateway uses a proprietary scheme.

---

# 11. VLAN Design for DALI Gateways

### Recommended VLAN Layout:

VLAN 220 – DALI Line 1 Gateway
VLAN 221 – DALI Line 2 Gateway
VLAN 222 – DALI Line 3 Gateway
VLAN 230 – D4i IoT Controllers
VLAN 240 – Emergency Lighting Monitoring

### Rules:
- Each IP gateway gets its own VLAN or grouped VLAN  
- Never put DALI gateways in KNX/BACnet VLANs  
- No direct connectivity from corporate networks  
- Apply firewall rules limiting BMS → gateway communication  

---

# 12. Performance Considerations

### Limitations:
- 64 devices per line  
- Bus is slow — do not flood it  
- Avoid excessive polling from gateways  
- Keep group commands instead of individual dimming where possible  
- Avoid highly granular brightness adjustments (e.g., “fade to 1-step increments”)  

### Scaling Strategies:
- Multiple DALI loops  
- DALI-2 multi-master controllers  
- D4i for per-fixture telemetry without heavy bus load  

---

# 13. Troubleshooting DALI

## 13.1 Common Issues

| Issue | Likely Cause |
|--------|--------------|
| Devices not responding | Short address collision / no power / wiring fault |
| Flickering | Overloaded DALI PSU / multiple masters conflicting |
| Slow response | Too many bus commands / gateway polling too fast |
| EM failures not reported | Gateway misconfiguration |
| Some lamps ignore scenes | Scene not stored locally |
| Group commands failing | Bad bus segment or unpowered driver |

## 13.2 Tools
- Manufacturer DALI test tools  
- DALI bus analysers (Tridonic, HELVAR, etc.)  
- BMS logs  
- Gateway debug interfaces  

---

# 14. Deployment Patterns by Building Type

## 14.1 Offices
- Large multi-loop DALI-2 networks  
- Daylight harvesting  
- Occupancy-linked HVAC adjustments  
- Emergency lighting integrated with BMS  

## 14.2 Hospitality (Hotels)
- Scene-based lighting  
- DALI for public areas  
- D4i emerging for guest-room IoT integration  

## 14.3 Retail
- Scene & schedule control  
- Integration with DMX for architectural lighting  

## 14.4 Mixed-Use Buildings
- Emergency lighting monitoring  
- Full DALI-2 deployment across office & residential  
- Per-residential-unit loops for privacy  

## 14.5 Education & Campus
- Classrooms with occupancy & daylight control  
- Lecture theatres with scene profiles  
- Emergency lighting across blocks  

## 14.6 Industrial
- Warehouse lighting  
- Large-area occupancy sensing  
- D4i for luminaire diagnostics  

---

# 15. DALI Implementation Checklist

### Architecture
- [ ] ≤ 64 devices per DALI line  
- [ ] Correctly sized DALI power supply  
- [ ] Multi-master supported only with DALI-2  
- [ ] IP gateways isolated via VLAN  

### Addressing
- [ ] Short addresses unique per line  
- [ ] Group assignments tested  
- [ ] Scenes stored correctly in all drivers  

### Emergency Lighting
- [ ] EM auto-test schedule configured  
- [ ] BMS gateway correctly exposes EM data  
- [ ] Duration tests logged  

### Integration
- [ ] BMS polling rate appropriate  
- [ ] Scene vs DAPC mapping clear  
- [ ] VLAN + Firewall rules applied  
- [ ] No bridging across floors without need  

---

# Summary

DALI, DALI-2, and D4i form a robust and highly interoperable ecosystem for commercial lighting control, emergency monitoring, and IoT-enabled luminaires.  
Although the bus itself is simple and low-speed, the integration layer (IP gateways) must be carefully engineered for stability and scalability.

Key principles:

- Keep DALI loops ≤ 64 devices  
- Use DALI-2 for multi-master reliability  
- Use D4i for luminaire-level analytics  
- Strong VLAN isolation for gateways  
- Avoid excessive polling  
- Validate scene, group, and EM configurations thoroughly  

DALI remains an essential part of modern building automation when integrated with BACnet, KNX, OPC-UA, and MQTT systems.
