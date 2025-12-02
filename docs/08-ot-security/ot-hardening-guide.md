# OT Hardening Guide  
**Practical Hardening Standards for Controllers, Gateways, VLANs, Supervisors, Protocols, Certificates, and Commissioning**

OT hardening focuses on two goals:

1. Reduce the attack surface  
2. Limit the blast radius when something fails  

This guide provides prescriptive, vendor-neutral hardening steps applicable across BMS, HVAC, lighting, metering, energy, and gateway vendors.

---

# 1. Controller & Field Device Hardening

Controllers (AHUs, FCUs, VAVs, VRF gateways, lighting interfaces) are typically the weakest link.  
Most are effectively embedded Linux/RTOS systems with minimal protection.

### 1.1 Disable Unused Protocols
Disable:
- Telnet  
- FTP  
- HTTP (use HTTPS)  
- SNMP v1/v2c  
- Vendor cloud agents (unless required and controlled)  
- Debug ports  

### 1.2 Enforce Authentication
If the device supports it:
- Passwords for local UI  
- Role-based access  
- Lock commissioning mode  

### 1.3 Lock Down BACnet
- Disable foreign device registration  
- Disable BBMD unless absolutely required  
- Limit device instance range  
- Enable BACnet/SC if supported  

### 1.4 Lock Down KNX IP Routers
- Set IP router password  
- Disable unneeded tunnelling slots  
- Restrict multicast scope  
- Use KNX Secure where possible  

### 1.5 Lock Down Modbus
- Disable write function codes if not needed  
- Whitelist read-only clients  
- Rate-limit poll frequency  

### 1.6 Lock Down IoT Devices
For Wi-Fi/BLE/Zigbee/Thread gateways:
- Disable vendor cloud mode unless essential  
- Use WPA3-Enterprise for Wi-Fi uplinks  
- Rotate keys regularly  
- Replace devices that cannot use TLS  

---

# 2. Gateway Hardening (Modbus, KNX, OPC, BACnet, DALI)

Gateways are high-value targets because they bridge OT and OT/DMZ.

### 2.1 Enforce ACLs
Configure built-in ACLs to allow only:
- Known supervisors  
- Known engineering laptops (temporarily)  

### 2.2 Change Default Credentials
Never leave gateway logins as:
- admin / admin  
- root / root  
- Manufacturer defaults  

### 2.3 Secure Management Interface
- Disable HTTP → use HTTPS  
- Block management ports from OT VLANs  
- Only reachable from jump host or dedicated management VLAN  

### 2.4 Disable Unused Services
- Telnet  
- FTP  
- SSH if not required  
- Vendor “call home” service  

### 2.5 Enable Logging
Gateways should log:
- Poll failures  
- Unexpected writes  
- Login attempts  
- Configuration changes  

---

# 3. VLAN & Network Isolation Hardening

Each system must be isolated into its own VLAN.

### 3.1 Rules
- One VLAN per system per building  
- No cross-building VLANs ever  
- No spanning tree beyond a single floor  
- Multicast scope limited  
- Storm control enabled on all access ports  

### 3.2 Access Port Controls
Enable:
- DHCP Snooping  
- Dynamic ARP Inspection  
- Port security (MAC count = 1 where possible)  
- Unknown multicast drop  

### 3.3 L3 Segmentation
Gateways between VLANs should be firewalled:
- OT Core Firewall  
- Firewall in DMZ  

### 3.4 No Internet Access from OT VLANs
Unless explicitly required and controlled.

---

# 4. Supervisor, Server & DMZ Hardening

Supervisors often run full operating systems (Windows, Linux) and must be hardened like IT assets.

### 4.1 OS Hardening
- Apply vendor-approved security patches  
- Disable SMBv1  
- Remove local admin accounts  
- Restrict RDP to jump host only  
- Enable local firewall with explicit rules  
- Disable unnecessary services  

### 4.2 Application Hardening
- Enforce authentication  
- Use HTTPS only  
- Disable default guest accounts  
- Enforce strong passwords & MFA if possible  
- Disable scripting consoles unless required  

### 4.3 Database Hardening
For SQL/InfluxDB/TimescaleDB:
- Unique DB credentials per application  
- Encrypted at rest  
- Encrypted in transit  
- Restricted source IPs  

### 4.4 Supervisors as Read-Only for IT
- IT dashboards should not send write commands  
- Expose read-only APIs via reverse proxy  

### 4.5 DMZ Placement
Supervisors must live in OT DMZ, not directly inside OT VLANs.

---

# 5. Certificate Management (BACnet/SC, OPC-UA, MQTT)

### 5.1 BACnet/SC Certificates
- Use internal CA  
- Issue per-controller certificates  
- Renew every 12–36 months  
- Revoke on device decommission  
- Protect hub private keys with HSM if available  

### 5.2 OPC-UA Certificates
- Reject untrusted certificates  
- Use signed + encrypted endpoints  
- Avoid anonymous authentication  
- Rotate certs regularly  

