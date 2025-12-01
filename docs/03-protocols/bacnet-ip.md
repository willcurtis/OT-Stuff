# BACnet/IP (Building Automation and Control Network over IP)

BACnet/IP is the most widely deployed communication protocol in modern Building Management Systems (BMS). It was designed specifically for building automation and remains the dominant standard for HVAC, lighting, metering, and environmental control systems. Understanding BACnet/IP is essential for network engineers working in Operational Technology (OT), as the protocol behaves differently from conventional IT traffic and introduces unique architectural and security challenges.

This document provides a detailed explanation of BACnet/IP behaviour, packet flows, addressing, broadcast requirements, BBMD functions, performance considerations, and troubleshooting methodologies.

---

## Overview of BACnet

BACnet (Building Automation and Control Network) is an ASHRAE standard (ANSI/ASHRAE 135). BACnet supports multiple data link layers, including:

- **BACnet/IP** (over UDP/IP)
- **BACnet MS/TP** (over RS-485)
- **BACnet Ethernet** (rare today)
- **BACnet over ARCNET** (obsolete)
- **BACnet/IPv6** (emerging but uncommon)

BACnet/IP is the version that runs over standard Ethernet/TCP/IP architecture and is the focus of this manual.

---

## BACnet/IP Key Characteristics

### 1. UDP-Based
BACnet/IP uses:
- UDP port **47808** (0xBAC0) by default
- Vendor variations: 47809, 47810, etc.

BACnet/IP is connectionless — there is no session establishment like TCP.

### 2. Broadcast Heavy
Device discovery, segmentation announcements, and general-purpose queries all rely on broadcast traffic.

Main broadcasts:
- **Who-Is** (supervisor asks devices to identify themselves)
- **I-Am** (devices respond with their identity)
- **I-Have / Who-Has**
- **Time sync messages**
- **Foreign Device Registrations (BDT/FD)** in BBMD deployments

Broadcasts do **not cross Layer 3 boundaries** without additional components (BBMDs).

### 3. Revisable Address Scheme
BACnet/IP includes:
- IP addressing  
- BACnet device instances  
- BACnet network numbers  
- Object identifiers  

All must be correct for reliable operation.

### 4. Object-Oriented Data Model
BACnet exposes building data as structured objects:
- Analog Input (AI)
- Analog Output (AO)
- Analog Value (AV)
- Binary Input (BI)
- Binary Output (BO)
- Binary Value (BV)
- Multi-State Value (MSV)
- Device Object
- Trend Log
- Schedule

Network engineers rarely interact with objects directly, but understanding their volume and update rates helps diagnose traffic load issues.

---

## BACnet Device Instance

A **BACnet Device Instance** is a unique identifier for each device across the entire BACnet ecosystem on a site.

- Range: **0 to 4,194,302**
- Must be **unique** across all IP and MS/TP devices on the site.
- Duplicates cause supervisors to behave unpredictably.

Network symptoms of duplicate device instances include:
- Controllers switching between online/offline states
- Trend logs failing
- COV subscriptions unstable
- “Device mismatch” errors

---

## BACnet Network Number

BACnet introduces logical network numbers for routing between different segments.

Key rules:
- Each IP subnet should have a unique network number (when routing)
- MS/TP networks each require their own network number
- Network numbers must not be reused across routed segments

Many poorly designed BMS deployments reuse the same network number across multiple VLANs, causing routing loops and supervisor confusion.

---

## BACnet/IP Packet Structure (Conceptual Description)

BACnet/IP frames travel over:

- Ethernet  
- IP  
- UDP  
- BACnet Virtual Link Control (BVLL)  
- NPDU (Network Protocol Data Unit)  
- APDU (Application Protocol Data Unit)  

In simplified terms:

**Ethernet → IP → UDP → BVLL → NPDU → APDU**

### Key elements:

**BVLL**  
Encapsulates BACnet messages into IPv4 UDP.

**NPDU**  
Contains routing information such as network numbers.

**APDU**  
Contains application-level content:
- ReadProperty
- WriteProperty
- SubscribeCOV
- ConfirmedCOVNotification

APDU sizes directly affect fragmentation and response times.

---

## Broadcast Behaviour

BACnet/IP discovery revolves around broadcasts:

### Who-Is
Supervisors broadcast a Who-Is to determine which devices exist.

### I-Am
Devices reply unicast or broadcast with device instance and addressing details.

### Who-Has / I-Have
Used for discovering specific object identifiers.

### Issues caused by excessive broadcasts:
- High CPU load on controllers
- Increased supervisor processing time
- Unpredictable behaviour on underpowered switches
- Performance collapse on Wi-Fi or VPN overlays

BACnet/IP expects a stable LAN — not wireless, not high-latency networks, not congested VLANs.

---

## Foreign Device Registration (FDR)

Foreign devices (devices outside a BACnet broadcast domain) register with a **BBMD** so they can participate in BACnet broadcasts.

Example:
- Remote engineer connected via VPN  
- Remote BACnet client using BACnet Explorer  
- Supervisors spanning multiple routed networks

Foreign devices register with:
- **BBMD address**
- **TTL** (Time To Live)

FDR is fragile and often misconfigured.

