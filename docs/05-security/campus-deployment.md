# Campus Deployment Pattern for OT/BMS Networks

Large multi-building estates introduce challenges not present in single-building OT networks.  
Campus OT designs must account for long-distance fibre distribution, multi-vendor systems, building-level autonomy, cross-site routing, high availability, and often security or compliance requirements.

This chapter provides a complete deployment blueprint for campus-scale OT/BMS networks.

---

# Architectural Goals of a Campus OT Network

A campus design must deliver:

- **Building-level independence**  
- **Centralised management and monitoring**  
- **Secure cross-site communication**  
- **Failover paths and redundant fibre**  
- **Clear boundaries between buildings and systems**  
- **Non-propagation of unnecessary broadcasts**  
- **Vendor isolation across entire estate**  
- **Scalable addressing and VLAN structures**  
- **Time synchronisation across all buildings**  

A campus OT architecture cannot simply be a “bigger building network.”  
It must be intentionally structured.

---

# 1. Campus OT Core

At the heart of a campus lies the **OT Core**, typically located in:

- A main data centre  
- A central comms room  
- A secure infrastructure zone  

### The OT Core provides:

- Routing between buildings  
- Firewall boundaries  
- Redundant NTP servers  
- Central supervisors (if used)  
- Remote access termination points  
- Logging/SIEM  
- Inter-building OT services  

### Core requirements:

- Redundant pair of core switches/routers  
- Redundant uplinks to each building  
- UPS and generator-backed power  
- Physical security  

---

# 2. Building-Level OT Distribution

Each building in the campus should be treated as a semi-independent OT domain.

### Within each building:

- Local OT distribution switches  
- Local VLANs for controllers  
- Building-level supervisors (optional)  
- Time sync local redundancy  
- Gateways for MS/TP, KNX, Modbus, etc.  
- Separation between HVAC, lighting, electrical, and security systems  

### Buildings must NOT rely on:

- Other buildings’ supervisors  
- Cross-site broadcast traffic  
- Inter-building BBMD  
- Cross-building controller communication  

Each building should be capable of running autonomously even if campus links fail.

---

# 3. Recommended Campus Topology

### **Hierarchical, Three-Tier OT Architecture:**

1. **Campus OT Core**  
2. **Building Distribution Layer**  
3. **Local Plant Rooms / Floor-level VLANs**  

This structure gives:

- Predictable routing  
- Failure domain isolation  
- Simple VLAN management  
- Scalable addressing  

Avoid flat multi-building Layer 2 networks at all costs.

---

# 4. Inter-Building Connectivity

Inter-building fibre runs typically form:

## Option A — **Dual-Homed Star Topology** (Recommended)

Each building has two diverse fibre paths to the OT core.

Pros:
- Best reliability  
- Limits lateral movement  
- Simple routing  
- Easy to secure  

Cons:
- Higher fibre cost  

## Option B — **Campus Ring (RSTP/MSTP/ERPS)**

Pros:
- Lower fibre usage  
- Fast recovery with ERPS  

Cons:
- Broadcast-heavy protocols can destabilise ring  
- KNX/BACnet multicast leakage becomes catastrophic  
- Complex troubleshooting  

Ring topologies are acceptable but require strict control of broadcast/multicast.

---

# 5. Cross-Site Routing Rules

### Rule 1 — No broadcast or multicast across buildings  
BACnet Who-Is, KNX routing multicast, etc., must never leave a building boundary.

### Rule 2 — Supervisors communicate via unicast ONLY  
Supervisors should use object reads, COV, and unicast writes.

### Rule 3 — No inter-building controller ↔ controller traffic  
Controllers must remain isolated by building.

### Rule 4 — Use OSPF/BGP sparingly  
Static routing is often safer for OT.

---

# 6. BACnet on a Campus

BACnet/IP is sensitive to multi-building designs.

### Avoid:
- Multi-building BBMD meshes  
- Cross-site broadcasts  
- Foreign Device Registration over WAN  
- Controllers communicating between buildings  

### Recommended:
- Per-building BACnet Network Numbers  
- Local supervisors per building OR  
- One central supervisor using unicast only  

### For multi-site operations:
Use **BACnet/SC hubs** rather than BBMD.

BACnet/SC offers:
- Encryption  
- Stable cross-site routing  
- Broadcast-free design  
- Cloud-friendly architecture  

---

# 7. KNX on a Campus

KNX multicast (224.0.23.12) must remain inside a building.

### KNX Campus Rules:
- Use KNX tunnelling for cross-site integrations  
- Do not transport routing multicast between buildings  
- Gateways remain local to building  
- Supervisors communicate via IP unicast  

Failure to isolate KNX multicast can collapse entire campus networks.

---

# 8. Modbus TCP on a Campus

Modbus TCP communicates via unicast.

### Campus Requirements:
- Treat each building as separate Modbus domain  
- Gateways local to plant rooms  
- Supervisors use routed Modbus where needed  
- Firewall enforce TCP/502 restrictions  
- No cross-site vendor access  

