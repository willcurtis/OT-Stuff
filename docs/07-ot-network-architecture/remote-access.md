# Remote Access Architecture  
**Zero-Trust Vendor Access, Jump Hosts, Session Recording, Temporary Credentials, Cloud vs On-Prem, High-Security Patterns**

Remote access is one of the *highest-risk* components of an OT/BMS network.  
Most historic OT breaches have occurred due to:

- Uncontrolled vendor VPNs  
- Direct access to controllers  
- Re-use of passwords  
- Misconfigured remote desktop tools  
- Cloud remote tunnels bypassing firewalls  
- Lack of audit, monitoring, and termination of sessions  

This chapter defines a hardened, zero-trust remote access framework suitable for modern building automation systems.

---

# 1. Zero-Trust Remote Access Principles

### 1.1 No implicit trust  
Every vendor, user, and device must authenticate and be authorised *per session*.

### 1.2 Least privilege  
Users receive the absolute minimum access required.

### 1.3 Access is temporary  
No permanent VPN accounts.  
Time-boxed access (e.g., 4 hours).

### 1.4 All access is logged and monitored  
Session logs, keystrokes (optional), connection metadata stored.

### 1.5 No direct access to OT field networks  
All remote access terminates in the OT DMZ jump host.

### 1.6 No cloud tunnels bypassing firewalls  
TeamViewer/Anydesk/LogMeIn-style reverse tunnels are prohibited.

---

# 2. Layered Remote Access Architecture

A secure remote access chain should look like:

Vendor → VPN → IT Firewall → OT DMZ Jump Host → OT DMZ Tools → Firewalled Access → OT System

### Breakdown:

### 2.1 VPN Layer (IT-controlled)
- MFA required  
- No shared accounts  
- Least privilege routing (split only to DMZ)  
- No direct OT routes  

### 2.2 IT Firewall
- Only allows traffic from VPN range → OT DMZ jump host  
- Denies all other OT connections  

### 2.3 OT DMZ Jump Host
- Windows or Linux bastion  
- No outbound Internet  
- Controlled toolset:  
  - BACnet/SC console  
  - Vendor BMS client  
  - SSH/RDP clients  
  - Modbus tools  
- File-transfer staging area  
- Audited login and session recording  

### 2.4 OT DMZ Application Gateway
- OPC-UA/Web APIs exposed from DMZ  
- Supervisors accessible via HTTPS  
- BMS interfaces provided securely  

### 2.5 OT Firewall (DMZ → OT)
- Strict allow lists  
- Per-protocol firewalling (BACnet/Modbus/etc.)  
- Read-only access unless explicitly authorised  

---

# 3. Allowed vs Prohibited Remote Access Methods

### 3.1 Allowed (with controls)
- VPN with MFA  
- SSH/RDP *via the jump host only*  
- HTTPS access to BMS front-end in DMZ  
- OPC-UA/MQTT dashboards (read-only)  
- BACnet/SC hub connections (controlled)  

### 3.2 Prohibited
- Direct VPN into OT  
- Direct RDP to BMS servers  
- TeamViewer, AnyDesk, LogMeIn, GoToAssist  
- Port-forwarding from controllers  
- Vendor-provided remote cloud tunnels  
- Unencrypted protocols (Telnet, FTP, VNC)  

---

# 4. Access Approval Workflow

A mature OT remote access model includes an explicit approval process.

### Step-by-step:

1. **Vendor or engineer submits request**  
   - Target system  
   - Purpose  
   - Expected duration  
   - Change reference  

2. **OT/Facilities/IT security approves**  
   - Confirms timings  
   - Validates necessity  
   - Ensures maintenance windows are respected  

3. **Temporary credentials issued**  
   - Time-limited VPN account  
   - Optional per-session token/OTP  

4. **Session recorded & monitored**  
   - RDP/SSH session capture  
   - Logs stored for 12–36 months  

5. **Account disabled automatically after expiry**  

---

# 5. Jump Host Design

A jump host (bastion) is the *only* permitted path into OT.

### 5.1 Requirements
- MFA login  
- Session recording (video or keystroke log)  
- Centralised authentication (LDAP/RADIUS)  
- No direct outbound Internet  
- No USB mass-storage unless approved  
- Hardened OS build  
- Logging to SIEM  
- Preinstalled vendor tools  

### 5.2 File Transfer Rules
- Files uploaded to a controlled staging area  
- Malware scanning required  
- All file transfers logged  
- No direct file upload into OT systems  

### 5.3 Tooling Available
- Wireshark with restricted privileges  
- BACnet explorers (only DMZ-contained)  
- Modbus poll/test tools  
- Vendor BMS applications  
- SSH/RDP clients  
- Browser for BMS UI  

