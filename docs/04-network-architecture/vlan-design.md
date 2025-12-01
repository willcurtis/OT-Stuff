# VLAN Design for OT/BMS Networks

Virtual LAN (VLAN) design is one of the most important aspects of OT/BMS network architecture.  
Unlike IT networks, where VLANs typically organise departments or floors, OT VLANs must align with functional boundaries, protocol behaviour, plant topology, and supervisory traffic patterns.

Poor VLAN design is one of the top causes of instability in BACnet, KNX/IP, Modbus TCP, and other building automation systems.

This chapter provides a complete, practical guide for designing VLANs specifically for OT/BMS.

---

# VLAN Design Philosophies for OT

There are three dominant VLAN segmentation philosophies in OT:

## 1. **By System Type (Recommended for most sites)**
Each major subsystem gets its own VLAN.
Examples:
- BACnet HVAC controllers  
- Modbus gateways  
- Energy meters  
- KNX/IP routers  
- Lighting processors  
- Vendor access  
- Supervisors  

## 2. **By Location (Used for very large sites)**
Each floor/zone gets its own VLAN.
Examples:
- Floor 1 controllers  
- Floor 2 controllers  
- Floor 3 controllers  

Works well in campus deployments.

## 3. **Hybrid (Common in modern OT)**
Functional segmentation inside location-based groups.
Example:
- Floor 1 HVAC VLAN  
- Floor 1 Electrical VLAN  
- Floor 1 Lighting VLAN  

This is the most scalable for multi-vendor, multi-protocol environments.

---

# Key VLAN Design Principles for OT/BMS

### 1. **Never mix unrelated systems in the same VLAN**
Examples of bad practice:
- Putting BACnet controllers and Modbus gateways in one VLAN  
- Putting KNX routers in a general-purpose VLAN  
- Giving vendor VPN clients direct access to controller VLANs  

### 2. **Broadcast/multicast-heavy protocols need tight containment**
These MUST be isolated:

Protocol | Reason  
--------|--------
BACnet/IP | Broadcast heavy (Who-Is/I-Am)  
KNX IP Routing | Multicast 224.0.23.12  
MS/TP over IP tunnelling | Can create unexpected bursts  

### 3. **Gateways should have their own VLAN**
Gateways commonly become overloaded; VLAN isolation protects controllers.

### 4. **Supervisors should have one VLAN that is routable to all controller VLANs**
A clean IP path is essential for polling and COV subscriptions.

### 5. **Vendor Access must NEVER share VLANs with plant equipment**
Vendors should reach plant only through firewalls.

---

# Recommended VLAN Topology Template

This structure works for most commercial buildings and is scalable to large campuses.

VLAN 100 – BMS Supervisor
VLAN 110 – BACnet Controllers (Plant Room)
VLAN 120 – BACnet Controllers (Floor 1)
VLAN 130 – BACnet Controllers (Floor 2)
VLAN 140 – Modbus TCP Gateways
VLAN 150 – KNX IP Routers
VLAN 160 – Energy Meters
VLAN 170 – OT DMZ
VLAN 180 – Vendor Access
VLAN 190 – OOB/Management

This approach ensures:
- Minimal broadcast domains  
- Clear firewall policy design  
- Predictable scaling  
- Logical grouping for documentation  
- Easy troubleshooting  

---

# VLAN Design by Protocol

## BACnet/IP

BACnet relies heavily on broadcast for:
- Who-Is/I-Am  
- Time sync  
- Alarm/notification  
- Some COV behaviours  

### VLAN Requirements:
- Keep BACnet devices within manageable /24 or /25 subnets  
- Avoid mixing BACnet controllers with other protocols  
- If multiple VLANs are required, use **BBMD** sparingly  
- Supervisors must be routable to all BACnet VLANs  

### NEVER DO:
- Place 200+ BACnet controllers in a single VLAN  
- Allow BACnet broadcasts into IT networks  

---

## Modbus TCP

Modbus TCP is unicast and simpler.

### VLAN Requirements:
- Group devices logically based on polling load  
- Gateways in their own VLAN  
- Isolate high-polling systems from general traffic  
- Firewalls enforce TCP/502 controls  

### Never Do:
- Allow open access to Modbus TCP from corporate LAN  
- Place Modbus in huge /16 or /23 subnets  

---

## KNX/IP

### Two behaviours to consider:

### 1. KNXnet/IP Routing (multicast)
Uses 224.0.23.12.

### 2. KNXnet/IP Tunnelling (unicast)
Used for ETS programming and BMS integrations.