Modbus is simple but dangerous without firewalling.

---

# 9. OPC-UA Across Buildings

OPC-UA is the easiest protocol to federate across a campus.

Guidelines:

- Use certificates  
- Place OPC-UA servers in building DMZs or OT DMZ  
- Supervisors subscribe across buildings using routed unicast  
- Enforce ACL rules on TCP/4840  

OPC-UA can also backhaul to cloud analytics.

---

# 10. VLAN Strategy for Campus Deployments

A scalable VLAN model is essential.

### Recommended Structure

Campus Core VLANs:
VLAN 50 – OT NTP
VLAN 60 – OT Management
VLAN 70 – OT DMZ
VLAN 80 – Remote Access DMZ

Building VLANs:
BLDG1:
VLAN 110 – BACnet Controllers (Plant)
VLAN 120 – BACnet Controllers (Floors)
VLAN 130 – Gateways
VLAN 140 – Lighting
VLAN 150 – Energy
VLAN 160 – Security (optional)

BLDG2:
VLAN 210 – BACnet Controllers (Plant)
VLAN 220 – BACnet Controllers (Floors)
VLAN 230 – Gateways
…

BLDG3:
…

### Benefits:
- Predictable numbering across buildings  
- Clear hierarchy  
- Simplifies firewall policies  

---

# 11. IP Addressing for Campus OT

Use a campus-wide addressing plan:

Example:

10.50.0.0/16 – Campus OT Space

10.50.1.0/24 – BLDG1 Supervisors
10.50.2.0/24 – BLDG1 Controllers
10.50.3.0/24 – BLDG1 Gateways

10.50.11.0/24 – BLDG2 Supervisors
10.50.12.0/24 – BLDG2 Controllers

---

Rules:
- Never reuse subnets across buildings  
- Document BACnet network numbers  
- Reserve future blocks  

---

# 12. Campus-Wide Remote Access

Remote access must terminate in the **campus OT DMZ**, not at each building.

Vendors → VPN → DMZ → Jump Host → OT Firewall → Building VLANs

Advantages:
- Single audit point  
- No vendor presence inside buildings  
- Consistent security model  

---

# 13. High Availability Across Buildings

Campus HA requires:

### Network HA
- Dual core switches  
- Dual fibre paths  
- Redundant distribution switches in each building  
- Avoid STP across buildings  

### Supervisor HA

Two options:

1. **Per-Building Supervisor with Local HA**
   - Each building independent  
   - Most resilient to WAN failure

2. **Central Supervisor Cluster in OT Core**
   - Requires dependable routing  
   - Ensures unified data model  
   - Works best with BACnet/SC  

### NTP HA
- Two redundant NTP servers in OT core  
- Optional third NTP in each building  

### Power HA
- UPS in each building comms room  
- Generators for core infrastructure  

---

# 14. Monitoring and Telemetry

A central monitoring system must aggregate:

- BACnet/SC or BACnet/IP supervisory data  
- OPC-UA events  
- Modbus polling results  
- Device uptime  
- VLAN and interface counters  
- Syslog from all OT network devices  
- Firewall logs  
- Time sync status  
- Controller health  
- Gateway load  

Campus monitoring is essential for early detection of cross-site issues.

---

# 15. Common Campus Deployment Failures

### 1. BBMD used across buildings  
Result: campus-wide broadcast storm.

### 2. KNX routing multicast leaking across L3  
Result: CPU exhaustion across all switches.

### 3. Flat L2 network across buildings  
Result: catastrophic spanning tree failures.

### 4. Supervisors placed in wrong building  
Result: WAN dependency for local plant operations.

### 5. Remote access terminating inside building LAN  
Result: vendors bypass core firewall and segmentation.

### 6. Duplicate IP or duplicate BACnet network numbers  
Result: hard-to-diagnose system outages.

---

# 16. Campus Deployment Checklist

- [ ] Per-building VLAN structure  
- [ ] Per-building addressing  
- [ ] No broadcast crossing building boundaries  
- [ ] BACnet/SC preferred for cross-building routing  
- [ ] Dual fibre uplinks  
- [ ] OT core routing/firewalling centralised  
- [ ] Supervisors placed correctly  
- [ ] Remote access only through core DMZ  
- [ ] Monitoring centralised  

---

# Summary

Campus deployments require strict separation of buildings, predictable addressing, and disciplined broadcast control.  
BACnet/SC is the long-term solution for multi-building BACnet routing, while legacy BBMD must be avoided wherever possible.

Key principles:

- Buildings must operate independently  
- No broadcast/multicast across buildings  
- OT core provides central routing and security  
- Supervisors should avoid cross-building dependencies  
- Remote access must terminate at the core  
- Redundancy must consider fibre, power, and supervisors  

A well-designed campus OT architecture is stable, secure, highly resilient, and scalable for decades.
