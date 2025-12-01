# Remote Access Deployment Pattern for BMS/OT Networks

Remote access is one of the most sensitive and high-risk components of an OT/BMS infrastructure.  
Incorrectly implemented remote access is the root cause of most real-world OT cyber incidents, often due to insecure vendor laptops, weak credentials, direct access to controller networks, or VPN misconfiguration.

This chapter provides a complete deployment pattern for secure, auditable, controlled remote access to BMS environments across HVAC, lighting, security, metering, and plant control systems.

---

# Remote Access Goals

A secure remote-access design must achieve:

- **Zero direct access to BMS controllers**  
- **Full auditability and logging**  
- **Encryption for all communications**  
- **Multi-factor authentication (MFA)**  
- **Time-limited access sessions**  
- **Protocol-based restrictions**  
- **Protection against vendor devices**  
- **Controlled access from OT to IT and vice versa**  

Remote access should be treated as a high-risk activity requiring strong governance.

---

# Recommended Remote Access Architecture

The architecture below represents current best practice for OT/BMS environments.

---

# 1. Vendor Access VLAN

A dedicated VLAN is mandatory.

### Requirements:
- No routing between vendor VLAN and controller VLANs except via firewall  
- No multicast/broadcast propagation  
- No direct BACnet/Modbus access  
- All traffic must traverse firewall inspection  
- Short-lived DHCP leases or no DHCP at all  

Vendor VLAN = *network quarantine zone*.

---

# 2. VPN Termination

Remote connections should land in a **DMZ**, not in OT directly.

Accepted VPN termination locations:
- IT DMZ → OT Firewall → OT Jump Host  
- OT DMZ → OT Firewall → OT Jump Host  

VPN types:
- SSL-VPN with TLS 1.2+  
- IPsec IKEv2  
- Certificate-based authentication preferred  

### Required security:
- Multi-factor authentication  
- Per-user named accounts  
- No shared vendor accounts  
- Device posture checks if possible  

---

# 3. Jump Host / Bastion Host

The jump host is the *only* permitted way to interact with plant systems remotely.

### Requirements for Jump Host:
- Screen recording or keystroke logging  
- Patched and hardened OS  
- No direct routable access to the internet  
- Access only via RDP/SSH from VPN users  
- Segmented from controllers by firewall  
- OT tools installed (BACnet browsers, Modbus clients, vendor tools)  
- Configured with time-limited privileged sessions  

### Why a jump host is essential:

- Protects controllers from insecure vendor devices  
- Provides full visibility of vendor actions  
- Enforces one inspection point  
- Enables forensic review  

---

# 4. OT Firewall Layer

The firewall enforces strict control between:

- Vendor VLAN  
- Jump host  
- Supervisors  
- Controller VLANs  
- OT DMZ  
- IT networks  

### Required Capabilities:
- Stateful inspection  
- Per-port and per-protocol rules  
- DoS/broadcast detection  
- Application filtering if available  
- Logging of all session start/stop events  
- Logging of Modbus writes and BACnet writes if supported  

---

# 5. Access Control and Least Privilege

Remote vendors get access ONLY to:

- Required supervisors  
- Required controllers  
- Required ports  
- Required protocols  

No jump host → controller traffic except:

| Protocol | Port | Notes |
|----------|------|-------|
| BACnet/IP | UDP/47808 | Allowed only to specific controllers |
| Modbus TCP | TCP/502 | Allowed only when commissioning |
| HTTP/HTTPS | 80/443 | Supervisors only |
| OPC-UA | TCP/4840 or defined | Usually supervisor only |
| KNX Tunnelling | UDP/3671 | Only on request |

All other protocols and ports are denied.

---

# 6. Identity & Authentication Flow

Full identity flow should be:

Vendor → VPN → MFA → DMZ → Jump Host → Firewall → OT System

### Mandatory authentication requirements:

- MFA enforced  
- No local accounts on controllers  
- Named accounts for all vendor staff  
- Time-bound access according to change approvals  
- Password rotation  

---

# 7. Logging & Audit Requirements

The following must be logged:

- VPN connection attempts  
- Authentication failures  
- Jump host login sessions  
- Jump host screen recording  
- Firewall logs for allowed/blocked traffic  
- Modbus writes (function codes 5, 6, 15, 16)  
- BACnet writes (WriteProperty, WritePropertyMultiple)  
- OPC-UA method calls  

Logs must be pushed to:
- SIEM  
- OT monitoring platform  
- Compliance archive  

---

# 8. Typical Reference Deployment

Below is a fully-specified typical deployment pattern.

---

## VLAN Layout

VLAN 100 – OT Supervisors
VLAN 110 – BACnet Controllers (Plant)
VLAN 120 – BACnet Controllers (Floors)
VLAN 130 – Gateways (MS/TP, Modbus, LON)
VLAN 150 – OPC-UA Servers
VLAN 170 – OT DMZ
VLAN 180 – Vendor Access VLAN
VLAN 190 – OT Jump Host VLAN

