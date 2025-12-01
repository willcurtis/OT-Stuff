# Time Synchronisation in OT/BMS Networks

Accurate and consistent time synchronisation is critical for the correct operation of Building Management Systems (BMS) and wider Operational Technology (OT) environments. While often overlooked, time drift causes faults in scheduling, alarm correlation, logging, trends, security monitoring, and protocol behaviour.

This chapter explains how time synchronisation works in OT networks, how controllers interpret timestamps, how BMS protocols rely on accurate clocks, and how to design a reliable and secure time-distribution architecture.

---

## Why Time Synchronisation Matters in OT/BMS

BMS systems rely heavily on timestamps for:

- Trend logs and energy reporting  
- Scheduling (e.g., plant start/stop, setback, night purge)  
- Alarm generation and correlation  
- Occupancy logic  
- Controller coordination  
- Data analytics and audits  
- Change-of-Value (COV) behaviour in BACnet  
- Accurate historian data  

Without proper synchronisation:

- Trends become useless  
- Schedules fire at the wrong time  
- Alarms appear out of sequence  
- Vendor systems conflict  
- Security logs cannot be correlated  
- Machine-learning/analytics results degrade  

Time sync is foundational infrastructure—not an optional feature.

---

# How Time Synchronisation Works in OT Networks

## Common Time Protocols

### 1. **NTP (Network Time Protocol)**  
The most widely used and suitable for OT environments.  
Characteristics:
- UDP/123  
- Hierarchical “stratum” model  
- Accuracy within milliseconds  
- Secure extensions available (NTS)

### 2. **SNTP (Simple NTP)**  
A simplified version used by many controllers that cannot handle full NTP.  
Still uses UDP/123.

### 3. **BACnet Time Synchronisation Services**  
BACnet devices can:
- Broadcast Time Synchronisation requests  
- Use the BMS supervisor as time master  

These broadcasts must remain within VLAN boundaries.

### 4. **OPC-UA time sync**  
OPC-UA supports time synchronisation at the application layer but typically relies on system-level NTP.

---

# Time Drift in BMS Controllers

Many field controllers use:

- Low-cost oscillators  
- Embedded real-time clocks with poor drift accuracy  
- No battery or supercapacitor backup  
- Limited RTC compensation algorithms  

Consequences:
- Controllers drift minutes or hours over months  
- After power loss, clocks may reset to factory defaults (e.g., 1 Jan 2000)  
- Schedules fail unpredictably  

Even modern controllers can drift **1–10 seconds per day** without reliable NTP.

---

# Designing NTP Architecture for OT Networks

## Architectural Requirements

### 1. Use a dedicated OT NTP server (or two)
Do not rely on internet time or IT AD domain controllers.

### 2. Place the NTP server(s) inside the OT core or OT DMZ  
Reasons:
- Low latency  
- Predictable routing  
- Avoid cross-firewall jitter  
- Independent from IT failures  

### 3. Use multiple internal time sources
Recommended:
- 2 × stratum-2 servers  
- Optionally a GPS-based stratum-1 source for large campuses  

### 4. All OT nodes point ONLY to OT NTP servers  
Never allow controllers to query:
- Internet NTP  
- Public time pools  
- IT domain controllers (unless explicitly integrated)  

### 5. Firewall Rules  
Allow:
- UDP/123 → NTP server  
Block:
- Any NTP from OT → Internet  
- NTP requests from vendor VPN networks  

### 6. Document NTP clients  
Controllers may silently fall back to internal clocks if NTP is unreachable.

---

# NTP and BACnet

BACnet uses timestamps for:

- COV notifications  
- Scheduling objects  
- Calendar objects  
- Trend logs  
- Alarm timestamps  
- Certificate validity (for BACnet/SC)

### BACnet Broadcast Time Sync
BACnet supports time synchronisation via broadcast messages.

Limitations:

- Works only within broadcast domain  
- Not reliable across VLANs  
- Not secure  
- Not a replacement for NTP  

