# Shopping Centre & Large Retail OT/BMS Deployment Pattern

Shopping centres and large retail estates have unique OT/BMS requirements driven by:
- High tenant turnover  
- Numerous independent systems  
- Large mechanical plants  
- Multi-vendor integration  
- Complex access-control requirements  
- The need for simple, robust infrastructure that supports constant operational changes  

This environment blends the scale of a campus with the churn of a small-site retail network, requiring careful design to ensure stability, security, and operational manageability.

---

# 1. Characteristics of Retail Centre OT/BMS

### 1. High churn of tenants & contractors
Frequent updates to HVAC, lighting, metering, and signage systems.

### 2. Wide variety of system integrators
Different vendors for HVAC, lighting, fire, metering, lifts, EV chargers, etc.

### 3. Centralised plant + distributed edge devices
- AHUs, chillers, boilers in central plant rooms  
- Retail units with FCUs, metering, lighting controllers  
- Supervisors often in the management suite  

### 4. Diverse protocols  
BACnet/IP, MS/TP, Modbus TCP, KNX, MQTT, OPC-UA, and numerous proprietary systems.

### 5. Strong security requirements  
Tenants must be isolated from landlord BMS, and vendor devices must be restricted.

---

# 2. Design Principles for Retail Centre BMS

### Principle 1 — Landlord OT and Tenant Systems Must Be Strictly Segmented
Tenants must never gain visibility of landlord OT networks.

### Principle 2 — Rapid Change Must Not Break the Network
VLAN models must be flexible.

### Principle 3 — Broadcast Containment Is Critical
BACnet/IP must be scoped to each mechanical zone or plant area.

### Principle 4 — Remote Access Must Be Vendor-Neutral and Secure
Contractors change frequently; access should be easy to grant/remove.

### Principle 5 — Plant Must Operate Independently from Tenants
Tenant HVAC failure must not impact whole-site stability.

---

# 3. Recommended Architecture for Shopping Centres

A typical retail centre OT architecture includes:

OT Core (in Management Suite)
├─ Supervisors (HVAC, Lighting, Energy)
├─ Integration Servers (OPC-UA / MQTT)
├─ NTP Servers
├─ OT Firewalls
├─ Remote Access DMZ
└─ Connection to Corporate Network via DMZ

Building-level / Zone-level Distribution
├─ Plant Room OT Switches (Level 0/1)
├─ Retail Unit OT Distribution (if required)
└─ Public Area Controllers (HVAC/Lighting)

Edge Field Devices
├─ FCUs, VAVs, VRF gateways
├─ KNX Lighting Controllers
├─ Energy & Water Meters
├─ Air Quality Sensors
├─ EV Charger Gateways
└─ Lift Interfaces (read-only)

---

# 4. VLAN Strategy for Malls & Retail Centres

A flexible but structured VLAN model is essential.

VLAN 100–119 – Central Plant HVAC (Chillers, Boilers, AHUs)
VLAN 120–149 – FCU/VAV Zones (per mall zone)
VLAN 150–169 – Lighting Control (Landlord Areas)
VLAN 170–179 – Energy Metering
VLAN 180–189 – Gateways (MS/TP, Modbus, KNX, VRF)
VLAN 200–299 – Tenant OT VLANs (optional, per tenant)
VLAN 300–349 – Landlord Supervisors / Integration Servers
VLAN 350–369 – Landlord OT DMZ
VLAN 380–389 – Vendor Access VLAN

### Rules:
- Tenant VLANs must NOT communicate with landlord OT VLANs.  
- Gateways must be isolated from controller VLANs.  
- BACnet broadcasts must not cross from plant to tenant zones.  
- Lighting VLANs must be separate from HVAC VLANs.  

---

# 5. Tenant OT Integration Strategy

Tenants often require:
- HVAC control signals  
- Metering (electricity, water, gas)  
- Temperature/pressure readings  
- Air handling interfacing  

### Integration MUST be:
- Read-only for most signals  
- Firewalled at the OT core  
- Performed via API or integration server  
- Logged and monitored  

### Prohibited:
- Allowing tenant contractors direct access to BMS VLANs  
- Allowing tenant systems to connect to shared OT networks  
- Bridging BACnet IP or MS/TP into tenant units  

Tenants change frequently — bad integration design causes operational chaos.

---

# 6. BACnet/IP in Large Retail Environments

BACnet/IP is used extensively for:
- AHUs  
- FCUs  
- VAVs  
- Chilled water systems  
- Heat pumps  
- VRF/VRV gateways  

