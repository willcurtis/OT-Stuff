# Zero-Trust for OT  
**Enforcing Identity, Device Trust, Network Segmentation, Access Policies, and Workload Protection in Building Automation Systems**

Zero-trust rejects the outdated assumption that anything inside the OT network is “trusted.”  
Instead, *every* device, user, protocol, and connection must continuously prove it is authorised.

This chapter redefines zero-trust for OT environments where controllers, gateways, wireless devices, and servers coexist—many with limited capability and long lifecycles.

---

# 1. What Zero-Trust Means for OT

Zero-trust in OT requires adapting enterprise ZT frameworks to the constraints of building automation.

### Key principles:
1. **Never trust any device or user by default**  
2. **Authenticate and authorise every session**  
3. **Use least-privilege access**  
4. **Micro-segment systems**  
5. **Encrypt where possible**  
6. **Assume breach and limit blast radius**  
7. **Continuously verify posture and behaviour**  

OT zero-trust must be *simple*, *offline-capable*, and *predictable*.

---

# 2. Zero-Trust Pillars in OT

OT zero-trust spans four domains:

	1.	Identity Trust   – Who is making the request?
	2.	Device Trust     – Is the device allowed to talk?
	3.	Network Trust    – Is this path permitted?
	4.	Workload Trust   – Is the application/protocol safe?

We build OT rulesets using these domains.

---

# 3. Identity Trust (Users & Vendors)

Identity trust governs all human-initiated activity.

### Requirements:
- MFA for all remote access  
- Per-vendor accounts  
- No shared accounts  
- No direct login to controllers  
- Jump host mandatory  
- Time-boxed access (auto-expire)  
- Session recording for vendors  
- Role-based access to all BMS UIs  

### Identity Approval Flow:
1. User requests access  
2. Reviewer approves  
3. Temporary credentials issued  
4. Session is monitored and recorded  
5. Account automatically expires  

---

# 4. Device Trust (Controllers, Gateways, IoT Devices)

OT devices must prove identity based on:

### 4.1 Allowed IP/VLAN Placement  
Devices only communicate within their assigned VLAN.

### 4.2 MAC/IP Binding  
Static mappings where possible.

### 4.3 Certificates  
For BACnet/SC, OPC-UA, and MQTT TLS.

### 4.4 Behavioural Expectations  
Devices have:
- Predictable poll intervals  
- Fixed protocol behaviour  
- Limited destinations  

Any deviation triggers an alert.

### 4.5 Disable Unused Services  
Remove:
- HTTP → use HTTPS  
- Telnet  
- FTP  
- Vendor cloud backdoors  

### 4.6 Enrollment Workflow  
Commissioning requires:
- Firmware validation  
- Password setup  
- Certificate enrollment (if applicable)  
- Registration in CMDB  

---

# 5. Network Trust (Micro-Segmentation & Boundary Protection)

OT networks must enforce network trust through segmentation and firewalls.

### 5.1 Per-System VLAN Micro-Segmentation  
Each subsystem gets its own VLAN:
- HVAC  
- Lighting  
- KNX  
- DALI  
- Modbus  
- Energy  
- IoT wireless  
- VRF/VRV  

### 5.2 L3 at Distribution  
Provides:
- Broadcast isolation  
- Per-floor segmentation  
- No spanning tree propagation  

### 5.3 No L2 Between Buildings  
All buildings connect via routed links only.

### 5.4 OT Firewalls Enforce Policy  
Firewalls block:
- Broadcast/multicast traversal  
- East–west controller traffic  
- OT ↔ IT direct communication  
- Lighting multicast leaving VLANs  

### 5.5 Allow Paths Only to Supervisors  
Controllers must only talk to:
- Their supervisor  
- Their gateway  
- BACnet/SC Hub  
- MQTT broker (if used)  

Nothing else.

---

# 6. Workload Trust (Protocol-Level Zero-Trust)

Workload trust ensures protocols are safe even if devices or users are compromised.

---

## 6.1 BACnet

Zero-trust rules:
- Only unicast permitted  
- No broadcast across VLANs  
- No BBMD across buildings  
- BACnet/SC preferred  
- Supervisors read/write only authorised objects  
- Logging of all writes  

---

## 6.2 Modbus TCP

Zero-trust rules:
- Only supervisors allowed to write registers  
- Gateways enforce read-only where possible  
- No east–west Modbus  
- Poll rate limits enforced  

---

## 6.3 KNX IP

Zero-trust rules:
- No routed multicast  
- Only jump host permitted for tunnelling  
- KNX Secure for future sites  

---

## 6.4 MQTT

