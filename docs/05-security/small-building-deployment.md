# Small Building Deployment Pattern for OT/BMS Networks

Small buildings—retail stores, small offices, branch sites, restaurants, schools, health clinics, remote plant rooms, etc.—require OT/BMS architecture that is simple, reliable, supportable remotely, and cost-effective.

Unlike large commercial sites, small buildings rarely justify:
- Multiple VLANs  
- Dedicated on-site supervisors  
- Multiple gateways  
- Complex redundancy schemes  

This chapter provides a minimal, robust deployment pattern optimised for small, standalone BMS installations.

---

# Design Goals for Small Sites

A small-site OT architecture must provide:

- **Stability with minimal equipment**  
- **Simple troubleshooting**  
- **Secure remote access**  
- **Clear separation between IT and OT**  
- **Support for future expansion**  
- **Low operational cost**  

Simplicity is the primary objective — complexity introduces fragility.

---

# 1. Recommended Hardware Architecture

A typical small building includes:

- 1 × OT access switch (layer 2)  
- 1 × Router/firewall (shared IT+OT or separate OT FW)  
- 1 × HVAC controller panel  
- Optional lighting controls  
- Optional energy meter(s)  
- Optional Modbus gateway  
- Optional BACnet MS/TP gateway  

Most deployments contain fewer than 10 IP-connected devices.

---

# 2. VLAN & IP Design

Small buildings should avoid unnecessary VLAN sprawl but must still separate OT from IT.

### Minimum VLAN structure:

VLAN 10 – IT LAN
VLAN 20 – OT/BMS
VLAN 30 – Vendor Remote Access

This ensures:
- OT traffic cannot mix with IT  
- Vendor access cannot reach OT directly  
- Clean firewall separation  

### IP addressing:

10.5.20.0/24 – OT/BMS subnet
10.5.30.0/24 – Vendor VLAN

### Do NOT:

- Put OT on the same LAN as POS or corporate devices  
- Use 192.168.0.0/24 or 192.168.1.0/24 (collisions with vendor defaults)  

---

# 3. Supervisor Strategy for Small Buildings

Small sites rarely justify a full supervisory server.

### Three recommended options:

---

## Option A — **Cloud-Hosted Supervisor**  
(Best for retail chains or multisite estates)

Local controllers → Secure outbound connection → Cloud supervisor

Pros:
- No on-site servers  
- Central analytics and monitoring  
- Automatic patching  
- No need for on-site IT support  

Cons:
- Requires stable outbound internet  
- Must avoid exposing controllers inbound  

---

## Option B — **Embedded Supervisor in Controller Panel**

Many modern HVAC controllers include:
- Local web UI  
- Local trending  
- Schedules  
- Simple alarm features  

Pros:
- Lowest cost  
- No PC/server required  

Cons:
- Limited trending capability  
- Vendor lock-in  
- Hard to scale  

---

## Option C — **Small Embedded Appliance in OT Network**

Examples:
- Industrial mini-PC  
- Ruggedised ARM appliance  

Pros:
- Local historian + remote sync  
- Robust performance  
- Works offline  

Cons:
- Requires management  
- Higher cost than embedded controller  

---

# 4. Gateway Placement for Small Sites

Small sites often require a gateway for:

- MS/TP  
- Modbus RTU  
- KNX TP1  
- Serial equipment  

### Placement:
- Gateways should reside in OT VLAN  
- Use static IP addresses  
- Keep serial wiring short and shielded  
- Mount on DIN rail in HVAC panel  

### Do NOT:
- Place gateways in the IT LAN  
- Bridge MS/TP across IT networks  
- Connect vendor laptops directly to gateway ports  

---

# 5. Remote Access Design for Small Buildings

Small buildings are frequent targets for poor remote-access practices:

- 4G/5G vendor routers  
- Unsecured VPN appliances  
- Direct controller exposure  
- Shared credentials  
- Ad-hoc unmanaged switches  

To avoid these pitfalls:

---

## Recommended Remote Access Model for Small Buildings

Vendor → VPN → DMZ → Jump Host → Firewall → OT VLAN

### Requirements:

- MFA mandatory  
- Vendor VLAN isolated  
- Jump host centralised (not on-site)  
- No direct vendor access to controllers  
- No inbound NAT to OT devices  

### Do NOT:
- Put a VPN endpoint inside the OT VLAN  
- Allow vendors to dial into controllers directly  
- Open inbound port forwards from the internet  

