# Security in OT/BMS Networks

Operational Technology (OT) and Building Management Systems (BMS) face unique security challenges.  
Unlike IT systems, OT devices typically run legacy firmware, lack basic authentication, and depend on protocols designed long before cybersecurity became essential.

This chapter provides a complete security overview for OT/BMS environments, including threat models, vulnerabilities, hardening strategies, and architectural considerations.

---

# Why OT/BMS Security Is Different

### 1. Protocols are inherently insecure  
- BACnet/IP: Unauthenticated, broadcast heavy  
- Modbus TCP: No authentication, write-anything model  
- KNX/IP: No default encryption  
- LON/IP: Weak or no security  
- MS/TP: No security at all  
- OPC-UA: Secure, but deployed inconsistently  

### 2. Devices have long lifecycles  
Many OT controllers remain in service for 15–25 years and cannot be frequently patched.

### 3. Availability outranks confidentiality  
Outages can disrupt heating, cooling, ventilation, lighting, and safety-related processes.

### 4. Vendors often require remote access  
This introduces supply-chain risk and weak entry points.

### 5. OT networks historically flat  
Legacy OT often used flat Layer 2 networks, which modern threats exploit.

---

# OT Threat Model (Realistic)

Threat actors include:

### **1. Opportunistic attackers**
Ransomware, botnets, or worms that spread into OT from infected IT networks.

### **2. Insider threats**
Contractors, engineers, or vendors misusing access accidentally or maliciously.

### **3. Targeted attackers**
Competitors, disgruntled employees, or nation-state actors targeting critical infrastructure.

### **4. Malware propagation**
Many OT breaches stem from:
- Compromised laptops  
- USB memory sticks  
- Remote vendor connections  
- Accidental bridging of IT and OT networks  

### **5. Misconfiguration**
Most outages come from:
- BACnet storms  
- Gateway misbehaviour  
- Unmanaged switches  
- VLAN leakage  
- Incorrect firewall rules  
- Duplicate IP/MAC/BACnet addresses  

Security must address not only malicious threats but also engineering faults.

---

# Common OT/BMS Vulnerabilities

## 1. Insecure protocols
- BACnet writes with no authentication  
- Modbus function codes allow direct manipulation  
- KNX telegrams can be replayed  
- OPC-UA deployed without certificates  
- MS/TP routes bypass firewall controls  

## 2. Lack of segmentation
Flat networks allow:
- Lateral movement  
- Broadcast storms  
- Discovery of all devices  
- Easy pivot into plant controls  

## 3. Weak or shared passwords
Gateways and supervisors often use:
- Default passwords  
- Shared vendor accounts  
- Unauthenticated APIs  

## 4. Remote access misconfiguration
Most severe OT incidents come from:
- Always-on VPNs  
- Direct vendor access  
- Lack of MFA  
- No session logging  

## 5. Unmanaged switches
Cheap switches installed by subcontractors bypass VLAN and STP design.

## 6. Unsupported operating systems
Many BMS servers run outdated Windows or Linux distributions.

## 7. Missing patch management
Patching OT systems is hard due to risk of downtime.

---

# Hardening Strategies for OT/BMS Networks

## 1. Segmentation (Primary Defence)
- Per-system VLANs  
- Strict firewalling  
- No vendor access in controller VLANs  
- Isolate gateways  

Segmentation limits the blast radius.

---

## 2. Secure Remote Access
- VPN with MFA  
- Jump hosts  
- Audit logging  
- Role-based access  
- No direct controller access  

Remove implicit trust from vendors.

---

## 3. Limit BACnet Exposure
- Block Who-Is/I-Am outside BACnet VLANs  
- Restrict BACnet via firewall  
- Use BACnet/SC where possible  
- Avoid BBMD unless required  

BACnet is one of the weakest OT protocols for security.

---

## 4. Lock Down Modbus TCP
- Allow only required function codes  
- Only permit communication between known IPs  
- Monitor for scanning behaviour  
- Disable writes where possible  

Modbus writes can directly alter plant operation.

---

## 5. Harden Gateways
Gateways are the primary attack surface in OT.

Hardening guidelines:
- Change all default credentials  
- Disable unused services  
- Apply firmware updates where possible  
- Isolate in their own VLAN  
- Restrict outbound access  
- Monitor traffic volumes  

Gateways collapse frequently under load or attack.

---

