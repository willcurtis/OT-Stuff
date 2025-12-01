# MQTT (Message Queuing Telemetry Transport)

MQTT is a lightweight publish/subscribe protocol widely used in IoT systems, telemetry, analytics platforms, and increasingly within modern OT and BMS architectures. Unlike traditional field protocols such as Modbus or BACnet, MQTT decouples devices from consumers through a central broker and provides efficient, low-bandwidth communication suitable for distributed building systems.

MQTT is not a replacement for BACnet or Modbus within traditional HVAC controls, but it is now commonly used for:

- Cloud analytics integration  
- Wireless sensor networks  
- LoRaWAN gateways  
- Smart energy systems  
- Occupancy analytics  
- Edge computing architectures  

This chapter provides a deep technical explanation of MQTT suitable for OT/BMS network engineers.

---

## Key Characteristics of MQTT

### 1. Publish/Subscribe Model  
Devices **publish** to topics, and subscribers receive messages without direct coupling.

### 2. Broker-Centric  
All messages flow through a central **MQTT broker** (e.g., Mosquitto, EMQX, HiveMQ).

### 3. Lightweight  
Low overhead compared to HTTP, Modbus, or BACnet.

### 4. Transport Agnostic  
Typically runs over:
- TCP port **1883** (unencrypted)  
- TCP port **8883** (TLS encrypted)  

Also supported over WebSockets.

### 5. Quality of Service (QoS) Levels  
MQTT provides reliability options not present in many OT protocols.

---

## MQTT Architecture

MQTT comprises three major components:

1. **MQTT Broker (Server)**  
   - Receives all messages  
   - Manages topic routing  
   - Applies authentication, ACLs, and QoS  

2. **MQTT Publisher**  
   - Devices that send messages (e.g., sensors, gateways, PLCs)

3. **MQTT Subscriber**  
   - Systems consuming data (e.g., BMS supervisor, cloud services, analytics engines)

Publishers and subscribers never communicate directly.

---

## MQTT Topics

Topics define message channels.

Examples:
- `building/1/ahu/3/supply_temp`  
- `energy/meter/boiler1/power`  
- `occupancy/floor2/zone4/status`  

### Topic Rules:
- Hierarchical, slash-separated  
- Case-sensitive  
- Wildcards supported:
  - `+` matches one level  
  - `#` matches all remaining levels  

Example:  
`building/+/ahu/#` subscribes to every AHU topic in all buildings.

---

## Payload Formats

MQTT does not define payload structure. Common formats are:

- JSON  
- CSV  
- Raw numeric values  
- Binary blobs  
- Proprietary encoded messages  

A lack of standardisation can cause integration complexity in BMS platforms.

---

## Quality of Service (QoS)

MQTT provides three QoS levels:

### **QoS 0 – At most once**  
No acknowledgement; best-effort delivery.  
Suitable for rapidly updating sensor data.

### **QoS 1 – At least once**  
Acknowledged delivery; duplicates possible.  
Most common for OT/IoT.

### **QoS 2 – Exactly once**  
Uses a four-step handshake.  
Rare in OT due to overhead.

BMS systems usually use QoS 1.

---

## Retained Messages

A **retained message** persists on the broker, so new subscribers immediately receive the last known value.

Useful for:
- Sensor states  
- Device availability  
- Configuration metadata  

Incorrect use can lead to:
- Stale values after devices go offline  
- Misleading alarms in BMS systems  

---

## Last Will and Testament (LWT)

MQTT supports setting a “Last Will” message to be published automatically if a client disconnects unexpectedly.

Example:
- Device publishes `online: true` on connect.
- Broker publishes `online: false` on disconnect.

Critical for determining device availability in BMS IoT systems.

---

## MQTT Security Model

MQTT includes no built-in security. All protections rely on:

### 1. **TLS Encryption (Port 8883)**  
Prevents interception of data.

### 2. **Authentication**  
Using:
- Username/password  
- Certificate-based auth  
- Token-based auth (JWT, OAuth in advanced brokers)

### 3. **Access Control Lists (ACLs)**  
Restrict topic access on a per-client basis.

### 4. **Firewalling**  
MQTT should **never** be exposed without firewall restrictions.

