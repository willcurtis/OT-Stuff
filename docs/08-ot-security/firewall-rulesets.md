# Firewall Rulesets  
**Baseline OT Firewall Policies, Per-Protocol Allow Lists, East–West Segmentation, DMZ Architecture, and Vendor Remote Access Rules**

This document defines standard firewall rulesets for OT/BMS networks.  
All rulesets follow the principles:

- **Default deny**  
- **Least privilege**  
- **Separation of duties**  
- **No broadcast or multicast across L3**  
- **Directionality enforced**  
- **Vendor accounts strictly controlled**  

---

# 1. Firewall Architecture Overview

OT environments generally have two main firewalls:

### 1.1 OT Core Firewall  
Between OT VLANs ↔ OT DMZ.

### 1.2 IT/OT Boundary Firewall  
Between OT DMZ ↔ IT network.

### Optional:
- Intra-OT firewall for high-security systems.

Basic architecture:

OT Networks → OT Firewall → OT DMZ → IT/OT Firewall → IT Network

# 2. Baseline Firewall Ruleset (OT ↔ OT, OT ↔ DMZ, DMZ ↔ IT)

### 2.1 OT Core Firewall (OT VLANs → DMZ)

| Source | Destination | Service | Action | Notes |
|--------|-------------|---------|--------|-------|
| OT VLANs | DMZ Supervisors | HTTP→HTTPS redirect | Allow | Enforce HTTPS only |
| OT VLANs | DMZ Supervisors | HTTPS | Allow | UI/API access |
| OT VLANs | BACnet/SC Hub | TCP 47808/TLS | Allow | Outbound only |
| OT VLANs | MQTT Broker (DMZ) | TCP 8883 | Allow | TLS only |
| OT VLANs | OPC-UA Aggregator | TCP 4840 | Allow | Cert-based authentication |
| DMZ | OT VLANs | Specific OT protocols only | Allow | Read-only unless required |
| Any | Any | Broadcast / multicast | Deny | Mandatory |

### 2.2 IT/OT Boundary Firewall (DMZ ↔ IT)

| Source | Destination | Service | Action |
|--------|-------------|---------|--------|
| IT Users | DMZ Supervisors | HTTPS | Allow |
| IT Analytics | MQTT Broker (DMZ) | MQTT/HTTPS | Allow (RO topics only) |
| IT | OT VLANs | Any | Deny |
| OT | IT | Any | Deny except required logging/auth |

---

# 3. OT Protocol Firewall Rulesets (Per Protocol)

---

# 3.1 BACnet/IP

BACnet/IP must not leak across OT boundaries.

### Allowed:
- Supervisor → Controllers: UDP 47808 (unicast only)
- Controller → Supervisor: UDP 47808 (unicast only)

### Deny:
- Any broadcast across VLANs  
- Any Who-Is / I-Am across buildings  
- BBMD registration except for explicit design  
- Foreign Device Registration  

### Example Rules:

Allow: DMZ Supervisor → OT_HVAC_VLAN: UDP/47808 (unicast)
Deny:  OT_HVAC_VLAN → ANY: UDP/47808 broadcast
Deny:  ANY → ANY: BACnet FDR (Foreign Device Registration)

---

# 3.2 BACnet/SC

### Allowed:
- Controllers → SC Hub: TLS/WebSocket (TCP 443 or 47808/TLS)
- Supervisors → SC Hub: TLS

### Deny:
- Any direct BACnet/IP broadcast  
- Any cross-building SC traffic unless allowed  

---

# 3.3 Modbus TCP

Modbus TCP requires strict write control.

### Allow:
- Supervisor → Gateway: TCP 502  
- Gateway → Supervisor: TCP 502  

### Deny:
- East–west Modbus  
- Writes from IT  
- Writes from untrusted DMZ apps  

Example:

Allow SUPERVISOR -> MODBUS_GW: TCP 502
Deny ANY -> MODBUS_GW: TCP 502 (except supervisors)

---

# 3.4 KNX IP

### Allow:
- Supervisor (DMZ) → KNX Router: Unicast only  
- Commissioning clients (jump host only) → KNX Router  

### Deny:
- Multicast routed across firewalls  
- KNX multicast leaving VLAN  

---

# 3.5 MQTT

### Allow:
- OT sensors → Broker: TCP 8883  
- Supervisor → Broker: Subscribe + Publish (TLS)  
- IT consumers → Broker (DMZ): Read-only  

### Deny:
- Anonymous connections  
- MQTT without TLS  
- OT VLANs direct to IT MQTT  

ACL example (broker-level):

iot/deviceA publish sensors/buildingA/deviceA/#
supervisorA subscribe sensors/buildingA/+/#
it-dashboard subscribe sensors/buildingA/+/# (RO)

---

# 3.6 OPC-UA

### Allow:
- OT Gateways → OPC Aggregator (DMZ): TCP 4840  
- IT Analytics → Aggregator: TCP 4840 or HTTPS  

### Deny:
- OT → IT direct OPC  
- IT → Controllers direct OPC  

---

# 3.7 DALI / DMX / Art-Net / sACN

These belong inside isolated lighting VLANs.

### Allow:
- Lighting controller → DMX nodes: UDP 6454 (Art-Net)  
- Lighting controller → Fixtures: UDP 5568 (sACN)  

### Deny:
- Any L3 multicast routing  
- Any Art-Net broadcast crossing VLANs  

---

# 3.8 IoT Wireless Gateways (LoRaWAN, Zigbee, Thread)

