# Data Centre OT/BMS Deployment Pattern

Data centres have some of the most demanding OT/BMS requirements of any built environment.  
Cooling, power, environmental monitoring, fire suppression, generators, and switching systems must maintain continuous operation. A failure in OT can directly cause IT outages, SLA breaches, financial loss, and reputational damage.

This chapter provides a full deployment pattern for mission-critical data centre OT/BMS networks.

---

# 1. Why Data Centre OT/BMS Is Unique

### Mission-critical environment where outages are unacceptable.
Cooling failures can trigger cascading IT outages in minutes.

### High levels of mechanical and electrical complexity:
- CRAC/CRAH units  
- Chillers  
- Cooling towers  
- UPS systems  
- MV/LV switching gear  
- PDU metering  
- Fire detection/suppression  
- Generator farms  

### Extremely high redundancy requirements (Tier III/IV):
- No single point of failure  
- Concurrent maintainability  
- Fault tolerant paths  

### High security posture:
- OT is an entry point into a high-value target  
- Remote access strictly governed  

---

# 2. Core Design Principles

### Principle 1 — Absolute Separation from Corporate IT  
OT networks must be firewalled or physically segregated.

### Principle 2 — Redundancy at Every Layer  
Network, power, control systems, and cooling must be dual-path.

### Principle 3 — Deterministic Performance  
Latency, jitter, and broadcast containment must be tightly controlled.

### Principle 4 — Detailed Monitoring & Analytics  
Cooling and power data must be accurate for SLA compliance.

### Principle 5 — Secure Remote Access  
Zero trust, no direct connectivity from vendors.

### Principle 6 — Change Control and Compliance  
Changes can cause SLA breaches and must be governed.

---

# 3. Data Centre OT/BMS Logical Architecture

A Tier III+ data centre typically uses the following architecture:

OT Core (A-side + B-side)
├─ Supervisor Servers (A + B)
├─ OPMS/DCIM Integration
├─ NTP Cluster (A + B)
├─ Firewall Pair (north-south + east-west)
├─ VLAN Routing + Redundant Distribution
└─ Remote Access DMZ / Jump Hosts

Building/Room Distribution (per room or per mechanical zone)
├─ A-side OT Switches
└─ B-side OT Switches

Plant-level Controllers & Gateways
├─ Chiller controllers
├─ CRAC/CRAH controllers
├─ PDU & UPS interfaces
├─ Modbus Gateways
└─ BACnet Controllers

### Requirements:
- A and B sides must be physically diverse  
- All critical plant devices should be dual-homed where possible  
- No cross-side L2 adjacency  

---

# 4. VLAN Structure for Data Centres

A scalable, structured VLAN plan is essential.

VLAN 100–119  – Supervisors (A-side)
VLAN 120–139  – Supervisors (B-side)
VLAN 200–249  – Chiller/CRAC BACnet Controllers
VLAN 250–259  – Humidification / Dehumidification
VLAN 260–269  – Power Monitoring (PDU, UPS, Switchgear)
VLAN 270–279  – Fire Systems (read-only integration)
VLAN 300–309  – Modbus Gateways
VLAN 310–319  – Serial ↔ IP Converters
VLAN 400–409  – OT DMZ
VLAN 500–509  – Vendor Access (jump host only)
VLAN 600–619  – Data Hall Environmental Sensors
VLAN 700–719  – Monitoring Fabric (Telemetry buses)

### Rules:
- Critical cooling (CRAC/CRAH/chillers) MUST be separated from power monitoring.  
- Fire systems should be read-only and isolated.  
- Vendor VLAN must not have direct access to any control VLAN.  
- No VLAN should span A-side and B-side at L2.  

---

# 5. IP Addressing Strategy

Data centres require structured and predictable addressing.

Example (per site):

10.100.0.0/16 – OT Core + Supervisors
10.100.10.0/24 – Supervisors A
10.100.11.0/24 – Supervisors B
10.100.20.0/24 – Chillers
10.100.21.0/24 – CRAC Units Row 1
10.100.22.0/24 – CRAC Units Row 2
10.100.40.0/24 – UPS A-side
10.100.41.0/24 – UPS B-side
10.100.50.0/24 – PDU Metering
10.100.60.0/24 – Modbus Gateways
10.100.70.0/24 – HVAC Sensors

### Requirements:
- Static IP addressing for all devices  
- Address blocks must be reserved decades ahead  
- BACnet network numbers must not repeat  
- Separate A and B plane addressing  

---

# 6. BACnet/IP in Data Centres

BACnet/IP is used for:

- CRAC/CRAH units  
- Chillers  
- Cooling towers  
- Pump systems  
- AHU interfaces  

### Best Practices:
- No BBMD unless unavoidable  
- Strong VLAN isolation  
- Per-zone BACnet networks (e.g., per data hall)  
- Supervisors in redundant A/B clusters  
- Strict COV tuning  
- Avoid heavy polling  

### BACnet/SC recommended:
- For cross-building or multi-hall integration  
- For secure routing  
- To remove broadcast dependency  

---

# 7. Modbus TCP in Data Centres

