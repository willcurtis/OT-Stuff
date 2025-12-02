# MQTT Deep Dive  
**MQTT 3.1.1 & MQTT 5 – Topics, QoS, Retained Messages, Brokers, TLS Security, Sparkplug B, OT/BMS Deployment**

MQTT (Message Queuing Telemetry Transport) is a lightweight publish/subscribe protocol widely used in IoT, smart buildings, and sensor networks.  
In modern OT/BMS infrastructure, MQTT is increasingly used for:

- IoT sensors (CO₂, occupancy, temperature)  
- Wireless energy meters  
- Room-level telemetry  
- Integration between cloud and local systems  
- Smart-building analytics  
- Digital twins  
- Vendor API interfaces  

This chapter covers MQTT from protocol behaviour to secure deployment and BMS-specific design considerations.

---

# 1. MQTT Architecture Overview

MQTT follows a **publish/subscribe model** with three components:

### **Publishers**
Send telemetry to the broker:

topic: building/floor1/temp
payload: 21.7

### **Subscribers**
Receive messages based on topic filters:

building/floor1/#

### **Broker**
Central server responsible for:
- Distributing messages  
- Managing subscriptions  
- Authentication & authorisation  
- Retained message storage  
- Session state  

Common brokers:
- Mosquitto  
- HiveMQ  
- EMQX  
- VerneMQ  
- AWS IoT Core  
- Azure IoT Hub  

MQTT is extremely lightweight: headers are tiny, messages minimal.

---

# 2. MQTT Topics & Wildcards

Topics are hierarchical:

building/AHU/01/supply_temp
building/AHU/01/status
building/office/floor2/occupancy

### Rules:
- Topics are case-sensitive  
- There is no concept of "metadata" — semantics are naming conventions  
- Wildcards are allowed for subscriptions, not for publishing

### Two wildcards:

#### 2.1 Single-level: `+`
Matches one level:

building/+/temp

#### 2.2 Multi-level: `#`
Matches all downstream levels:

building/#

---

# 3. QoS Levels

MQTT defines three Quality of Service levels:

| QoS | Guarantee | Notes |
|------|-----------|--------|
| **0** | At most once | Fastest, no retries |
| **1** | At least once | May duplicate messages |
| **2** | Exactly once | Expensive, rarely needed |

### When to use each in OT:
- **QoS 0** – For high-frequency, non-critical telemetry (occupancy, live state)  
- **QoS 1** – Most OT/BMS telemetry (temperatures, energy, CO₂)  
- **QoS 2** – Billing, critical alarms (almost never used due to overhead)  

---

# 4. Retained Messages

MQTT supports **retained messages**:

- Broker stores the last retained message per topic  
- New subscribers immediately receive the retained value  
- Useful for current state (temperature, device status)

**Danger:**  
Retained messages can deliver stale data if not managed properly.

---

# 5. MQTT Sessions & Clean Start

Clients connect to brokers with:

### MQTT 3.1.1:
- `cleanSession = false` → persistent session  
- Tracks unreceived QoS1/QoS2 messages

### MQTT 5:
- `cleanStart` replaces `cleanSession`  
- Session expiry controls when state is removed  

---

# 6. MQTT Broker Architecture

Brokers handle:

- Session state  
- Topic routing  
- Authentication  
- Authorisation (ACLs)  
- TLS termination  
- Load balancing & clustering  
- Retained message storage  

### Cluster scaling:
- EMQX & HiveMQ scale horizontally  
- Mosquitto is single-node unless wrapped with a load balancer  
- Persistent storage often uses RocksDB or internal DB engines  

---

# 7. MQTT Security

MQTT itself has **no encryption** or **authentication**.  
Security depends entirely on broker configuration.

### 7.1 TLS Encryption
- Mandatory for OT/BMS  
- Use TLS 1.2 or TLS 1.3  
- Server-side certificates required  
- Optional client certificates  

### 7.2 Authentication Methods
- Username & password  
- Client certificates (mTLS)  
- Token-based authentication  
- OAuth2/OpenID Connect (HiveMQ, EMQX)

### 7.3 Authorization — ACL Examples

Allow a device to publish its own data:

user device123
topic write building/device123/#
topic read  building/commands/device123/#

OT rule: **never allow wildcard publish** permissions.

---

# 8. MQTT Sparkplug B

Sparkplug B is a standard for industrial MQTT interoperability.

### Benefits:
- Defines metric structures  
- Ensures consistent payloads  
- Standardizes birth/death messages (NBIRTH/NDEATH)  
- Includes edge node/cell topology  
- Reduces vendor-specific formats  

### Sparkplug B Payload Example:

{
“timestamp”: 1700000000,
“metrics”: [
{ “name”: “temp”, “value”: 21.7, “type”: “float” },
{ “name”: “status”, “value”: “ok”, “type”: “string” }
]
}