Zero-trust rules:
- TLS only  
- Per-device certificates  
- No anonymous clients  
- ACLs by topic  
- Sensors can publish only  
- Analytics/readers can subscribe only  

---

## 6.5 OPC-UA

Zero-trust rules:
- TLS + certificate pinning  
- Signed/encrypted nodes  
- Role-based node access  
- No direct IT → controller OPC connections  

---

## 6.6 Lighting Protocols (DALI, DMX, Art-Net, sACN)

Zero-trust rules:
- Never routed  
- Multicast contained to VLAN  
- Controllers only  
- No Internet exposure  
- No unauthorised Art-Net broadcast  

---

# 7. Zero-Trust in Remote Access

Remote access is the easiest path to compromise.

### Required Controls:
- VPN + MFA  
- No split tunnelling  
- Jump host only  
- No direct RDP/SSH to controllers  
- Session recording mandatory  
- JIT (Just-In-Time) accounts  
- Automatic rule expiration  

### Enforcement Flow:

Vendor → VPN → IT Firewall → DMZ Jump Host → OT Firewall → OT Device (Restricted)

Every hop enforces identity, device, and network trust.

---

# 8. Zero-Trust Enforcement Points

### 8.1 Firewalls  
Primary enforcement of:
- East–west segmentation  
- Protocol allow-lists  
- Broadcast containment  
- Remote-access gating  

### 8.2 Access Switches  
Enforce:
- Port security  
- DHCP snooping  
- DAI  
- Storm control  

### 8.3 Gateways  
Enforce:
- Protocol ACLs  
- Rate limits  
- Authentication  

### 8.4 Application Layer  
Enforce:
- RBAC  
- MFA for UIs  
- Certificate validation  
- Write restrictions  

---

# 9. Zero-Trust Architecture Diagram

```mermaid
flowchart TD

    subgraph Identity Trust
        IDA[Identity Provider / MFA]
    end

    subgraph Device Trust
        DT[Certificates / Behaviour Profiles]
    end

    subgraph Network Trust
        FW1[OT Firewall]
        FW2[DMZ Firewall]
        VLAN[VLAN Micro-Segmentation]
    end

    subgraph Workload Trust
        WL[Protocol Enforcement (BACnet/SC, MQTT ACLs, Modbus RO, OPC-UA Certs)]
    end

    User[Vendor/Engineer] --> IDA
    Device --> DT

    DT --> VLAN
    VLAN --> FW1
    FW1 --> DMZ
    DMZ --> FW2
    FW2 --> IT

    VLAN --> WL
    WL --> OTSystems[OT Systems]


# 10. Zero-Trust Migration Path (Practical, Step-by-Step)

OT environments cannot adopt zero-trust in one jump.
A phased migration is essential.

## Phase 1 — Establish Network Boundaries
	•	Create VLAN per system
	•	Implement L3 at distribution
	•	Block BACnet broadcasts across VLANs
	•	Begin logging traffic

## Phase 2 — Deploy OT DMZ
	•	Move supervisors into DMZ
	•	Enforce DMZ ↔ OT firewall rules
	•	Remove IT → OT direct links

## Phase 3 — Implement Remote Access Zero-Trust
	•	Introduce MFA
	•	Introduce jump host
	•	Remove vendor direct VPNs
	•	Approvals + session recording

## Phase 4 — Introduce Workload Controls
	•	Switch to BACnet/SC
	•	Add MQTT ACLs
	•	Add OPC-UA certificates
	•	Remove unsafe protocols

## Phase 5 — Introduce Device Trust
	•	Certificate enrollment
	•	Baseline behaviour modelling
	•	Enforce firmware signatures
	•	Add device identity checks

## Phase 6 — Continuous Verification
	•	Monitor for anomalous behaviour
	•	Audit user access
	•	Review firewall logs
	•	Correlate OT SIEM events

# 11. Zero-Trust Success Criteria

You have achieved OT zero-trust when:
	•	No controller accepts traffic outside its whitelist
	•	No VLAN talks to any other VLAN except via supervisor
	•	No broadcast crosses L3 boundaries
	•	Vendors cannot reach OT without explicit approval
	•	Supervisors are isolated in DMZ
	•	Every protocol has application-level enforcement
	•	OT and IT networks remain mutually isolated
	•	An attacker in one subsystem cannot move laterally

⸻

# Summary

Zero-trust transforms OT networks from flat, implicitly trusted environments into tightly controlled, segmented, identity-driven architectures.

Success requires:
	•	Strong identity
	•	Strong device validation
	•	Strict network segmentation
	•	Protocol-level enforcement
	•	Controlled remote access
	•	Continuous monitoring

Zero-trust is not a product—it is an architecture and operational model adapted to the realities of legacy and modern building systems.
