# BMS Architecture

Building Management Systems (BMS) follow a tiered architectural model that separates supervisory functions, control logic, and field-level sensing. This structure is consistent across most vendors, even if naming conventions differ. For a network engineer, understanding this hierarchy is essential to designing reliable network paths, segmentation models, and routing policies.

---

## Architectural Layers

Modern BMS deployments typically consist of three tiers:

1. **Supervisory Tier**
2. **Controller Tier**
3. **Field Device Tier**

Each layer serves a distinct role in data processing, control execution, and system monitoring.

---

## 1. Supervisory Tier

The supervisory tier is the highest level within the BMS. It is responsible for:

- Centralised monitoring  
- Data trending and storage  
- Alarm management  
- Graphics and dashboards  
- Scheduling  
- User authentication and authorisation  
- Integration between subsystems

It normally consists of:

- A **BMS Supervisor/Server** (e.g., Tridium Niagara Supervisor, Schneider EBO Enterprise Server, Siemens Desigo CC)
- **Database components**
- **Application services**
- **API/Integration layers**

Supervisory systems typically communicate with controllers using:

- **BACnet/IP**
- **Modbus TCP**
- **OPC-UA**
- Proprietary vendor APIs over HTTPS

The supervisory tier is almost always IP-based and resides within a dedicated OT VLAN or subnet. This is the tier most frequently integrated with corporate IT systems, analytics platforms, and external FM (Facilities Management) tools.

---

## 2. Controller Tier

The controller tier contains the devices executing control logic. Unlike IT servers, controllers have real-time constraints and must continue to operate autonomously during network outages.

Two main types exist:

### **Direct Digital Controllers (DDCs)**  
Used heavily in HVAC and general building automation. Responsibilities:

- Executing sequences of operation  
- Reading sensors  
- Controlling actuators  
- Managing local I/O expansion modules  
- Communicating with supervisory systems  

DDCs may speak:

- **BACnet/IP**  
- **BACnet MS/TP (RS-485)**  
- **Modbus TCP/RTU**  
- **KNX**  
- **LonWorks**  
- Vendor-specific buses  

### **Programmable Logic Controllers (PLCs)**  
Used mainly in plant rooms, industrial equipment, and high-integrity systems. Responsibilities:

- High-speed control loops  
- Deterministic operation  
- Safety interlocks  
- Complex process control  

Common communication technologies:

- **Ethernet/IP**  
- **Profinet**  
- **Modbus TCP**  
- **OPC-UA**  

In a BMS deployment, PLCs often interface with chillers, boilers, pumps, CHP units, water treatment systems, and specialist mechanical equipment.

---

## 3. Field Device Tier

This tier includes all sensors, actuators, and electromechanical components connected to controllers. Examples:

- Temperature sensors  
- Humidity sensors  
- CO₂ sensors  
- VOC sensors  
- Pressure sensors  
- Valve actuators  
- Damper actuators  
- Fan starters  
- Pump contactors  
- Meter interfaces (pulse or serial)  

Field devices may connect through:

- Hardwired I/O (0–10V, 4–20mA, digital input/output)  
- Serial buses (RS-485, manufacturer-specific)  
- KNX  
- DALI (via gateway)  
- Wireless gateways (LoRaWAN, Zigbee, BLE)  

Network engineers rarely interact with devices at this tier directly, but understanding their role and dependencies is essential for troubleshooting.

---

## IP vs. Serial Architecture

A BMS typically includes a mix of IP and serial links:

### **IP-based Components**
- Supervisors  
- IP controllers  
- Gateways  
- PLCs  
- IP sensors (newer deployments)  

Benefits:
- High bandwidth  
- Routable  
- Easier to segment  
- Supports modern security controls  

### **Serial Components**
- MS/TP controllers  
- Modbus RTU devices  
- Expansion modules  
- Legacy field devices  

Constraints:
- Not routable  
- Sensitive to cable quality and grounding  
- Limited tooling for diagnostics  
- Vendors often require fixed baud rates  

Serial traffic often passes through **gateways** that bridge field buses into IP networks.

---

## Gateways and Integration Devices

Gateways translate between communication protocols. Common examples:

- **MS/TP-to-BACnet/IP routers**  
- **Modbus RTU-to-Modbus TCP bridges**  
- **KNX-IP routers**  
- **OPC-UA servers aggregating PLC data**  

Gateways are frequently installed inside control panels. They introduce:

- Additional points of failure  
- Bandwidth/processing limits  
- Security risks if internet-connected  
- Dependency on correct addressing and routing  

Network engineers must ensure gateways are:

- Assigned fixed IPs  
- Placed in correct VLANs  
- Firewalled appropriately  
- Time-synchronised  

---

## Multi-VLAN Architecture

Larger BMS deployments split the system across several VLANs:

- **Supervisor VLAN**  
- **Controller VLAN(s)**  
- **Plant room VLANs**  
- **Lighting VLAN**  
- **Security VLAN**  
- **Metering VLAN**  
- **Vendor VLAN** (for third-party access)  

Reasons for segmentation:

- Reduce broadcast domains (BACnet is broadcast-heavy)  
- Enforce security boundaries  
- Prevent cross-system impacts  
- Improve fault isolation  
- Align with ZTA (Zero Trust Architecture) principles  

BACnet/IP deployments often require careful handling because broadcasts do not cross Layer 3 boundaries without a **BBMD (BACnet Broadcast Management Device)**.

---

## Typical BMS Architecture (Text Description)

A typical medium-size site includes:

- A **BMS server** located in the OT network  
- One or more **IP controllers** serving major plant rooms  
- Several **MS/TP networks** hanging off those controllers  
- Gateways integrating meters, CHP, boilers, and lighting  
- A firewall separating OT from IT  
- Secure remote-access path  
- NTP server for time synchronisation  
- Local/edge storage for trend data  

The network engineer ensures that:

- Each segment is routed correctly  
- Broadcasts are controlled using BBMDs  
- Supervisor-to-controller paths are reliable  
- Firewalls enforce least-privilege rules  
- Remote access does not expose controllers  
- OT traffic cannot reach corporate networks without strict filtering  

---

## Supervisory Redundancy Models

Different vendors provide different models of resilience:

### **No Redundancy (common in older sites)**
Single supervisor, manually recovered after failure.

### **Hot-Standby Redundancy**
A secondary server mirrors the primary and takes over automatically.

### **Distributed Supervisory Architecture**
Multiple supervisors manage different subsystems; integration occurs at a higher level.

### **Cloud-assisted Supervisory Systems**
Emerging model where analytics and scheduling offload to cloud services while control remains local.

Network engineers must account for:

- Cluster IPs  
- Supervisor-to-supervisor synchronisation traffic  
- Load balancing  
- Firewall rules  

---

## Key Takeaways

- BMS architecture is hierarchical: Supervisor → Controller → Field devices.  
- IP is used for supervisory and many controller-level functions; serial is still common at field level.  
- Gateways are essential but sensitive components in BMS networks.  
- VLAN segmentation and routing are critical to system performance and security.  
- Supervisory redundancy requires careful network design to avoid failover issues.  
