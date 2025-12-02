# OT/BMS Data Flow Reference  
**Detailed End-to-End Data Flows for BACnet/IP, BACnet/SC, KNX, Modbus, MQTT, Lighting Protocols, IoT Wireless, and Vendor Access**

The OT network interconnects dozens of subsystems, each with unique traffic patterns, broadcast behaviours, and integration constraints.  
Understanding the data flows is essential for designing secure, deterministic, and maintainable architectures.

This chapter presents reference data flows for all major OT/BMS subsystems, using both ASCII and Mermaid diagrams.

---

# 1. BACnet/IP Data Flow

BACnet/IP is a broadcast-heavy protocol.  
Its traffic *must stay local to each building* and must not traverse routed boundaries unnecessarily.

### Key Flow Characteristics:
- Uses UDP 47808  
- Frequent broadcasts (“Who-Is”, “I-Am”)  
- Supervisors poll devices via unicast / broadcast  
- BBMD is rarely needed and discouraged  
- OT firewalls must block broadcast crossing  

### ASCII Data Flow

Controllers (BACnet/IP)
|
v
Access Switch (Floor)
|
v
Distribution Switch (Riser)
|
Routed Boundary
|
v
OT Core
|
v
OT DMZ (Supervisor)

### Mermaid Diagram

```mermaid
flowchart LR
    C[Controllers] --> A[Access Switch]
    A --> D[Distribution Switch]
    D --> CORE[OT Core Router]
    CORE --> DMZ[OT DMZ - BACnet Supervisor]

BACnet Read Path:
	•	Supervisor → Unicast: ReadProperty
	•	Supervisor → Broadcast: Who-Is
	•	Controllers → Broadcast: I-Am


# 2. BACnet/SC (Secure Connect) Data Flow

BACnet/SC replaces broadcast with TLS-secured WebSockets.

Characteristics:
	•	Outbound-only connections from controllers
	•	No broadcast storms
	•	Central hub in DMZ
	•	IT systems can safely subscribe via the hub

ASCII Data Flow

 Controller → TLS → BACnet/SC Hub (DMZ) → Supervisor → IT Consumers

```mermaid
flowchart LR
    C[Controller] --TLS/WebSocket--> HUB[BACnet/SC Hub (DMZ)]
    HUB --> SUP[BMS Supervisor]
    SUP --> IT[IT Consumers]

This is the preferred multi-building BACnet architecture.

# 3. KNX IP Data Flow

Only multicast packets remain inside each KNX VLAN.

Characteristics:
	•	Multicast 224.0.23.12
	•	IP routers connect TP (twisted pair) → IP
	•	Tunnelling connections used for commissioning
	•	IGMP snooping mandatory

KNX TP Devices → KNX IP Router → Access Switch → Distribution → OT Core → DMZ (Optional Logic Engines)

```mermaid
flowchart LR
    TP[KNX TP Bus] --> RTR[KNX IP Router]
    RTR --> A[Access Switch]
    A --> D[Distribution]
    D --> CORE[OT Core]
    CORE --> DMZ[Logic Engine / Supervisor]

Multicast does not cross firewalls.

# 4. Modbus TCP Data Flow

Modbus TCP is a simple request/response protocol.

Flow:
	•	Supervisor or gateway polls devices
	•	No multicast
	•	No discovery
	•	Poll rates must be controlled

Supervisor (DMZ)
     |
     v
 OT Firewall (strict ACLs)
     |
     v
 Modbus Gateway (Riser)
     |
     v
 Modbus RTU Devices (RS-485)

```mermaid
flowchart LR
    SUP[Supervisor] --> FW[OT Firewall]
    FW --> GW[Modbus TCP Gateway]
    GW --> RTU(Modbus RTU Devices)

# 5. MQTT Data Flow

MQTT is publish/subscribe with a broker acting as the exchange point.

Typical Roles:
	•	Sensors publish telemetry
	•	Supervisors subscribe
	•	Broker lives in DMZ
	•	TLS mandatory

IoT Sensors → MQTT Broker (DMZ) ←→ Supervisors / Analytics / IT Dashboards

```mermaid
flowchart LR
    S[IoT Sensors] --publish--> BRK[MQTT Broker (DMZ)]
    BRK --subscribe--> SUP[Supervisor]
    BRK --exports--> IT[IT Analytics]

MQTT is ideal for IoT sensor consolidation.

# 6. OPC-UA Data Flow

OPC-UA acts as the normalised data layer between OT and IT.

Flow:
	•	Gateways expose nodes
	•	Aggregator in DMZ
	•	IT systems read from DMZ only

Controllers → OPC-UA Gateway → DMZ Aggregator → IT Consumers

```mermaid
flowchart LR
    C[Controllers] --> GW[OPC-UA Gateway]
    GW --> AGG[OPC-UA Aggregator (DMZ)]
    AGG --> IT[IT Consumers]

# 7. DALI (Lighting) Data Flow

DALI itself is not IP-based but gateways expose it upstream.

Flow:
	•	DALI drivers ↔ DALI Gateway
	•	Gateway → BACnet/Modbus/MQTT/REST

DALI Bus → DALI Gateway → OT VLAN → OT Core → DMZ → Supervisor

