# Core OT Network Architecture  
**Switching, Routing, Segmentation, Resilience, DMZ Design for Building & Campus OT Networks**

This chapter defines the reference architecture for an OT/BMS network, focusing on:
- Core switches  
- Distribution & access layers  
- Fibre topologies  
- VLAN & IP segmentation  
- Resilience models  
- OT DMZ patterns  
- Integration with IT networks  
- Security zoning  
- Protocol containment  

It provides a vendor-neutral, scalable design suitable for:
- Commercial offices  
- Retail malls  
- Hospitals  
- Mixed-use campuses  
- Industrial facilities  
- Hotels and hospitality  
- Education estates  

---

# 1. OT Network Design Principles

### 1.1 Predictability over flexibility  
OT networks prioritise stability over convenience.  
VLANs, addressing, and routing must remain deterministic.

### 1.2 Resist broadcast-heavy protocols  
BACnet, KNX, and certain lighting protocols must be isolated.

### 1.3 Separation from IT  
OT must be independently secured, monitored, and governed.

### 1.4 Build for decades, not years  
Buildings operate longer than IT refresh cycles.

### 1.5 Avoid single points of failure  
Where possible:  
- dual power  
- dual uplinks  
- dual core nodes  
- UPS-backed switches  

### 1.6 Local autonomy  
Building systems must continue operating if the corporate network is offline.

---

# 2. Logical Network Layers

OT networks follow a 3-tier pattern:

+———————––+
|        OT DMZ           |
+———————––+
/      
/        
+———————––+
|     OT Core Layer       |
+———————––+
/      
/        
+———————––+
| Distribution Layer (per building / riser)
+———————––+
/      
/        
+———————––+
|       Access Layer      |
+———————––+

### 2.1 OT Core Layer
- Redundant pair of switches  
- Layer 3 routing boundary  
- Default gateways for OT VLANs  
- Inter-building connectivity  
- Policy enforcement point  
- Logging, NTP, monitoring, DMZ connectivity  

### 2.2 Distribution Layer
- One per building or per riser  
- Aggregates access switches  
- Provides redundant uplinks to OT core  
- In some cases performs inter-floor routing  

### 2.3 Access Layer
- Field-level connection points for controllers and gateways  
- VLAN per system/zone  
- Deep buffer switches recommended (BACnet storms mitigation)  

---

# 3. Fibre Topologies for OT Networks

### 3.1 Star Topology (Recommended for most buildings)

Core
├─ Riser A (fibre pair)
├─ Riser B (fibre pair)
├─ Riser C (fibre pair)

### 3.2 Ring Topology (Large campuses)
For multi-building estates:

Building A ─ Building B ─ Building C ─ Building D ─ back to A

Requires:
- Rapid spanning-tree or  
- ERPS/RSTP or  
- Routed links  

Never run BACnet or KNX over building-to-building L2 rings.

### 3.3 Direct Fibre for Critical Plant Rooms  
Chillers, boilers, main plant should run on physically redundant fibre.

---

# 4. VLAN & IP Addressing Strategy

### 4.1 Principle: **One VLAN per System per Building**  
Examples:

VLAN 110 - Building A HVAC (BACnet/IP)
VLAN 120 - Building A Lighting (KNX IP)
VLAN 130 - Building A DALI Gateways
VLAN 140 - Building A VRF/VRV
VLAN 150 - Building A Energy Meters (Modbus TCP)
VLAN 160 - Building A IoT Sensors (MQTT gateways)

Repeat per building.

### 4.2 Do NOT share VLANs across buildings  
No cross-building broadcast domains.

### 4.3 Recommended IP Scheme

10.<building_number>.<system_number>.0/24

Example:

Building 1 HVAC:     10.1.10.0/24
Building 1 Lighting: 10.1.11.0/24
Building 2 HVAC:     10.2.10.0/24

### 4.4 Management VLAN

10.255..0/24

Used for:
- Switch management  
- UPS  
- Environmental monitoring  
- OT NTP servers  

---

# 5. Resilience & High Availability Models

### 5.1 Core Layer HA

Options:

#### A. Stacked Core  
Pros: simple L2/L3  
Cons: full outage during stack upgrade

#### B. MLAG / vPC / MC-LAG  
Pros: hitless uplink redundancy  
Cons: requires careful design

#### C. Routed Core (best practice for campuses)  
- No MLAG  
- Pure L3 between cores and distributions  
- No spanning tree  

Core1 <——L3——> Dist <——L3——> Core2

### 5.2 Distribution HA

- Redundant fibre up-links  
- VRRP/HSRP/GLBP if doing L3 at distribution  
- Avoid STP-heavy topologies  

### 5.3 Access Layer Redundancy

Local redundancy is often limited—focus on:
- UPS backing  
- Industrial temperature-rated switches  
- Per-floor failover to alternate riser  

---

# 6. OT Security Zones

Reference zoning model:

