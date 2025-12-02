# Access Layer Architecture  
**Switching, Power, Fieldbus Integration, Port Profiles, Cabinet Design, Physical Security**

The Access Layer is where the OT network touches the field.  
It connects:
- HVAC controllers  
- Lighting gateways  
- DALI/DMX interfaces  
- Modbus TCP gateways  
- VRF/VRV units  
- Sensors (IoT, KNX-IP, BACnet/IP)  
- IP relays & digital IO modules  
- Lift controllers  
- Fire alarm/BMS integration points (via firewalls)  
- UPS, meters, and utility devices  

This layer must be engineered for stability, predictable behaviour, and long-term maintainability.

---

# 1. Access Layer Design Principles

### 1.1 Predictability
All ports must behave deterministically with strict access policies.

### 1.2 Containment
Limit the blast radius of protocol storms (BACnet, KNX multicast, Art-Net, etc.).

### 1.3 Physical Security
Riser cabinets and plant-room cabinets must be secure.

### 1.4 Environmental Hardening  
OT switches operate in hot, dusty, electrically noisy environments.

### 1.5 Power Resilience
Switches must survive power events and run from UPS-backed circuits.

### 1.6 Simplicity  
No dynamic behaviour unless required. Static VLAN assignment. No dynamic routing at access.

---

# 2. Access Layer Switch Requirements

### 2.1 Essential Features
- Gigabit interfaces minimum  
- Fanless (if in quiet/office risers)  
- Industrial temperature rating for plant rooms  
- PoE/PoE+ as needed  
- Deep packet buffers  
- Storm-control (broadcast, multicast, unknown-unicast)  
- DHCP snooping  
- BPDU Guard  
- Root Guard  
- Port security  
- IGMP snooping  

### 2.2 Hardware Form-Factors
- 8–24 port for risers  
- 24–48 port for plant rooms  
- DIN-rail switches for tight mechanical spaces  
- Hardened IP-rated switches outdoors  

---

# 3. Power, UPS & Resilience

### 3.1 UPS Backing
Every access switch **must** be powered from a UPS.

Load calculation example:

24-port switch: 45–60 W typical
PoE load: up to 370 W (if full PoE+)
UPS recommended: 750–1500 VA

### 3.2 Dual Power Feeds (Industrial Switches)
Some industrial switches accept dual DC inputs (redundant feeds).

### 3.3 Surge Protection
Protect field cabling entering risers.

### 3.4 Environmental Monitoring
Cabinet should include:
- Temperature sensor  
- Humidity sensor  
- Door contact sensor  

Telemetry fed to OT monitoring system.

---

# 4. Cabinet, Riser & Plant Room Design

### 4.1 Cabinet Layout

+—————————————–+
| PATCH PANEL (40–50% spare)              |
| OT SWITCH                               |
| Fieldbus gateways (Modbus/BACnet/DALI)  |
| DIN-rail PSU + fusing                   |
| Cable management bar                    |
| UPS (rack or tower)                     |
+—————————————–+

### 4.2 Separation of Responsibilities
Fire systems, access control, CCTV **must not** share cabinets with OT unless segregated.

### 4.3 Physical Security
- Keyed access  
- CCTV coverage of riser rooms  
- Tamper alarms on critical risers  

### 4.4 Labeling Standards
Mandatory:
- Cabinet ID  
- Switch hostname  
- Port mapping chart  
- VLAN mapping  
- Patch panel labels matching port numbers  
- Asset tag  

---

# 5. Port Profiles (Templates)

Port profiles ensure consistent configuration across switches.  
Below are recommended templates.

## 5.1 BACnet/IP Controller Port

switchport mode access
switchport access vlan <BACNET_VLAN>
storm-control broadcast level 1
storm-control multicast level 1
storm-control action shutdown
spanning-tree bpduguard enable
ip dhcp snooping limit rate 5

## 5.2 KNX-IP Router / Gateway Port

switchport mode access
switchport access vlan <KNX_VLAN>
storm-control multicast level 0.5
igmp snooping enable
bpduguard enable

## 5.3 Modbus TCP Gateway Port

switchport mode access
switchport access vlan <MODBUS_VLAN>
storm-control broadcast level 1
bpduguard enable
ip dhcp snooping trust  (only if gateway is DHCP forwarder)

## 5.4 DALI Gateway Port

switchport mode access
switchport access vlan <DALI_VLAN>
storm-control broadcast level 1
bpduguard enable

## 5.5 DMX/Art-Net/sACN Node Port

switchport mode access
switchport access vlan <LIGHTING_VLAN>
igmp snooping enable
storm-control multicast level 0.5
bpduguard enable

## 5.6 VRF/VRV HVAC Gateway

switchport mode access
switchport access vlan <VRF_VLAN>
storm-control broadcast level 1
bpduguard enable

## 5.7 IoT Sensor Hub (MQTT)

switchport mode access
switchport access vlan <IOT_VLAN>
storm-control broadcast level 1
ip dhcp snooping limit rate 3
bpduguard enable

## 5.8 OT Server / BMS Supervisor (Access Layer)

