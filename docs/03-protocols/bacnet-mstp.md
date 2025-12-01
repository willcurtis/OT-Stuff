# BACnet MS/TP (Master-Slave / Token-Passing)

BACnet MS/TP is a widely used field bus protocol for connecting building automation controllers, sensors, and actuators over RS-485 serial wiring. It predates BACnet/IP and remains heavily deployed in both legacy and modern systems, particularly in VAV networks, terminal units, fan coil controllers, and low-cost DDCs.

Although MS/TP does not run over IP networks, it has a direct impact on BACnet/IP performance when used behind gateways. Network engineers who support OT/BMS deployments must understand MS/TP behaviour because faults in the serial layer frequently appear as network issues upstream.

---

## Overview

MS/TP stands for **Master-Slave / Token-Passing**, though the protocol has evolved into a token-passing peer bus without traditional master/slave roles. It operates on:

- RS-485 physical layer  
- Half-duplex communication  
- Multi-drop topology (daisy chained)  
- Data speeds from **9.6 kbps to 76.8 kbps** (sometimes up to 115.2 kbps)

MS/TP is fundamentally different from IP-based BACnet. It is:

- Slow  
- Highly sensitive to wiring issues  
- Dependent on correct termination  
- Not routable  
- Unable to support large object models efficiently  

However, it is inexpensive, simple, and still widely used.

---

## Typical MS/TP Use Cases

MS/TP remains dominant in:

- VAV box controllers  
- FCU networks  
- Small room controllers  
- Low-cost I/O modules  
- Legacy plant equipment  
- Expansion modules for DDCs  

A typical MS/TP bus may have anywhere from **5 to 60 devices**, occasionally more.

---

## Physical Layer (RS-485)

MS/TP uses RS-485, which has the following characteristics:

- Balanced differential signalling  
- Two-wire or three-wire configurations  
- Max recommended bus length: approximately **1200 m**  
- Daisy-chain topology only (no stars or spurs)  
- Requires termination resistors at both ends  
- Requires bias resistors on the bus  

Network engineers may be asked to diagnose MS/TP faults arising from:

- Incorrect polarity  
- Loose drain/ground connections  
- Poorly terminated cable runs  
- Third-party modifications  
- Cable routing near electrical noise sources  

---

## Token Passing Mechanism

Unlike Ethernet, MS/TP does not allow devices to speak whenever they want.

### Token passing rules:

1. One device at a time holds the **token**.  
2. Only the token holder may initiate communication.  
3. Token is passed in numerical MAC address order.  
4. If a device is offline, the token bypasses it.  
5. If a device fails without releasing the token, the bus stops functioning.  

### Implications:

- A single faulty device can stall the entire network.  
- High MAC addresses extend token rotation time.  
- More devices → longer cycle times → slower data updates.  

Token timing parameters (Tusage_delay, Treply_timeout, etc.) must be tuned correctly, particularly with mixed vendor environments.

---

## MS/TP Addressing

Each MS/TP device requires:

- **A unique MAC address** (1–127; 0 is reserved)
- **Correct Max_Master setting** (must be equal to or greater than the highest MAC)

Common misconfigurations include:

- Duplicate MAC addresses → total bus collapse  
- Max_Master set too low → some devices never receive the token  
- Devices left at default addresses → collisions  

---

## Baud Rate Considerations

Supported baud rates vary by vendor:

Common speeds:
- 9600  
- 19200  
- 38400  
- 76800  

All devices on the bus **must use the same baud rate**.

Symptoms of mismatch:
- Intermittent communication  
- Slow response times  
- Devices appearing offline  
- High retry counts in BACnet/IP gateways  

Some devices auto-detect baud rate; many do not. Inconsistent baud detection is a major cause of MS/TP instability.

---

## Wiring Requirements and Common Faults

### Cable Specifications

Recommended properties:
- Twisted pair, shielded  
- Characteristic impedance: 120 ohms  
- Low capacitance  

### Frequent wiring problems:

1. **Star topology**  
   Causes reflections and bus instability.

2. **Long stubs/spurs**  
   Degrades signal quality.

3. **Improper termination**  
   Missing or extra termination leads to collisions and poor signal levels.

4. **Shield grounding errors**  
   Grounded at multiple locations → ground loops.  
   Not grounded → noise issues.

5. **Poor-quality field terminations**  
   Loose screws, corrosion, or over-stripped conductors.