These are the most common causes of small-site OT compromises.

---

# 6. Firewall Rules for Small Buildings

Small-site firewalls must be *minimal but strict*.

### Outbound from OT:
- Allow NTP to internal OT/DC sources  
- Allow HTTPS to cloud supervisory platform  
- Allow DNS  

### Inbound to OT:
- Block all inbound unless via jump host  
- Block Modbus (TCP 502) from IT  
- Block BACnet (UDP 47808) from IT  

### Between VLANs:
- IT → OT: deny by default  
- Vendor → OT: allow via jump host only  
- OT → IT: allow supervisor access to DB/log servers if required  

---

# 7. Small-Site BACnet/IP Design

For small sites, BACnet/IP is very simple:

- One BACnet VLAN  
- No BBMD needed  
- One BACnet network number  
- Supervisor (cloud or on-site) communicates via unicast  
- Controllers use static IP addresses  

This eliminates most BACnet/IP complexity.

---

# 8. Small-Site Modbus TCP Design

Modbus best practices:

- Place all Modbus devices in OT VLAN  
- Gateways use static IP  
- Supervisory polling rate should be low (<2 polls/sec/device)  
- No vendor scanning tools allowed on-site  
- Firewall Modbus TCP (502) strictly  

---

# 9. High Availability Considerations

Small buildings typically do **not** use:

- Redundant controllers  
- Redundant switches  
- Fibre rings  
- Supervisor HA  

But you *should* still consider:

### Power resilience:
- UPS on OT switch  
- UPS on firewall/router  
- Surge protection  

### Network resilience:
- Avoid daisy-chaining  
- Use industrial-grade switch for harsh environments  
- Document wiring and ports  

### Logical resilience:
- Supervisor fallback logic  
- Gateway watchdog timers  
- Local trending in controllers  

---

# 10. Internet Connectivity Strategy

Small-site OT must not depend on:

- Guest Wi-Fi  
- Retail POS networks  
- Customer-facing broadband  
- Temporary vendor SIM routers  

### Acceptable options:
- Dual WAN with failover  
- Managed SD-WAN from corporate IT  
- MPLS or private WAN circuits  
- Outbound-only secure tunnels  

Reliability of remote access relies on stable connectivity.

---

# 11. Monitoring for Small Buildings

Monitoring should be centralised.

Monitoring items:

- Controller online/offline status  
- Trend uploads  
- Gateway health  
- Modbus/BACnet communication errors  
- Temperature/energy anomalies  
- NTP sync status  
- Firewall logs  
- Remote-access events  

Small sites must be monitored at scale.

---

# 12. Common Small-Site Deployment Failures

### ❌ Vendor installs unmanaged switch  
Result: VLAN leaks, STP loops, instability.

### ❌ VPN router inside HVAC panel  
Result: complete bypass of OT firewall.

### ❌ Controller connected to IT switch  
Result: broadcast storms, uncontrolled access.

### ❌ IT NAT exposes BACnet/Modbus to internet  
Result: severe security incident.

### ❌ Using consumer broadband routers with UPnP  
Result: unpredictable inbound exposure.

### ❌ Shared vendor login accounts  
Result: no auditability.

### ❌ Cloud supervisor requires inbound port forwarding  
Result: immediate high-risk exposure.

---

# 13. Small Building Deployment Checklist

- [ ] 1 OT VLAN only  
- [ ] 1 Vendor VLAN  
- [ ] Strict separation from IT LAN  
- [ ] Supervisor = cloud or embedded  
- [ ] No BBMD required  
- [ ] Gateways use static IPs  
- [ ] All inbound access blocked  
- [ ] Remote access via central jump host  
- [ ] Firewall manages inter-VLAN access  
- [ ] UPS for OT networking gear  
- [ ] Monitoring integrated with central estate  

---

# Summary

Small buildings benefit from simple, robust OT architectures.  
The key is strong separation from IT, secure remote access, minimal VLANs, and stable, well-managed gateways and controllers.

Key principles:

- Keep architecture simple  
- Avoid BBMD and complex routing  
- Secure remote access through DMZ + jump host  
- Never let vendors connect directly to controllers  
- Monitor centrally  
- Prioritise reliability and ease of support  

A correctly designed small-site OT network is low-maintenance, predictable, and secure across hundreds or thousands of remote buildings.