### 5.3 MQTT TLS Certificates
- Use device-specific client certs  
- Disable anonymous connections  
- Only allow TLS 1.2+  
- Enforce topic ACLs per device  

---

# 6. SNMP Hardening

### Do:
- Use SNMPv3 only  
- Unique credentials per role  
- Restrict source IPs  

### Don’t:
- Use SNMP v1 or v2c  
- Expose SNMP to vendor networks  

---

# 7. Logging & Audit Hardening

### Required Logs:
- Logins (success/failure)  
- Configuration changes  
- Firmware upgrades  
- Modbus writes  
- BACnet writes  
- MQTT publish failures  
- OPC-UA session changes  

### Log Forwarding:
- Forward to SIEM/SOC  
- Timestamp with NTP  
- Store for 12–36 months  

---

# 8. Firmware & Patch Hardening

### 8.1 Controller Firmware
- Update only in maintenance windows  
- Validate checksums  
- Store firmware in version-control repository  
- Track firmware per device  

### 8.2 Gateway Firmware
- Upgrade regularly  
- Apply vendor security bulletins  
- Remove deprecated cipher suites  

### 8.3 Supervisor Patching
- Follow vendor support matrix  
- Patch monthly if permitted  
- Snapshot VMs prior to patching  

---

# 9. Secure Commissioning & Decommissioning

---

## 9.1 Secure Commissioning Workflow
1. Controller installed but not network-connected  
2. Engineer configures:
   - Password  
   - Disable unused services  
   - Assign IP  
   - Disable cloud mode  
   - Load correct firmware  
3. Connect to designated OT VLAN  
4. Register device in asset inventory  
5. Back up configuration  
6. Validate logs appear in SIEM  

### Output:
A device that is secure from the moment it touches the OT network.

---

## 9.2 Secure Decommissioning Workflow
1. Remove device from OT network  
2. Revoke certificates  
3. Wipe configuration  
4. Remove from asset inventory  
5. Archive backups  
6. Update network monitoring  

---

# 10. Least Privilege Access Hardening

### 10.1 For OT Engineers
- Jump host only  
- MFA required  
- No direct controller access  
- Time-boxed local admin accounts  
- Use service accounts only for applications  

### 10.2 For Vendors
- Vendor-specific accounts  
- Expire automatically  
- Session recording mandatory  
- No Internet browse allowed  

### 10.3 For IT
- Read-only access into DMZ  
- No access to OT VLANs  
- No ability to write to controllers  

---

# 11. Physical Hardening

### Plant Rooms:
- Locked  
- Environmental monitoring  
- CCTV coverage  
- Restricted key/FOB access  

### Riser Cabinets:
- Locked with secure keys  
- Tamper switches where possible  
- Dedicated OT patching (no corporate shared patch panels)  

### Server Rooms:
- UPS  
- Fire suppression  
- Environmental monitoring  

---

# 12. Verification Testing

### Before Go-Live:
- Pen-test supervisor interfaces  
- Validate firewall rules permit only intended traffic  
- Confirm broadcast containment  
- Confirm BACnet/KNX/multicast behavior  
- Verify Modbus write blocking  
- Test vendor remote access workflow  

### Quarterly:
- Review user accounts  
- Rotate credentials  
- Verify backups  
- Validate firmware and patch posture  

### Annually:
- Full OT security assessment  
- Disaster recovery test  
- Certificate rotation if required  

---

# 13. Hardening Checklist (Master Summary)

### Controllers
- [ ] Default creds removed  
- [ ] TLS where possible  
- [ ] Unused services disabled  
- [ ] Logs enabled  
- [ ] BACnet/KNX/Modbus locked down  

### Gateways
- [ ] HTTPS only  
- [ ] IP ACLs enforced  
- [ ] Default creds removed  
- [ ] Cloud mode disabled unless required  

### Network
- [ ] VLAN per system  
- [ ] No cross-building L2  
- [ ] L3 at distribution  
- [ ] OT firewalling enforced  
- [ ] Multicast/broadcast limits  
- [ ] SNMPv3  

### DMZ & Supervisors
- [ ] OS hardened  
- [ ] Database secured  
- [ ] Certificate management active  
- [ ] Logging centralised  
- [ ] Patching controlled  

### Remote Access
- [ ] Jump host only  
- [ ] MFA  
- [ ] Time-boxed vendors  
- [ ] Session recording  

### Physical
- [ ] Riser cabinets locked  
- [ ] UPS for OT core  
- [ ] Fire suppression for server rooms  

---

# Summary

OT hardening is about making real-world systems safer, predictable, and resistant to failure or compromise.

Hardening must cover:
- Controllers  
- Gateways  
- VLANs  
- Supervisors  
- Protocols  
- Certificates  
- Remote access  
- Physical security  

A hardened OT system is resilient, observable, and protects the building from both accidents and deliberate attacks.
