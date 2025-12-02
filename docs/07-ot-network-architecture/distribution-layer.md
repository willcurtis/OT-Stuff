# Distribution Layer Architecture  
**Riser Switching, L3 Boundaries, Redundant Fibre, Equal-Cost Routing, and Multi-Building OT Design**

The Distribution Layer aggregates Access Layer switches and provides structured, resilient pathways back to the OT Core.  
It is responsible for:

- Redundant fibre uplinks  
- Aggregating per-floor risers  
- Local L3 routing (where used)  
- Containing broadcast domains  
- Providing deterministic northbound paths  
- Handling failover in fibre or switch failures  

The distribution layer is where architectural discipline prevents outages from propagating across floors or buildings.

---

# 1. Distribution Layer Roles

### 1.1 Riser / Intermediate Aggregation  
Each building typically has:
- 1–2 riser shafts  
- Each riser has a distribution switch  
- Access switches (per floor) uplink into the riser  

### 1.2 Inter-Floor Routing (Optional)  
If using L3-at-distribution:
- Distribution switch becomes gateway for all floor VLANs  
- Multiple risers summarise routing towards the core  

### 1.3 Resilience Hub  
The distribution layer provides:
- Link redundancy  
- Path redundancy  
- Power-source redundancy (where feasible)  

### 1.4 Containment Boundary  
BACnet, KNX multicast, Art-Net, and Modbus storms must not propagate beyond distribution.

---

# 2. L2 vs L3 Distribution Models

OT networks typically use one of two models.

---

## 2.1 Model A – **L3 at Distribution (Recommended)**

### Characteristics:
- Each riser switch performs routing  
- Access switches operate purely at L2  
- VLANs do **not** extend beyond riser

### Benefits:
- Fault isolation per floor  
- No spanning tree between floors  
- Routing is deterministic  
- Broadcast domains remain small  

### Routing Example:

Access Floor 3 → Dist Riser A (Gateway) → Core
Access Floor 4 → Dist Riser A (Gateway) → Core

### Pros:
- Most scalable  
- Best for large buildings  
- Best for BACnet/IP and KNX IP containment  

### Cons:
- Higher switch cost (needs L3 licenses)  
- Riser switches must be sized appropriately  

---

## 2.2 Model B – **L2 Distribution (Legacy)**

### Characteristics:
- Riser switches are L2 only  
- VLANs stretch from core to access  
- Core performs routing for all VLANs

### Issues:
- Spanning tree required  
- Large broadcast domains  
- BACnet/IP storms propagate  
- Multicast for KNX/Lighting spreads uncontrolled  

### Only acceptable when:
- Buildings are very small  
- Systems are simple  
- All devices extremely low-traffic  

**Not recommended for modern OT networks.**

---

# 3. Fibre Topology & Redundancy Design

Reliable distribution requires fault-tolerant fibre design.

---

## 3.1 A/B Riser Redundancy (Best Practice)

Each floor access switch connects to:
- Riser A  
- Riser B  

Both risers uplink separately to dual OT Core switches.

Access Floor 3 → Dist A → Core A & Core B
Access Floor 3 → Dist B → Core A & Core B

Advantages:
- Fibre break does not isolate floor  
- Riser switch failure does not isolate floor  
- Maintenance is hitless with dynamic routing  

---

## 3.2 Single Riser with Redundant Fibre Legs

Used in older buildings with limited riser space.

Access → Riser → Core A
Access → Riser → Core B

Protection against fibre failure, but not riser switch failure.

---

## 3.3 Ring-Based Distribution (Campus)

For multi-building estates where buildings connect sequentially:

Building A → Building B → Building C → Building D → back to A

Requires:
- Routed links (OSPF)  
- No Layer 2 across buildings  
- ECMP load sharing  
- Fast convergence (sub-1s ideal)  

Never run BACnet, KNX multicast, or lighting protocols across buildings via L2.

---

# 4. Uplinks: Bandwidth & Redundancy

### 4.1 Fibre Type  
- OS2 single-mode recommended  
- LC connectors, duplex  
- At least two fibres per path (A & B risers)  
- Consider 10G minimum, 25G where future-proofing  

### 4.2 Uplink Protocols  
If L3 at distribution:
- OSPF recommended  
- Passive summarisation towards core  
- No default-route received from floor VLANs  

If L2:
- MSTP/RSTP highly tuned  
- Avoid root bridge in riser switch  

---

# 5. Traffic Engineering & Storm Containment

### 5.1 Controls Applied at Distribution  
- Per-VLAN storm control  
- BACnet broadcast throttling  
- KNX multicast policing  
- Logging of broadcast events  
- Isolation of lighting VLANs that use sACN/Art-Net  

