# BMS & OT Infrastructure Glossary

A practical glossary of Building Management System (BMS) components and OT-network elements that network engineers commonly encounter during design, deployment, or troubleshooting.

---

## Core BMS Controllers

### **BMS Supervisor / Head-End**
- Central server or appliance running the BMS platform (Tridium Niagara, Schneider EBO, Siemens Desigo CC).
- Aggregates data from field controllers.
- Hosts graphics, trends, alarms, and APIs.
- Often dual-NIC or VLAN-segmented on OT networks.

### **DDC (Direct Digital Controller)**
- Field-level controller managing HVAC, lighting, or plant equipment.
- Communicates using BACnet/IP, BACnet MS/TP, Modbus TCP/RTU, KNX, or proprietary protocols.

### **Programmable Logic Controller (PLC)**
- Industrial controller used for sequence control, safety logic, and plant automation.
- Common brands: Siemens S7, Allen-Bradley, Wago.
- Interfaces over Ethernet/IP, Profinet, Modbus TCP.

---

## Field Bus & Protocol Infrastructure

### **BACnet/IP Router / BBMD**
- Bridges segmented BACnet broadcast domains.
- BBMD allows BACnet broadcasts to traverse routed networks.
- Common failure point in multi-VLAN BMS networks.

### **BACnet MS/TP to IP Gateway**
- Converts serial MS/TP traffic to BACnet/IP.
- Sensitive to grounding, baud rate, and cable length issues.

### **Modbus TCP/RTU Gateway**
- Bridges Modbus RTU (RS-485) devices to Ethernet.
- Requires correct register mapping, byte order, and function codes.

### **KNX/IP Router**
- Connects KNX twisted-pair bus to IP networks.
- Often used with lighting systems.

### **LonWorks / LON Router**
- Legacy protocol infrastructure for HVAC and lighting.
- May require IP-852 routers for integration to Ethernet.

---

## Sensors, Actuators, and IO

### **Temperature / Humidity Sensors**
- Feed environmental data to controllers.
- Usually wired into DDC IO, sometimes BACnet/Modbus addressable.

### **Differential Pressure Sensors**
- Used for AHU filters, clean rooms, laboratories.

### **CO₂ / VOC Sensors**
- Dictate fresh-air strategies based on air quality.

### **Motorised Dampers & Actuators**
- Controlled via analog outputs (0–10V), relays, or BACnet/Modbus.

### **Valves (2-Port, 3-Port, PICV)**
- Used in heating/cooling circuits.
- Controlled electrically or via actuator.

### **VFD (Variable Frequency Drive)**
- Controls fan/pump speed.
- Frequently integrated over Modbus TCP or BACnet/IP.

### **Energy Meters**
- Provide electrical usage data.
- Output via Modbus RTU/TCP, M-Bus, or BACnet.

### **I/O Modules**
- Expand the number of digital or analog input/output channels on a controller.
- Often daisy-chained using MS/TP or proprietary serial buses.

---

## Plant & Mechanical Equipment Interfaces

### **AHU (Air Handling Unit) Controller**
- Controls fans, dampers, coils, filters.
- May be standalone or integrated via DDC controller.

### **Chiller Interface**
- Exposes chiller operating data and controls.
- Integration typically via BACnet/IP or Modbus TCP.

### **Boiler Interface Panel**
- Provides burner status, flow temps, faults.
- Usually linked via relay contacts or Modbus RTU.

### **BEMS Panel / Control Panel**
- Wall-mounted enclosure housing DDCs, I/O, relays, transformers, and terminations.
- Often includes unmanaged industrial switches or serial buses.

---

## OT Network Infrastructure (BMS Context)

### **Industrial Ethernet Switch**
- Hardened switch for panel or plant room deployment.
- DIN-rail mount, wide temp support, often unmanaged.
- VLAN support varies widely.

### **Serial-to-IP Converter**
- Bridges legacy RS-232/485 equipment to modern networks.