Prefer NTP except in legacy networks that lack NTP client support.

---

# NTP and Modbus TCP

Modbus itself has no time concept.

But devices using Modbus may:
- Store logged data using RTC  
- Report timestamped values  
- Depend on time sync for internal schedules  

Energy meters are particularly sensitive.

---

# NTP and OPC-UA

OPC-UA benefits strongly from accurate time:

- Subscriptions with timestamps  
- Event generation  
- Historical data queries  
- Certificate validation  

If time drift occurs:
- OPC-UA event ordering breaks  
- Clients reject server certificates  
- Subscriptions may fail due to old timestamps  

OPC-UA servers should ALWAYS point to the OT NTP infrastructure.

---

# NTP and KNX

KNX TP1 devices often lack accurate clocks, but KNX IP routers/gateways may provide:

- NTP client support  
- KNX time broadcast telegrams  

If using KNX time broadcasts:
- They only propagate inside KNX TP1/IP routing domains  
- Not reliable across VLANs  
- Should be backed by NTP upstream  

Time sync misalignment causes issues with:
- Scene activation  
- Scheduled blind control  
- Lighting sequences  

---

# Redundancy and Reliability

### 1. Deploy at least two NTP servers inside OT
- Place them on separate switches/UPS feeds  
- Use GPS or upstream stratum-2 IT sources optionally  

### 2. Use static IPs for all NTP sources  
Controllers often do not support DNS-based NTP entries.

### 3. Document failover behaviour  
Some controllers:
- Use first available server only  
- Never return to primary  
- Fail silently  

### 4. Monitor NTP drift  
OT monitoring should track:
- Offset  
- Jitter  
- Stratum  
- Reachability  

---

# Firewall Considerations for NTP

### Allow:
- UDP/123 from all OT subnets → OT NTP servers  
- Internal communications between redundant NTP servers  

### Block:
- OT → Internet UDP/123  
- Vendor access zones → controller VLANs  
- Controller-to-controller NTP (unless explicitly needed)  
- NTP originating from IT → OT  

Misconfigured firewall idle timers can cause intermittent NTP failures, especially in low-traffic OT networks where NTP packets are infrequent.

---

# Common Failure Scenarios

### 1. OT controllers drifting due to unreachable NTP
Symptoms:
- Schedules out of sync  
- Alarms timestamped incorrectly  
- Analytics platform misaligned  

Cause:
- Firewall blocks or missing route  

### 2. BACnet COV storms appearing out of order  
Cause:
- Controller time drift causes supervisor ordering errors  

### 3. Historian data misaligned  
Cause:
- Multiple time sources in OT  

### 4. OPC-UA certificate rejection  
Cause:
- Device clock too far from CA timestamp  

### 5. Vendor systems using internet NTP  
Cause:
- Vendor laptops bypass OT controls  

---

# Troubleshooting Methodology

### Step 1: Validate NTP reachability
Use:
- `ntpq -p`  
- Firewall logs  
- Packet captures  

### Step 2: Measure time drift on controllers
Compare controller timestamps with supervisor or NTP server.

### Step 3: Verify configuration consistency
Ensure:
- All controllers use same NTP servers  
- No stray public NTP servers configured  

### Step 4: Monitor NTP jitter and offset
High jitter indicates:
- Packet loss  
- Routing asymmetry  
- Firewall interference  

### Step 5: Inspect BACnet supervisor for time errors
Supervisors often log time mismatch warnings.

---

# Summary

Reliable time synchronisation is essential for OT/BMS stability, accurate logging, analytics, cybersecurity, and protocol behaviour. While simple in principle, time sync failures can create complex, system-wide issues.

Key principles:

- Deploy dedicated OT NTP servers  
- Block internet NTP from OT  
- Ensure all controllers use the same authoritative time source  
- Avoid reliance on BACnet or KNX time broadcasts alone  
- Monitor and audit NTP drift regularly  

Time synchronisation is a foundational building block of high-quality OT network design.