switchport mode access
switchport access vlan <SUPERVISOR_VLAN>
storm-control broadcast level 1
bpduguard disable (if server NIC uses LLDP)
lldp transmit
lldp receive

## 5.9 Uplinks to Distribution Switches

switchport trunk allowed vlan <ONLY_OT_VLANS>
spanning-tree portfast trunk disable
spanning-tree guard root
storm-control NONE

---

# 6. Device Onboarding & Addressing

### 6.1 Static IP-Only  
No DHCP on BACnet, KNX, DALI, Modbus, or VRF VLANs unless required by vendor.

### 6.2 Naming Scheme

--<device_type>-

Example:

B1-HVAC-AHU-01
B1-LGT-GW-03

### 6.3 Documentation Required:
- Port utilisation per cabinet  
- Device IP and MAC table  
- VLAN and subnet mapping  
- Field device count per system  

---

# 7. Controlling Protocol Storms

### 7.1 BACnet/IP
- Use storm-control  
- Keep VLAN local to building  
- Prevent BBMD misuse  

### 7.2 KNX Multicast
- IGMP snooping  
- Limit VLAN to single floor/zone  
- No routing without KNX Secure  

### 7.3 Lighting (sACN/Art-Net)
- Strong VLAN containment  
- IGMP querier mandatory  
- Rate limit where possible  

### 7.4 IoT Device Storms
- Rogue DHCP  
- Excessive broadcasting  
- MDNS/SSDP floods  
- Apply ACLs to strip unnecessary service discovery  

---

# 8. Security Controls

### 8.1 Port Security
- Sticky MAC for critical devices  
- Single MAC per port on controller ports  
- Violation mode: shutdown  

### 8.2 NAC (Optional)
Rare in OT; use only for:
- OT staff laptops  
- Admin stations  
- Remote engineering PCs  

### 8.3 Control Which Protocols Transit Access Layer
ACL examples:

#### Deny mDNS/SSDP:

deny udp any any eq 5353
deny udp any any eq 1900

#### Deny IPv6 if not used:

deny ipv6 any any

#### Deny inter-VLAN access:

permit ip <VLAN_SUBNET> host 
deny ip <VLAN_SUBNET> any

---

# 9. Environmental Considerations

### 9.1 Heat
Plant rooms exceed 40°C — industrial-grade switches preferred.

### 9.2 Vibration
Mechanical rooms require ruggedised DIN rail models.

### 9.3 Dust/dirt
Enclosures with air filters or sealed industrial housings recommended.

### 9.4 EMI
HVAC inverters, VRF outdoor units, and VSDs generate EMI.

Mitigation:
- Shielded cabling  
- Avoid long parallel runs  
- Maintain separation from power conduits  

---

# 10. Monitoring & Logging at Access Layer

Monitor:
- Port up/down  
- Port errors (CRC, collisions)  
- Broadcast/multicast levels  
- MAC flapping  
- Device offline events  
- LLDP neighbour changes  

Log all:
- Port shutdown events (BPDU guard, storm-control)  
- MAC violations  
- DHCP snooping alerts  

---

# 11. Example Access Layer Blueprint

+––––––––––––––––––––––––––+
| RISER CABINET (Level 3)                            |
|                                                    |
| Patch Panel (CAT6A)                                |
|                                                    |
| 24-port OT Switch (Fanless, UPS-backed)            |
|   - VLAN 110 (HVAC Controllers)                    |
|   - VLAN 120 (KNX IP Routers)                      |
|   - VLAN 130 (DALI Gateways)                       |
|   - VLAN 140 (Modbus TCP Gateways)                 |
|   - VLAN 150 (Lighting IP)                         |
|                                                    |
| DIN Rail PSU                                       |
| DALI/DMX Gateway                                   |
| Modbus Gateway                                     |
| VRF Controller                                     |
| UPS (750–1500 VA)                                  |
|                                                    |
+––––––––––––––––––––––––––+

---

# 12. Implementation Checklist

### Switch Configuration
- [ ] Port profiles applied  
- [ ] Storm-control active  
- [ ] BPDU guard ON  
- [ ] DHCP snooping enabled  
- [ ] LLDP configured where needed  

### Cabinet
- [ ] UPS installed  
- [ ] Temperature/humidity sensors  
- [ ] Clear labelling  
- [ ] Secure enclosure  

### Protocol Containment
- [ ] BACnet confined  
- [ ] KNX multicast contained  
- [ ] Art-Net/sACN restricted  
- [ ] Modbus gateways isolated  

### Security
- [ ] No unauthorised Wi-Fi IoT  
- [ ] Port security enforced  
- [ ] Firewall rules validated  

---

# Summary

The access layer is where OT networking meets real-world building systems.  
It must be secure, resilient, predictable, and tightly controlled.

Key principles:
- UPS-backed switches  
- VLAN per system  
- Strong storm-control  
- Strict port profiles  
- Physical security of risers  
- Minimal tolerance for misbehaving devices  

A well-built access layer is the foundation for a stable OT environment.
