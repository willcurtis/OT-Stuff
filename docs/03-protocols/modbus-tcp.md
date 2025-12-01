# Modbus TCP

Modbus TCP is one of the most widely used industrial communication protocols for integrating mechanical plant equipment, meters, drives, boilers, chillers, and energy systems into a Building Management System (BMS). It is simple, stable, and supported by almost every industrial and building-services manufacturer. However, its simplicity introduces challenges around polling efficiency, register mapping, network load, and security.

This chapter provides a detailed technical analysis of Modbus TCP for network engineers working in Operational Technology (OT) environments.

---

## Overview of Modbus Protocol Family

Modbus exists in multiple variants:

- **Modbus TCP** (Ethernet-based, port 502)
- **Modbus RTU** (serial RS-485)
- **Modbus ASCII** (rare)
- **Modbus Plus, Modbus over UDP** (legacy/specialised)

Modbus TCP is the most relevant to modern OT networks.

### Key Characteristics:

- Master–slave architecture  
- Polling-based communication  
- Lightweight, simple packet structure  
- No security (plaintext data, no authentication)  
- Widely supported across PLCs, drives, chillers, boilers, meters, BMS gateways  

Modbus TCP is not event-driven; it relies entirely on the master (usually the BMS supervisor or gateway) to request data.

---

## Modbus TCP Architecture

Modbus TCP runs on:

- Ethernet (standard IEEE 802.3)
- IPv4 (IPv6 in some implementations)
- **TCP port 502**

The communication model is:

**Client (Master) → Server (Slave)**

The Modbus “server” is typically:

- A PLC  
- A gateway device  
- A chiller/boiler controller  
- A VFD (Variable Frequency Drive)  
- An energy meter  
- Any device exporting Modbus registers via IP  

The Modbus “client” is typically:

- A BMS supervisory server  
- A DDC controller acting as a master  
- A data logger or analytic engine  

There is no auto-discovery; everything depends on correct register mapping.

---

## Modbus Register Types

Modbus defines four logical register areas:

1. **Coils (00001–09999)**  
   - Read/write  
   - Single-bit values  

2. **Discrete Inputs (10001–19999)**  
   - Read-only  
   - Single-bit values  

3. **Input Registers (30001–39999)**  
   - Read-only  
   - 16-bit values  

4. **Holding Registers (40001–49999)**  
   - Read/write  
   - 16-bit values  

Most useful data (temperatures, pressures, setpoints) are held in **Input** or **Holding Registers**.

---

## Typical Data Formats in Modbus

Registers are 16-bit values, but equipment often uses:

- 32-bit integers  
- 32-bit floats  
- 48- or 64-bit values  
- Signed or unsigned numbers  
- Strings (rare but possible)  

Because Modbus only moves 16-bit chunks, multi-register values require:

- Correct endianness  
- Correct register ordering  
- Correct data type mapping  

### Common Endianness Issues

Manufacturers use one of several formats:

- Big-endian words, big-endian bytes  
- Little-endian words, little-endian bytes  
- Mixed formats (common)  

Symptoms of incorrect endianness:

- Negative temperatures  
- Impossible values (9999, -32768, etc.)  
- Swapped bytes leading to unrealistic readings  

---

## Function Codes (FC)

Modbus TCP uses specific **function codes** to perform read/write operations:

### Common Function Codes

- **FC1 – Read Coils**  
- **FC2 – Read Discrete Inputs**  
- **FC3 – Read Holding Registers**  
- **FC4 – Read Input Registers**  
- **FC5 – Write Single Coil**  
- **FC6 – Write Single Holding Register**  
- **FC15 – Write Multiple Coils**  
- **FC16 – Write Multiple Holding Registers**  

BMS systems predominantly use:

- FC3  
- FC4  
- FC6  
- FC16  

---

## Polling Behaviour

Modbus TCP is **entirely polling-based**.

Polling frequency determines:

- Network load  
- CPU load on the Modbus device  
- Responsiveness of the BMS  

### High Polling Frequency Issues

If polling frequency is too high:

- Device CPU becomes overloaded  
- Responses are delayed or dropped  
- Supervisory system marks device offline  
- Trend logs show gaps  
- Gateways reset due to overload  

