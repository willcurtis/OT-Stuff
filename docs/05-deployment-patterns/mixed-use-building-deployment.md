# Mixed-Use Building Deployment Pattern

Mixed-use buildings combine multiple operational environments under a single physical structure.  
Typical combinations include:

- Retail + Office  
- Office + Residential  
- Retail + Residential  
- Office + Hotel  
- Retail + Hotel  
- Office + Gym/Leisure/Pool  
- Restaurant + Retail + Car Park + Mechanical Plant  

This diversity creates significant OT/BMS challenges, requiring explicit segmentation, multi-tenant access control, robust supervision, and strict boundaries between systems.

---

# 1. Characteristics of Mixed-Use OT/BMS

### 1. Diverse functional zones in one building  
Each zone has different:
- Risk profiles  
- Occupancy patterns  
- Mechanical load  
- Control strategies  
- Vendor ecosystems  

### 2. Multi-tenant and multi-operator complexity  
Retail tenants, residential owners, office operators, restaurant chains, hotel operators—each with their own vendors and systems.

### 3. Shared plant  
Chillers, AHUs, boilers, generators, metering often shared across zones.

### 4. High risk of misconfiguration  
Common problems include:
- VLAN leakage  
- BACnet storms  
- Duplicate device IDs  
- Tenants connecting unauthorised devices  
- Cross-zone broadcast contamination  

### 5. Security boundaries must be explicit  
BMS cannot assume all building systems belong to the same entity.

---

# 2. Recommended Architecture for Mixed-Use Buildings

The architecture must enforce **operational isolation** while allowing central plant control.

OT Core (Landlord-controlled)
├── Supervisors for HVAC, Lighting, Energy
├── Integration Servers (OPC-UA, MQTT, BACnet/SC)
├── OT Firewalls
├── OT/IT DMZ
├── Remote Access DMZ + Jump Hosts
├── Backup/Trend Storage
└── NTP & Monitoring Infrastructure

Functional Zones (each isolated)
├── Retail Zone Networks
├── Office Zone Networks
├── Residential Zone Networks
├── Hotel/Hospitality Zones
├── Car Park Systems
├── Leisure/Spa/Gym/HVAC Zones
├── Plant Rooms (shared services)

Each functional zone is handled almost like a separate building.

---

# 3. VLAN Strategy for Mixed-Use Buildings

Segmentation is critical.

Landlord OT (Shared Systems):
VLAN 100–119 – Central Plant HVAC
VLAN 120–139 – Shared Lighting / Energy Systems
VLAN 140–159 – Gateways (Modbus/MS/TP/KNX)
VLAN 160–179 – OT DMZ
VLAN 180–189 – Integration Platforms
VLAN 190–199 – Supervisors

Retail Zones (Per Tenant or Per Floor):
VLAN 200–219 – Retail HVAC
VLAN 220–239 – Retail Lighting
VLAN 240–249 – Retail Energy Metering

Office Zones:
VLAN 300–319 – Office HVAC
VLAN 320–339 – Office Lighting
VLAN 340–349 – Office IoT Sensors

Residential Zones:
VLAN 400–429 – Apartment HVAC
VLAN 430–449 – Smart Home Gateways
VLAN 450–459 – Resident Metering

Hospitality / Hotel Zones:
VLAN 500–529 – Guest Room HVAC
VLAN 530–549 – Lighting/Blind Control
VLAN 550–569 – PMS + Guest Experience Integrations

Leisure / Gym / Pool:
VLAN 600–619 – Pool AHUs / Dehumidifiers
VLAN 620–629 – Spa & Sauna HVAC
VLAN 630–639 – Gym HVAC & Sensors

Car Parks & EV:
VLAN 700–719 – CO Sensors / Ventilation
VLAN 720–739 – EV Charging Systems

Security (Landlord-Only):
VLAN 800–839 – CCTV (view-only integrations)
VLAN 840–859 – Access Control (read-only integration)

### Key Segmentation Principles:
- Landlord systems remain separate from tenant/occupant systems  
- VLANs NEVER span across functional groups  
- No cross-zone L2 adjacency  
- Each zone treated as a separate risk domain  
- Shared plant VLAN is the ONLY shared network space — and only for landlord systems  

---

# 4. BACnet/IP in Mixed-Use Buildings

BACnet/IP is heavily used across all functional zones.

### Best Practices:
- Unique BACnet network numbers per zone  
- No BBMD except in multi-building complexes  
- Supervisors mapped to zone-specific VLANs  
- Inter-zone communication strictly via OT firewall  
- Discourage tenant systems from exposing BACnet/IP at all  

### Common Failures:
- Tenants connect BACnet equipment directly to landlord networks  
- Duplicate device IDs across zones  
- BACnet storms leaking from residential to retail  
- BBMDs configured by accident between zones  

Treat BACnet like a hazardous substance: contain it.

---

# 5. KNX, DALI, and Lighting Control

Lighting systems differ across zones.

### Retail Lighting:
- High scene changes  
- DALI-2 common  
- KNX for back-of-house  

### Office Lighting:
- KNX or DALI-2  
- Occupancy integration  
- Daylight harvesting  

### Residential Lighting:
- Often proprietary or smart-home systems  
- Must be strictly isolated  
- Supervisory access often limited  

