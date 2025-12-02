# Monitoring & Alerting  
**OT Network Observability, BMS Health Monitoring, BACnet/KNX/Modbus/MQTT Metrics, Time-Series Databases, Logging & Alarm Correlation**

Effective monitoring in OT systems is mission-critical.  
Unlike IT networks—where downtime is inconvenient—OT downtime results in:

- Failed HVAC  
- Loss of lighting control  
- Environmental instability  
- Fire system failures  
- Compliance violations  
- Disruption to building operations  

This chapter provides a reference architecture for monitoring OT networks, controllers, and building systems.

---

# 1. Monitoring Priorities for OT

OT monitoring must answer three questions:

### 1.1 Is the network healthy?  
- Switches  
- Links  
- VLANs  
- Multicast domains  
- Uplinks  
- Fibre health  

### 1.2 Are OT systems behaving correctly?  
- HVAC  
- Lighting  
- DALI/DMX  
- Modbus devices  
- IoT sensors  
- VRF/VRV  
- Gateways  

### 1.3 Are protocols functioning normally?  
- BACnet reads/writes  
- KNX multicast presence  
- MQTT topic activity  
- OPC-UA node health  

If any of these fail, building systems degrade rapidly.

---

# 2. Monitoring Tools & Tech Stack

A complete OT monitoring stack often includes:

### 2.1 SNMP Pollers
- Switch CPU, memory, temperature  
- Interface status  
- Error counters  
- PoE usage  
- UPS metrics  

### 2.2 Flow Telemetry
- NetFlow / sFlow  
- Detect BACnet storms  
- Identify rogue protocols  
- Monitor multicast load  

### 2.3 Service Monitors
- BACnet device discovery  
- KNX heartbeat  
- Modbus register test reads  
- MQTT topic availability  
- OPC-UA node count  
- HTTP(S) checks on BMS servers  

### 2.4 Time-Series Database
- InfluxDB  
- Prometheus  
- TimescaleDB  

Used for:
- Long-term trending  
- Capacity planning  
- Root-cause analysis  
- Performance baselining  

### 2.5 Dashboards
- Grafana  
- PRTG Maps  
- NOC views  
- Executive overviews  

### 2.6 Log Analytics / SIEM
- Syslog  
- Firewall logs  
- BACnet/SC connection logs  
- Broker logs  
- Windows/Linux event logs  

---

# 3. Network Monitoring for OT

### 3.1 Interface Health
Track:
- CRC errors  
- Packet drops  
- Duplex mismatches  
- Link flaps  
- Excessive broadcast  

### 3.2 Switch Health
- CPU > 70% is a concern  
- Memory utilisation  
- Temperature (especially in plant rooms)  
- PSU status  

### 3.3 Uplink Monitoring
Check:
- OSPF adjacency stability  
- ECMP path operation  
- Fibre errors (LOS, LOF, FEC events)  

### 3.4 Multicast Monitoring
For KNX, lighting (sACN), IPTV:

- IGMP group membership  
- Querier status  
- Multicast bandwidth  
- VLAN-specific multicast storms  

### 3.5 Broadcast Storm Detection
Critical for BACnet/IP containment:

- Track broadcast pps  
- Alert when thresholds exceeded  
- Auto-shutdown port (optional)  

---

# 4. Protocol-Specific Monitoring

OT protocols require dedicated health checks.

---

## 4.1 BACnet/IP
Monitor:
- Who-Is / I-Am traffic  
- Device count stability  
- Foreign device table health  
- BBMD (if used—should not be)  
- BACnet/SC hub connection list  
- Read-time for critical points  

Alerts:
- Sudden drop in devices  
- Broadcast spike  
- Slow response to reads  

---

## 4.2 KNX IP
Monitor:
- Multicast traffic continuous presence  
- Router health  
- Tunnelling session limits  
- Routing load  
- Commissioning ports availability  

Alerts:
- Too many KNX IP routers  
- Multicast drops / IGMP misconfiguration  
- Duplicate physical addresses  

---

## 4.3 Modbus TCP
Monitor:
- Response time per device  
- CRC errors on gateways  
- Register read failure rate  
- Gateway CPU usage  

Alerts:
- Device offline  
- Slow or failed polls  
- High CRC error count  

---

## 4.4 MQTT
Monitor:
- Broker uptime  
- Subscriber count  
- Publisher count  
- MQTT retained store size  
- Topic activity volumes  
- TLS handshake failures  

Alerts:
- Drop in critical topics  
- Publisher offline  
- Excessive retained messages  
- Authentication failures  

---

## 4.5 OPC-UA
Monitor:
- Node count  
- Session count  
- Certificate expiry  
- Server uptime  
- Browse time  

Alerts:
- Bad session quality  
- Node disappearing  
- Certificate expiring within 30 days  

---

# 5. BMS Application Monitoring

BMS supervisors and application servers must be monitored like critical assets.

