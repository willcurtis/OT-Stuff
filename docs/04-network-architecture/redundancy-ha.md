# High Availability and Redundancy in OT/BMS Networks

Operational Technology (OT) networks for Building Management Systems (BMS) require high levels of uptime and predictability. However, the redundancy models applicable to IT systems cannot always be applied directly in OT due to protocol behaviour, legacy device constraints, and real-world plant dependencies.

This chapter provides a comprehensive engineering reference for designing HA and redundancy strategies tailored to OT/BMS networks.

---

# The Unique Nature of Redundancy in OT Networks

Unlike IT systems, OT redundancy is constrained by:

- Legacy protocols (BACnet, Modbus, MS/TP, KNX, LON)  
- Polling behaviours  
- Fieldbus limitations  
- Controller hardware designs  
- Plant safety requirements  
- Vendor-specific supervisory architectures  

**Redundancy must be designed around process behaviour, not just network availability.**

---

# Types of Redundancy in OT/BMS

OT redundancy broadly falls into five categories:

1. **Network Layer Redundancy** (switches, links, routers)  
2. **Hardware Redundancy** (controllers, gateways, servers)  
3. **Application-Level Redundancy** (supervisors, schedulers, historians)  
4. **Protocol-Level Redundancy** (BACnet/SC, dual BBMD paths)  
5. **Physical Topology Redundancy** (dual fibres, ring networks, separate risers)  

Each must be considered separately to avoid creating single points of failure.

---

# 1. Network Layer Redundancy

## Redundant Switch Cores

OT networks typically use:
- Two core/distribution switches  
- Running VRRP/HSRP for gateway redundancy  
- Dual power feeds  
- Dual uplinks from access switches  

Best practices:
- Use industrial or enterprise-grade switches for core and plant areas  
- Avoid daisy-chaining access switches  
- Keep STP domains small and predictable  
- Use LACP for link redundancy where supported  

## Access Switch Redundancy

In small BMS deployments, single access switches per plant room are common.

Where redundancy is required:
- Deploy physically separate switches  
- Dual-feed controllers where possible  
- Split critical SBCs/DDCs across switches  

Limitations:
- Many controllers have only one Ethernet interface  
- Some devices are sensitive to link flaps or MAC movement  

---

# 2. Router / Default Gateway Redundancy

VRRP/HSRP are acceptable in OT networks if:

- The topology is simple  
- Broadcast-heavy protocols are considered  
- MAC failover behaviour is stable  

Potential issues:
- BACnet flooding during failover  
- Devices not handling ARP changes well  
- Supervisors losing sessions during VRRP transition  

Recommended:
- Keep VRRP groups small  
- Do not run unnecessary dynamic routing  
- Test failover with actual plant traffic loads  

---

# 3. Physical Redundancy: Fibre Rings, Dual Risers

OT networks often use physical redundancy through cabling:

### Fibre Rings (RSTP or ERPS)
- Suitable for campuses and large buildings  
- Must be designed with proper guard instancing  
- Avoid heavy multicast/broadcast in ring topologies  

### Dual Riser Architectures
- Each riser contains independent fibre paths  
- Reduces risk from fire/water incidents  
- Supervisors and gateways should connect via both risers where possible  

### Redundant Paths to Plant Rooms
- Ideal for critical workshops, data halls, or hospitals  
- OT switches should not be single-homed unless risk is acceptable  

---

# 4. Controller-Level Redundancy

Most BMS controllers DO NOT support active-active or even active-standby redundancy.

Limitations:
- Single Ethernet port  
- No concept of cluster membership  
- Internal logic coupled to hardware  
- Limited CPU and memory for HA features  

Therefore:
- **Network redundancy cannot make a non-redundant controller highly available**  
- Redundancy must be handled at the supervisory level or at the physical process level  

---

# 5. Redundancy for Gateways

Gateways connecting serial protocols to IP are single points of failure:

### Examples:
- BACnet MS/TP → BACnet/IP  
- Modbus RTU → Modbus TCP  
- KNX TP1 → KNX/IP  
- LON → BACnet  

Gateway redundancy strategies:

