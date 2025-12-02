# OPC-UA Deep Dive  
**OPC Unified Architecture – Architecture, Security, Address Space, Subscriptions, PubSub, Deployment**

OPC-UA (OPC Unified Architecture) is the most secure, flexible, and modern protocol used in industrial automation and increasingly in advanced BMS/OT deployments.  
Unlike BACnet and Modbus, OPC-UA provides:

- Object-oriented modelling  
- Rich metadata  
- Encrypted communication  
- Authentication  
- Subscriptions & eventing  
- Platform independence  
- Scalable architectures suitable for factories, campuses, and large BMS deployments  

This chapter is a full reference for designing, integrating, and operating OPC-UA in OT/BMS environments.

---

# 1. OPC-UA Architecture Overview

OPC-UA is built on four major components:

### 1. Information Model
Defines objects, variables, methods, data types, and relationships.

### 2. Address Space
Structured browsing model for interacting with server-exposed data.

### 3. Services
Standardized operations:
- Read / Write  
- Browse  
- Call (method invocation)  
- Subscribe (monitored items)  
- Query  
- RegisterNodes  

### 4. Transport & Security Stack
- UA-TCP (binary)  
- HTTPS / WebSockets  
- OPC-UA PubSub (MQTT/UDP)  
- X.509 certificate security  

OPC-UA supports both client/server and publish/subscribe patterns.

---

# 2. OPC-UA Information Model

OPC-UA is **object-oriented**, unlike Modbus or BACnet.

Objects include:
- Variables (analog/digital)  
- Methods (callable functions)  
- Events  
- Folders  
- ObjectTypes  
- DataTypes (scalar, structured, arrayed)

Example:

Objects
├─ Building
│   ├─ HVAC
│   │   ├─ AHU1
│   │   │   ├─ SupplyTemp (Variable)
│   │   │   ├─ FanStatus (Variable)
│   │   │   └─ StartFan() (Method)
│   └─ Metering
│       └─ Electricity
│           └─ kWh (Variable)

OPC-UA models can represent far more complex systems than BACnet's object model.

---

# 3. Node Identifiers (NodeIds)

Every address space element has a **NodeId** consisting of:

Examples:
- `ns=2;i=1001` (numeric ID)  
- `ns=3;s=SupplyTemp` (string ID)  
- `ns=4;g=GUID-here` (GUID ID)  

The **namespace index** separates vendor-defined model extensions from standard OPC-UA types.

### Common issue:
Clients assume namespace indices are fixed — **they are not**.  
Indices may change after server restart unless the server pins them.

---

# 4. OPC-UA Services Explained

Key OPC-UA services include:

### 4.1 Read / Write
Read or write data values or attributes.

### 4.2 Browse
Navigate the address space like a tree.

### 4.3 Call
Invoke a method on an object.

### 4.4 Subscribe / Monitored Items
Receive updates at a specified sampling interval and publishing interval.

### 4.5 Query
Structured SQL-like query over address space (rarely implemented).

### 4.6 RegisterNodes
Optimisation mechanism for repeated access.

---

# 5. Subscriptions & Monitored Items

Subscriptions allow clients to receive updates without polling.

A subscription consists of:
- **Monitored Items** (variables or events)
- **Sampling Interval** (e.g., 1000 ms)
- **Publishing Interval** (e.g., 2000 ms)
- **Queue Size**
- **Deadband** (percentage or absolute)

### Example:
Monitor `SupplyTemp` with:
- Sampling interval: 1 second  
- Deadband: 0.5 °C  
- Publishing interval: 5 seconds  

### Common Failures:
- Too many monitored items overwhelms controller  
- Sampling interval too fast  
- Client disconnects leaving ghost subscriptions  
- Server does not implement queue properly  

OPC-UA requires tuning just like BACnet COV.

---

# 6. OPC-UA Transport Layers

OPC-UA supports multiple transports:

### 6.1 UA-TCP (opc.tcp://)
- Binary protocol  
- Fastest  
- Most common in industrial automation  
- Requires direct TCP connectivity

### 6.2 HTTPS (https://)
- Higher latency  
- Proxies/firewalls friendly  
- Uses standard TLS certificates  

### 6.3 WebSockets (opc.ws:// / wss://)
- Useful for cloud and browser-based clients  
- Supported by OPC-UA WebSocket gateways  

### 6.4 OPC-UA PubSub
A next-generation transport for high-scale systems.

Supports:
- UDP multicast  
- MQTT (brokered messaging)
- AMQP  
- Security via key servers  

Great for:
- IoT sensors  
- Large-scale BMS telemetry  
- Multi-building campuses  

---

# 7. OPC-UA Security Model

OPC-UA has one of the strongest security architectures among OT protocols.

### 7.1 X.509 Certificates
Used for:
- Server authentication  
- Client authentication  
- Encrypted sessions  
- Trust chains (CA-signed)  

