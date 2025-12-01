# Education Campus Deployment Pattern

Education estates—schools, colleges, universities, and research campuses—combine characteristics from commercial offices, multi-tenant retail, hospitality, and industrial environments.  
They often include teaching spaces, offices, laboratories, lecture theatres, residential buildings, sports facilities, and plant rooms spread across multiple buildings.

This diversity leads to highly variable OT/BMS requirements, with strong segmentation, multi-vendor coordination, and central policy enforcement required to maintain safety, resilience, and stability.

---

# 1. Characteristics of Educational OT/BMS Environments

### 1. High building diversity  
Typical campus buildings include:
- Teaching blocks  
- Science labs  
- Student accommodation  
- Libraries  
- Sports centres  
- Catering buildings  
- Admin offices  
- Data centres/server rooms  

Each has different HVAC, lighting, and control requirements.

### 2. Large geographical spread  
Campuses may span dozens of buildings, often separated by roads or public access areas.

### 3. Frequent user turnover  
Students, staff, visitors, contractors, and researchers.

### 4. High equipment turnover  
Annual refurbishments, seasonal works, and incremental upgrades produce complexity.

### 5. Security variability  
Some buildings require strict security (research labs), others are public access.

### 6. Legacy + modern systems mixed  
Decades-old plant equipment coexists with new smart-building systems.

---

# 2. Recommended Architecture for Education Campuses

A campus BMS architecture combines:
- Strong segmentation  
- Centralised management  
- Building autonomy  
- Robust remote access  
- Multi-facility monitoring  

Typical architecture:

Campus OT Core (Main Building / Data Centre)
├── Supervisors for HVAC, Lighting, Lab Systems
├── NTP Cluster
├── OT Firewalls
├── OT Monitoring/SIEM
├── Integration Servers (MQTT, OPC-UA, REST)
├── OT/IT DMZ
├── Remote Access DMZ + Jump Hosts
└── Backup / Trend Storage

Building Distribution Layer
├── Redundant building OT switches
└── Riser/Floor OT switches

Building OT VLANs
├── HVAC (BACnet/IP)
├── Lighting (KNX/DALI)
├── Metering
├── Lab-specific OT systems
├── Accommodation HVAC networks
├── Sports facility control systems
├── Renewable energy systems (solar, CHP)

---

# 3. VLAN Strategy for Education Campuses

Segmentation must reflect **building type, system type, and criticality**.

Core VLANs:
VLAN 10–19   – Supervisors & Integration Servers
VLAN 20–29   – OT DMZ
VLAN 30–39   – Remote Access DMZ
VLAN 40–49   – NTP / Monitoring

Building-Level VLANs (replicated per building block):
VLAN 110–119 – HVAC Controllers (Building A)
VLAN 120–129 – HVAC Controllers (Building B)
VLAN 130–139 – HVAC Controllers (Building C)
…
VLAN 200–219 – Lighting Control (KNX/DALI)
VLAN 220–239 – Science Lab Ventilation & Fume Cupboards
VLAN 240–249 – Metering (Water/Energy/Gas)
VLAN 250–259 – Accommodation HVAC
VLAN 260–269 – Gateways (Modbus/MS/TP/KNX)
VLAN 270–299 – Renewable Energy (Solar/CHP/Turbines)
VLAN 300–319 – Sports Centre Control Systems

### Key Rules:
- **No cross-building VLANs** (Layer 2 must not span buildings).  
- BACnet, KNX, and Modbus must be tightly scoped.  
- Lab systems must not mix with general campus HVAC.  
- Student residential networks must be isolated entirely from OT.  
- Sports facility controls often require high reliability—configure separately.  

---

# 4. BACnet/IP in Education Campuses

BACnet/IP is used for:
- AHUs  
- FCUs/VAVs  
- Heating/cooling plants  
- Fume cupboard extract systems  
- Teaching/lab ventilation  
- Accommodation HVAC  

### Best Practices:
- BACnet networks **per building**  
- BACnet network numbers must be unique campus-wide  
- Avoid BBMD wherever possible—use routed unicast  
- Supervisors must support multi-building federation  
- Enable COV for high-use areas (lecture theatres, sports halls)  

### Common Problems:
- Contractors installing duplicate BACnet IDs across buildings  
- Using the same VLAN across multiple buildings  
- Campus-wide broadcast storms due to misconfigured BBMD  

---

# 5. Laboratory & Workshop HVAC Requirements

Labs require:
- Fume cupboard ventilation  
- Constant airflow tracking  
- Differential pressure monitoring  
- Temperature and humidity control  
- Emergency override controls  

### Network Requirements:
- Dedicated VLAN for lab-based HVAC  
- Segmentation from general HVAC  
- BACnet/SC recommended for cross-building integration  
- Low latency required for real-time airflow control  
- Logging mandatory for compliance (HSE, COSHH)  

Labs often require near-industrial-grade segregation.

---

# 6. Student Accommodation BMS Requirements

Accommodation areas typically have:
- Fan coil units (FCUs)  
- Electric heaters  
- Occupancy sensors  
- Window/door contacts  
- Local thermostats  