### Monitor:
- CPU  
- Memory  
- Disk I/O  
- Temp directories  
- Services (BACnet/SC hub, MQTT broker, OPC-UA aggregator)  
- Database size  
- Backup success/failure  

### Application-Level Checks:
- Dashboard load  
- API responsiveness  
- SCADA/HMI heartbeat  

---

# 6. Alarm & Alert Hierarchy

### 6.1 Critical
- Network partition  
- Distribution switch down  
- BACnet storm  
- Loss of supervisor  
- Database failure  
- MQTT broker offline  
- Plant room switch critical temp  

### 6.2 Major
- Gateway offline (DALI, Modbus, KNX)  
- Uplink flap  
- High CPU on riser switch  
- BMS service restart  

### 6.3 Minor
- Single device offline (controller)  
- Slight increase in multicast  
- Non-critical sensor failure  

### 6.4 Informational
- New device discovered (should be reviewed)  
- Firmware upgrade success  
- Configuration backup completed  

---

# 7. Logging Architecture

All logs feed OT SOC or central log server.  
Recommended stack:

- Syslog → Log server → SIEM  
- Firewall logs → SIEM  
- Switch logs → Syslog + SIEM  
- BACnet/SC hub → Syslog  
- MQTT broker logs → SIEM  
- Application logs → Central storage  

Log retention:
- 12 months minimum  
- 36 months typical for regulated sectors  

---

# 8. Time Synchronisation (NTP)

Time drift breaks:
- BACnet timestamping  
- Modbus logs  
- MQTT timestamps  
- Trend data consistency  
- SIEM correlation  
- Certificate validation  

### Best Practice:
- Two OT NTP servers  
- One IT NTP (firewalled view)  
- All controllers and gateways sync to OT NTP only  

---

# 9. Capacity & Performance Baselining

Run baselines for:
- Broadcast traffic  
- Multicast load  
- Uplink utilisation  
- Database growth  
- MQTT throughput  
- BACnet read/write latencies  

These baselines enable:
- Trend prediction  
- Root-cause analysis  
- Capacity planning  

---

# 10. Dashboards (Grafana / PRTG Examples)

### 10.1 Network Dashboard
- Uplink utilisation  
- Core CPU/Temp  
- Multicast groups  
- Broadcast pps  
- BACnet packet rate  

### 10.2 Protocol Dashboard
- BACnet device count  
- KNX multicast heartbeat  
- Modbus error rate  
- MQTT topic throughput  
- OPC-UA session count  

### 10.3 BMS Dashboard
- HVAC alarms  
- Gateway online/offline  
- VRF/VRV status  
- Chiller/Boiler supervision  
- DALI emergency test results  

---

# 11. OT Monitoring Architecture Blueprint

                         +-------------------+
                         |   OT SOC / SIEM   |
                         +---------+---------+
                                   ^
                                   |
                           Syslog / API / Flow
                                   |
          +------------------------+-------------------------+
          |                        |                         |
  +-------+--------+     +---------+--------+       +--------+-------+
  | OT Core Switch |     |   OT DMZ Servers  |       |  Firewalls     |
  +-------+--------+     +---------+--------+       +--------+-------+
          ^                        ^                       ^
          |                        |                       |
    SNMP / Flow              Logs / Metrics          Logs / Alerts
          |                        |                       |
 +--------+--------+       +-------+---------+      +------+--------+
 | Dist / Riser Sw  | ---- |  BMS Supervisors | ---- | Protocol Hubs |
 +------------------+       +-----------------+      +---------------+
                  ^                 ^                ^
                  |                 |                |
             Access Layer      Protocol Polls     Application Logs
                  |                 |                |
          Controllers / Gateways / Field Systems

---

# 12. Implementation Checklist

### Network
- [ ] SNMP on all switches & UPS  
- [ ] sFlow/NetFlow from core  
- [ ] IGMP/Mcast monitoring enabled  

### Protocols
- [ ] BACnet device discovery monitoring  
- [ ] KNX heartbeat checks  
- [ ] Modbus register polling tests  
- [ ] MQTT topic monitoring  
- [ ] OPC-UA node health checks  

### Servers
- [ ] Supervisor CPU/memory monitoring  
- [ ] Database growth tracking  
- [ ] Backup validation alerts  
- [ ] Certificate expiry alerts  

### Security
- [ ] Firewall log ingestion  
- [ ] Vendor access logging  
- [ ] BACnet/SC hub monitoring  
- [ ] SIEM correlation rules deployed  

---

# Summary

Monitoring and alerting in OT networks requires far more than simple network uptime checks.  
A complete monitoring solution must observe the *network*, *protocols*, *servers*, and *building systems*, with strong integration into SIEM for security oversight.

Key principles:
- Monitor protocols, not just ports  
- Use time-series DBs for trends  
- Enforce NTP across OT  
- Alert on early indicators of instability  
- Include BMS-level and controller-level checks  
- Integrate everything into a single observability plane  

Stable OT networks are observable OT networks.