Typical firewall rules:

Allow: Gateway → DMZ MQTT Broker (TCP 8883)
Allow: Gateway → Network Server (DMZ)
Deny: Gateway → Internet (unless required)
Deny: IoT devices → OT VLANs

---

# 4. East–West OT Segmentation Rulesets

Controllers must only talk to supervisors, never to each other.

### Example Rules:

HVAC_VLAN -> SUPERVISOR: Allow (BACnet/SC, HTTPS)
HVAC_VLAN -> LIGHTING_VLAN: Deny
HVAC_VLAN -> ENERGY_VLAN: Deny
LIGHTING_VLAN -> SUPERVISOR: Allow
LIGHTING_VLAN -> ANY_OTHER: Deny

### Principle:
**Every system gets read/write only to its supervisor.**

---

# 5. DMZ Firewall Rules (Inside the DMZ)

Supervisors, brokers, and APIs communicate internally.

### Allow:
- Supervisor ↔ BACnet/SC Hub  
- Supervisor ↔ OPC-UA Aggregator  
- MQTT Broker ↔ Analytics  
- Reverse Proxy ↔ Supervisor  

### Deny:
- East–west DMZ device intercommunication unless explicitly required  

Example:

Deny: DMZ_Server1 → DMZ_Server2 (any) unless rule exists

---

# 6. Remote Access Firewall Rules

### Access Path:

Vendor → VPN → IT Firewall → DMZ Jump Host → OT Firewall → OT VLAN

### Rules:

#### IT Firewall

Allow: VPN_POOL → DMZ_JUMP_HOST: RDP/SSH/HTTPS
Deny: VPN_POOL → OT Networks

#### OT Firewall

Allow: DMZ_JUMP_HOST → Specific OT Controller/Gateway (Temporary)
Deny: DMZ_JUMP_HOST → ANY_OTHER

Temporary rules expire automatically.

---

# 7. Logging Firewall Rule

Mandatory rule:

Log all denied traffic
Log all remote access sessions
Log BACnet/SC authentication failures
Log Modbus writes
Log KNX tunnelling sessions
Log MQTT anomalous connections

OT security depends on visibility.

---

# 8. Firewall Object Groups (Template)

### Network Objects

OBJ_OT_HVAC_VLAN
OBJ_OT_LIGHTING_VLAN
OBJ_OT_ENERGY_VLAN
OBJ_OT_DALI_VLAN
OBJ_SUPERVISORS
OBJ_BACNET_SC_HUB
OBJ_MQTT_BROKER
OBJ_OPC_AGGREGATOR
OBJ_JUMP_HOST
OBJ_IT_ANALYTICS

### Service Objects

SRV_BACNET_UDP_47808
SRV_BACNET_SC_TLS
SRV_MODBUS_502
SRV_MQTT_TLS_8883
SRV_OPCUA_4840
SRV_SACN_5568
SRV_ARTNET_6454

---

# 9. Example Rulesets (Vendor Syntax)

## 9.1 FortiGate Example

```bash
config firewall policy
    edit 1
        set name "HVAC_to_Supervisor"
        set srcintf "HVAC_VLAN"
        set dstintf "DMZ"
        set srcaddr "OBJ_OT_HVAC_VLAN"
        set dstaddr "OBJ_SUPERVISORS"
        set action accept
        set schedule always
        set service "SRV_BACNET_SC_TLS"
        set logtraffic all
    next

    edit 2
        set name "Block_BACnet_Broadcast"
        set srcintf "HVAC_VLAN"
        set dstintf "any"
        set srcaddr "OBJ_OT_HVAC_VLAN"
        set dstaddr "all"
        set action deny
        set service "SRV_BACNET_UDP_47808"
        set logtraffic all
    next
end

## 9.2 Palo Alto Example

set rulebase security rules HVAC-to-Supervisor from HVAC_VLAN to DMZ \
    source OBJ_OT_HVAC_VLAN destination OBJ_SUPERVISORS \
    application bacnet-sc service application-default action allow log-start yes

set rulebase security rules Block-BACnet-Broadcast from HVAC_VLAN to any \
    source OBJ_OT_HVAC_VLAN destination any \
    application bacnet-ip action deny log-end yes

# 10. Golden Rules for OT Firewalling

Always:
	•	Default deny
	•	No broadcast or multicast routed
	•	No OT ↔ IT direct paths
	•	Supervisors only talk to OT
	•	Use object groups
	•	Log everything denied

Never:
	•	Permit BACnet broadcast across buildings
	•	Allow Modbus from IT
	•	Allow vendor VPNs directly into OT
	•	Permit cloud backdoors unless tightly controlled
	•	Route lighting multicast

# 11. Implementation Checklist

OT Firewall
	•	Broadcast filter rules configured
	•	Multicast limits enforced
	•	Per-system VLAN ACLs
	•	DMZ-only supervisory access

IT/OT Firewall
	•	No direct OT exposure
	•	Only HTTPS from IT
	•	Logging enabled

Remote Access
	•	Jump host only
	•	Vendor accounts expire
	•	Temporary firewall rules

# Summary

These firewall rulesets enforce the OT security architecture defined across the manual.
Correct firewalling ensures:
	•	Protocol containment
	•	Zero-trust access
	•	Supervisory-only control paths
	•	No broadcast or multicast leakage
	•	Strong boundaries between OT, DMZ, and IT

Firewalls are the most important enforcement point in OT networks—and these rulesets form the baseline for secure operation.
