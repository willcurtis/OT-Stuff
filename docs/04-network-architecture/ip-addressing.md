# IP Addressing Strategy for OT/BMS Networks

OT/BMS networks require predictable, well-structured IP addressing to ensure stability, simplify troubleshooting, and avoid conflicts caused by legacy device behaviour. Unlike IT systems, BMS controllers often have limited or inflexible TCP/IP stacks, require static addressing, and depend on predictable gateway relationships.

This chapter provides a complete reference for designing IP addressing schemes specifically tailored for OT/BMS deployments.

---

# The Goals of OT IP Addressing

An effective addressing strategy must:

- Support long-term maintainability  
- Provide enough space for future growth  
- Avoid overlapping ranges between OT and IT  
- Clearly separate functional systems  
- Minimise confusion for integrators  
- Enable consistent firewall and routing policies  
- Support BACnet/IP, Modbus TCP, OPC-UA, KNX/IP, LON/IP, and gateway devices  

Addressing must prioritise **clarity over density**.

---

# Key Principles for OT/BMS IP Addressing

### 1. Use entirely different IP ranges from the corporate IT network  
Avoid conflicts during integration, routing, and vendor access.

Preferred OT ranges:
- 10.10.0.0/16  
- 10.20.0.0/16  
- 10.30.0.0/16  

### 2. Use static IP addresses for all controllers  
Most BMS controllers:
- Do not handle DHCP lease renewals well  
- Cannot gracefully manage IP changes  
- Lose point mappings or time sync when address changes  

### 3. Allocate subnets per system or per location  
Systems with different traffic patterns should not share subnets.

Examples:
- Supervisors  
- Gateways  
- BACnet controllers  
- Modbus devices  
- KNX/IP routers  
- Energy meters  
- Lighting control processors  

### 4. Keep subnets reasonably small  
Many OT devices broadcast frequently.

Recommended subnet sizing:
- /28 (16 addresses) for small plant rooms  
- /27 (32 addresses) for medium systems  
- /24 (256 addresses) for large systems  

Avoid giant subnets (e.g., 10.0.0.0/8).

### 5. Reserve logical address blocks  
Predictability saves significant engineering time.

---

# Example OT Addressing Scheme (Conceptual)

This structure is suitable for most commercial buildings.

### 10.20.0.0/16 – OT/BMS Core Address Space

| Subnet | Purpose |
|--------|----------|
| 10.20.10.0/24 | BMS Supervisors & Databases |
| 10.20.20.0/24 | BACnet/IP Controllers (Plant Room 1) |
| 10.20.30.0/24 | BACnet/IP Controllers (Floor 1) |
| 10.20.40.0/24 | Modbus TCP Gateways |
| 10.20.50.0/24 | Energy Meters |
| 10.20.60.0/24 | KNX/IP Routers |
| 10.20.70.0/24 | Vendor Access VLAN |
| 10.20.80.0/24 | OT DMZ |

This approach:

- Separates noisy systems  
- Reduces broadcast domain size  
- Simplifies firewalling  
- Enables per-function monitoring  

---

# Address Planning for BACnet/IP

BACnet/IP requires careful alignment between IP addressing and BACnet network numbers.

### Key rules:

### 1. BACnet/IP devices must share a broadcast domain (unless using BBMD)
BACnet relies on:
- Who-Is → I-Am broadcast discovery  
- COV notifications  
- Alarm transmissions  

Place devices in appropriate subnets.

### 2. One BACnet network number per VLAN  
BACnet network numbers are NOT IP subnets.  
Example:
- VLAN 30 → BACnet Network 10030  
- VLAN 31 → BACnet Network 10031  

### 3. Supervisors must have reachable paths to all controllers  
Ensure routing allows UDP/47808 between supervisor and controllers.

### 4. BBMD deployment requires static addressing  
BBMDs must be configured with static IPs; DHCP is unsafe.

