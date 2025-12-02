# Modbus Deep Dive  
**Modbus RTU & Modbus TCP — Protocol Internals, Gateways, Polling, Tuning, Troubleshooting**

Modbus is one of the most widely deployed industrial and BMS protocols.  
It is simple, lightweight, and universally supported—but also insecure, ambiguous, and prone to implementation errors.

This chapter provides a complete technical and practical reference for Modbus in OT/BMS environments.

---

# 1. Modbus Architecture Overview

Modbus comes in two main variants:

| Variant | Transport | Notes |
|--------|-----------|-------|
| **Modbus RTU** | RS-485 (2-wire or 4-wire), serial | Oldest format, still widely used |
| **Modbus TCP** | TCP/IP port 502 | Most common in modern BMS |
| **Modbus ASCII** | Rare | Legacy hardware |

Modbus is a simple **request-response** protocol.  
The client (master) polls devices; the server (slave) responds.

**There is no discovery mechanism.**  
Everything depends on knowing register maps, addresses, and wiring.

---

# 2. Modbus Function Codes

Function codes define what operation is being performed.

## 2.1 Common Function Codes

| Code | Name | Type | Description |
|------|-------|-------|-------------|
| **01** | Read Coils | Digital | Read on/off outputs |
| **02** | Read Discrete Inputs | Digital | Read on/off inputs |
| **03** | Read Holding Registers | Analog | Read writable registers (most common) |
| **04** | Read Input Registers | Analog | Read sensor/readonly registers |
| **05** | Write Single Coil | Digital | Write 0/1 |
| **06** | Write Single Register | Analog | Write integer value |
| **15** | Write Multiple Coils | Digital | Batch writes |
| **16** | Write Multiple Registers | Analog | Batch writes |

**FC03 / Read Holding Registers** is the most widely used function in BMS.

## 2.2 Less Common Function Codes

| Code | Name | Notes |
|------|------|-------|
| 08 | Diagnostics | Vendor-specific quirks |
| 20/21 | File Record Read/Write | Rare |
| 22 | Mask Write Register | Used in power meters |
| 23 | Read/Write Multiple Registers | Some gateways support, others don’t |

---

# 3. The Modbus Register Model

Registers are arranged in 4 reference types:

| Reference | Type | Range | Description |
|-----------|------|--------|-------------|
| **0xxxx** | Coils | RW | Boolean output |
| **1xxxx** | Discrete Inputs | RO | Boolean input |
| **3xxxx** | Input Registers | RO | Sensor readings |
| **4xxxx** | Holding Registers | RW | Writable values |

Important:

- The 0xxxx/1xxxx/3xxxx/4xxxx prefixes **do not appear on the wire**.  
- Actual register addresses are **zero-based**.  
- Vendors often diverge (e.g., 40001 is actually 0 on the wire).

This causes endless confusion.

---

# 4. Data Encoding & Endianness

Modbus registers are **16-bit words**.

### Common Encoding Types
- **16-bit integer**
- **32-bit integer** (2 registers)
- **32-bit float** (2 registers)
- **64-bit float** (rare)
- **Boolean (bit-packed)**

### Endianness Variants (32-bit)
| Format | Word Order | Byte Order | Notes |
|--------|-------------|-------------|-------|
| **Big-Endian** | AB CD | Standard Modbus |
| **Little-Endian** | CD AB | Common edge case |
| **Word-swapped** | CD AB or BA DC | Used by many power meters |

You MUST know the register documentation for each device — there is no negotiation.

---

# 5. Modbus RTU (RS-485) Technical Deep Dive

Modbus RTU uses serial frames:

| silence | Address | Function | Data | CRC | silence |

Key characteristics:

- 1 master limits throughput  
- Up to 247 slave addresses (0 reserved for broadcast)  
- Tokenless half-duplex bus  
- Timing-critical (3.5 char silence before/after frames)  
- Cable length up to ~1200m  
- Typically daisy-chained  
- Requires termination and biasing resistors  

### 5.1 RTU Failure Modes
- Reflections due to missing termination  
- Vendors using the same slave address  
- Noise/interference causing CRC errors  
- Long chains (>30 nodes) causing slow response  
- Mixed baud rates on multi-drop bus  

### 5.2 Recommended Wiring Guidelines
- Shielded twisted pair, grounded at one end  
- Short stub lengths (< 1m)  
- Terminate both ends of bus  
- Avoid star topologies  
- Keep electrically noisy devices away from the bus  

---

# 6. Modbus TCP Technical Deep Dive

Modbus TCP wraps Modbus frames in a TCP/IP header:

MBAP Header (Transaction ID, Length, Unit ID)
Function Code
Data

Key characteristics:

- No timing constraints  
- No bus length issues  
- Fast and easy to scale (but easy to overload)  
- Supports parallel connections  
- Gateways convert TCP <-> RTU  

### 6.1 Unit ID in Modbus TCP
- Used when Modbus TCP is forwarded to an RTU bus  
- Often ignored for pure TCP devices  
- Some devices misuse Unit ID as device ID  

---

# 7. Modbus TCP Gateways

Gateways translate Modbus TCP to Modbus RTU.

### 7.1 How Gateways Work
- Accept TCP requests  
- Queue requests  
- Send to RTU bus sequentially  
- Wait for response  
- Forward back to TCP client  

### 7.2 Gateway Bottlenecks
- RTU bus is slow; TCP is fast  
- Too many TCP clients cause queue collapse  
- Long register blocks cause RTU timeout  
- Large RTU networks overwhelm gateway CPU  
- Polling too frequently starves the bus  

