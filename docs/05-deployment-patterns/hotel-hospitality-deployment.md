# Hotel & Hospitality OT/BMS Deployment Pattern

Hotels and hospitality venues have unique BMS requirements driven by:
- High guest turnover  
- Room-level HVAC and lighting control  
- Large-scale VRF/VRV deployments  
- Occupancy/energy optimisation  
- Integration with PMS (Property Management Systems)  
- Strict privacy and isolation requirements  

BMS systems must operate efficiently, securely, and without compromising the guest experience.

---

# 1. Characteristics of Hospitality OT/BMS

### 1. Large number of small, similar zones  
Every guest room is effectively a mini-BMS environment with HVAC, lighting, occupancy sensing, blinds, and card readers.

### 2. Integration with PMS  
Rooms must change mode when:
- Guests check in  
- Guests check out  
- Housekeeping enters  
- Rooms placed out of service  

### 3. High system diversity  
VRF/VRV HVAC, card-access, lighting control, shading, IP TVs, energy meters.

### 4. Security & Privacy  
Guest rooms must never see each other’s devices.  
Vendor misconfigurations can leak BACnet/KNX across floors.

### 5. Energy performance  
Occupancy-based and schedule-based optimisation is essential.

---

# 2. Recommended Hospitality OT Architecture

A typical hotel OT architecture:

OT Core (in back-of-house)
├── Supervisors (HVAC, Lighting, Room Control)
├── PMS Integration Server
├── NTP Servers
├── OT Firewall
├── Remote Access DMZ
├── Logging / Monitoring
└── Database for Trends & Room Status

Floor Distribution
├── Floor OT Switches
├── VRF/VRV Gateways
├── Lighting Control Panels
├── Room Controller Networks

Guest Rooms
├── Fan Coil Unit (FCU) Controllers
├── Occupancy Sensors
├── Card Reader Integration
├── Lighting Controllers (DALI/KNX/BACnet)
├── Blinds/Shades Controllers
└── Thermostats

Hotels contain the highest density of controllers per square metre of any building type.

---

# 3. VLAN Strategy for Hotels

The VLAN structure must support segmentation by **function and location**.

VLAN 100–119 – Supervisors & PMS Integrations
VLAN 120–129 – Central Plant HVAC
VLAN 200–239 – Guest Room Floornets (unique per floor)
VLAN 240–259 – VRF/VRV Gateways
VLAN 260–279 – Room Control Panels
VLAN 280–289 – Lighting Control (DALI/KNX)
VLAN 290–299 – Energy Metering
VLAN 350–359 – OT DMZ
VLAN 360–369 – Vendor Access VLAN

### Key Rules:
- Each floor must have its own dedicated VLAN(s).  
- Guest room devices must not communicate across floors.  
- VRF gateways must not be in the same VLAN as FCUs.  
- Lighting VLANs must be isolated from HVAC VLANs.  

Guest privacy and network stability depend on strict segmentation.

---

# 4. BACnet/IP in Hotels

BACnet/IP is used for:
- FCUs  
- VRF/VRV interfaces  
- Room controllers  
- AHUs for corridors and shared areas  

### Best Practices:
- Assign unique BACnet device IDs to each room controller  
- Use per-floor VLANs to contain broadcasts  
- Avoid BBMD unless integrating multiple buildings  
- Tune COV thresholds to avoid high volumes of occupancy transitions  
- Supervisors should use unicast wherever possible  

### Common Problems:
- Duplicate device IDs across floors  
- Broadcast storms caused by contractor laptops  
- VRF gateways overwhelmed by polling  

---

# 5. KNX, DALI, and Lighting Systems

Lighting in hotels is often KNX or DALI with IP gateways.

### KNX Requirements:
- Keep KNX routing multicast local to the VLAN  
- Use tunnelling for floor-to-core traffic  
- Do not expose KNX gateways to guest networks  
- Isolate per-floor KNX from other floors  
- Avoid giant KNX line structures spanning multiple floors  

### DALI Requirements:
- IP gateways placed in riser panels  
- VLAN-isolated DALI networks  
- Supervisory interface via BACnet or vendor API  

Lighting is critical for guest comfort; outages are immediately visible.

---

# 6. VRF/VRV System Integration

VRF/VRV systems form the backbone of hotel HVAC.

### Requirements:
- Gateways placed in isolated VLAN  
- Supervisory access only  
- Avoid vendor-proprietary cloud access if possible  
- Polling rate must be conservative  
- Provide fallback automation in room controllers  
- Ensure firmware and register maps are documented  

### Failure Modes:
- VRF gateways overloaded  
- Too many BACnet objects exposed  
- Vendor cloud outages blocking control  
- Mismatched addressing between floors  

