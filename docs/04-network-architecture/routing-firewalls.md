# Routing and Firewall Design for OT/BMS Networks

Routing and firewall design are central to achieving reliability, performance, and security in Operational Technology (OT) and Building Management Systems (BMS). Unlike general IT traffic, OT protocols often rely on broadcast-heavy discovery, strict timing, legacy behaviours, or polling models that require careful alignment with network boundaries.

This chapter provides a complete technical reference for network engineers designing Layer 3 boundaries, firewall rules, and routing policies in OT/BMS networks.

---

## Architectural Principles

Designing routing and firewall rules for OT requires:

### 1. **Predictable data paths**
BMS systems must have stable, low-latency routes between supervisors, controllers, and gateways.

### 2. **Broadcast containment**
BACnet/IP and KNX routing require bounded broadcast/multicast domains.

### 3. **Least privilege**
OT devices should only communicate with systems necessary for their function.

### 4. **North–south and east–west control**
- North–south = OT ↔ IT  
- East–west = device-to-device inside OT  

### 5. **Deterministic behaviour**
OT networks demand explicit, well-defined routing tables and firewall policies.

### 6. **Protection of legacy protocols**
Modbus, BACnet, LON/IP, and KNX have no inherent security and must rely on network-layer defences.

---

# Layer 3 Routing in OT/BMS Networks

## Goals of Routing in OT Environments

Routing ensures:
- Controlled broadcast domain size  
- Separation of controller groups  
- Enforcement of security boundaries  
- Predictable communication paths  
- Support for multi-VLAN architectures  
- Preventing leakage of OT traffic into IT networks  

Routing also determines how (or if) certain OT protocols traverse between zones.

---

## Routing Behaviour by Protocol

### BACnet/IP
- Broadcast-based discovery  
- Typically remains within one VLAN  
- Requires BBMD if broadcasts must cross subnets  
- Routing should be minimal to reduce complexity  

### Modbus TCP
- Pure unicast  
- Routes easily across VLANs  
- Routing rarely problematic unless polling frequency is high  

### KNX/IP
- KNX routing uses multicast (224.0.23.12)  
- Multi-VLAN routing discouraged  
- Tunnelling (unicast) preferred across routed boundaries  

### OPC-UA
- No broadcast or multicast required  
- Routes cleanly through firewalls  
- Strong security controls available  

### LON/IP
- Depends on deployment  
- Tunnelling preferred for cross-site communication  

---

# Routing Design Best Practices

### 1. Use a dedicated OT core router or pair of redundant switches  
Separating OT routing from corporate routing reduces risk.

### 2. Reserve unique IP subnets per OT function  
Example:
- 10.20.10.0/24 – BMS Supervisors  
- 10.20.20.0/24 – Controllers (Plant Room 1)  
- 10.20.30.0/24 – Controllers (Floor 1)  
- 10.20.40.0/24 – Gateways  
- 10.20.50.0/24 – Energy Meters  
- 10.20.60.0/24 – Vendor Access  

### 3. Avoid dynamic routing protocols in OT  
Static routes or manually controlled dynamic routing (OSPF in stub mode) is preferred.

### 4. Do not route OT broadcast traffic into IT  
BACnet/IP and KNX multicast must never cross into IT networks.

### 5. Keep controller-to-controller routing minimal  
Controllers rarely need to speak horizontally.

---

# Firewall Architecture for OT/BMS

OT firewalls enforce the security boundaries that legacy protocols lack.

## Firewall Functions in OT

- Block unauthorised device discovery  
- Prevent vendor backdoors or rogue tools  
- Stop malware from reaching controllers  
- Enforce segmentation and least privilege  
- Limit Modbus, BACnet, and KNX exposure  
- Protect supervisory servers  
- Control vendor remote access  
- Provide a secure boundary between OT and IT  

---

## North–South Control (OT ↔ IT Boundary)

The OT firewall should enforce strict rules:

### Allowed (Typical)
- HTTPS from IT to BMS portal  
- Read-only OPC-UA from OT to IT analytics  
- MQTT publish from OT to DMZ broker  
- Syslog/SIEM export  
- SNMP traps/telemetry (if required)  

### Blocked
- BACnet (all UDP/47808)  
- Modbus TCP (TCP/502)  
- KNX multicast (224.0.23.12)  
- Controller management ports  
- Vendor tools unless approved  

---

## East–West Control (Inside OT)

OT east–west rules prevent uncontrolled device interactions.

### Allow
- Supervisor → controllers  
- Controllers → supervisor  
- Gateways → supervisory platforms  
- Time sync (NTP) from OT NTP server  

### Block
- Controller ↔ controller  
- Gateway ↔ controller groups not related  
- Vendor VLAN ↔ controller VLAN  
- IT VLAN ↔ OT VLANs  

East–west controls drastically reduce the impact of misconfigured BACnet, rogue discovery packets, or malware.

---

# Firewall Policies by Protocol

## BACnet/IP (UDP/47808)

### Allow:
- Supervisor → controller UDP/47808  
- Controller → supervisor UDP/47808  

### Block:
- Controller ↔ controller  
- Controller ↔ unrelated controller VLANs  
- BACnet broadcasts northbound into IT  
- Vendor access to controller VLANs  

### If BBMD is required:
- Only permit BBMD traffic between specific VLANs  
- Do NOT enable BBMD on all controllers  
- Keep BACnet network numbers unique  

---

## Modbus TCP (TCP/502)

### Allow:
- Supervisor → device TCP/502  
- Gateway → device TCP/502  

### Block:
- External Modbus scanning tools  
- Direct Modbus access from IT  
- Vendor access without explicit permit  

### Modbus Firewalls Tips:
- Use stateful inspection  
- Limit frequency of permitted connections  
- Restrict source IPs aggressively  

---

## KNX/IP

### Allow:
- KNX tunnelling ports between ETS workstations and specific routers  
- KNX routing only inside KNX VLAN  

### Block:
- Multicast 224.0.23.12 across routed boundaries  
- KNX routing into IT networks  
- Vendor Wi-Fi clients interacting with KNX routers  

---

## OPC-UA

### Allow:
- OPC-UA client ↔ server communication (TCP/4840 or configured port)  
- Reverse proxy or DMZ-based connection brokers  

### Block:
- Wide-open access to OPC-UA servers  
- Deprecated security policies (None, Basic128Rc5, etc.)  

### Best Practices:
- Enforce TLS  
- Use certificate-based authentication  
- Apply role-based access control  

---

# ACL and Rule Templates (Text-Only Examples)

### BACnet/IP Example ACL