6. **Electrical noise interference**  
   Cable too close to VFDs or power conductors.

### Symptoms of wiring faults:

- Random device drops  
- Very slow bus traffic  
- Token loss events  
- MS/TP → IP gateway timeouts  
- High retry count  
- Supervisory alarms without clear cause  

---

## MS/TP Gateways and Their Impact on IP Networks

MS/TP devices do not speak BACnet/IP directly. Gateways (often built into DDCs) translate between MS/TP and IP.

The gateway must:

- Collect MS/TP traffic  
- Maintain the token cycle  
- Convert BACnet objects into IP frames  
- Handle COV subscriptions  
- Buffer slow MS/TP responses  

### Network impacts:

1. **Slow MS/TP responses cause IP timeouts**  
   Supervisors assume devices are offline when the MS/TP bus is slow.

2. **Large object lists overload the gateway**  
   Some MS/TP controllers expose hundreds of objects over a bus running <50 kbps.

3. **Gateways become single points of failure**  
   If the gateway fails, the entire MS/TP segment becomes unreachable.

4. **High polling rates from supervisors collapse MS/TP**  
   Supervisors often poll too fast for MS/TP to keep up.

---

## COV (Change of Value) on MS/TP

COV is supported but is less effective on MS/TP compared to IP.

Issues include:

- Delayed notifications due to token latency  
- Poor reliability on long buses  
- Gateways buffering and releasing late notifications  

Many integrators disable COV and rely on polling.

---

## Performance and Scaling

MS/TP is slow compared to IP networks.

Typical update rates:

- A small bus (<10 devices): values update every 1–3 seconds  
- A large bus (>30 devices): values may take 10–30 seconds to update  

Adding more devices also increases:

- Token rotation time  
- Gateway processing time  
- Chance of single-device failures cascading through the bus  

BACnet/IP supervisors must be configured with realistic timeouts when polling MS/TP devices.

---

## Troubleshooting MS/TP

Effective troubleshooting requires both network knowledge and field awareness.

### Step 1: Check Physical Wiring
- Verify polarity  
- Check shielding and grounding  
- Confirm proper termination  
- Look for star topologies  
- Identify spurs/stubs  

### Step 2: Check Device Configuration
- Unique MAC addresses  
- Max_Master correctly set  
- Correct baud rate  

### Step 3: Check Token Flow
Look for:
- Token loss  
- Excessive retries  
- Long frame times  

### Step 4: Verify Gateway Behaviour
Common gateway KPIs:
- Frames per second  
- Retry count  
- Token cycle time  
- MS/TP error counters  

### Step 5: Check Supervisor Polling
Supervisors often poll too aggressively.

Reduce:
- Polling frequency  
- Number of points read  
- Unnecessary WriteProperty operations  

### Step 6: Isolate Sections
Temporarily disconnect parts of the bus to determine where faults originate.

---

## Common Failure Scenarios

### Scenario 1: Duplicate MAC Address
Symptoms:
- Bus freezes  
- Token never passes  
- Devices appear offline intermittently  

### Scenario 2: Incorrect Termination
Symptoms:
- Unstable communication  
- High error rates  
- Intermittent “device offline”  

### Scenario 3: Baud Rate Mismatch
Symptoms:
- Severe communication delays  
- Complete bus failure  

### Scenario 4: Faulty Device Holding Token
Symptoms:
- Entire MS/TP network offline  
- Gateway reports token timeout  

### Scenario 5: Long Stub Created During Maintenance
Symptoms:
- Bus instability following contractor work  

### Scenario 6: Gateway Overloaded
Symptoms:
- BACnet/IP supervisor timeouts  
- “Device unreachable” errors  

---

## Summary

BACnet MS/TP is a low-cost and widely deployed building automation bus. It is sensitive to cabling, termination, device configuration, and load. Small faults in the MS/TP layer frequently manifest as BACnet/IP issues upstream, making MS/TP a critical area for network engineers to understand.

Key principles:

- MS/TP is slow and easily overloaded.  
- Gateways are bottlenecks and single points of failure.  
- Wiring quality affects network-level performance.  
- MAC addressing rules are strict and must be followed.  
- Polling must be tuned to MS/TP capabilities.  

A solid understanding of MS/TP drastically improves the ability to diagnose BACnet/IP performance issues and build reliable networks for BMS systems.
