# Controllers

Controllers are the core of any Building Management System (BMS). They execute control logic, read field sensors, drive actuators, and maintain stable environmental conditions. For a network engineer, controllers are the primary source and destination of OT traffic and form the largest group of connected devices within a BMS network.

This document provides a detailed explanation of controller types, communication behaviours, addressing, performance characteristics, and common design considerations relevant to OT networking.

---

## Controller Categories

Most BMS deployments include two main classes of controllers:

1. **Direct Digital Controllers (DDCs)**  
2. **Programmable Logic Controllers (PLCs)**

Although they share some similarities (I/O, sequences, autonomous operation), they differ significantly in performance, protocols, and expected behaviour.

---

## Direct Digital Controllers (DDCs)

DDCs are purpose-built for building automation. They run vendor-specific firmware and are optimised for HVAC, lighting, and environmental control scenarios.

### Core Responsibilities

- Running sequences of operation (e.g., AHU control, VAV control, heating valves)
- Reading and scaling sensor inputs
- Driving actuators (analog/digital outputs)
- Managing local loops even during network outages
- Exchanging data with a supervisory platform
- Maintaining local schedules if the supervisor is offline

### DDC Architecture

DDCs typically consist of:

- A CPU module  
- Onboard I/O or expansion modules  
- Communication interfaces (Ethernet and/or RS-485)  
- Real-time operating system  
- Non-volatile memory for programs and configuration  

They are designed for **24/7 uninterrupted operation** and often support firmware updates without service interruption (though not always safely).

### DDC Communication Methods

DDCs may use one or more of the following:

- **BACnet/IP**  
- **BACnet MS/TP (RS-485)**  
- **Modbus TCP**  
- **Modbus RTU**  
- **KNX**  
- **LonWorks**  
- **Proprietary room/bus networks**

Network engineers should note:

- DDC traffic is often periodic (polling), not transactional like IT workloads.
- Many DDCs depend heavily on broadcast-based service discovery.
- MS/TP networks often hang from the controller’s serial port.

---

## Programmable Logic Controllers (PLCs)

PLCs are industrial-grade controllers used in environments requiring deterministic behaviour, fast control cycles, and robust error handling.

### Common PLC Use Cases in Buildings

- Chillers  
- Boilers and burner control  
- Water treatment systems  
- CHP plant  
- Industrial air handling units  
- High-integrity safety systems  

### PLC Architecture

Typical PLC architecture includes:

- A ruggedised CPU module with real-time deterministic scheduling  
- Dedicated communication buses (Ethernet/IP, Profinet)  
- Hot-swappable I/O modules  
- Redundant power and network options  
- High scan-rate support (1–20 ms loops)  

PLCs generally outclass DDCs in performance and reliability and are often integrated into BMS systems via gateways or direct protocol export (Modbus TCP, OPC-UA).

### PLC Communication Methods

- **Ethernet/IP** (Rockwell environments)  
- **Profinet** (Siemens environments)  
- **Modbus TCP**  
- **OPC-UA**  
- **Proprietary vendor protocols**  

Network engineers must handle PLC traffic carefully:

- Some PLC protocols are multicast-heavy.
- Time synchronisation is critical for determinism.
- PLC failure can halt critical plant equipment.

---

## Controller Addressing

Controller addressing varies by protocol and vendor.

### IP Controllers

Controllers using BACnet/IP, Modbus TCP, or proprietary IP stacks typically require:

- Static IP address  
- Subnet mask and gateway  
- BACnet device instance (unique across the site)  
- BACnet network number (unique per broadcast domain)  
- Hostname (optional and often unused)  

Misconfigured addressing is one of the top causes of BMS failures.

### MS/TP Controllers

MS/TP controllers require:

- MAC address (0–127, must be unique per bus)  
- Baud rate (must be consistent across the entire bus)  
- Max master setting  
- Token timeout configuration (vendor-specific)  

MS/TP networks fail if:

- Two devices share a MAC address  
- Baud rate mismatches occur  
- Grounding is poor  
- Cable length exceeds spec  

---

## Polling vs Event-Driven Behaviour

Different controllers and protocols use different communication models.

### Polling (Modbus, many vendor systems)

The master device repeatedly requests values at intervals.

Characteristics:

- Predictable bandwidth consumption  
- Performance degrades with large point counts  
- Can overload devices if polling frequency is too high  

### Event-Driven (BACnet COV, OPC-UA subscriptions)

Clients subscribe to changes.

Characteristics:

- More efficient  
- Lower bandwidth  
- Reduced controller CPU load  
- Requires stable supervisor connectivity  

Many integrators disable event-driven updates due to poor network design, causing unnecessary polling.

---

## Controller Performance Limitations

Controllers have significant constraints compared to IT servers.

### Common Limitations

- Low CPU clock speeds  
- Limited RAM (< 128–1024 MB)  
- Limited concurrent connections  
- Slow flash storage  
- Limited logging capability  
- Weak TLS support (or none at all)  
- Limited or no syslog capability  

This impacts:

- How often controllers can be polled  
- How many BACnet subscriptions they can handle  
- Whether HTTPS APIs are viable  
- How fast they recover after network disruptions  

---

## Firmware Management

Firmware on controllers:

- Fixes critical bugs  
- Adds protocol improvements  
- Closes security vulnerabilities  
- Introduces new features  

However:

- Firmware updates may require physical access  
- Many controllers do not support rollback  
- Updates can invalidate control logic  
- Some vendors require licensed tools to upgrade  

From a network perspective:

- Always document firmware versions  
- Maintain an isolated update VLAN when possible  
- Ensure redundant controllers don’t run mismatched versions  

---

## Control Loop Behaviour and Network Impact

Controllers run local control loops:

- Temperature control  
- Pressure control  
- Flow control  
- Mixed-air control  
- Valve modulation  

These loops **must not** depend on network availability.

A poorly designed network should never compromise:

- Fan speed control  
- Heating/cooling output  
- Ventilation rates  

If a controller relies too heavily on supervisory input:

- Behaviour may degrade when the network fails  
- Equipment may oscillate or run at defaults  
- Alarms may be suppressed or delayed  

---

## Network Engineer Considerations

### Essential points to consider when working with controllers:

1. **Controllers must operate independently during outages.**  
2. **Broadcast traffic impacts controller performance.**  
3. **MS/TP segments require careful electrical design.**  
4. **Gateways between controllers and IP introduce delays and faults.**  
5. **Firmware mismatches can create protocol inconsistencies.**  
6. **Controllers have very limited security controls by default.**  
7. **Incorrect BACnet device IDs cause supervisory conflicts.**  
8. **Clock drift can affect scheduling and trending accuracy.**  
9. **Controller startup behaviour varies by vendor and may take minutes.**  
10. **Supervisory systems often overload controllers with high-frequency polling.**  

---

## Summary

Controllers form the backbone of building automation. They operate autonomously, communicate using specialised OT protocols, and interact with sensors and actuators in real time.

For network engineers, the key priorities are:

- Ensuring stable IP reachability between controllers and supervisors  
- Minimising unnecessary broadcast or polling load  
- Maintaining segmentation between different subsystems  
- Protecting controllers from direct internet exposure  
- Designing networks tolerant of outages and latency spikes  

Understanding controller behaviour is a prerequisite for all other OT/BMS networking topics.