### 5.2 BACnet/IP Control  
- Disable learning on untrusted ports  
- Rate-limit who can broadcast  
- Use BACnet/SC in DMZ  

### 5.3 KNX IP  
- IGMP querier runs at distribution  
- Do not forward multicast between risers  

---

# 6. Equal-Cost Multipath Routing (ECMP)

If L3-at-distribution:
- Uplinks to Core A and Core B should be equal-metric  
- OSPF ECMP splits flows across links  
- Provides load-balancing and rapid failover  

Example:

Dist A → Core A (10G)
Dist A → Core B (10G)
Both links cost = 10

---

# 7. Integration With Core Layer

### Best Practice:
- Core summarises routes from distribution  
- Distribution advertises /24 per VLAN  
- Distribution only receives default route from core  

### Example:

Core advertises: 0.0.0.0/0
Dist advertises: 10...0/24

### Benefits:
- Rapid convergence  
- Clean routing table  
- Prevents routing loops  
- Limits broadcast domain size  

---

# 8. Device Types Connected at Distribution

- Access switches  
- Lift/firewall gateways (OT approved only)  
- Large KNX/IP backbones  
- UPS/escalator plant controllers  
- Chiller/Boiler supervisory devices  
- OT management hosts (optional)  
- Global time servers for the building  
- MQTT aggregators if localised  

Do NOT connect:
- Corporate devices  
- CCTV servers  
- Access control panels (unless isolated VLAN + firewall rules)  

---

# 9. Distribution Switch Requirements

### Hardware:
- L3 routing (OSPF, static routes)  
- Deep buffers  
- Redundant PSUs  
- 10/25G uplinks, 1/10G downlinks  
- Strong multicast handling  
- Full SNMP/sFlow/NetFlow  

### Software:
- OSPFv2  
- VRRP (if L3 at access is required; rare)  
- DHCP Snooping  
- Option82 if required  
- ACLs on VLAN interfaces  

---

# 10. Example Distribution Layer Blueprint

+———————————————————––+
| Building A – Riser Switch (Distribution A)                  |
|                                                             |
| VLAN 110 – HVAC                                             |
| VLAN 120 – KNX IP                                           |
| VLAN 130 – DALI                                             |
| VLAN 140 – Modbus TCP                                       |
| VLAN 150 – Lighting IP (sACN/Art-Net)                       |
|                                                             |
| L3 Gateway for:                                             |
|   10.1.110.0/24 (HVAC)                                      |
|   10.1.120.0/24 (KNX)                                       |
|   10.1.130.0/24 (DALI)                                      |
|                                                             |
| Uplinks (OSPF, ECMP):                                       |
|   Dist A → Core A (10G)                                     |
|   Dist A → Core B (10G)                                     |
+———————————————————––+

---

# 11. Multi-Building Considerations

### 11.1 No Shared VLANs Across Buildings  
Each building is fully autonomous.

### 11.2 Routed Links Only  
No L2 links between buildings.  
Absolutely no spanning tree across buildings.

### 11.3 OSPF Areas  
Optional but recommended for very large estates:
- Area per building  
- Backbone at core  

### 11.4 BACnet/SC Support  
Use BACnet/SC for multi-building deployments instead of BBMD.

---

# 12. Monitoring & Observability

Monitor:
- Fibre link errors  
- OSPF adjacency stability  
- Broadcast storms  
- CPU spikes from lighting multicast  
- Interface flaps on riser uplinks  
- Ping latency floor-by-floor  

Log:
- Routing changes  
- IGMP reports  
- Storm-control events  
- PSU events  

---

# 13. Implementation Checklist

### Architecture
- [ ] L3-at-distribution enabled  
- [ ] A/B riser uplinks deployed  
- [ ] ECMP active  
- [ ] No L2 across buildings  

### Performance
- [ ] IGMP querier running  
- [ ] Storm-control per VLAN  
- [ ] Oversubscription ratio validated  
- [ ] Fibre ER/LC/connector budget verified  

### Security
- [ ] ACLs on SVI interfaces  
- [ ] Only required inter-VLAN routes  
- [ ] No unnecessary routing to IT networks  

### Resilience
- [ ] Dual fibre paths  
- [ ] Redundant power  
- [ ] UPS-backed distribution switches  

---

# Summary

The Distribution Layer is the backbone of the OT network inside a building.  
It must be predictable, resilient, and strictly controlled.  
L3-at-distribution is the recommended design for modern OT systems due to superior containment, stability, and scalability.

Key principles:
- Use A/B risers  
- Route at distribution  
- Contain broadcast-heavy OT protocols  
- Use ECMP for optimal performance  
- Do not extend VLANs between buildings  

A well-designed distribution layer eliminates entire classes of outages and provides the platform for a reliable OT environment.