```mermaid
flowchart LR
    DALI[DALI Bus] --> GW[DALI Gateway]
    GW --> NET[OT Network]
    NET --> DMZ[Supervisor in DMZ]

# 8. DMX / Art-Net / sACN Data Flow

These are high-rate lighting control protocols.

Flow Notes:
	•	Art-Net may use broadcast
	•	sACN uses multicast
	•	Never routed across buildings
	•	VLAN containment mandatory

Lighting Controller (DMZ or OT VLAN)
       |
       v
 Art-Net/sACN
       |
       v
 DMX Nodes ↔ Fixtures

```mermaid
flowchart LR
    CTRL[Lighting Controller] --> ART[Art-Net/sACN VLAN]
    ART --> NODE[DMX Node]
    NODE --> FX[Fixtures]

# 9. Wireless Gateways (LoRaWAN, Zigbee, Thread)

Wireless protocols always terminate at IP gateways.

9.1 LoRaWAN

LoRa Sensors → Gateway → Network Server (DMZ) → MQTT/API → OT/IT Analytics

```mermaid
flowchart LR
    LORA[LoRa Sensors] --> GW[LoRa Gateway]
    GW --> NS[Network Server (DMZ)]
    NS --> MQTT[MQTT Broker]
    MQTT --> OT[OT Analytics]
    MQTT --> IT[IT Analytics]

9.2 Zigbee / Thread / BLE

Wireless Mesh → IP Gateway → MQTT/REST → Supervisor/Analytics

```mermaid
flowchart LR
    W[Wireless Mesh] --> G[IP Gateway]
    G --> BRK[MQTT Broker]
    BRK --> SUP[Supervisor]

# 10. VRF/VRV HVAC Data Flow

VRF/VRV systems often use proprietary gateways.

Indoor Units → Outdoor Unit → Vendor Gateway → OT VLAN → Supervisor

```mermaid
flowchart LR
    IN[Indoor Units] --> OUT[Outdoor Unit]
    OUT --> GW[VRF Gateway]
    GW --> NET[OT VLAN]
    NET --> SUP[Supervisor]

# 11. Lift (Elevator) Integration Flow

Lifts must be isolated from OT except through a controlled gateway.

Lift Controller → Lift Gateway → DMZ → BMS Supervisor (read-only)

```mermaid
flowchart LR
    LIFT[Lift Controller] --> GW[Lift Gateway]
    GW --> DMZ[DMZ Integration]
    DMZ --> BMS[BMS Supervisor (RO)]

No writes should be permitted.

# 12. Fire System Integration Flow

Fire systems cannot depend on OT. A one-way gateway is preferred.

Fire Panel → Read-Only Gateway → OT DMZ → Supervisor

```mermaid
flowchart LR
    FP[Fire Panel] --> RO[Read-Only Gateway]
    RO --> DMZ[DMZ]
    DMZ --> SUP[Supervisor (RO)]

# 13. OT → DMZ → IT Data Flow (Zero Trust)

OT VLANs → OT Core Firewall → OT DMZ → IT Firewall → IT Consumers

```mermaid
flowchart LR
    OT[OT VLANs] --> FW1[OT Firewall]
    FW1 --> DMZ[OT DMZ]
    DMZ --> FW2[IT Firewall]
    FW2 --> IT[IT Network]

Flows always travel through two firewalls.

# 14. Vendor Remote Access Flow

Vendor → VPN → IT Firewall → DMZ Jump Host → OT Firewall → OT Systems

```mermaid
flowchart LR
    V[Vendor] --> VPN[VPN (MFA)]
    VPN --> FW1[IT Firewall]
    FW1 --> JH[DMZ Jump Host]
    JH --> FW2[OT Firewall]
    FW2 --> SYS[OT Systems]

# 15. Combined OT Protocol Flow Map (High-Level)

```mermaid
flowchart TD
    BAC[ BACnet/IP VLAN ] --> CORE
    BACSC[ BACnet/SC ] --> DMZ
    KNX[ KNX IP VLAN ] --> CORE
    MOD[ Modbus TCP Gateways ] --> CORE
    MQTT[ MQTT Brokers ] --> DMZ
    OPC[ OPC-UA Aggregator ] --> DMZ
    DALI[ DALI Gateways ] --> CORE
    LGT[ Lighting Art-Net/sACN ] --> CORE
    IOT[ Wireless Gateways ] --> DMZ
    CORE[ OT Core ] --> DMZ[ OT DMZ ]
    DMZ --> IT[ IT Consumers ]

16. Implementation Checklist

Segmentation
	•	Each protocol isolated per VLAN
	•	No cross-building L2
	•	Lighting/multicast traffic contained

Routing
	•	BACnet broadcast blocked across L3
	•	KNX multicast IGMP scoped
	•	MQTT/OPC components live in DMZ

Security
	•	Zero-trust remote access enforced
	•	Fire systems read-only
	•	Lift systems read-only
	•	Vendor access audited

Monitoring
	•	Data flow anomalies detected
	•	Multicast load visible
	•	Protocol heartbeat checks implemented

⸻

Summary

This reference provides a complete overview of how data flows across OT/BMS environments.
Proper data flow mapping ensures:
	•	Secure boundaries
	•	Predictable system behaviour
	•	Broadcast containment
	•	Reduced integration risks
	•	Easier troubleshooting
	•	Faster onboarding of new systems

A consistent flow architecture is foundational to a resilient OT network.

---

