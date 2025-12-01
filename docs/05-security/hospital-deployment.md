# Hospital & Healthcare OT/BMS Deployment Pattern

Hospitals, healthcare facilities, and clinical environments introduce some of the most demanding requirements for OT/BMS networks.  
Reliability directly affects life-safety systems, clinical workflows, environmental conditions for patient care, infection control, surgical environments, and high-dependency treatment zones.

This chapter provides a full deployment blueprint for hospital-grade OT/BMS networks.

---

# 1. Why Hospital OT/BMS Is Unique

Hospital OT differs from commercial buildings due to:

### • Life-critical dependencies  
   HVAC failure in operating theatres or ICU can be life-threatening.

### • Strict environmental control  
   Temperature, humidity, positive/negative pressure, fresh air volumes, etc.

### • Regulatory compliance  
   HTM standards (UK), ASHRAE 170, ISO 14644 (cleanrooms), GMP for pharmacy and labs.

### • Infection control  
   Pressure cascades must operate continuously.

### • Redundancy requirements  
   No single point of failure allowed for key systems.

### • High integration levels  
   BMS ↔ medical gas, nurse call, alarms, power monitoring, chilled water, hot water, AHUs, air valves, lighting for theatres, etc.

The architecture must prioritise **high availability, strong segmentation, and dependable monitoring**.

---

# 2. Core Design Principles for Hospital OT/BMS

### Principle 1 — Reliability First  
Systems must function continuously, even during maintenance or network faults.

### Principle 2 — Segregate Clinical-Critical and Non-Critical OT  
Operating theatres, isolation rooms, ICU ventilation may require dedicated VLANs and controllers.

### Principle 3 — Redundant Infrastructure  
Dual-core switches, redundant links, redundant supervisors, UPS, generator-backed.

### Principle 4 — Zero-Trust Vendor Access  
Hospitals are high-value cyber targets; remote access must be tightly restricted.

### Principle 5 — No Broadcast/Multicast Propagation Between Areas  
BACnet and KNX traffic must remain scoped to each clinical zone.

### Principle 6 — Monitoring & Alerting Must Be Continuous  
OT faults must be surfaced to clinical and estates teams immediately.

---

# 3. Hospital OT Network Architecture

Hospitals require a **tiered** architecture:

### • Tier 1 – OT Core (redundant)  
   - Dual-core switches  
   - Firewalls  
   - Supervisors  
   - NTP cluster  
   - Logging/SIEM  
   - OT DMZ  
   - Remote-access termination  

### • Tier 2 – Building Distribution  
   - One per building or block  
   - Separate feeds and risers  
   - Redundant uplinks to OT core  

### • Tier 3 – Clinical Zones / Plant Rooms  
   - ICU, theatres, wards, cleanrooms  
   - Redundant switches for critical plant  
   - Isolated VLANs per zone  

### • Tier 4 – Field Networks  
   - Controllers for HVAC, AHU, isolation suites, medical gas  
   - MS/TP, Modbus RTU, KNX TP1  
   - Airflow valve controllers  

This layering ensures isolation, autonomy, and resilience.

---

# 4. VLAN Strategy for Hospitals

Segmentation must reflect **clinical criticality**.

### Recommended VLAN groups:

VLAN 100–199 – Critical HVAC (Theatres, ICU, Isolation Rooms)
VLAN 200–299 – General HVAC (Wards, Admin Areas)
VLAN 300–349 – Medical Gas Monitoring
VLAN 350–399 – Cleanroom / Lab Environmental Controls
VLAN 400–449 – Energy Meters
VLAN 450–499 – Lighting Control
VLAN 500–549 – Gateways (MS/TP, Modbus, KNX)
VLAN 560–579 – OPC-UA / Integration Servers
VLAN 580–599 – BMS Supervisors
VLAN 600–619 – Vendor Access VLAN
VLAN 700–719 – OT DMZ

### Key rules:

- Critical zones must **never** share VLANs with non-critical HVAC.  
- KNX and BACnet routing traffic must remain isolated in their VLANs.  
- No inter-VLAN controller ↔ controller communication except via supervisor.  
- No vendor VLAN overlap with any clinical VLAN.

---

# 5. Addressing Plan for Hospital OT

Use large, predictable address ranges for decades of expansion.

Example (per site):

10.60.0.0/16 – Hospital OT Space
10.60.10.0/24 – OT Core Services
10.60.20.0/24 – Supervisors (Primary)
10.60.21.0/24 – Supervisors (Secondary)
10.60.30.0/24 – Critical HVAC Controllers
10.60.40.0/24 – Theatres HVAC Controllers
10.60.50.0/24 – Infection Control (Pressurisation)
10.60.60.0/24 – Medical Gas
10.60.70.0/24 – Lab/Cleanroom

### Requirements:

- Static IP for all controllers  
- Unique BACnet network numbers for each VLAN  
- No address reuse between buildings  
- Document addressing in asset management system  

---

# 6. BACnet Deployment in Hospitals

BACnet/IP is the dominant protocol in hospitals for HVAC and monitoring.

Recommendations:

### ✓ Keep clinical VLANs small  
Critical zones often < 20 controllers per VLAN.

### ✓ Avoid BBMD in clinical VLANs  
Prevent unnecessary broadcast complexity.

### ✓ Use BACnet/SC for cross-building connectivity  
Encrypted, WAN-ready, reliable.

### ✓ COV tuning is essential  
High-frequency changes (e.g., air valves) require careful thresholds.