### 7.2 Security Policies
Define:
- Algorithm sets  
- Hashing functions  
- Key lengths  

Common policies:
- **Basic256Sha256** (recommended minimum)  
- **Aes256-Sha256-RsaPss** (strong)  

### 7.3 User Authentication
- Anonymous  
- Username/password  
- Certificate-based  
- Kerberos / Active Directory (enterprise environments)

### 7.4 Access Control
Role-based:
- Read-only  
- Operator  
- Engineer  
- Administrator  

### 7.5 Message Security Modes
- **None**  
- **Sign**  
- **SignAndEncrypt** (recommended)

---

# 8. OPC-UA vs BACnet vs Modbus

| Feature | OPC-UA | BACnet/IP | Modbus |
|---------|--------|-----------|--------|
| Security | Strong (TLS, certs, RBAC) | None | None |
| Data Model | Complex, object-based | Simple objects | Flat registers |
| Discovery | Browsable | Broadcast | None |
| Control | Methods | WriteProperty | Write Register |
| Scalability | Excellent | Limited by broadcasts | Limited by polling |
| WAN-friendly | Yes | No | Partly |

OPC-UA is the only protocol among the three designed for modern, secure, distributed systems.

---

# 9. OPC-UA Gateways & Wrappers

OPC-UA often acts as the integration layer between:

- BACnet/IP  
- Modbus TCP/RTU  
- KNX  
- Proprietary HVAC/VRF systems  
- Energy platforms  
- Cloud analytics  

A gateway typically:

1. Polls underlying systems  
2. Exposes unified OPC-UA model  
3. Provides secure API for IT systems  

This pattern is increasingly common in large campuses.

---

# 10. Performance Considerations

### 10.1 Sampling vs Publishing
Sampling too frequently wastes CPU cycles.

### 10.2 Too many subscriptions
Rule of thumb:  
**< 200 monitored items per low-end controller**  
**< 2,000 for high-end servers**

### 10.3 PubSub Offloads Load
For telemetry-heavy systems, PubSub (MQTT) is preferred.

### 10.4 Certificate validation overhead
Large trust chains can slow handshakes.

---

# 11. Troubleshooting OPC-UA

## 11.1 Common Symptoms

| Symptom | Likely Cause |
|---------|--------------|
| Client disconnects | Certificate mismatch / expired certs |
| Browser errors | Namespace index changed |
| Slow browsing | Giant address space / deep hierarchies |
| Missing updates | Monitored item sampling too slow |
| Server overloaded | Too many subscriptions |

## 11.2 Diagnostic Tools
- UaExpert (primary tool)  
- Prosys OPC UA Browser  
- Unified Automation SDK tools  
- Wireshark (opcua dissector)  

---

# 12. Deployment Patterns by Building Type

## 12.1 Data Centres
- Power management integration  
- UPS / PDU telemetry  
- Chiller plant advanced diagnostics  
- Secure cross-site communication  

## 12.2 Shopping Centres
- Energy dashboards  
- Tenant billing integration  
- Chiller/boiler optimisation  

## 12.3 Hotels
- Integration between PMS and BMS  
- VRF/VRV via OPC-UA gateways  

## 12.4 Industrial
- SCADA/BMS convergence  
- Historian integration  
- Quality and traceability data  

## 12.5 University Campus
- Renewable energy plant  
- Laboratory analysis devices  
- Smart metering  

## 12.6 Mixed-Use Buildings
- Unified energy reporting  
- API-driven smart building features  

---

# 13. OPC-UA Implementation Checklist

### Security
- [ ] TLS SignAndEncrypt enabled  
- [ ] Certificate management process documented  
- [ ] Revocation lists configured  
- [ ] RBAC roles defined  

### Performance
- [ ] Appropriate sampling intervals  
- [ ] Queue sizes sized correctly  
- [ ] Avoid unnecessary subscriptions  

### Architecture
- [ ] All integrations via DMZ  
- [ ] Gateways isolated in VLAN  
- [ ] No direct building controllers exposed to IT network  

### Troubleshooting
- [ ] UaExpert test profile prepared  
- [ ] Certificate lifetime monitored  
- [ ] Logging enabled for session faults  

---

# Summary

OPC-UA is the most secure, flexible, and future-proof protocol used in OT/BMS environments.  
It provides a rich object model, strong encryption, robust authentication, scalable telemetry, and broad interoperability across vendors and systems.

Key principles:

- Use certificates and strong security policies  
- Avoid oversampling and oversized subscription sets  
- Use PubSub for large-scale telemetry  
- Place gateways in DMZ, not in field VLANs  
- Model data cleanly for IT integrations  
- Treat OPC-UA as the canonical interface between OT and smart-building systems  

With correct architectural design, OPC-UA becomes the backbone for safe, secure, scalable building and industrial automation.
