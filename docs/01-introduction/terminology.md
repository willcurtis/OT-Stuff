# Terminology

This section defines key terms and abbreviations used throughout the manual. All abbreviations are expanded in full at first use.

---

## Networking & Infrastructure Terms

### **OT (Operational Technology)**
Systems that monitor and control physical processes such as HVAC, lighting, access control, and plant equipment.

### **BMS (Building Management System)**
A system that integrates and controls building automation functions to maintain comfort, efficiency, and safety.

### **ICS (Industrial Control System)**
Broader category that includes BMS, SCADA, and PLC-based systems used in industrial automation.

### **SCADA (Supervisory Control and Data Acquisition)**
High-level monitoring and control platform commonly used in industrial facilities.

### **PLC (Programmable Logic Controller)**
A ruggedised industrial controller used for sequencing, automation, and safety functions.

### **DDC (Direct Digital Controller)**
A BMS-specific controller managing HVAC and environmental plant.

---

## OT Protocols

### **BACnet/IP (Building Automation and Control Network over IP)**
An ASHRAE standard protocol for building automation communications over Ethernet/TCP/IP.

### **BACnet MS/TP (Master-Slave / Token-Passing)**
A serial (RS-485) version of BACnet used at field level.

### **Modbus TCP (Modbus Transmission Control Protocol)**
Ethernet-based version of Modbus used for plant integration and metering.

### **Modbus RTU (Modbus Remote Terminal Unit)**
Serial RS-485 version of Modbus.

### **OPC-UA (Open Platform Communications Unified Architecture)**
A modern, secure industrial interoperability standard for structured data exchange.

### **KNX (Konnex)**
A widely adopted building-automation protocol for lighting and room control.

### **LonWorks / LON (Local Operating Network)**
A legacy protocol for building automation devices.

### **MQTT (Message Queuing Telemetry Transport)**
A lightweight publish/subscribe protocol used for IoT-style integrations.

---

## Architecture & Security Terms

### **BBMD (BACnet Broadcast Management Device)**
A BACnet router allowing broadcasts across IP subnets.

### **NAT (Network Address Translation)**
Technique for translating private to public IP ranges.

### **ACL (Access Control List)**
Firewall or switch rule controlling traffic.

### **VRF (Virtual Routing and Forwarding)**
Logical segmentation of routing tables on a device.

### **ZTA (Zero Trust Architecture)**
Security model that denies implicit trust and validates every flow.

### **OT DMZ (Operational Technology Demilitarised Zone)**
A security boundary separating OT from IT networks.

---

## Building & HVAC Terms

### **AHU (Air Handling Unit)**
HVAC system that conditions and circulates air within a building.

### **FCU (Fan Coil Unit)**
A terminal HVAC unit providing local heating/cooling.

### **VAV (Variable Air Volume) Box**
A device that controls airflow into a zone.

### **VFD (Variable Frequency Drive)**
Motor controller that adjusts pump or fan speed.

### **CHP (Combined Heat and Power)**
Plant generating electricity and heat.

### **I/O (Input/Output)**
Electrical or software-defined control points (e.g., temperature sensor input, valve output).

---

## Remote Access & Operations

### **VPN (Virtual Private Network)**
Encrypted tunnel providing secure remote access.

### **OOB (Out-of-Band) Management**
Alternative access path to a network for management when the main path fails.

### **FAT (Factory Acceptance Test)**
Testing before equipment ships to site.

### **SAT (Site Acceptance Test)**
Testing on site after installation.