### VLAN Requirements:
- Assign KNX routers to a **dedicated VLAN**  
- Enable IGMP snooping  
- Ensure multicast cannot leave VLAN  
- Create firewall rules for tunnelling sessions only  

---

## OPC-UA

OPC-UA routes cleanly and does not rely on broadcast/multicast.

### VLAN Requirements:
- Place OPC-UA servers in their own VLAN or grouped with similar systems  
- Ensure supervisors can reach OPC-UA ports (default TCP/4840)  
- Do not expose OPC-UA directly to IT; use OT DMZ if necessary  

---

## LON/IP

### VLAN Requirements:
- Dedicated VLAN if using LON/IP  
- Avoid mixing with BACnet/Modbus  
- Static addressing for LON routers  

---

# VLAN Design for Gateways

Gateways bridge legacy fieldbuses to IP:
- BACnet MS/TP → BACnet/IP  
- Modbus RTU → Modbus TCP  
- KNX TP1 → KNX/IP  
- LON → IP  

Gateways should NEVER share VLANs with controllers.

### Reasons:
1. Gateway failures are common  
2. Gateways can flood networks when misconfigured  
3. Gateway rebooting can disrupt controllers  
4. Gateways often need firewall constraints  

Put gateways in a stable, isolated VLAN with controlled routing to supervisors.

---

# VLAN Design for Supervisors

Supervisors require:

- Access to all controller VLANs  
- Access to gateways  
- Access to historian databases  
- Access to NTP and DNS  

Supervisors should NOT have:

- Direct access from vendor laptops  
- Access to IT networks without firewall boundary  
- Exposure to broadcast-heavy traffic  

Place supervisor VLAN close to the OT core.

---

# VLAN Trunking and Switch Behaviour

### Best Practices:
- Trunk VLANs only where required  
- Avoid unnecessary trunks into plant rooms  
- Keep STP domains small  
- Use MSTP or RSTP, never PVST in mixed-vendor OT environments  

### Avoid unmanaged switches
They cause:
- VLAN leakage  
- STP loops  
- Broadcast storms  
- KNX multicast flooding  

---

# VLAN Size Guidelines

**General Recommendation:**
- /28 (14 hosts usable) for small controller groups  
- /27 (30 hosts usable) for plant rooms  
- /24 for large systems or supervisors  

Avoid overpopulating VLANs.

---

# VLAN Tagging Considerations for OT Devices

Some OT devices:
- Do not support VLAN tagging (untagged only)  
- Support only one untagged interface  
- Misbehave if connected to trunk ports  

Always use access ports for controllers unless the manufacturer explicitly supports 802.1Q tagging.

---

# Vendor Access VLAN Design

Vendors require remote connection for:
- Commissioning  
- Troubleshooting  
- Firmware updates  

### Design Requirements:
- Dedicated VLAN  
- Routed ONLY via firewalls  
- No L2 adjacency with controllers  
- ACLs restricting traffic to specific IPs and ports  
- VPN termination into vendor VLAN, not controller VLAN  

Vendor VLAN is often the weakest point if misconfigured.

---

# Common VLAN Design Failures in OT/BMS

1. **Putting all BMS devices in one VLAN**  
   → BACnet storms, slow performance, controller instability.

2. **Allowing KNX multicast to escape its VLAN**  
   → KNX flooding across entire network.

3. **Vendor VPN clients placed directly in BACnet VLAN**  
   → Catastrophic security and stability risks.

4. **Supervisors placed in the same VLAN as controllers**  
   → Loss of clarity in broadcast scoping.

5. **Gateways placed in noisy controller VLANs**  
   → Gateways crash or overload under broadcast conditions.

6. **Using unmanaged switches with multiple VLANs**  
   → VLAN bleeding, STP loops, broadcast storms.

---

# VLAN Design Checklist

- [ ] VLANs grouped by function OR location  
- [ ] Broadcast-heavy protocols isolated  
- [ ] Gateways in dedicated VLANs  
- [ ] Vendor access isolated with firewalls  
- [ ] Supervisor VLAN routable to all controllers  
- [ ] No shared VLANs between IT and OT  
- [ ] No unmanaged switches in core OT  
- [ ] KNX multicast isolated  
- [ ] VLAN sizes appropriate for growth  
- [ ] Documented in source-controlled repository  

---

# Summary

VLAN design is one of the foundational components of OT/BMS network architecture. Proper segregation ensures:

- Stable BACnet and KNX behaviour  
- Clean routing and firewall policy  
- Predictable broadcast domains  
- Reduced plant downtime  
- Clear operational boundaries  
- Easier troubleshooting and vendor coordination  

A well-structured VLAN design dramatically improves reliability and simplifies every part of OT network lifecycle management.