---

# 6. Remote Access for Cloud-Dependent Vendors

Many new BMS, lighting, and IoT systems require cloud portals.

### Controls:
- Cloud access from DMZ only  
- Firewall egress allow-list to specific vendor FQDNs  
- TLS inspection optional but often unnecessary  
- No controller-to-cloud paths direct from OT  

### Architecture:

Controller → OT VLAN → OT Firewall → DMZ Proxy → Cloud

### Prohibited:
- Controller → Cloud direct (via Internet break-out in OT)  
- Vendor cloud agent running inside OT network  

---

# 7. Secure Remote Access Protocol Handling

### 7.1 BACnet/SC
Remote vendors connect:

Vendor → VPN → Jump Host → BACnet/SC Hub → Building Controllers

Controller initiates outbound connection only.

### 7.2 Modbus TCP
Only supervisors allowed to read/write registers.  
Vendors use:

Vendor → Jump Host → Supervisor UI → Modbus Gateway

### 7.3 KNX
Commissioning tunnelling must run via jump host.  
Multicast IGMP must not leak across firewall.

### 7.4 MQTT
- Brokers live in DMZ or secured OT VLAN  
- Vendors get read-only topics unless absolutely required  

### 7.5 OPC-UA
- Certificate pinning  
- Username+password + TLS  
- Node-level authorisation  

---

# 8. High-Security Environments (Data Centres, Airports, Defence)

### Additional controls include:
- Hardware token MFA + password  
- Jump host + session recording mandatory  
- No vendor VPN — instead portal-based access (Privileged Access Gateway)  
- All access proxied — no direct RDP/SSH  
- Dedicated OT security operations centre  
- Mandatory pre/post access attestations  
- USB port blocking on all OT servers  
- Air-gapped commissioning where necessary  

### Data Exfiltration Controls:
- Outbound DMZ → Internet blocked by default  
- Whitelist only vendor URLs  
- Disable clipboard and file copy on remote sessions  

---

# 9. Example End-to-End Remote Access Architecture

                  +-----------------------+
                  |       Vendor          |
                  | (Laptop + MFA Token)  |
                  +-----------+-----------+
                              |
                              |
                      VPN Tunnel (MFA)
                              |
                    +---------+----------+
                    |     IT Firewall    |
                    +---------+----------+
                              |
                  Allow only to Jump Host
                              |
              +---------------+---------------+
              |            OT DMZ Jump Host   |
              |  - Session Recording          |
              |  - Vendor Tools               |
              |  - No direct OT access        |
              +---------------+---------------+
                              |
                      OT Firewall (Strict ACLs)
                              |
    +-------------------------+--------------------------+
    |                          OT Core                  |
    +-------------------------+--------------------------+
                              |
                      Building VLANs
                              |
                   Controllers & Gateways
                              |
                      Field Devices

---

# 10. Monitoring, Logging & Audit Requirements

### 10.1 Logging Sources:
- VPN logs  
- Jump host login/logout  
- Jump host session recordings  
- Firewall logs  
- BMS supervisor logs  
- BACnet/SC hub events  

### 10.2 Alerts:
- Unauthorized access attempts  
- Unexpected protocol activity  
- Outbound Internet attempts from OT networks  
- Vendor attempting to bypass jump host  
- High-risk Modbus writes  

### 10.3 SIEM Integration:
- All logs forwarded to IT/OT SOC  
- Correlation rules for unusual patterns  

---

# 11. Implementation Checklist

### Policies
- [ ] Zero-trust remote access documented  
- [ ] No direct access to OT allowed  
- [ ] Cloud remote access prohibited unless controlled  

### Controls
- [ ] Jump host hardened and isolated  
- [ ] MFA required everywhere  
- [ ] Session recording enabled  
- [ ] Temporary credentials only  

### Networking
- [ ] Firewalls enforce directionality  
- [ ] No multicast routed across firewall  
- [ ] OT VLANs non-routable from VPN  

### Governance
- [ ] Approval workflow enforced  
- [ ] Activity logs retained (12–36 months)  
- [ ] Vendor accounts reviewed quarterly  

---

# Summary

Remote access is a critical security boundary for OT networks.  
The goal is to avoid uncontrolled vendor pathways, eliminate direct access to field devices, and enforce auditability and least privilege.

Key principles:
- Zero-trust architecture  
- DMZ-hosted jump host  
- MFA everywhere  
- No cloud or VPN shortcuts  
- Strict firewalling and monitoring  
- Session recording for full traceability  

Properly implemented, these controls allow safe and efficient vendor maintenance while protecting building systems from compromise.