Sparkplug improves reliability for SCADA/BMS streaming.

---

# 9. MQTT in OT/BMS Architectures

MQTT is used for:

- IoT sensors  
- Wireless room control  
- Smart metering  
- Multi-building telemetry consolidation  
- Data lakes & analytics  
- Digital twin ingestion  
- Cross-vendor integration  

MQTT is **not** a replacement for:
- BACnet control  
- KNX lighting control  
- Modbus for plant equipment  

It supplements rather than replaces core control protocols.

---

# 10. BMS Integration Patterns

## 10.1 MQTT → BACnet / OPC-UA Gateway
Common when receiving IoT sensor data.

- MQTT subscriber → processes payload → exposes BACnet/OPC variables  
- Use for CO₂, occupancy, environmental metrics  

## 10.2 BACnet / Modbus → MQTT
Publishers push OT data to analytics systems or cloud.

Example:

topic: building/AHU/01/supply_temp
payload: 17.3

## 10.3 MQTT for Demand-Control Ventilation
Occupancy sensors publish:

building/floor2/meetingroom1/occupancy = 1

AHU adjusts ventilation rate.

---

# 11. Topic Namespace Design

A structured naming scheme prevents chaos.

### Recommended Structure:

////

Example:

campus1/library/hvac/ahu01/supply_temp
campus1/library/lighting/corridor01/scene
campus1/accommodation/blockA/room203/co2

### Avoid:
- Deep nesting beyond 6–7 levels  
- Vendor-chosen random topic names  
- Mixed naming conventions  

---

# 12. MQTT Performance Considerations

### 12.1 Message Size
MQTT is optimized for small payloads (<1 KB).  
Larger messages should use chunking or binary compression.

### 12.2 Broker Load
High-frequency publishers can overwhelm brokers.

### 12.3 QoS1 Delivery Guarantees
QoS1 duplicates must be handled by subscriber logic.

### 12.4 Retained Message Storage
Large retained datasets can impact startup time.

---

# 13. Troubleshooting MQTT

## 13.1 Common Issues

| Issue | Likely Cause |
|-------|--------------|
| No messages | Wrong topic or wildcard mismatch |
| Duplicate messages | QoS1 redelivery |
| Stale values | Retained message older than expected |
| Connection drops | TLS misconfig, keepalive interval too low |
| Slow performance | Broker overload or wildcard subs too broad |

## 13.2 Tools
- MQTT Explorer  
- MQTTLens  
- mosquitto_sub / mosquitto_pub  
- HiveMQ Web Dashboard  
- EMQX Dashboard  
- Wireshark (mqtt dissector)  

---

# 14. Deployment Patterns by Building Type

## 14.1 Offices
- IoT sensors for occupancy  
- Environmental analytics  
- Desk booking systems  
- MQTT → BACnet for HVAC adjustment  

## 14.2 Hospitality
- Room telemetry  
- Occupancy-driven HVAC  
- Smart locks (with caution)  

## 14.3 Education Campus
- Distributed IoT networks  
- Smart classrooms  
- Energy dashboards  

## 14.4 Retail
- Footfall & occupancy sensors  
- Temperature monitoring for food storage  
- Cloud analytics  

## 14.5 Industrial
- Sparkplug B edge nodes  
- SCADA streaming  
- Predictive maintenance  

## 14.6 Mixed-Use Buildings
- Unified data layer across residential/office/retail  
- IoT-based energy optimisation  

---

# 15. MQTT Implementation Checklist

### Security
- [ ] TLS enabled  
- [ ] Client authentication enforced  
- [ ] ACLs restrict publish & subscribe rights  
- [ ] No anonymous clients  

### Architecture
- [ ] VLAN isolation for broker  
- [ ] Edge gateways per building or zone  
- [ ] Topic namespace standardised  

### Performance
- [ ] QoS tuned per metric  
- [ ] Retained messages reviewed  
- [ ] Broker monitored (CPU/memory/persistence)  

### Integration
- [ ] Gateways validated for payload formats  
- [ ] MQTT → BACnet/OPC-UA mapping documented  
- [ ] Avoid uncontrolled cloud integrations  

---

# Summary

MQTT is a lightweight, scalable, and secure-by-design messaging protocol ideal for IoT and smart-building telemetry.  
It complements, rather than replaces, core OT protocols like BACnet, KNX, Modbus, and LON.

Key principles:

- Use TLS and strict ACLs  
- Structure topic namespaces clearly  
- Avoid wildcard overuse  
- Use QoS1 for most telemetry  
- Deploy brokers in isolated OT VLANs  
- Use Sparkplug B for strong interoperability  
- Integrate MQTT into BMS/analytics carefully  

MQTT enables a robust, modern data pipeline for digital buildings and campuses.