Zone 0 – Field Controllers (sensors, actuators)
Zone 1 – Access Switches / Field Networks
Zone 2 – Building Systems (HVAC, lighting, gateways)
Zone 3 – OT Core & Monitoring
Zone 4 – OT DMZ (firewalls, jump hosts)
Zone 5 – IT / Corporate

### 6.1 Firewalls must sit between:
- OT Core ↔ OT DMZ  
- OT DMZ ↔ IT  
- OT Core ↔ external vendors  

---

# 7. OT DMZ Architecture

The OT DMZ provides a **controlled, secure bridge** between OT and IT/cloud networks.

### 7.1 Services hosted in the OT DMZ:
- BMS servers & supervisors  
- SQL/InfluxDB time-series databases  
- BACnet/SC hubs  
- OPC-UA aggregation servers  
- MQTT brokers for OT  
- Vendor remote access jump servers  
- Historian servers  
- Reverse proxies / API gateways  

### 7.2 Firewall Rules Pattern
- OT → DMZ: VERY restricted, mostly northbound telemetry  
- DMZ → OT: Write controls only where strictly required  
- IT → DMZ: Read-only where possible  
- DMZ → Cloud: Tight outbound allow-list  

### 7.3 Jump Host Pattern
Vendor access:

VPN → Jump Host → Proxy → Specific OT System

Never allow direct VPN-to-field-layer access.

---

# 8. Protocol Containment & Interoperability

### 8.1 BACnet/IP
- Must be isolated per building  
- Broadcast storms must be contained  
- No cross-building BBMD  

### 8.2 KNX IP
- Keep multicast inside VLAN  
- Tunnelling for commissioning  

### 8.3 Modbus TCP
- Gateways isolated  
- Read-only where possible  
- Polling rates throttled  

### 8.4 OPC-UA
- Lives in DMZ  
- Used for unifying data upstream  
- TLS mandatory  

### 8.5 MQTT
- Broker in DMZ or secure OT VLAN  
- TLS + ACL enforced  

---

# 9. Monitoring & Observability

High-quality monitoring is essential.

### 9.1 Recommended Tools:
- PRTG for SNMP + custom BMS metrics  
- InfluxDB / Prometheus for time-series  
- Grafana for visualisation  
- Syslog & SIEM for firewall/switch events  
- BACnet explorers (contained in VLAN)  

### 9.2 Monitor:
- Network utilisation  
- Storms on BACnet/KNX VLANs  
- Gateway CPU & memory  
- Polling failures  
- Device offline events  
- NTP drift  

---

# 10. OT Core Switch Requirements

### 10.1 Essential Features:
- Redundant power  
- Industrial temperature rating (optional but ideal)  
- Support for:  
  - VRRP/HSRP  
  - OSPF/IS-IS  
  - Deep packet buffers  
  - IGMP snooping + Querier  
  - DHCP snooping  
  - Broadcast storm control  
  - NetFlow/sFlow  

### 10.2 Avoid:
- Consumer-grade hardware  
- Single-switch core  
- Spanning-tree heavy designs  

---

# 11. Example Reference Architecture

          +------------------------+
          |       OT DMZ FW        |
          | + OT DMZ Servers       |
          | + Remote Access        |
          | + Supervisors / API    |
          +-----------+------------+
                      |
            L3 Routed Firewall
                      |
        +-------------+-------------+
        |                           |
  +-----------+               +-----------+
  | OT Core A |               | OT Core B |
  +-----------+               +-----------+
        |  \                     /   |
        |   \                   /    |
        |    \                 /     |
  L3 Routed Links (OSPF, No STP, No L2)
        |      \           /        |
 +------------+  \       /   +-------------+
 | Dist Riser |   \     /    | Dist Riser B|
 +------------+    \   /     +-------------+
        |            \ /            |
 VLAN-Per-System   Access Layer    VLAN-Per-System

---

# 12. Implementation Checklist

### Architecture
- [ ] L3 core, no cross-building L2  
- [ ] VLAN per system per building  
- [ ] Dual core switches  
- [ ] UPS-backed distribution/access  

### Security
- [ ] OT DMZ deployed  
- [ ] Firewalls between OT and IT  
- [ ] Vendor access via jump host  
- [ ] No direct field layer exposure  

### Protocol Containment
- [ ] BACnet/IP confined  
- [ ] KNX multicast contained  
- [ ] Modbus gateways isolated  
- [ ] MQTT brokers secured  

### Performance
- [ ] Storm control configured  
- [ ] IGMP snooping + querier enabled  
- [ ] OSPF summarisation  
- [ ] Monitoring deployed  

---

# Summary

OT networks require deterministic behaviour, strict segmentation, strong security isolation, and resilience unmatched by typical enterprise networks.  
The core architecture leans heavily on:

- L3 everywhere  
- VLAN-per-system  
- No cross-building broadcast domains  
- Strict DMZ boundaries  
- High-availability switching  

This model ensures that building systems remain stable, secure, and maintainable over their multi-decade operational life.