### Required Design Principles:
- Unique VLAN per accommodation block or floor  
- No cross-room device visibility  
- Room controllers must not influence each other  
- Lighting and HVAC separated  
- Secure remote-access restrictions  

Privacy is critical—student rooms cannot leak data across the network.

---

# 7. Lighting Control in Universities and Schools

Lighting systems often use:
- KNX  
- DALI-2  
- BACnet lighting gateways  

### Requirements:
- Per-floor or per-building lighting VLAN  
- KNX routing multicast must remain local  
- Supervisors poll lighting gateways only  
- Daylight harvesting and presence detection influence HVAC schedules  

Lighting plays a major role in energy optimisation.

---

# 8. Modbus TCP in Education Campuses

Modbus TCP is used for:
- Energy meters  
- Plant equipment  
- Solar inverters  
- CHP units  
- EV charging  
- Water metering  

### Best Practices:
- Gateways isolated  
- Read-only access for most integrations  
- Trend polling must be conservative  
- Document register maps strictly  

Modbus gateways are prone to overload if poorly polled.

---

# 9. Renewable Energy & Microgeneration Integration

Campuses often operate:
- Solar PV arrays  
- Combined Heat & Power (CHP) units  
- Battery storage systems  
- EV chargers  

### Recommended Integration:
- OPC-UA  
- Modbus TCP  
- MQTT (read-only telemetry)  

### VLAN Considerations:
- Renewable systems should be on separate VLANs  
- Do not mix with HVAC or lighting  
- Firewall rules must restrict external cloud connections  

Energy systems often report to corporate sustainability dashboards via OT/IT DMZ.

---

# 10. Remote Access Requirements

Campuses have many vendors, contractors, researchers, and internal estates teams.

### Requirements:
- MFA mandatory  
- Jump host in OT remote-access DMZ  
- Session recording  
- Access limited per building system  
- Read-only data access for researchers (no control)  
- Time-limited vendor credentials  

### Prohibited:
- Direct VPN into building networks  
- Connecting contractor laptops into classroom floor boxes  
- Allowing integrators to bypass firewalls using 4G routers  

Educational sites are often soft targets—remote access must be tightly controlled.

---

# 11. Monitoring Requirements

Monitoring must provide visibility into:

### Campus-wide:
- BACnet health  
- KNX routing behaviour  
- Modbus gateway CPU load  
- Supervisory server health  
- VLAN cross-traffic anomalies  
- NTP drift  

### Building-level:
- HVAC performance  
- Occupancy-driven control  
- Lab pressures  
- Energy profiles  
- Fault alarms  
- Filter pressure spikes  

### Student accommodation:
- FCU offline events  
- Sensor failures  
- Zone temperature anomalies  

Monitoring ensures the campus remains energy-efficient and compliant.

---

# 12. High Availability Requirements

Campuses typically require moderate-to-high levels of resilience.

### Recommended:
- Dual core OT switches  
- Redundant supervisors for multi-building deployments  
- Local plant controllers capable of stand-alone operation  
- UPS in all comms rooms  
- Redundant fibre to each building  

### Not required:
- Full data-centre-grade A/B separation  
- Controller-level redundancy across all rooms  

Focus on **building-level independence** and **core-level redundancy**.

---

# 13. Common Education Campus Deployment Failures

### ❌ Campus-wide BACnet VLAN  
Massive broadcast storms across buildings.

### ❌ Labs sharing VLANs with general classrooms  
Misconfiguration can disrupt safety systems.

### ❌ Contractor plugging unmanaged switch into riser cabinet  
Breaks spanning tree and segmentation.

### ❌ Student networks leaking into OT networks  
Critical security risk.

### ❌ Multiple contractors reusing BACnet IDs  
Devices disappear or behave unpredictably.

### ❌ IoT sensors dumped into HVAC VLAN  
Performance and security issues.

---

# 14. Education Campus Deployment Checklist

### Segmentation
- [ ] VLAN per building, per system  
- [ ] BACnet network numbers unique  
- [ ] Lab systems isolated  

### Integration
- [ ] All integrations via OT/IT DMZ  
- [ ] No direct integration from corporate networks  
- [ ] Renewable energy segregated  

### Security
- [ ] Jump host for all vendor access  
- [ ] MFA enforced  
- [ ] No unmanaged switches  

### Monitoring
- [ ] HVAC, lab, lighting, metering monitored  
- [ ] Gateway health tracked  
- [ ] Network anomaly detection in place  

---

# Summary

Education estates require a hybrid OT/BMS approach that supports laboratory safety, accommodation privacy, commercial office comfort, and campus-scale resilience.  
The key to stability is **per-building segmentation**, **system isolation**, **secure integrations**, and **strict contractor governance**.

Key principles:
- No cross-building L2  
- BACnet and KNX containment  
- Isolated lab environments  
- Strong monitoring  
- Secure remote access  
- Documented addressing and BACnet numbering  

A correctly engineered campus OT implementation is resilient, manageable, scalable, and secure for decades.