### Common Security Failures
- Anonymous access left enabled  
- No TLS  
- Open ACLs allowing a client to publish anywhere  
- Brokers reachable from IT networks or internet  
- Default credentials left unchanged  

In OT/BMS networks, TLS and ACLs are mandatory.

---

## MQTT in BMS and OT Environments

MQTT adoption is increasing rapidly. Typical use cases include:

### 1. **Wireless Sensor Systems**
- Battery-powered temperature/humidity/CO₂ sensors  
- LoRaWAN gateways publishing MQTT payloads  
- BLE and Zigbee proxies exporting via MQTT  

### 2. **Smart Lighting and IoT Devices**
Lighting systems increasingly use MQTT as backend integration.

### 3. **Edge Gateways**
Gateways ingest:
- Modbus TCP  
- Modbus RTU  
- BACnet/IP  
and publish summarised data via MQTT to:

- Analytics platforms  
- BMS supervisors  
- Cloud services  

### 4. **Energy Management**
Meters and energy monitoring platforms export high-frequency telemetry.

### 5. **Digital Twins**
MQTT is often the chosen protocol due to scalability and event-driven nature.

---

## MQTT and Network Design

### 1. Broker Placement  
Options:
- On-prem OT network  
- DMZ  
- Cloud-hosted  

On-prem is recommended for operational control loops.

### 2. VLAN Segmentation  
IoT/MQTT devices should operate on isolated VLANs.

### 3. NAT Considerations  
MQTT handles NAT well, but persistent connections require stable mapping.

### 4. Firewall Rules  
Allow:
- Only specific client subnets  
- Only broker port(s)  
- Only TLS (no unencrypted 1883)  

Block:
- Broker-to-client unsolicited traffic  
- Wildcard routes to corporate networks  

---

## Performance Considerations

### 1. Message Rate  
MQTT brokers can handle thousands of messages per second, but low-end gateways cannot.

### 2. Persistent Sessions  
Useful for mobile IoT devices but require broker memory.

### 3. Large Payloads  
While possible, large payloads degrade performance and should be avoided.

### 4. QoS 2 Overhead  
Too slow for high-volume OT telemetry.

### 5. Retained Message Storage  
Improper configuration leads to:
- Memory leaks  
- Accumulated stale data  

---

## MQTT Failure Scenarios

### 1. Broker Overload
Symptoms:
- Clients disconnect  
- Slow deliveries  
- Missed telemetry  

Causes:
- Excessive message rate  
- Too many retained messages  
- Resource-constrained brokers  

### 2. Misconfigured ACLs
Symptoms:
- Devices cannot publish or subscribe  
- Security exposures if ACLs are too permissive  

### 3. Network Partitioning
Symptoms:
- Clients appear offline  
- Buffered messages lost  
- Supervisory alarms  

### 4. Non-TLS Connections Blocked
Symptoms:
- Legacy devices fail after enforcing secure mode  

### 5. Duplicate Subscriptions
Symptoms:
- Multiple deliveries of the same message  
- Increased broker workload  

---

## Troubleshooting Methodology

### Step 1: Validate Broker Health
- CPU, RAM, disk  
- Connection count  
- Retained message store  
- Queue depths  

### Step 2: Inspect Client Logs
- Disconnect codes  
- TLS negotiation errors  
- Authentication failures  

### Step 3: Monitor Traffic
Use:
- Broker dashboards  
- Tools like `mosquitto_sub` or `mqtt-cli`  

### Step 4: Validate ACLs
Check:
- Topic permissions  
- Client ID restrictions  
- Wildcard access  

### Step 5: Examine Network Path
- Latency  
- Firewall idle timeouts  
- NAT stability  

---

## Summary

MQTT is becoming a core integration technology for modern buildings, especially in sensor networks, analytics platforms, and IoT-driven control systems. Its publish/subscribe model, low overhead, and event-driven behaviour make it ideal for scalable telemetry.

Key takeaways for network engineers:

- MQTT is broker-centric; protect the broker.  
- TLS + ACLs are mandatory in OT networks.  
- Retained and QoS settings heavily impact behaviour.  
- Gateways often become bottlenecks.  
- MQTT is best suited for telemetry, not real-time control loops.  

MQTT is not a replacement for BACnet or Modbus but increasingly complements them in hybrid BMS deployments.