## 6. OPC-UA Security Controls
OPC-UA is the most secure OT protocol—when configured correctly.

Recommendations:
- Enforce certificate-based auth  
- Disable insecure policies (None, Basic128Rc5)  
- Restrict endpoint exposure  
- Use TLS only  
- Store certificates securely  

---

## 7. Controller-Level Hardening
Most controllers have limited security capabilities, but:

- Disable unused ports (e.g., Web UI, FTP, Telnet)  
- Change default passwords  
- Lock engineering access behind jump hosts  
- Document firmware and configuration versions  

Some newer controllers support:
- TLS  
- Secure commissioning  
- Authentication for writing  

Use these features where available.

---

# Firewall Hardening for OT

### 1. East–west microsegmentation  
- Only allow supervisor ↔ controller  
- Block controller ↔ controller  

### 2. Protocol enforcement  
Example block rules:
- Deny UDP/47808 (BACnet) except to supervisors  
- Deny TCP/502 (Modbus) except to gateways  
- Deny multicast except KNX VLAN  

### 3. State-based protections  
- Detect malformed packets  
- Rate-limit broadcasts  
- Drop suspicious traffic  

### 4. Logging  
Critical for auditing incidents.

---

# Monitoring and Detection

OT monitoring requires:
- Syslog ingestion  
- SIEM correlation  
- BACnet traffic analysis  
- Modbus write logging  
- OPC-UA subscription anomalies  
- Gateway load monitoring  
- Time sync drift alarms  

Early detection prevents plant outages.

---

# Patch and Update Strategy

Patching must balance security and availability.

### Safe Strategy:
1. Maintain offline test environment  
2. Validate updates with vendor  
3. Schedule maintenance window  
4. Snapshot VMs or back up configs  
5. Roll out gradually per subsystem  

### Never patch:
- During peak load periods  
- Without full rollback plan  

OT patching is a risk—but lack of patching is worse.

---

# Physical Security

OT equipment must be:
- Locked in comms rooms  
- Protected from unauthorised local access  
- Connected to UPS-backed power  
- Marked clearly  
- Documented for access audits  

Local access is a frequent attack vector.

---

# Supply Chain Risks

Vendors bring:
- Unknown laptops  
- USB media  
- Remote access portals  
- Custom firmware  
- Third-party cloud dependencies  

Mitigate by:
- Vetting vendors  
- Enforcing policies  
- Logging all activity  
- Using jump hosts  
- Blocking USB use on OT servers  

---

# Common Attack Pathways in OT

1. IT → OT pivot due to poor segmentation  
2. Vendor VPN compromise  
3. Malicious or infected engineering laptop  
4. BACnet broadcast flood  
5. Exploited Modbus server  
6. Unauthenticated web interface on gateway  
7. Weak OPC-UA configuration  
8. LON gateway exposed to IT networks  
9. KNX routing multicast flood across L3 boundary  
10. Stolen credentials  
11. Poorly configured BBMD enabling remote broadcast injection  

---

# OT Security Checklist

### Network Level
- [ ] VLAN segmentation implemented  
- [ ] Firewall per-protocol enforcement  
- [ ] Supervisor isolated  
- [ ] Gateways isolated  
- [ ] No unmanaged switches  
- [ ] Broadcast control implemented  

### Remote Access
- [ ] VPN with MFA  
- [ ] Jump host  
- [ ] Session logging  
- [ ] Vendor accounts restricted  
- [ ] No direct VLAN access  

### Devices
- [ ] Default passwords changed  
- [ ] Unused services disabled  
- [ ] Firmware tracked  
- [ ] Certificates validated  

### Monitoring
- [ ] SIEM receiving OT logs  
- [ ] BACnet/Modbus write alerts  
- [ ] Gateway traffic monitored  
- [ ] Time drift alarms configured  

---

# Summary

Security in OT/BMS networks must account for insecure protocols, long-lived hardware, vendor access requirements, and the critical nature of building systems. Traditional IT security approaches must be adapted, strengthened, and enforced at the network and architectural level.

Key principles:

- Segmentation is the foundation  
- Remote access must be highly controlled  
- Gateways are critical attack surfaces  
- Protocols must be constrained by firewalls  
- Monitoring and logging are essential  
- Vendor behaviours must be restricted  
- Security must support *availability first*  

A well-hardened OT environment dramatically reduces operational and cyber risk.