### ✓ Supervisor clusters recommended  
Dual supervisors with hot or warm standby.

### ✓ Gateways isolated  
MS/TP networks should be isolated in gateway VLANs and polled via BACnet/IP.

### ✓ Trend locally, upload centrally  
Avoid excessive polling in theatre and ICU VLANs.

---

# 7. Control of Airflow, Pressure Rooms, and Theatres

Theatres and isolation rooms often use:

- Air pressure sensors  
- Airflow valves  
- VAV controllers  
- AHUs with HEPA filtration  
- Redundant air handling paths  

### Network Requirements:

- Dedicated VLAN per theatre or suite  
- High-availability controllers where available  
- Strict firewalling to avoid interference  
- Monitoring of airflow setpoints in real time  

### Protocol considerations:

- Controllers may use BACnet/IP for supervisory functions  
- Airflow controllers may use proprietary serial protocols internally  
- Redundant paths must be engineered into plant-side control  

---

# 8. Integration with Medical Gas Systems

Medical gas panels (O₂, N₂O, vacuum, etc.) often integrate via:

- Modbus TCP  
- Serial Modbus RTU  
- OPC-UA (newer systems)  

### Requirements:

- Place medical gas in its own VLAN  
- Allow read-only access from BMS unless explicitly required otherwise  
- Log all access to Modbus registers  
- Block vendor-direct Modbus access  

Gas systems are often safety-classified and should not be grouped with HVAC.

---

# 9. Cleanrooms & Laboratory Environmental Controls

Hospitals often host:

- Pathology labs  
- Tissue labs  
- Pharmacy cleanrooms  
- GMP manufacturing areas  

These require:

### Network Considerations:

- Dedicated VLANs  
- Highly stable BACnet/IP behaviour  
- Tight COV thresholds  
- Redundant supervisory logic  
- NTP precision for compliance  
- Logging of all setpoint changes  

### Regulatory Considerations:

- EN/ISO 14644  
- GMP/GxP guidelines  
- Mandatory audit trails  

OT networks must support reliable timestamping to pass audits.

---

# 10. High Availability Requirements

Hospitals exceed typical commercial building resilience.

### Switch Redundancy:
- Dual distribution switches per building  
- Redundant uplinks from each plantroom  
- No daisy-chained unmanaged switches  

### Supervisor Redundancy:
- Hot/warm standby cluster mandatory for critical systems  
- Automatic failover for alarms and trend logging  

### Power Redundancy:
- UPS on all OT equipment  
- Generators for long-duration outages  
- Isolated power pathways for critical rooms  

### WAN Resilience (Multi-Building):
- Dual fibre risers  
- Independent pathways  
- No STP across buildings  

---

# 11. Remote Access Requirements for Hospitals

Given the clinical safety implications:

### Mandatory Controls:
- MFA  
- Jump host  
- Session recording  
- Named accounts  
- No direct controller access  
- Vendor VLANs fully isolated  
- Time-limited access windows  

### Prohibited:
- Direct VPN into BMS VLANs  
- Shared vendor logins  
- 4G/5G vendor routers bypassing firewalls  
- Inbound exposure of BACnet/Modbus/OPC-UA  

Hospitals are frequent ransomware targets — remote access must be bulletproof.

---

# 12. Monitoring Requirements

Hospitals require enhanced OT monitoring, including:

- Controller health  
- AHU redundancy failovers  
- Pressure room status  
- Medical gas alarms  
- Trend data completeness  
- Gateway load  
- BACnet errors/BVLL issues  
- Time drift  
- OT firewall alerts  
- NTP server status  

### Alarms must integrate with:
- Building management dashboards  
- Estates on-call paging  
- Clinical teams for theatre/ICU air safety  

---

# 13. Common Hospital Deployment Failures

### ❌ Failure 1 — Flat BACnet network across whole hospital  
Leads to broadcast storms and total system instability.

### ❌ Failure 2 — Gateways placed in clinical VLANs  
Causes gateway overload and plant failures.

### ❌ Failure 3 — Lack of redundancy in critical areas  
A single controller failure can shut down a theatre.

### ❌ Failure 4 — Remote access into clinical VLANs  
Massive cyber risk, potential patient impact.

### ❌ Failure 5 — BBMD deployed across multiple buildings  
Creates unpredictable behaviour under load.

### ❌ Failure 6 — No monitoring of pressurisation  
Leads to compliance failure or infection outbreaks.

---

# 14. Hospital Deployment Checklist

- [ ] Dedicated VLANs for critical clinical zones  
- [ ] Unique BACnet network numbers  
- [ ] Supervisors in HA cluster  
- [ ] Gateways isolated in their own VLAN  
- [ ] Strict firewall segmentation  
- [ ] Remote access through jump host only  
- [ ] NTP servers redundant  
- [ ] Monitoring integrated with clinical systems  
- [ ] No unmanaged switches  
- [ ] Full audit trails of all changes  
- [ ] Documentation maintained to regulatory standard  

---

# Summary

Hospital OT/BMS networks must deliver extreme reliability, strong segmentation, and uncompromised security.  
Environmental conditions directly affect patient safety, infection control, theatre operations, and laboratory compliance.

Key principles:

- Isolate critical clinical workloads  
- Provide redundant network, supervisor, power, and control systems  
- Treat remote access as a clinical safety risk  
- Avoid BBMD across buildings and critical zones  
- Maintain strong monitoring and time synchronisation  

A properly engineered hospital OT architecture is resilient, auditable, and compliant with clinical and regulatory requirements.
