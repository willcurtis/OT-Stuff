# Remote Access in OT/BMS Networks

Remote access is one of the highest-risk components in any OT/BMS architecture.  
Unlike IT systems, building automation environments contain insecure protocols (BACnet, Modbus, KNX, LON), safety-critical plant equipment, and long-lived devices that cannot be patched frequently. Remote access must therefore be tightly controlled, isolated, monitored, and designed around least-privilege principles.

This chapter provides a complete engineering reference for secure vendor and engineer remote access to OT/BMS networks.

---

# Why Remote Access Is High Risk in OT

Remote access is dangerous because:

- Many OT protocols have **no authentication or encryption**  
- Controllers can be overwritten by simple write commands  
- Gateways expose internal plant networks  
- Vendor laptops often run outdated or non-hardened software  
- Malware can spread into OT networks via VPNs  
- Misconfiguration can shut down plant equipment  

Most major OT cybersecurity incidents begin with compromised remote access credentials.

---

# Objectives of a Secure Remote Access Design

A well-designed system must ensure:

1. **Isolation** — Vendors must never be placed in controller VLANs  
2. **Authentication** — MFA and strong identity validation  
3. **Authorisation** — Role-based access, restrict per-system  
4. **Encryption** — All remote traffic must be encrypted  
5. **Auditing** — Full session logging  
6. **Non-persistent access** — Access provided only when needed  
7. **Least privilege** — Only the necessary devices and ports  
8. **Accountability** — Every action tied to a known individual  

Remote access should be treated as a controlled security event, not an always-on service.

---

# Remote Access Architecture

The following components form a secure OT remote access design:

## 1. Vendor Access VLAN  
- Isolated from controller VLANs  
- Routed only through a firewall  
- No broadcast or multicast propagation  
- No direct access to plant devices  

## 2. VPN Termination Point  
- Located in IT DMZ or OT DMZ  
- Never directly into OT core  
- Uses strong encryption (IPsec, SSL-VPN TLS 1.2+)  
- Enforces MFA  

## 3. Jump Host / Bastion  
- Single audit point  
- Screen recording or keystroke logging  
- Restricted outbound access  
- Patched and hardened OS  
- Requires MFA to access tools  

## 4. Firewall Enforcement Layer  
- Application-level restrictions  
- Protocol filtering (BACnet UDP/47808, Modbus TCP/502, etc.)  
- Per-user or per-group policies  
- Time-based access if required  

## 5. Session Monitoring & Logging  
- Store session logs for audit  
- Alert on suspicious patterns  
- Provide visibility for compliance  

---

# VPN Models for OT Remote Access

## Model A — **VPN → DMZ → Jump Host → OT VLANs** (Recommended)

Flow:
Vendor → VPN → DMZ → Jump Host → Firewall → OT controller VLAN

Pros:
- Strongest control  
- All actions logged  
- No direct connectivity to OT  
- Easily restrict by port  

Cons:
- Vendors must use remote desktop tools  
- Slightly more onboarding work  

---

## Model B — **VPN → Strict Firewall → OT VLAN** (Acceptable if well controlled)

Flow:
Vendor → VPN → Firewall → Controller VLAN

Pros:
- Simpler workflow for vendors  
- Supports commissioning tools directly  

Cons:
- Riskier  
- Requires extremely strict firewall ACLs  
- Harder to monitor activity  

Should only be used when commissioning tools cannot operate through jump hosts.

---

## Model C — **Vendor Cloud Portals (e.g., secure vendor gateways)**

Flow:
Cloud Portal → Push tunnel → On-site secure connector → OT VLAN

Pros:
- No inbound firewall rules  
- Central audit trail  
- MFA integrated  

Cons:
- Requires trust in vendor cloud  
- Must ensure connector cannot bypass firewall  

---

# Identity and Authentication Requirements

### Mandatory Controls:
- MFA for all remote access  
- Vendor accounts must be named, not shared  
- Password expiration and rotation  
- Certificates where possible (e.g., for OPC-UA tooling)  
- No local accounts stored long-term on jump hosts  

### Additional Controls:
- Enforce conditional access rules  
- Limit login locations  
- Certificate pinning for VPN endpoints  

---

# Authorisation & Access Control

Vendors should have access limited to:

- Specific IP addresses  
- Specific ports  
- Only during approved change windows  

Example ACL:

