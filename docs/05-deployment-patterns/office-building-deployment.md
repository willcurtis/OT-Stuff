# Office Building Deployment Pattern

Office buildings are the most common type of BMS deployment, ranging from small commercial units to large corporate towers with thousands of occupants.  
They typically include HVAC, lighting, shading, access control, energy metering, occupancy analytics, and increasingly “smart workplace” integrations.

This chapter provides a complete deployment pattern for modern office-grade OT/BMS networks.

---

# 1. Characteristics of Office Building OT/BMS

### 1. High occupant density  
Demand-driven changes in HVAC load, fresh air supply, lighting usage.

### 2. Integration with corporate IT  
Meeting-room systems, occupancy analytics, identity services.

### 3. Multiple building systems  
HVAC, lighting, blinds, metering, access control, lifts, parking systems, fire systems (read-only).

### 4. Smart building platforms  
IoT sensors, wireless gateways, cloud analytics, digital twin platforms.

### 5. Sustainability and ESG reporting  
Energy dashboards, carbon reporting, corporate compliance.

### 6. Multi-vendor infrastructure  
Different contractors responsible for HVAC, lighting, security, and audiovisual systems.

---

# 2. Recommended Office OT Architecture

A typical office OT architecture:

OT Core (Dedicated Room or DC)
├── BMS Supervisors
├── Smart Building Platform / Integration Server
├── NTP Cluster
├── OT Firewalls
├── OT/IT DMZ
├── Vendor Access DMZ
├── SIEM / Monitoring
└── Data Lake / Historian

Building Distribution
├── Riser Switches per floor
├── Floor OT Switches
├── PoE switches for IoT devices (if required)

Floor/Zone Networks
├── FCUs / VAVs
├── Room CO2 / temperature sensors
├── KNX/DALI lighting controllers
├── Shading controllers
├── Meeting room AV integration
└── People counting / occupancy sensors

Office buildings balance broad functionality with maintainability and energy performance.

---

# 3. VLAN Strategy for Office Buildings

A clean VLAN model is essential for scalability and system stability.

VLAN 100–119 – Supervisors & Smart Building Servers
VLAN 120–149 – HVAC Plant
VLAN 150–199 – Floor HVAC (FCUs/VAVs)
VLAN 200–229 – Lighting (KNX/DALI gateways)
VLAN 230–249 – Shading / Blind Controllers
VLAN 250–269 – Energy Meters
VLAN 270–289 – IoT Sensors & Gateways
VLAN 300–319 – OT DMZ
VLAN 320–339 – Vendor Access
VLAN 400–419 – Lift / Conveyance Integration (read-only)

### Key Principles:
- Segmentation must mirror building systems.  
- Lighting, HVAC, and sensors should be in **separate VLANs**.  
- Per-floor VLANs recommended for large buildings.  
- No unmanaged switches anywhere.  

Smart building deployments tend to accumulate vendor devices — segmentation prevents instability.

---

# 4. BACnet/IP in Office Deployments

BACnet/IP is heavily used for:

- VAVs and FCUs  
- AHUs  
- Chillers and boilers  
- Heat pumps  
- CO2 monitoring  
- Shading systems (via gateways)  

### Best Practices:
- Unique BACnet network numbers per floor or per system.  
- Avoid BBMD unless absolutely required.  
- Supervisor discovery by unicast preferred.  
- COV for temperature/CO2; polling for slow-moving metadata.  
- Controller IP addresses must remain static for full lifecycle.  

### Common Pitfalls:
- Duplicate device IDs from different contractors.  
- BACnet storms caused by integrator tools.  
- Oversized broadcast domains (e.g., entire building in one VLAN).  

---

# 5. KNX, DALI, and Lighting Control

Lighting systems in offices are typically KNX or DALI-2.

### KNX Requirements:
- Multicast routing confined to lighting VLAN.  
- Per-floor segmentation recommended.  
- KNX IP routers/gateways placed in secure riser cabinets.  
- Tunnelling used for floor-to-core communication.  

### DALI-2 Requirements:
- IP gateways for each floor or zone.  
- BACnet/KNX/MQTT integration via supervisory layer.  
- Emergency lighting often monitored but not controlled.  

Lighting networks can grow large—maintain strong VLAN boundaries.

---

# 6. Shading / Blind Controls

Blinds and shading systems often integrate via:
- BACnet  
- KNX  
- Modbus  
- Vendor cloud APIs  

### Requirements:
- Put shading on its own VLAN.  
- Avoid direct vendor cloud connections from OT VLANs.  
- Supervisor or integration hub should act as broker.  

Shading failures can affect occupant comfort and energy performance.

---

# 7. Integration with Corporate IT

Smart office deployments require integration with IT systems such as:

- Identity platforms (AD/Azure AD for room booking)  
- Meeting room scheduling (Exchange/M365/Google Workspace)  
- Occupancy analytics  
- Space booking systems  
- Visitor management  