### **4G/5G Industrial Router**
- Provides out-of-band access to remote BMS assets.
- Often isolated by firewall policy.

### **Time Server / NTP Appliance**
- Critical for timestamping trends, alarms, and synchronising controllers.

### **Syslog Server**
- Stores controller and gateway logs for troubleshooting.

### **OT Firewall**
- Segments BMS networks from IT networks.
- Enforces protocol-aware rules for BACnet, Modbus, and proprietary systems.

---

## Lighting & Room Control Systems

### **DALI Gateway**
- Converts DALI (lighting bus) to BACnet/IP or Modbus.
- Used for dimming, ballasts, and emergency lighting.

### **Lighting Control Processor**
- Central controller for lighting scenes and scheduled events.
- May expose REST, BACnet, or KNX interfaces.

### **Blind / Shutter Controller**
- Controls window blinds via relays or KNX/DALI.

### **Room Controller / Occupancy Unit**
- Manages temperature, lights, blinds, and occupancy.
- Communicates via BACnet, KNX, or proprietary wireless.

---

## Security, Access & Life Safety Integrations

### **Access Control Panel**
- Connects door readers, locks, PIRs.
- Integration typically Modbus or vendor API, not direct BACnet.

### **CCTV NVR**
- Sometimes integrated for status-only data (e.g., alarm triggers).

### **Fire Alarm Panel (FAP)**
- Often via Modbus or relays for cause-and-effect.
- Read-only in many jurisdictions due to regulatory constraints.

### **Public Address/Voice Alarm Controller**
- Limited integration via contact closures or relay outputs.

---

## Power & Infrastructure Components

### **UPS (Uninterruptible Power Supply)**
- Provides clean power for BMS panels.
- SNMP or Modbus monitoring.

### **Power Distribution Unit (PDU)**
- Supplies circuits to panels.
- Sometimes metered and monitored via Modbus.

### **Transformers & PSU Modules**
- Provide low-voltage power (24V AC/DC) for controllers and IO.

### **Trend/History Storage Appliance**
- Dedicated local storage for BMS time-series data.
- Examples: Niagara JACE, EBO SmartX, proprietary historian boxes.

---

## Wireless & Specialist Systems

### **Wireless Sensor Gateways**
- LoRaWAN, Zigbee, or proprietary RF.
- Used for retrofit environments.

### **People Counting Sensors**
- Integrated via REST APIs, BACnet, or edge gateways.

### **Indoor Air Quality (IAQ) Hubs**
- Multi-sensor platforms providing CO₂, PM2.5, VOC, humidity, temp.

### **Metering Concentrator**
- Aggregates pulse inputs, M-Bus, or Modbus meters for export to BMS.

---

## Documentation & Operational Artifacts

### **Points List (I/O Schedule)**
- Defines every sensor, actuator, and software point the BMS monitors.

### **Sequence of Operations (SoO)**
- Textual specification of how plant and systems should behave.

### **Network Architecture Diagram**
- VLANs, routing, firewalls, BACnet segment boundaries.

### **As-Built Drawings**
- Final electrical, mechanical, and control wiring diagrams.

---

## Integration Interfaces

### **REST / SOAP API Endpoint**
- Used for integrating BMS with CAFM, FM, analytics platforms.

### **MQTT Broker**
- Sometimes used for modern IoT-style BMS devices.

### **OPC/OPC-UA Server**
- Common integration point for SCADA and analytics systems.

---

## Legacy & Vendor-Specific Items

### **Proprietary Fieldbus Gateways**
- Converts closed vendor protocols into Modbus or BACnet.

### **JACE / Supervisor Station**
- Tridium Niagara gateways used to normalise multiple protocols.

### **Trend IQ Controllers**
- Legacy UK building control system.
- Uses Trend LAN, Ethernet, or BACnet.

---

# Contributing
Feel free to propose additional components, particularly from specialist domains such as water treatment, CHP systems, smart-grid interfaces, and vertical transport (lifts).