### 5. Avoid IP renumbering once deployed  
BACnet devices often store IP references internally.

---

# Address Planning for Modbus TCP

Modbus TCP uses unicast and is flexible, but:

- Each device should have a **permanent** static IP  
- Gateways must be placed in predictable ranges  
- Polling load influences subnet sizing  

Best practice:
- Group Modbus devices in /27 or /28 subnets  
- Keep large pollers (supervisors) isolated  

---

# Address Planning for KNX/IP

KNX/IP routers use:
- UDP/3671 for tunnelling  
- Multicast 224.0.23.12 for routing  

Best practice:
- Place all KNX routers into a **dedicated VLAN**  
- Assign continuous IP address blocks to simplify ETS management  
- Never mix KNX multicast with unrelated OT systems  

---

# Address Planning for OPC-UA

OPC-UA servers often reside on:

- Chillers  
- Boilers  
- Energy management systems  
- PLCs  
- Edge gateways  

Recommendations:

- Place OPC-UA servers in a subnet separate from BACnet and Modbus  
- Use static IPs  
- Document certificate CN/SAN → IP mapping  
- Avoid changes to OPC-UA server IPs (breaks certificates)  

---

# Address Planning for LON/IP

LON/IP requires:

- Predictable addressing for LON routers  
- Dedicated VLAN to avoid broadcast conflicts  
- Stable paths to the LON management server  

Static addressing is mandatory.

---

# Addressing Gateways

Gateways convert between protocols:
- BACnet/IP ←→ MS/TP  
- Modbus TCP ←→ Modbus RTU  
- KNX IP ←→ TP1  
- LON ←→ BACnet  

Gateways should:

1. Be placed in their own VLAN  
2. Have controlled access via firewalls  
3. Use static addressing  
4. Be located near supervisory zones (lower latency)  
5. Avoid IP changes after commissioning  

---

# Documenting IP Address Plans

Documentation must include:

- Device name  
- Function (controller, gateway, meter, etc.)  
- Protocol used  
- VLAN  
- Subnet mask  
- Gateway  
- MAC address  
- BACnet network number (if applicable)  
- Serial number (for plant equipment)  
- Room/plant location  

Clear documentation reduces misconfiguration during future upgrades.

---

# Common Addressing Failures

### 1. Overlapping subnets between OT and IT
Cause: OT integrators using default ranges (e.g., 192.168.1.0/24).

### 2. DHCP assigned to controllers
Cause: IT-style design mistakenly applied.

### 3. BBMD misconfiguration due to IP change
Cause: BACnet devices configured with old addresses.

### 4. Vendor access VLAN allowed into controller VLAN
Cause: Poor firewalling combined with overlapping ranges.

### 5. Certificates break when OPC-UA server IP changes
Cause: CN/SAN mismatch.

### 6. KNX multicast leaks between VLANs
Cause: Non-dedicated addressing and misconfigured routing.

---

# Addressing Checklist

- [ ] All OT devices have static IPs  
- [ ] Dedicated prefixes for each subsystem  
- [ ] BACnet network numbers documented  
- [ ] KNX multicast contained  
- [ ] OPC-UA IPs tied to certificate SANs  
- [ ] Gateways placed in isolated VLANs  
- [ ] Address plan covers growth for 10+ years  
- [ ] No overlap with corporate IT networks  
- [ ] All addressing documented in version-controlled repository  

---

# Summary

A robust IP addressing strategy for BMS/OT networks must prioritise predictability, clarity, and strict separation between systems. By grouping devices logically, isolating protocols, and assigning static, well-defined IPs, network engineers can avoid the majority of integration issues encountered in real-world OT deployments.

Proper addressing is foundational to:
- BACnet routing  
- Modbus polling efficiency  
- KNX/IP stability  
- OPC-UA certificate integrity  
- Secure firewall designs  

A clean, well-structured addressing plan is one of the most powerful tools in an OT network engineer’s toolkit.