permit tcp host 10.20.70.50 host 10.20.10.10 eq 443
permit udp host 10.20.70.50 host 10.20.20.21 eq 47808
deny ip any 10.20.0.0 0.0.255.255

---

# Firewalls in Remote Access

Remote access firewalls must:

- Enforce least privilege  
- Apply stateful inspection  
- Log all session entries/exits  
- Block risky protocols unless explicitly needed  
- Throttle malformed BACnet packets  
- Prevent Modbus scanning tools  

### Critical Block Rules:
- Block broadcast/multicast to OT VLANs  
- Block BACnet Who-Is storms  
- Block vendor access to BBMDs  
- Block Modbus TCP 502 except from whitelisted sources  

---

# Logging and Monitoring

### Log:
- Authentication attempts  
- Session establishment and termination  
- Commands issued from jump hosts  
- File transfers  
- BACnet write commands  
- Modbus register writes  
- OPC-UA method calls  

### Alert on:
- Large volume of BACnet broadcasts  
- Abnormal scanning behaviour  
- Commands issued outside working hours  
- High-risk plant operations (e.g., setpoint write to 0°C)  

---

# Vendor Access Policies

### Vendors MUST:
- Use company-issued devices  
- Maintain updated AV/EDR  
- Patch OS regularly  
- Use MFA  
- Agree to audit logging  
- Follow site change control procedures  

### Vendors MUST NOT:
- Use personal laptops  
- Connect directly to OT VLANs  
- Leave always-on connections  
- Store plant credentials in plaintext  
- Share logins  

---

# Remote Access for Specific Protocols

## BACnet/IP
- Vendor tools often generate broadcasts  
- Use unicast-only filtering where possible  
- Never allow vendor laptops into BACnet VLAN  
- Allow UDP/47808 only to specific hosts  

## Modbus TCP
- Remote engineers frequently use scan tools  
- Restrict to specific registers or specific devices  
- Block all Modbus function codes except required ones  
- Log writes to registers  

## KNX/IP
- ETS programming requires tunnelling  
- Only allow UDP/3671 on request  
- Block multicast routing entirely  

## OPC-UA
- Supports certificate authentication  
- Permit TCP/4840 only from known jump hosts  
- Strongest remote-access model  

---

# Common Remote Access Failures

### Failure 1: Vendor VPN allowed directly into controller VLAN  
Result:  
- BACnet/IP storms  
- Unsecured Modbus access  
- Possible plant shutdown  

### Failure 2: Poorly controlled jump host  
Result:  
- Malware propagation  
- No accountability  

### Failure 3: VPN idle timeout too aggressive  
Result:  
- Commissioning tools lose connection  
- Partial configuration writes  

### Failure 4: No logging or monitoring  
Result:  
- No traceability for misconfigurations  
- Compliance failure  

### Failure 5: Shared vendor accounts  
Result:  
- Zero auditability  
- Impossible to attribute actions  

---

# Recommended Remote Access Blueprint

1. Vendor connects via VPN with MFA  
2. VPN terminates in DMZ  
3. Vendor accesses OT jump host  
4. Jump host logs all activity  
5. Jump host connects via firewall to OT VLANs  
6. Firewalls enforce per-protocol restrictions  
7. SIEM collects logs from VPN + firewall + jump host  
8. Access time-boxed and expires automatically  

This is the safest model for real-world OT/BMS environments.

---

# Remote Access Checklist

- [ ] Dedicated vendor VLAN  
- [ ] VPN termination in DMZ  
- [ ] MFA enforced  
- [ ] Jump host deployed and hardened  
- [ ] Full session logging  
- [ ] Minimal firewall rules per vendor  
- [ ] No direct VLAN access  
- [ ] BACnet/Modbus restricted  
- [ ] Change control for enabling access  
- [ ] Expiry timers for vendor credentials  
- [ ] Audit reviewed at regular intervals  

---

# Summary

Remote access is one of the most sensitive aspects of OT security.  
A properly architected remote access system isolates vendors from plant controllers, enforces strong authentication, applies strict firewall controls, and ensures full accountability.

Key principles:

- Vendor access must never bypass OT firewalls  
- Jump hosts provide essential auditability  
- Protocol-level restrictions prevent accidental outages  
- MFA and per-vendor accounts are mandatory  
- All access should be temporary and monitored  

Used carefully, remote access enables safe, controlled maintenance without exposing critical building systems to unacceptable risk.
