# KNX (Konnex)

KNX is a global building automation standard used primarily for lighting, shading, room control, presence detection, and small HVAC applications. Although KNX originated as a twisted-pair field bus protocol (KNX TP1), its modern implementations often include KNX/IP interfaces and routers, making KNX increasingly relevant for network engineers working in BMS and OT environments.

This chapter explains KNX architecture, group addressing, KNX/IP behaviour, multicast implications, gateway considerations, and typical integration challenges in commercial buildings.

---

## Overview

KNX is widely adopted in commercial and high-end residential environments. It excels in decentralised, room-level control rather than large mechanical plant.

Key design goals:
- High reliability  
- Vendor interoperability  
- Distributed logic (no dependency on a central server)  
- Long product longevity and backwards compatibility  

KNX supports several media types:
- **KNX TP1 (Twisted Pair)** — the most common  
- **KNX RF** (wireless)  
- **KNX IP** (Ethernet-based)  
- **Powerline (obsolete)**  

Network engineers primarily interact with KNX/IP interfaces and KNX IP routers.

---

## KNX TP1 (Twisted Pair) Fundamentals

Although TP1 does not run over IP, its behaviour influences KNX/IP integration.

### Characteristics
- 9600 bps data rate  
- 30V DC power and data on the same bus  
- Multi-drop, free topology  
- Up to 64 devices per line  
- Lines grouped into areas for large installations  

Because TP1 is slow, KNX/IP is often used to speed up backbone communication.

---

## KNX Group Addresses

KNX uses **group addresses** rather than object identifiers or registers. These group addresses define logical communication channels (e.g., “Switch Lighting On”).

Standard structure:

**Main Group / Middle Group / Sub Group**

Example:
- 1/2/3  
- Lighting/Floor 2/Office 14 switch  

Group addresses map to:
- Switch commands  
- Dimmer commands  
- Temperature setpoints  
- Presence detection  
- Blinds up/down/stop  

Group communication is typically multicast-like on TP1, and KNX/IP replicates this behaviour using Ethernet multicast.

---

## KNX/IP

KNX/IP provides:
- Transport of KNX telegrams over Ethernet  
- Backbone connections between TP1 lines  
- Tunnelling for programming tools (ETS)  
- High-speed communication between building controllers  

KNX/IP **does not** replace TP1 in most deployments; instead, it supplements it with a fast backbone and easier integration.

### Two key KNX/IP mechanisms:

1. **KNXnet/IP Routing**  
2. **KNXnet/IP Tunnelling**

---

## KNXnet/IP Routing (Multicast)

Routing is used to link KNX TP1 lines across Ethernet.

### Characteristics:
- Uses IP multicast (default address: 224.0.23.12)  
- Broadcasts KNX telegrams across participating KNX/IP routers  
- Designed for large installations  

### Network Requirements:
- IGMP snooping must be correctly configured  
- Multicast should not leak into other VLANs  
- Switches must support multicast stability  
- Flooding can occur if multicast is not constrained  

Common problems:
- Multicast storms on poorly configured switches  
- Lost telegrams due to blocked multicast  
- Router instability due to high CPU load  

KNXnet/IP routing is powerful but fragile without correct network configuration.

---

## KNXnet/IP Tunnelling (Unicast)

Tunnelling provides point-to-point unicast channels for:

- ETS (Engineering Tool Software) programming  
- BMS integrations  
- Commissioning and diagnostics  

Characteristics:
- Each tunnel requires its own connection slot  
- Many KNX devices support only a small number of tunnels (typically 4–8)  
- Unicast, so multicast is not used  

Tunnelling is far more firewall-friendly and easier to manage.

Common issues:
- Tunnel exhaustion  
- Connection drops due to network timeouts  
- Slow response if KNX TP1 bus is overloaded  

---

## KNX/IP and BMS Integration

BMS systems integrate with KNX primarily via:

- **KNX IP routers**  
- **KNX/IP gateways with datapoint export**  

Datapoints typically include:
- Lighting commands  
- Temperature setpoints  
- Valve positions  
- Presence detection  
- Dimming levels  
- Blind/shade position  

### Integration Approaches:

1. **Direct KNX/IP Group Address Export**  
   - BMS listens for group telegrams over IP multicast  
   - Requires multicast configuration on switches  