---

## BBMD (BACnet Broadcast Management Device)

A BBMD allows BACnet broadcasts to be forwarded between different IP subnets.

BBMDs:
- Maintain a **Broadcast Distribution Table (BDT)**
- Forward broadcasts using **Directed Broadcast**  
- Support **Foreign Device Registration**

Common issues:
- Missing BBMD entries
- Duplicate entries
- Incorrect subnet masks
- Wrong TTL in FDR clients

BBMD problems often manifest as:
- Devices online in one VLAN but offline elsewhere
- Supervisor alarm floods
- Trend logs missing data

---

## BACnet/IP VLAN Segmentation

BACnet/IP often requires segmentation for:

- Security  
- Traffic isolation  
- Fault domain control  
- Vendor separation  

BACnet can operate safely across multiple VLANs **if**:
- BBMDs are configured correctly  
- Device instances are unique  
- Network numbers do not clash  
- Supervisory routing is properly configured  

Best practice:
- One BACnet network number per VLAN  
- One BBMD per BACnet IP segment  
- Supervisory system acts as a router only when required  

---

## BACnet COV (Change of Value)

COV is an event-driven model:

- Controllers send updates only when values change beyond a threshold.
- Reduces polling load.
- Imported points remain fresh without constant reads.

COV is beneficial, but many integrators disable it.

Common issues:
- Supervisors overusing polling instead  
- Controllers overloaded by excessive COV subscriptions  
- Missed updates due to lost notifications  

Network implications:
- COV reduces bandwidth dramatically
- COV requires stable unicast paths between controller and supervisor

---

## BACnet Time Synchronisation

Many BACnet devices rely on time sync messages:

- TimeSynchronisation  
- UTCTimeSynchronisation  

If devices lose sync:
- Trend logs become misaligned  
- Schedules behave incorrectly  
- Supervisors misinterpret alarms  

Network engineers should provide:
- A reliable NTP source  
- Firewall rules allowing required traffic  

---

## BACnet Security (or lack thereof)

BACnet/IP was not designed with modern security in mind.

### Major weaknesses:

- No encryption (all data in clear text)
- No authentication (ReadProperty and WriteProperty are open)
- Broadcast-dependent
- Susceptible to spoofing
- Weak or no password mechanisms in many controllers

### Consequences:

- Anyone on the BACnet VLAN can discover devices and write control points  
- Malware can rogue broadcast Who-Is to overload controllers  
- Attackers can change setpoints or disable alarms undetected  

### Network mitigations:

- Strict VLAN separation  
- Layer 3 filtering (block all but necessary devices)  
- ACLs preventing east-west controller traffic  
- Supervisory-to-controller only flow model  
- No direct access from IT networks  
- No controller exposure to corporate VPNs  
- Separate vendor access VLAN with firewall rules  

---

## Common Failure Scenarios

### 1. Duplicate Device Instance
Symptoms:
- Devices flick online/offline  
- Trend data failing  
- Alarms unstable  

### 2. Missing BBMD Entries
Symptoms:
- Devices online in one VLAN but not visible across others  
- Only some messages delivered  

### 3. Excessive Who-Is Traffic
Symptoms:
- CPU overload  
- Delayed responses  
- Controllers appear offline intermittently  

### 4. Subnet Mask Misconfiguration
Symptoms:
- Some devices reachable, others not  
- BBMD fails to distribute broadcasts  

### 5. Routing Loops in BACnet Network Numbers
Symptoms:
- Unpredictable routing  
- Controller instability  
- Supervisor hangs  

### 6. Overpolling by the Supervisor
Symptoms:
- High network traffic  
- Controller performance issues  
- Slow UI and trending failures  

---

## BACnet Troubleshooting Methodology

A structured approach is critical when diagnosing BACnet faults.

### Step 1: Verify Layer 1/2
- Controller powered and online  
- Correct VLAN assignment  
- No duplicate MAC addresses  

### Step 2: Verify IP Layer
Check:
- IP address  
- Subnet mask  
- Gateway  
- Ping reachability  
- UDP/47808 accessibility  

### Step 3: Check BACnet Layer
Validate:
- Device instance uniqueness  
- Network number correctness  
- BBMD configuration  
- FDR status  
- Broadcast behaviour  

### Step 4: Validate Application Layer
Check:
- Object availability  
- Property values  
- COV subscriptions  
- Point scaling  

### Step 5: Analyze Traffic
Look for:
- Excessive Who-Is  
- Non-stop ReadProperty requests  
- Missing I-Am responses  

### Step 6: Verify Supervisor Behaviour
Confirm:
- Polling intervals  
- Trending configurations  
- Alarm routing  
- Firmware compatibility  

---

## Summary

BACnet/IP is a flexible but fragile protocol. It is simple to deploy in small environments but becomes extremely complex at scale. Network engineers supporting BACnet/IP must understand:

- Broadcast dependencies  
- BBMD and FDR behaviour  
- Device instance uniqueness  
- VLAN and routing implications  
- Polling vs COV behaviour  
- Security weaknesses  
- Gateway impacts  

With these concepts mastered, BACnet/IP becomes predictable and supportable, even in large enterprise deployments.