A typical plant device (e.g., chiller) may have:

- 200–400 registers  
- BMS polling every 5–15 seconds (reasonable)  
- Some integrators poll every second (unreasonable)

---

## Modbus TCP Performance Considerations

### 1. Network Latency
Modbus is sensitive to latency because each register read is its own transaction.

### 2. Large Register Maps
When devices expose hundreds or thousands of registers:

- Polling becomes slow  
- Gateways buffer large responses  
- Controllers may split responses across multiple messages  

### 3. Device Connection Limits
Some PLCs or meters support only a small number of concurrent TCP connections (sometimes as low as 1).

### 4. Packet Fragmentation
Large Modbus responses may require fragmentation, causing:

- Higher CPU load  
- Delays in processing  

---

## Gateways (Modbus RTU ↔ TCP)

Modbus RTU devices often sit behind IP gateways.

Gateways must:

- Poll Modbus RTU devices  
- Aggregate responses  
- Convert to Modbus TCP  
- Maintain multiple serial buses  
- Handle different baud rates and timeouts  

### Gateway Limitations

Many gateways:

- Cannot handle large numbers of requests  
- Require slow polling intervals  
- Fail under load  
- Drop serial packets silently  

Faulty RTU devices cause traffic collapse across the entire gateway.

---

## Security Weaknesses

Modbus TCP has **no security**:

- No encryption  
- No authentication  
- No integrity checking  
- No session validation  

An attacker can:

- Read any register  
- Write any writable register  
- Send malformed packets that crash devices  
- Spoof device responses  
- Trigger unsafe plant behaviour  

### Mitigation Strategies

- Place Modbus devices in isolated VLANs  
- Restrict TCP/502 traffic at firewalls  
- Only allow known supervisory systems to connect  
- Avoid exposing Modbus devices to VPN user subnets  
- Convert to OPC-UA where possible for secure readouts  

---

## Common Modbus Failure Scenarios

### 1. Incorrect Register Mapping
Symptoms:
- Wrong values  
- "Offline" readings  
- Control loops behaving erratically  
Cause:
- Integrator used incorrect offset/index  

### 2. Gateway Overload
Symptoms:
- Timeouts  
- Unresponsive Modbus RTU devices  
- Supervisor marking devices offline  

### 3. Endianness Errors
Symptoms:
- Strange negative numbers  
- Impossible values  
Cause:
- Multi-register values decoded incorrectly  

### 4. Excessive Polling
Symptoms:
- Device CPU 100%  
- Slow response times  
- Repeated TCP resets  

### 5. Connection Limit Exhaustion
Symptoms:
- Device refuses new TCP session  
- Intermittent offline status  

### 6. Timeout Mismatch
Symptoms:
- Partial reads  
- Random failures  
Cause:
- Gateway or Modbus RTU device has long response times  

---

## Troubleshooting Methodology

### Step 1: Confirm Network Reachability
- Ping device  
- Check gateway connectivity  
- Confirm VLAN routing  

### Step 2: Validate Port 502 Access
Use tools such as:
- `tcping`
- `nmap`
- `modpoll` (command-line Modbus client)

### Step 3: Verify Register Map
- Check vendor documentation  
- Confirm offsets  
- Validate data types  

### Step 4: Check Polling Frequency
Compare:
- Requested interval  
- Device capability  

### Step 5: Test Manually
Read registers using a manual client to confirm values.

### Step 6: Evaluate Gateway Health
Look for:
- High error count  
- Retry count  
- Buffer overflow messages  

### Step 7: Isolate Serial Buses (RTU)
Disconnect segments to isolate faulty devices.

---

## Summary

Modbus TCP is a simple, reliable protocol when used correctly, but its polling model and lack of security introduce significant risks. Network engineers must understand register mapping, polling intervals, gateway behaviour, and device limitations to diagnose issues effectively.

Key principles:

- Modbus has no auto-discovery; everything depends on correct documentation.  
- Polling too fast breaks devices.  
- Endianness matters.  
- Gateways are bottlenecks.  
- Strict network segmentation is essential for security.  

Understanding Modbus TCP is a core requirement for working with modern OT and BMS environments.