1. **Dual gateways reading the same fieldbus**  
   Sometimes possible but can overload the bus.

2. **Hot standby gateways**  
   Vendor-dependent, common in industrial PLC environments.

3. **Redundant IP paths**  
   Provide link redundancy, not functional redundancy.

4. **Supervisory fallback logic**  
   Supervisors detect gateway failure and switch to alternate source.

Gateways should be placed on:
- UPS-backed switches  
- Redundant paths  
- Dedicated, low-noise VLANs  

---

# 6. Supervisory Redundancy

The BMS supervisor is the most redundancy-capable component.

### Typical HA models:

#### **A. Warm Standby**
- Primary supervisor active  
- Secondary synchronised but passive  
- Failover triggered manually or by cluster monitoring  

Pros:
- Simple  
- Low cost  

Cons:
- Short outage during changeover  

#### **B. Hot Standby / Active-Active**
- Both supervisors run concurrently  
- Redundant trending, alarms, scheduling  

Pros:
- No outage  
- High resilience  

Cons:
- Licensing cost  
- Requires strict database synchronisation  
- Not supported by all vendors  

---

# 7. Protocol-Specific Redundancy Considerations

## BACnet/IP
- BBMD must be carefully planned  
- Avoid multiple BBMDs per VLAN unless required  
- BACnet/SC provides encrypted, routed, redundant paths  
- Broadcast dependence reduces redundancy options  

## MS/TP
- Very limited redundancy  
- A broken device or physical cable fault takes out part of the bus  
- Only physical loop designs with break-detection (rare) offer redundancy  

## Modbus TCP
- No inherent redundancy  
- Use redundant network paths or dual Ethernet cards (rare)  
- Supervisory systems can implement retry logic  

## KNX/IP
- Routing redundancy depends on IP multicasting  
- Tunnelling requires free connection slots  
- Some installations use dual KNX/IP routers per line  

## OPC-UA
- Excellent redundancy support  
- Multiple redundant servers possible  
- Aggregators can provide automatic failover  

---

# 8. Power Redundancy

Essential for high availability:

- All core and plant switches on UPS  
- Controllers powered through resilient building circuits  
- Avoid mixing IT and OT power paths  
- Supervisors and gateways on dual power supplies where available  

Power is the most common point of failure in OT networks.

---

# 9. Common Redundancy Failures in OT/BMS

### Failure 1: STP loops created by unmanaged switches  
Cause: contractor adds a cheap 5-port switch to extend controller cabling.

### Failure 2: VRRP causing BACnet storm  
Cause: controller caches incorrect gateway MAC or ARP state.

### Failure 3: MS/TP bus failure halts plant monitoring  
Cause: single device holds token or bus wiring fault.

### Failure 4: KNX routing collapse  
Cause: multicast leak or IGMP failure.

### Failure 5: Gateways single-homed to non-redundant access switch  
Cause: access switch failure takes out entire mechanical plant visibility.

### Failure 6: Supervisory failover incomplete  
Cause: trend/historian database not in sync.

---

# 10. Redundancy Design Checklist

- Dual OT core switches with redundant power  
- Redundant fibre uplinks to each plant room  
- VRRP/HSRP for gateway redundancy  
- Supervisors in warm/hot standby  
- Gateways placed on UPS-backed core or distribution switches  
- BBMD designed correctly (one per subnet unless required)  
- KNX multicast isolated to its VLAN  
- OPC-UA redundancy groups implemented where supported  
- Time sync servers redundant  
- Monitoring for path flap, link down, gateway failover  
- No unmanaged switches in critical paths  

---

# Summary

Redundancy in OT/BMS networks must be carefully engineered around real-world constraints—legacy protocols, limited controller capabilities, and the physical nature of building systems. True HA comes not from copying IT designs but from aligning redundancy to plant processes, fieldbus behaviour, and supervisory logic.

Key principles:

- Network redundancy does not replace process redundancy  
- Supervisors provide most practical HA options  
- Gateways must be protected, not assumed redundant  
- STP loops and multicast misconfigurations are major risks  
- Redundant power is as important as redundant links  

A well-designed redundancy architecture dramatically improves resilience and operational safety across OT environments.