### Integration Requirements:
- All integrations must traverse the OT/IT DMZ.  
- Never expose OT systems directly to corporate networks.  
- Use APIs (REST/MQTT/OPC-UA), not raw protocols like BACnet.  
- Maintain strict firewall rules and logging.  

A clean DMZ prevents OT from becoming an attack vector into corporate IT.

---

# 8. Occupancy Sensors & Smart Building IoT

Modern offices deploy:
- CO2 sensors  
- Humidity sensors  
- BLE beacons  
- PIR/ultrasonic occupancy sensors  
- Meeting room utilisation sensors  

Many use:
- MQTT  
- HTTP/HTTPS APIs  
- LoRaWAN gateways  
- BACnet over IP from IP-based sensors  

### Requirements:
- IoT sensors must be isolated in IoT VLANs  
- MQTT brokers must live in OT/IT DMZ  
- LoRaWAN gateways require restricted outbound-only internet  
- Do not allow IoT devices into HVAC/LAN VLANs  

IoT is a major cybersecurity risk; treat it with caution.

---

# 9. Meeting Room Automation

Meeting rooms often integrate:

- HVAC temperature boost  
- Lighting scenes  
- Occupancy-based control  
- AV system integration (Crestron/Extron)  
- Blinds  

### Requirements:
- AV networks must remain separate from BMS networks  
- Integrations must be via approved APIs  
- No AV device should speak BACnet/IP or KNX directly  
- Room controllers must not see devices from other rooms  

Meeting room AV integrators frequently bypass network design — enforce policy tightly.

---

# 10. Remote Access Requirements

Office buildings have many vendors but fewer than malls/hospitals.

### Recommended Access Model:
Vendor → VPN → DMZ → Jump Host → OT Firewall → Approved systems

### Controls:
- MFA mandatory  
- Vendor-specific firewall rules  
- Logging of all BACnet/Modbus writes  
- Session recording on jump host  
- Time-limited access windows  

### Prohibited:
- Direct vendor VPN into OT  
- Contractors connecting laptops to BMS switches  
- Unmanaged switches for AV or lighting contractors  

Contractor behaviour is the biggest risk to office BMS stability.

---

# 11. Monitoring Requirements

Monitoring in office buildings should cover:

### HVAC:
- VAV/FCU status  
- AHU temperatures & pressures  
- CO2 levels  
- Occupancy patterns  

### Lighting:
- Driver failures  
- Scene activation stats  

### Energy:
- Meter readings  
- Power factors  
- Demand response episodes  

### IoT:
- Sensor availability  
- Uplink health  
- MQTT throughput  

### Network:
- BACnet storms  
- KNX routing anomalies  
- DHCP or ARP conflicts  
- Gateway performance  

Monitoring ensures a stable tenant experience and supports ESG objectives.

---

# 12. High Availability Requirements

Commercial offices typically require moderate resilience.

### Recommended:
- Dual OT Core switches  
- UPS in all risers  
- Supervisor redundancy for large sites (>250,000 sq ft)  
- Redundant integration server where PMS/occupancy is used  

### Not Required:
- Full dual-path A/B physical separation  
- Controller-level redundancy for FCUs/VAVs  
- HA clustering for every system  

Focus HA on *plant* and *supervisors*, not end devices.

---

# 13. Common Office Deployment Failures

### ❌ One VLAN for entire building BMS  
Causes broadcast storms and poor scalability.

### ❌ Integrators mixing HVAC and lighting on same VLAN  
Leads to multicast instability.

### ❌ IoT sensors dumped into HVAC VLAN  
Creates noise and vulnerabilities.

### ❌ AV contractors plugging gear into OT switches  
Breaks segmentation and confuses device discovery.

### ❌ Cloud integrations allowed directly from OT network  
Bypasses DMZ and exposes OT systems.

### ❌ Duplicate BACnet device IDs  
Causes devices to vanish from BMS.

---

# 14. Office Deployment Checklist

### Segmentation
- [ ] Per-system VLANs (HVAC, lighting, shading, IoT)  
- [ ] Per-floor segmentation for large sites  
- [ ] Strict isolation of IoT  

### Integration
- [ ] All IT integrations via DMZ  
- [ ] Use APIs, not raw protocols  
- [ ] Gateways isolated  

### Remote Access
- [ ] Jump host mandatory  
- [ ] MFA enforced  
- [ ] Access time-limited  

### Monitoring
- [ ] HVAC, lighting, shading  
- [ ] IoT device health  
- [ ] Network traffic anomalies  
- [ ] BACnet/KNX behaviour  

---

# Summary

Office buildings are evolving into smart buildings that blend HVAC, lighting, blinds, sensors, analytics, and corporate IT platforms.  
The OT network must support these features while enforcing strict segmentation, secure integrations, and predictable performance.

Key principles:

- Per-system + per-floor VLAN design  
- Isolate IoT from HVAC and lighting  
- Use DMZ for IT integrations  
- Strong remote access governance  
- Continuous monitoring  
- Avoid overloading BACnet and KNX networks  

A well-engineered office OT/BMS network delivers comfort, efficiency, and smart-building capabilities without compromising security or stability.
