# Firewall & Security Zoning  
**OT Firewalls, Security Zones, Vendor Access, BACnet/SC, Micro-Segmentation, DMZ Design, Remote Access Controls**

Modern OT networks require strict segmentation and deterministic traffic patterns.  
Firewalls enforce trust boundaries and prevent lateral movement between systems, floors, buildings, and corporate networks.

This chapter defines:

- OT security zones  
- Firewall placement  
- OT DMZ architecture  
- Micro-segmentation patterns  
- Vendor remote access  
- BACnet/SC hub design  
- Secure protocol handling  
- OT logging & SIEM integration  
- Recommended firewall rulesets  

---

# 1. OT Security Model Overview

OT uses a tiered zoning model inspired by industrial ISA/IEC 62443 security.

Zone 0 – Field Devices (sensors, actuators)
Zone 1 – Controllers & Gateways
Zone 2 – Building Systems (HVAC, lighting, lifts, metering)
Zone 3 – OT Core Switching
Zone 4 – OT DMZ (Firewalls, jump hosts, servers)
Zone 5 – IT / Corporate

### Key principle:
**Traffic must only flow between zones through firewalls, never directly.**

---

# 2. Firewall Placement in OT Architectures

### 2.1 Core ↔ OT DMZ Firewall (Mandatory)
Separates:
- OT VLANs  
- OT servers  
- Supervisors  
- Historian  
- MQTT brokers  
- OPC-UA servers  

### 2.2 OT DMZ ↔ IT Firewall (Mandatory)
Strict boundary between:
- IT corporate network  
- OT DMZ  
- Cloud services  

### 2.3 Optional: Intra-OT Firewalls
Used when:
- High-security zones (e.g., critical plant rooms)  
- Lift/fire interface isolation  
- Fire system segregation  

---

# 3. OT DMZ Architecture

The OT DMZ hosts services that sit between IT and OT.

### 3.1 Typical Components:
- BMS/SCADA supervisors  
- Database servers (SQL, InfluxDB, TimescaleDB)  
- Application servers  
- Patch management servers  
- Logging/SIEM collectors  
- BACnet/SC hub  
- MQTT broker (OT only)  
- OPC-UA aggregator  
- Reverse-proxy/API layer  
- Authentication services (LDAP proxy, RADIUS)  
- Remote access jump hosts  

### 3.2 Governance Rules:
- No direct field-level writes from IT  
- No L2 adjacency between OT and IT  
- No shared management between OT and IT  

---

# 4. Firewall Rulesets (by Protocol)

Below are recommended patterns.

---

## 4.1 BACnet

### OT VLAN → DMZ BACnet/SC Hub  

Allow UDP/47808 (BACnet) only between specific controllers and SC hub
Deny broadcasts beyond building VLAN
No BBMD across buildings

### DMZ → OT Systems (if needed)

Allow UDP/47808 to specific target controllers only
Deny any broadcast traffic

### IT → DMZ

Allow HTTPS only to BMS UI (read-only ideally)

---

## 4.2 Modbus TCP

Allow TCP/502 only from supervisors to gateways
Deny any OT → OT Modbus (east-west)
Deny IT → OT direct Modbus

---

## 4.3 KNX IP (Multicast)

Block multicast traffic from crossing firewall
Allow KNX tunnelling TCP connections only

---

## 4.4 MQTT
DMZ-hosted broker recommended.

OT → DMZ: Allow MQTT/TLS on 8883
DMZ → IT: Read-only MQTT bridges if required
IT → DMZ: Read-only dashboards only

ACLs at broker enforce zero-trust publisher/subscriber rules.

---

## 4.5 OPC-UA

OT → DMZ: Allow TCP/4840 (OPC-UA) to aggregator
DMZ → IT: Allow HTTPS or OPC-UA to analytics
Deny OT → IT direct OPC-UA

---

## 4.6 Lighting Protocols
Art-Net, sACN, DMX gateways must **never** cross firewalls as multicast is not suitable for routed domains.

Block: UDP/6454 (Art-Net)
Block: UDP 5568 (sACN)
Only allow unicast management connections

---

# 5. East–West Segmentation (within OT)

Even within OT, systems must not trust each other.

### Example segmentation:

HVAC VLAN → Supervisor only
Lighting VLAN → Supervisor only
Energy Meter VLAN → Supervisor only

Inter-system communication must be:
- Through the supervisor  
- Or through an OT data bus in the DMZ  

Direct controller-to-controller access across systems is forbidden.

---

# 6. Micro-Segmentation Strategy

Micro-segmentation limits lateral movement.

### 6.1 At VLAN Level:
One VLAN per system per building:

Building A HVAC
Building A Lighting
Building A DALI Gateways
Building A VRF/VRV