### 7.3 Gateway Tuning
- Polling interval ≥ 1–3 seconds per device  
- Limit number of registers per request (<50 recommended)  
- Avoid multiple clients polling same register map  
- Use **one gateway per RTU bus**, not shared across building  

---

# 8. Polling Strategy & Performance Tuning

Modbus is **poll-based**, so performance depends entirely on polling strategy.

### Recommended Polling Intervals
| Device Type | Polling Interval |
|-------------|------------------|
| Power meter | 2–10 seconds |
| Water/gas meter | 30–120 seconds |
| UPS | 3–10 seconds |
| Generator | 2–5 seconds |
| HVAC gateway | 2–10 seconds |
| Solar inverters | 5–30 seconds |

### Avoid:
- Polling faster than device datasheet specifies  
- Polling > 50 registers per request  
- Polling thousands of registers via a small RTU gateway  

### Golden Rule:
**Slow down polling; it increases stability.**

---

# 9. Modbus Error Codes

Modbus exceptions:

| Code | Meaning |
|------|---------|
| 01 | Illegal Function |
| 02 | Illegal Data Address |
| 03 | Illegal Data Value |
| 04 | Server Failure |
| 05 | Acknowledge (processing) |
| 06 | Busy |
| 0x0B | Gateway Target Device Failed |
| 0x0C | Gateway Path Unavailable |

RTU-specific errors:
- **CRC mismatch**  
- **Timeout**  
- **Malformed response**  

TCP-specific errors:
- **Connection refused/reset**  
- **Unexpected close**  
- **Multiple clients collision**  

---

# 10. Security Weaknesses in Modbus

Modbus has **no built-in security**.

- No encryption  
- No authentication  
- No integrity checking beyond CRC  
- Anyone with access can write registers  
- Replayable  
- Impersonation is trivial  
- No role-based access  

### Attack Scenarios:
- Write coil to disable HVAC  
- Change generator modes  
- Modify metering data  
- Disable alarms  
- Inject false readings  
- Crash gateway via malformed packets  
- Flood gateway causing RTU starvation  

---

# 11. Securing Modbus in OT Networks

### Mandatory Controls:
- VLAN isolation  
- Deny-all firewall rules  
- Supervisors permitted only to read/write needed addresses  
- Gateways placed in isolated VLANs  
- No cloud access from Modbus networks  
- OT/IT DMZ for any integration  
- Jump host for vendor access  
- Disable write registers unless required  

### Recommended:
- Rate limiting  
- Gateway ACLs  
- SIEM logging for write operations  
- Duplicate gateway for redundancy in critical systems  

---

# 12. Deployment Patterns by Building Type

## 12.1 Data Centres
- Power meters everywhere  
- UPS, PDUs, ATS, generator monitoring  
- Modbus TCP common  
- Poll slowly to avoid UPS overload  
- Use separate VLAN for power metering  

## 12.2 Shopping Centres
- Tenant metering  
- EV charger integration  
- Water/gas usage trending  
- Gateways per tenant riser  

## 12.3 Hotels & Hospitality
- Energy metering per floor  
- Hot water plant monitoring  
- Kitchen equipment monitoring  
- Isolate Modbus VLAN from guest networks  

## 12.4 Industrial
- Heavy Modbus use  
- SCADA + BMS both polling the same devices — coordinate carefully  
- Long RTU chains common  
- Use redundant gateways for critical processes  

## 12.5 University Campus
- Solar PV  
- CHP units  
- Smart lab equipment  
- Trend polling via OPC-UA recommended for large datasets  

## 12.6 Mixed-Use Buildings
- Tenant billing  
- EV chargers  
- Shared plant metering  
- Security risk if tenants exposed to Modbus VLAN  

---

# 13. Troubleshooting Modbus

## 13.1 Common Symptoms & Root Causes

| Symptom | Likely Cause |
|---------|--------------|
| Timeouts | Polling too fast / wiring faults / address clashes |
| CRC errors | Electrical noise or cable fault |
| Illegal Address | Wrong register map |
| Gateway overload | Too many registers or clients |
| Value always zero | Wrong endianness |
| Device not responding | Slave address mismatch |

## 13.2 Diagnostic Tools
- Modbus Poll / ModScan  
- QModMaster  
- Wireshark (Modbus dissector)  
- Vendor test tools  
- oscilloscope for RTU troubleshooting  

---

# 14. Modbus Implementation Checklist

### Wiring & Addressing
- [ ] Unique RTU slave addresses  
- [ ] Proper termination & biasing  
- [ ] RTU segment lengths within limits  

### Gateways
- [ ] One RTU bus per gateway  
- [ ] Poll intervals within vendor guidelines  
- [ ] Limited register block sizes  

### Security
- [ ] VLAN isolation  
- [ ] Firewall-limited reachability  
- [ ] Writes restricted  
- [ ] Remote access via jump host  

### Monitoring
- [ ] Track gateway CPU load  
- [ ] Detect polling failures  
- [ ] Log all Modbus writes  
- [ ] Monitor device offline events  

---

# Summary

Modbus is simple, ubiquitous, and essential—but also fragile, insecure, and easy to overload.  
Successful Modbus deployments rely on careful polling strategy, strict segmentation, well-configured gateways, and strong firewall controls.

Key principles:

- Keep RTU chains short  
- Slow the polling rate  
- Limit register block size  
- Use separate VLANs for gateways  
- Secure access with firewalls + DMZ  
- Avoid simultaneous SCADA and BMS polling  
- Log and restrict write operations  

A well-engineered Modbus network is stable, predictable, and supportable—even at scale.