### Key Rules:
- Never mix lighting VLANs across functional zones  
- KNX multicast must be trapped in its VLAN  
- DALI gateways isolated and mapped to supervisors only  

---

# 6. VRF/VRV and HVAC Integration

Mixed-use buildings almost always contain:

- Shared chillers/boilers  
- VRF/VRV systems per tenant/floor  
- AHUs serving corridors or common spaces  
- FCUs/VAVs for offices  
- Apartment HVAC for residential zones  

### Requirements:
- VRF gateways in their own VLAN  
- Shared plant isolated in landlord network  
- Tenant HVAC never mixes with landlord plant control  
- Apartment HVAC NEVER accessible from tenant spaces or guest Wi-Fi  

VRF gateways should be rate-limited and monitored to avoid overload.

---

# 7. Metering & Billing Systems

Multi-tenant billing requires accurate and secure metering.

Metering types include:
- Electricity  
- Gas  
- Water  
- Heat energy (BTU)  
- EV charging energy  
- Solar/CHP generation  

### Requirements:
- All tenant meters isolated  
- Landlord meters separated from tenant meters  
- Supervisory integration via OT DMZ  
- Tamper detection where available  

Billing integrity depends on strong segmentation.

---

# 8. Smart Building Platforms

Mixed-use buildings increasingly deploy smart-building systems for:

- Occupancy analysis  
- Comfort optimisation  
- Energy efficiency  
- Visitor management  
- ESG reporting  

### Requirements:
- Smart-building platform runs in OT/IT DMZ  
- IoT devices placed ONLY in IoT VLANs  
- Supervisors publish data via secure APIs  
- Tenants must not be able to view each other’s analytics  

Many “smart building” vendors push for cloud connectivity — firewall and proxy policies must control this.

---

# 9. Remote Access Architecture

Multi-tenant and multi-vendor environments require extremely strict remote access governance.

### Recommended Access Path:
Vendor → VPN → DMZ → Jump Host → OT Firewall → Allowed Zone

### Requirements:
- Vendors see **only their zone**  
- MFA mandatory  
- Session recording  
- Access time-limited  
- Tenant access logged separately from landlord access  
- No 4G routers or unmanaged devices allowed  

Remote access is one of the biggest risks in mixed-use buildings.

---

# 10. Monitoring Requirements

Monitoring must handle complex cross-zone behaviour.

### Landlord Monitoring:
- Shared plant  
- Energy dashboards  
- Alarms for chilled/hot-water distribution  
- Fire system read-only status  

### Tenant or Zone-specific Monitoring:
- Retail HVAC  
- Office comfort systems  
- Apartment HVAC offline alerts  
- Hotel guest-room telemetry  
- Gym/pool environmental controls  

### Network Monitoring:
- BACnet storms per VLAN  
- KNX routing anomalies  
- Modbus gateway saturation  
- VLAN cross-talk  
- Unauthorised device detection  

A failure in one zone must not impact another — monitoring verifies this.

---

# 11. High Availability Requirements

Mixed-use buildings require moderate-to-high resilience, depending on occupancy and function.

### Recommended:
- Redundant OT core  
- UPS on all riser and plant OT switches  
- Supervisor redundancy for shared plant  
- Backup VRF gateways for hotel/apartment zones  
- Redundant fibre runs in large complexes  

### Not Required:
- Full A/B physical separation as in data centres  
- Controller-level redundancy in residential apartments  

Prioritise HA for *shared systems* and *high-traffic public zones*.

---

# 12. Common Mixed-Use Deployment Failures

### ❌ Same VLAN used across retail, office, apartment zones  
Creates massive broadcast instability and privacy issues.

### ❌ Tenant contractors connecting directly to landlord OT switches  
Leads to security breaches and outages.

### ❌ Shared BACnet network numbers  
Causes device collisions across zones.

### ❌ VRF gateway placed in apartment VLAN  
Overloads gateway or exposes apartment HVAC to retail systems.

### ❌ IoT devices placed in HVAC VLAN  
Causes noise, instability, and high risk.

### ❌ Cloud-based systems allowed direct access from OT  
Severe security risk.

---

# 13. Mixed-Use Deployment Checklist

### Segmentation
- [ ] VLAN per zone and per system  
- [ ] Unique BACnet/KNX network numbers  
- [ ] No cross-zone broadcast domains  

### Security
- [ ] Jump host use enforced  
- [ ] Vendor access restricted per tenant/zone  
- [ ] No unmanaged switches  
- [ ] OT DMZ for integrations  

### Integration
- [ ] Landlord systems separated from tenant systems  
- [ ] Shared plant isolated  
- [ ] Billing systems segregated  

### Monitoring
- [ ] Zone-level telemetry  
- [ ] BACnet/KNX/Modbus health monitored  
- [ ] Unauthorized device detection  

---

# Summary

Mixed-use buildings are some of the most complex OT/BMS environments.  
They must support multiple independent ecosystems while maintaining stability, security, and strict data and control isolation.

Key principles:
- Segmentation per zone  
- Gateway and broadcast containment  
- Secure vendor access  
- Clear boundaries between landlord and tenant systems  
- Monitoring across all functional zones  
- Strong governance to handle constant change  

A well-designed mixed-use OT architecture ensures safe, efficient, scalable operation in even the most complex environments.