### 6.2 At Firewall Level:
- Supervisors allowed minimal access  
- Controllers only allowed northbound read/write  

### 6.3 At Host Level:
- Linux/Windows hosts have host-based firewalls  
- Only specific ports opened  

### 6.4 At Application Level:
- MQTT ACLs  
- OPC-UA node access control  
- BACnet/SC certificates  

---

# 7. Vendor Remote Access

Remote access is one of the highest-risk OT activities.

### 7.1 Allowed Architecture:

Vendor → VPN → IT Firewall → OT DMZ Jump Host → Target OT System

### 7.2 Controls:
- MFA required  
- Jump host screen recording optional  
- No vendor accounts on OT devices  
- Time-boxed access  
- Activity logs stored in SIEM  

### 7.3 Strictly Prohibited:
- Vendor VPN directly to OT core  
- Direct access to controllers  
- Cloud tunnels that bypass firewalls  

---

# 8. BACnet/SC (Secure Connect) in the OT DMZ

BACnet/SC replaces classic BACnet broadcast with TLS-secured WebSockets.

### Architecture:
- BACnet/SC Hub lives in DMZ  
- Controllers establish outbound TLS connections  
- IT systems connect to hub for read-only  

### Benefits:
- No more BBMDs  
- No broadcast storms  
- Easier multi-building deployments  
- Secure certificate-based authentication  

### Rules:
- Hubs must not be reachable from Internet  
- Controllers must initiate outbound connections only  
- Use CA with short-lived certificates  

---

# 9. Firewall High Availability (HA)

### 9.1 Options:
- Active/Passive  
- Active/Active (rare for OT)  
- VRRP between pairs  

### 9.2 Required Characteristics:
- Deterministic failover  
- No session loss for building automation protocols  
- State table synchronisation  
- Consistent logs across HA nodes  

### 9.3 Avoid:
- Complex application-layer firewalls in OT core path  
- NAT unless required for DMZ  
- SSL inspection of OT control protocols  

---

# 10. Logging, Monitoring, and SIEM Integration

OT needs full visibility of firewall behaviour.

### Log:
- All denied traffic  
- All vendor access sessions  
- All admin actions  
- All VPN connections  
- All protocol anomalies  
- BACnet broadcast rate alerts  
- DHCP rogue alerts  

### Telemetry to SIEM:
- Firewall logs  
- NetFlow/sFlow from core  
- BACnet/SC connection status  
- MQTT broker logs  

### SIEM Use Cases:
- Detect lateral movement  
- Detect brute-force login attempts  
- Detect BACnet anomalies  
- Detect sudden increase in KNX multicast  

---

# 11. Example OT Zoning Diagram

           +-----------------------+
           |        IT Network     |
           +----------+------------+
                      |
              IT Firewall
                      |
           +----------+------------+
           |          OT DMZ       |
           | (Supervisors / APIs)  |
           +---+--------------+----+
               |              |
    OT DMZ FW  |              | Vendor VPN FW
               |              |
    +----------+--------------+---------+
    |           OT Core Switching       |
    +----------+--------------+---------+
               |              |
            Dist A         Dist B
               |              |
             Floors         Floors
               |              |
           Controllers → Field Devices

---

# 12. Implementation Checklist

### Architecture  
- [ ] OT DMZ deployed  
- [ ] Firewalls between OT ↔ DMZ and DMZ ↔ IT  
- [ ] No L2 extension across firewalls  
- [ ] Strictly routed boundaries  

### Security  
- [ ] Zero-trust vendor access  
- [ ] No direct OT-facing VPN  
- [ ] TLS on all DMZ services  
- [ ] Secure key management for BACnet/SC  

### Protocol Containment  
- [ ] BACnet/IP restricted to building VLANs  
- [ ] KNX multicast blocked at firewall  
- [ ] Modbus TCP only northbound from supervisor  
- [ ] Lighting protocols not routed  

### Monitoring  
- [ ] SIEM integration  
- [ ] Firewall denials logged  
- [ ] Vendor access recorded  
- [ ] BACnet/SC status monitored  

---

# Summary

Firewalls and zoning form the security backbone of modern OT networks.  
They isolate systems, stop broadcast-heavy protocols, enforce strict access rules, and form the boundary between OT, DMZ, and IT.

Key principles:
- Zero-trust east–west and north–south segmentation  
- OT DMZ as the neutral integration plane  
- No L2 between buildings or across firewalls  
- No vendor VPNs directly into OT  
- Use BACnet/SC, MQTT/TLS, OPC-UA for secure integration  
- Full SIEM visibility across all boundary devices  

A robust zoning architecture protects the building for decades and reduces operational risk dramatically.