---

# 7. Guest Room Integration Design

Each room acts as a small automation cell.

### Typical Room Subsystems:
- FCU/VRF controller  
- Chain-door card reader (occupancy)  
- PIR sensors  
- Lighting controls  
- Smart thermostat  
- Blinds  
- Receptacle (socket) control (energy saving)  

### Integration Logic:
- Guest check-in → Room occupied mode  
- Guest leaves → Economy mode  
- Guest check-out → Shutdown mode  

### Requirements:
- All logic handled through supervisor or integration server  
- No room-to-room communication  
- If one room system fails, others unaffected  

Guest rooms must be isolated to prevent cascading failures.

---

# 8. PMS (Property Management System) Integration

PMS integration is one of the most important components of hotel automation.

Common PMS systems:
- Opera (Oracle)  
- Protel  
- Maestro  
- Cloud PMS platforms  

### Integration Methods:
- REST API (most common)  
- SOAP  
- BACnet via integration server  
- MQTT  

### Requirements:
- PMS <-> BMS communication must traverse OT DMZ  
- No direct PMS access into OT VLANs  
- All check-in/out events logged  
- Redundant integration servers if possible  

Failure of PMS–BMS integration leads to:
- Rooms stuck in wrong mode  
- Energy waste  
- Poor guest experience  

---

# 9. Remote Access Requirements

Hotels experience extremely high contractor turnover: HVAC, lighting, VRF, AV, etc.

### Mandatory Controls:
- MFA  
- Jump host  
- Session recording  
- Vendor-specific access profiles  
- Access time windows aligned with maintenance hours  

### Prohibited:
- Vendor connecting laptop in guest room  
- Vendor connecting to room controller VLAN  
- 4G routers installed by contractors  
- Direct VPN into hotel OT network  

The hospitality environment is a major cybersecurity target.

---

# 10. Monitoring Requirements

Monitoring must cover both public areas and guest room environments.

### Room-Level Telemetry:
- Temperature  
- Setpoint  
- Occupancy status  
- Window contact sensors  
- FCU/VRF status  
- Lighting scenes  

### System-Level Telemetry:
- VRF load  
- AHU performance  
- Hot water temperature  
- Chiller/boiler operation  
- Energy usage  
- Lift and fire system integration (read-only)  

### Network Monitoring:
- BACnet storms per floor  
- KNX routing behaviour  
- Gateway overload  
- VLAN misconfigurations  

Monitoring ensures guest comfort and energy efficiency.

---

# 11. High Availability Requirements

Hotels rarely require Tier III/IV redundancy, but uptime remains important.

### Recommended:
- Dual OT Core switches  
- UPS-backed plant areas  
- Spare room controllers for quick replacement  
- Redundant supervisors for large hotels (>200 rooms)  
- Redundant PMS integration servers  

### Not Required:
- Dual controllers per room  
- Controller-level HA for FCUs  
- VRF gateway redundancy (unless high-volume or business critical)  

---

# 12. Common Hospitality Deployment Failures

### ❌ Shared VLAN for all guest rooms  
Causes broadcast storms and privacy breaches.

### ❌ Room controllers reachable from guest Wi-Fi  
Critical security vulnerability.

### ❌ VRF gateways in same VLAN as FCUs  
Gateway overload and polling collisions.

### ❌ Duplicate device IDs across floors  
Breaks BACnet auto-discovery.

### ❌ KNX multicast leaking between floors  
Causes lighting instability.

### ❌ PMS integration direct to BMS supervisor  
Bypasses OT DMZ and logs.

---

# 13. Hotel Deployment Checklist

### Segmentation
- [ ] Unique VLAN per floor  
- [ ] Gateways in their own VLAN  
- [ ] Guest room networks isolated  
- [ ] Lighting/HVAC networks separate  

### Integration
- [ ] PMS integration via OT DMZ  
- [ ] Room-level controllers interconnected only via supervisor  
- [ ] VRF/VRV gateways restricted  

### Remote Access
- [ ] Jump host mandatory  
- [ ] No vendor access to guest rooms  
- [ ] MFA enforced  

### Monitoring
- [ ] Room telemetry  
- [ ] System telemetry  
- [ ] Network monitoring  

---

# Summary

Hotels combine high-density automation with strict privacy requirements and complex occupancy-driven behaviour.  
Network design must isolate rooms, protect tenant/guest confidentiality, and support large-scale VRF and lighting systems.

Key principles:

- Segmentation per floor and per system  
- Secure PMS integration  
- Strong remote access controls  
- Gateway isolation  
- Robust monitoring  
- Minimise broadcast domains  

A well-designed hospitality OT network improves both guest experience and energy efficiency.