Modbus is heavily used for:

- UPS systems  
- Switchgear  
- PDU metering  
- Generators  
- Power quality analysers  

### Best Practices:
- Gateways isolated in VLANs  
- Supervisors access via firewall rules only  
- Limit function codes  
- Log all Modbus writes  
- Reduce polling rates to avoid stressing gateways  

### Common Issues:
- Gateway overload  
- Large register maps  
- Timeouts under high polling load  

---

# 8. OPC-UA in Data Centres

OPC-UA is ideal for:

- Power management  
- Chiller plant optimisation  
- DCIM integration  
- Analytics platforms  

### Requirements:
- Certificates mandatory  
- TLS required  
- Only secure policies allowed (Basic256Sha256 or better)  
- Supervisor or DCIM server must validate identities  

---

# 9. High Availability Requirements

### A/B Plane Physical Separation
All critical OT infrastructure must be duplicated.

- A-side core switch + firewall  
- B-side core switch + firewall  
- Separate risers  
- Diverse fibre paths  
- Controllers dual-homed where possible  

### Supervisor HA Cluster
- Active/standby or active/active  
- Shared historian or replicated DB  
- Unified alarm routing  

### Power Resilience
- UPS for all OT networking  
- Generator-backed building supply  
- Surge protection for long cable runs  

---

# 10. OT/IT Integration Boundary

Data centre management systems (e.g., DCIM) often integrate with OT.

### Integration MUST occur in OT DMZ.

Data flow direction:
- OT → DMZ → IT/DCIM  
- Never IT → OT directly  

### Methods:
- OPC-UA read-only  
- BACnet/SC proxies  
- REST APIs from supervisors  
- MQTT for telemetry  

### Never expose:
- BACnet/IP  
- Modbus TCP  
- KNX/IP  
- Direct controller visibility  

---

# 11. Remote Access for Data Centres

Due to extreme sensitivity:

### Mandatory:
- MFA  
- Jump host  
- Zero direct vendor access  
- Session recording  
- Time-bound access  
- Strict firewalling  
- No vendor tools in control VLANs  

### Remote Access Flow:
Vendor → VPN → IT/OT DMZ → Jump Host → OT Firewall → Specific systems

### Prohibited:
- Direct vendor VPN into OT  
- Modbus or BACnet reachable from internet  
- Dual-purpose jump hosts shared with IT  
- Unmanaged switches in plant rooms  

Data centres are prime ransomware targets — remote access must be bulletproof.

---

# 12. Monitoring and Telemetry

A data centre demands continuous monitoring:

### Mechanical:
- Chilled water flow  
- Delta-T  
- CRAC return/supply temps  
- Humidity levels  
- Airflow balance  
- Fan speeds  
- Valve positions  

### Electrical:
- UPS load  
- PDU load  
- Voltage/current/phase  
- Generator status  
- ATS/STS switching events  

### Network:
- BACnet traffic health  
- Modbus error rates  
- Latency and jitter  
- Interface counters  
- Redundancy path status  
- Supervisor CPU and trend upload rates  

### Alarms:
- Must integrate into DCIM/NOC  
- Must support escalation policies  

---

# 13. Common Data Centre Deployment Failures

### ❌ Single VLAN for all HVAC and power  
Leads to broadcast storms and uncontrolled interdependencies.

### ❌ BBMD used across entire facility  
Disastrous under load; creates instability.

### ❌ Polling too aggressively  
Crashes Modbus gateways, especially for UPS/PDU.

### ❌ Remote access terminating inside OT VLAN  
Severe security risk.

### ❌ A/B plane mixing at Layer 2  
Creates a single point of failure.

### ❌ Supervisors not redundant  
Loses alarm routing and telemetry during failover.

---

# 14. Data Centre Deployment Checklist

### Architecture
- [ ] Dual A/B OT core  
- [ ] Separate building blocks  
- [ ] VLANs per system type  
- [ ] No cross-plane L2  
- [ ] BACnet network numbers unique  

### Security
- [ ] Strict firewall segmentation  
- [ ] DMZ for IT/OT integration  
- [ ] Jump host for remote access  
- [ ] MFA everywhere  
- [ ] No direct vendor access  

### Redundancy
- [ ] Dual uplinks per switch  
- [ ] Supervisor HA  
- [ ] UPS/generator for OT gear  
- [ ] Redundant gateways where possible  

### Monitoring
- [ ] BACnet health  
- [ ] Modbus errors  
- [ ] OT firewall events  
- [ ] Cooling telemetry  
- [ ] Power telemetry  
- [ ] Supervisor performance  

---

# Summary

Data centre OT/BMS networks must be engineered with the same level of rigour as the mechanical and electrical systems they control.  
Cooling, power, fire, and environmental control are mission-critical — and the OT network must be just as reliable.

Key principles:

- Segregation of A/B systems  
- No single point of failure  
- Minimal BACnet broadcast domains  
- Strong firewall and remote access controls  
- Predictable, deterministic behaviour  
- Full monitoring and telemetry  

A well-designed OT infrastructure is essential for maintaining uptime, meeting SLAs, and protecting data centre assets.