2. **Gateway with BACnet or Modbus**  
   - KNX datapoints mapped to BACnet objects or Modbus registers  
   - Easier firewalling  
   - Less dependent on multicast  

---

## Multicast Traffic Considerations

KNX routing uses Ethernet multicast heavily.

### Network engineering considerations:

- Ensure IGMP snooping is enabled  
- Ensure IGMP queriers are present in each VLAN  
- Avoid mixing KNX multicast with unrelated traffic  
- Evaluate switch CPU load (control-plane sensitivity)  
- Never run KNX multicast over Wi-Fi  

If multicast is misconfigured:
- KNX traffic floods the network  
- Telegrams are lost  
- ETS cannot program devices reliably  
- Automation logic becomes unstable  

---

## KNX and VLAN Segmentation

Best practices for KNX segmentation:
- Assign KNX/IP routers to a dedicated VLAN  
- Ensure multicast does not leak outside the KNX VLAN  
- Allow unicast tunnelling traffic where required  
- Block multicast at Layer 3 unless explicitly needed  
- If connecting multiple sites, use tunnelling, not routing  

KNX routing is rarely suitable for enterprise-scale networks without very careful multicast design.

---

## KNX Gateways

Gateways translate KNX group addresses into:
- BACnet/IP  
- Modbus TCP  
- OPC-UA  
- MQTT  

Gateways introduce:
- Latency  
- Mapping errors  
- Limited bandwidth  
- Single points of failure  

Common issues:
- Incorrect datapoint type mapping (e.g., 1-bit vs. 1-byte)  
- Missing group addresses  
- Slow bus performance due to TP1 congestion  
- Gateway TCP connection exhaustion  

---

## Security Considerations

KNX TP1 has no security whatsoever.

KNX/IP introduced **KNX Secure**, which implements:
- Encryption  
- Authentication  
- Secure key exchange  

However:
- Many deployed systems do not use KNX Secure  
- KNX/IP interfaces are often exposed on flat networks  
- Group telegrams lack authentication in non-secure deployments  

Security best practices:
- Place KNX/IP devices in isolated VLANs  
- Block KNX multicast except where needed  
- Enable KNX Secure where supported  
- Restrict ETS programming access  
- Do not expose KNX/IP to corporate VPN user networks  

---

## Common KNX Failure Scenarios

### 1. Misconfigured Multicast
Symptoms:
- Lighting commands delayed  
- Scenes fail to execute  
- Blinds respond erratically  

Cause:
- Multicast flooding or blocking  

### 2. TP1 Bus Overload
Symptoms:
- Slow system response  
- Intermittent telegram loss  

Cause:
- Too many devices on a line  
- Long cable runs  
- Poor-quality terminations  

### 3. Tunnelling Slot Exhaustion
Symptoms:
- ETS cannot connect  
- BMS integration unstable  

Cause:
- Too many active connections  

### 4. Incorrect Datapoint Type Mapping
Symptoms:
- Values appear inverted or incorrect  
- Commands do not execute  

Cause:
- Wrong DPT used in integration  

### 5. Gateway Failure or Overload
Symptoms:
- Large parts of system unresponsive  
- Partial datapoint updates  

Cause:
- Excessive polling or traffic  

---

## Troubleshooting Methodology

### Step 1: Identify whether TP1 or IP is the issue
- Check KNX/IP router logs  
- Confirm TP1 voltage  
- Verify telegram count and error rate  

### Step 2: Check Multicast Stability
- Validate IGMP snooping  
- Confirm router/querier configuration  

### Step 3: Test Tunnelling Connections
- Connect via ETS  
- Check connection slots  

### Step 4: Validate Group Address Mapping
- Confirm correct DPTs  
- Monitor live group telegrams  

### Step 5: Evaluate System Load
- Too many devices on one line  
- High traffic from motion detectors or lighting events  

---

## Summary

KNX is a reliable, flexible building automation protocol with strong vendor interoperability and decentralised logic. For network engineers, the key aspects are understanding:

- Multicast requirements (KNXnet/IP Routing)  
- Tunnelling behaviour and connection limits  
- How group addresses map to automation functions  
- Gateway behaviour when translating KNX to BACnet/Modbus  
- Security considerations, especially in older deployments  

KNX remains one of the most widely deployed lighting and room automation technologies and is increasingly integrated into enterprise BMS platforms.