### Best Practices:
- VLANs per mechanical zone (broadcast containment)  
- Unique BACnet network numbers  
- Supervisors in OT core  
- No BBMD unless site spans multiple buildings  
- Tune COV thresholds to avoid load spikes during peak occupancy  

### Common Problems:
- FCU flooding due to excessive Who-Is  
- Tenant contractors causing broadcast storms  
- Duplicate device IDs across multiple retail units  

---

# 7. Lighting Systems in Shopping Centres

Lighting is usually controlled by:
- KNX  
- DALI via DALI-IP gateways  
- BACnet-connected lighting control panels  

### Requirements:
- Lighting VLANs must be isolated from HVAC VLANs  
- KNX multicast must never leave its VLAN  
- Gateways stored in secure plant areas, not tenant risers  
- Time synchronisation mandatory for schedules  

---

# 8. Energy Metering & ESG Reporting

Shopping centres rely heavily on metering:

- Electricity meters (Modbus TCP or RTU)  
- Water & gas meters  
- Heat energy (BTU) meters  
- EV charger metering  
- Solar/PV inverters  

### Best Practices:
- All meters in separate VLAN  
- Polling rates low (30–300 sec typical)  
- Supervisors central in OT core  
- Modbus write commands blocked  
- EV chargers in separate VLAN with restricted access  

Metering data is often integrated into:
- ESG dashboards  
- Billing systems  
- Corporate sustainability platforms  

---

# 9. Remote Access Model for Shopping Centres

High contractor turnover = strict governance required.

### Recommended Model:
Vendor → VPN → DMZ → Jump Host → OT Firewall → Allowed systems

### Requirements:
- MFA  
- Session logging  
- No direct access to controllers  
- Vendor VLAN isolated  
- Time-limited credentials  
- Per-contractor access profiles  

### Prohibited:
- Vendor installing 4G routers inside riser cupboards  
- Direct VPN access to controller VLANs  
- Unmanaged switches introduced by contractors  
- Shared vendor accounts  

---

# 10. Monitoring Requirements

Shopping centres must monitor:

### Mechanical:
- AHU status  
- Chilled water temps  
- Fan/valve positions  
- Zone temperatures  

### Lighting:
- Schedule compliance  
- DALI ballast failures  
- Power consumption  

### Meters:
- Consumption anomalies  
- Zero-read or stuck values  
- Billing deviations  

### Network:
- BACnet storms  
- KNX multicast anomalies  
- Gateway CPU usage  
- Controller offline events  

Operational monitoring is essential to maintain comfort and compliance.

---

# 11. High Availability in Retail Centres

Retail centres require high uptime but not data centre–level redundancy.

### Recommended:
- Dual-core OT switches  
- Diverse fibre risers  
- UPS-backed plant rooms  
- Redundant supervisors (if landlord BMS is mission-critical)  

### Not necessary:
- Dual-homed FCUs  
- Dual Modbus gateways per tenant  
- Controller-level HA for retail units  

Focus redundancy on *central plant* and *supervisors*, not tenant equipment.

---

# 12. Common Retail Deployment Failures

### ❌ Tenant contractor connects laptop to BMS switch  
Causes broadcast storms or rogue DHCP.

### ❌ Unmanaged switches installed in riser by vendor  
Breaks VLAN segmentation.

### ❌ Single VLAN used for entire mall  
Plants fail under broadcast load.

### ❌ Shared vendor login credentials  
Impossible to audit; huge compliance risk.

### ❌ Poor documentation of tenant integrations  
Future changes break dependencies.

### ❌ Lighting and HVAC controllers mixed in same VLAN  
Creates unpredictable multicast behaviour.

---

# 13. Retail Centre Deployment Checklist

- [ ] Landlord OT and tenant systems fully segregated  
- [ ] HVAC, lighting, meters each in separate VLANs  
- [ ] Gateways isolated  
- [ ] BACnet broadcasts contained  
- [ ] No unmanaged switches anywhere  
- [ ] Strong remote access security  
- [ ] Tenant access provided via integration servers, not direct  
- [ ] Monitoring for HVAC, lighting, metering, and network traffic  
- [ ] Documentation updated for every tenant change  

---

# Summary

Shopping centre OT/BMS design must tolerate high contractor turnover, multi-vendor complexity, and constant tenant changes without compromising network stability or security.

Key principles:
- Strict segmentation  
- Broadcast containment  
- Gateway isolation  
- Secure vendor access  
- Strong monitoring  
- Separation of landlord and tenant systems  

A well-designed mall OT network is stable, predictable, easily supportable, and resistant to operational churn.