---

## Firewall Rule Example

### Vendor → Jump Host

permit tcp 10.20.180.0/24 10.20.190.10 eq 3389
deny ip any any

### Jump Host → Supervisor

permit tcp host 10.20.190.10 host 10.20.100.10 eq 443
permit udp host 10.20.190.10 host 10.20.100.10 eq 47808
deny ip any any

### Jump Host → Controller VLANs

permit udp host 10.20.190.10 10.20.110.0/24 eq 47808
permit tcp host 10.20.190.10 10.20.130.0/24 eq 502
deny ip any any

### Vendor VLAN → Controller VLANs (must be blocked)

deny ip 10.20.180.0/24 10.20.0.0/16

---

# 9. Remote Commissioning Workflow Example

### Step 1 — Request Access  
Vendor submits ticket detailing:
- Purpose  
- Affected systems  
- Required duration  
- Expected ports  

### Step 2 — Approval  
OT manager approves request.

### Step 3 — Access Enablement  
- Firewall rule temporarily enables jump host access  
- VPN profile activated for vendor  
- Time-limited AD group membership enabled  

### Step 4 — Vendor Connects  
- MFA enforced  
- Jump host session recorded  
- Vendor performs tasks  

### Step 5 — Session Monitoring  
- SIEM monitors traffic  
- Alerts on unusual behaviour  
- Engineering staff monitor BACnet/Modbus writes  

### Step 6 — Access Removal  
- Remove firewall exception  
- Disable vendor VPN user  
- Archive logs  

---

# 10. Remote Access Anti-Patterns (Absolutely Avoid)

### ❌ Direct VPN into controller VLAN  
Most dangerous possible design.

### ❌ NAT-t’ed VPN clients appearing inside BACnet VLAN  
Causes broadcast storms and device collisions.

### ❌ Suppliers connecting via 4G routers  
No governance or monitoring.

### ❌ Persistent vendor accounts  
Creates long-term supply-chain vulnerability.

### ❌ Remote access without logging  
Creates zero accountability.

### ❌ Allowing broadcast/multicast across VPN  
Breaks KNX/BACnet behaviour and exposes OT to unnecessary risk.

### ❌ Shared vendor credentials  
No way to attribute actions.

---

# 11. Secure Remote Access for Specific Protocols

## BACnet/IP
- Vendors often use discovery tools → broadcast storms  
- Allow only targeted UDP/47808 traffic  
- Never allow vendor tools direct access to BBMD  

## Modbus TCP
- Restrict Modbus function codes where firewall supports it  
- Log all writes  
- Allow only when commissioning  

## KNX/IP
- Only allow KNX tunnelling (UDP/3671)  
- Never allow KNX routing multicast across firewalls  

## OPC-UA
- Require client certificates  
- Disable insecure security policies  
- Use reverse proxy where possible  

---

# 12. Security Enhancements

### Device Posture Enforcement  
VPN checks:
- OS version  
- Antivirus/EDR state  
- Disk encryption  
- No forbidden software  

### One-Time Access Tokens  
For short-lived commissioning sessions.

### Just-in-Time Firewall Rules  
Automatically expire after defined window.

### Jump Host Hardening  
- RDP restricted to vendor VLAN  
- No internet access  
- Application allowlist  

---

# 13. Common Failure Scenarios in Real Sites

### Scenario 1 — Vendor connects directly to BACnet VLAN  
Outcome:
- Broadcast storm  
- Controllers reboot  
- Loss of plant control  

### Scenario 2 — Vendor laptop infected with malware  
Outcome:
- Malware spreads through Modbus/BACnet  
- Supervisors compromised  
- Outage or manipulation event  

### Scenario 3 — NAT on VPN breaks BACnet FDR  
Outcome:
- BBMD table corrupted  
- Discovery unreliable  

### Scenario 4 — Jump host bypassed  
Outcome:
- No monitoring  
- No control  
- No accountability  

---

# Remote Access Deployment Checklist

- [ ] VPN terminates in DMZ, not OT core  
- [ ] MFA enforced on all remote users  
- [ ] Vendor VLAN isolated  
- [ ] Jump host with activity logging  
- [ ] Controller VLANs unreachable directly  
- [ ] Firewall denies broadcast/multicast from vendors  
- [ ] Protocol-specific restrictions in place  
- [ ] Logs shipped to SIEM  
- [ ] Access time-limited  
- [ ] Full documentation retained  

---

# Summary

A secure remote-access design is essential to protect BMS/OT networks from cyber threats, misconfiguration, and accidental damage by contractors.  
The deployment blueprint provided in this chapter represents best practice for commercial buildings, campuses, healthcare, industrial facilities, and critical infrastructure.

Key principles:

- No direct vendor access to controllers  
- All traffic must pass through a firewall  
- Jump hosts provide accountability and isolation  
- MFA and strong authentication required  
- Logging is mandatory  
- Access must be temporary  

Remote access is useful — but only when implemented with strict, uncompromising security controls.
