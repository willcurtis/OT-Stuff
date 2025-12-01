# BMS & OT Infrastructure Glossary

A practical glossary of Building Management System (BMS) and Operational Technology (OT) components that network engineers commonly encounter during design, deployment, or troubleshooting.  
All abbreviations are expanded on first use.

---

## Core BMS Controllers

### **BMS (Building Management System) Supervisor / Head-End**
Central server or appliance running the BMS platform (e.g., Tridium Niagara, Schneider EcoStruxure Building Operation). Aggregates data from field controllers and provides graphics, alarms, trends, and APIs.

### **DDC (Direct Digital Controller)**
Field-level controller managing HVAC, lighting, or plant equipment. Uses BACnet/IP, BACnet MS/TP, Modbus TCP/RTU, KNX, or proprietary protocols.

### **PLC (Programmable Logic Controller)**
Industrial controller for sequencing, automation, and safety logic. Interfaces via Ethernet/IP, Profinet, Modbus TCP.

---

## Field Bus & Protocol Infrastructure

### **BACnet/IP (Building Automation and Control Network over IP) Router / BBMD (BACnet Broadcast Management Device)**
Routes BACnet broadcast traffic between network segments. Enables BACnet to traverse routed/VLAN environments.

### **BACnet MS/TP (Master-Slave/Token-Passing) to IP Gateway**
Converts serial MS/TP traffic to BACnet/IP for integration. Sensitive to grounding, baud rate, and cabling distance.

### **Modbus TCP/RTU (Transmission Control Protocol / Remote Terminal Unit) Gateway**
Bridges Modbus RTU devices on RS-485 to Ethernet-based Modbus TCP networks. Requires correct register maps.

### **KNX (Konnex) / KNX-IP Router**
Router that bridges KNX building automation wiring to IP networks. Widely used in lighting and room control.

### **LonWorks / LON (Local Operating Network) Router**
Legacy automation protocol and associated routers. May require IP-852 interfaces for Ethernet connectivity.

---

## Sensors, Actuators, and IO

### **CO₂ (Carbon Dioxide) / VOC (Volatile Organic Compound) Sensors**
Provide air quality data to control ventilation rates.

### **VFD (Variable Frequency Drive)**
Controls the speed of motors (fans/pumps). Often integrated via Modbus TCP or BACnet/IP.

### **PICV (Pressure Independent Control Valve)**
Valve used in hydronic systems to maintain constant flow regardless of pressure fluctuations.

### **I/O (Input/Output) Modules**
Expand digital and analog points available to a controller. Connected via MS/TP or proprietary serial buses.

---

## Plant & Mechanical Equipment Interfaces

### **AHU (Air Handling Unit) Controller**
Controls fans, dampers, filters, coils, and associated HVAC functions. Integrates via DDC or vendor API.

### **CHP (Combined Heat and Power) Interface**
Plant equipment that provides heat and power. Integration typically through Modbus TCP.

### **BEMS (Building Energy Management System) Panel / Control Panel**
Panel housing DDCs, IO modules, relays, and power supplies. May contain unmanaged industrial switches.

---

## OT Network Infrastructure (BMS Context)

### **NTP (Network Time Protocol) Server**
Used for time synchronisation across controllers, gateways, and supervisory platforms.

### **OOB (Out-of-Band) Router**
4G/5G industrial router for remote access to isolated BMS networks.

### **UPS (Uninterruptible Power Supply)**
Provides conditioned power and battery backup for critical BMS panels. Monitored via SNMP or Modbus.

### **PDU (Power Distribution Unit)**
Supplies electrical power to control panels; may provide metering via Modbus TCP.

---

## Lighting & Room Control Systems

### **DALI (Digital Addressable Lighting Interface) Gateway**
Connects DALI lighting bus to BACnet/IP, Modbus TCP, or KNX. Used for dimming, ballast control, and emergency lighting reporting.

### **PIR (Passive Infrared) Occupancy Sensor**
Detects motion to control lighting and HVAC.

### **Room Controller / OCC (Occupancy) Unit**
Integrated unit for temperature, lighting, blinds, and occupancy control.

---

## Security, Access & Life Safety Integrations

### **FAP (Fire Alarm Panel)**
Connected via Modbus, dry contacts, or vendor gateways. Usually read-only for BMS due to regulatory controls.

### **NVR (Network Video Recorder)**
Used in CCTV systems; limited integration such as alarm-trigger I/O.

### **PAC (Physical Access Control) Panel**
Manages door access, readers, locks, and associated sensors. Integration may use REST APIs or Modbus.

---

## Power & Infrastructure Components

### **PSU (Power Supply Unit)**
Provides 24V AC/DC or other required voltages for controllers and field devices.

### **M-Bus (Meter-Bus) Master / Concentrator**
Used for utility metering systems (heat, water, electricity).

### **Historians / Trend Storage Appliances**
Dedicated systems for storing time-series BMS data (e.g., Niagara JACE, EBO Enterprise Server).

---

## Wireless & Specialist Systems

### **LoRaWAN (Long Range Wide Area Network) Gateway**
Integrates wireless sensors for temperature, humidity, IAQ, and utility data.

### **IAQ (Indoor Air Quality) Hub**
Multi-sensor platform (CO₂, VOC, PM2.5, temperature, humidity).

### **UWB (Ultra-Wideband) / BLE (Bluetooth Low Energy) Sensors**
Used in people-counting, asset tracking, and presence detection.

---

## Documentation & Operational Artifacts

### **SoO (Sequence of Operations)**
Specifies how the HVAC or building system should behave logically.

### **As-Built Drawings**
Final diagrams representing electrical, mechanical, network, and wiring layouts after installation.

### **I/O Schedule (Input/Output Schedule)**
Defines each point (sensor, actuator, software point) and its mapping.

---

## Integration Interfaces

### **API (Application Programming Interface)**
Used for integrating BMS with FM, CAFM, analytics, and external applications.

### **MQTT (Message Queuing Telemetry Transport) Broker**
Lightweight messaging protocol for IoT-style BMS devices.

### **OPC (OLE for Process Control) / OPC-UA (Open Platform Communications Unified Architecture) Server**
Standard interoperability interface for industrial and SCADA systems.

### **SCADA (Supervisory Control and Data Acquisition) Interface**
Provides central supervisory control for plant and industrial automation systems.

---

## Legacy & Vendor-Specific Items

### **JACE (Java Application Control Engine)**
Tridium Niagara controller/gateway used to normalise protocols such as BACnet, Modbus, KNX, and LON.

### **Trend IQ (Intelligent Quantifier) Controllers**
Legacy BMS controllers using Trend LAN or BACnet/IP.

### **Proprietary Fieldbus Gateways**
Vendor-specific converters bridging closed protocols to BACnet, Modbus, or MQTT.

---

# Contributing
Feel free to suggest additional components, especially from specialist systems such as water treatment, CHP, smart-grid interfaces, and vertical transport (lifts).
