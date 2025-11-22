# OT / BMS Network Playbook

Practical guidance for discovering, documenting, and improving OT & BMS networks from a network engineer’s perspective.

---

## 1. Objectives
- Understand “what’s here?” without breaking anything.
- Identify OT/BMS devices, services, and protocols.
- Baseline topology (VLANs, subnets, routes).
- Prepare for segmentation, hardening, or migration.

---

## 2. Phased Discovery Approach

### Phase 0 – Preparation & Safety
- Change record / approval opened.
- Critical systems listed (CHW, AHUs, theatres, cold rooms, etc.).
- “Do not touch” systems (fire, life safety, medical gases).
- Scope agreed (buildings, VLANs, windows).
- Single estates/FM contact.
- Rollback expectations defined.

### Phase 1 – Passive Baseline (No Active Scans)
1. SPAN / RSPAN on a core OT switchport.
2. Capture with Wireshark/tshark (15–30 min minimum).
3. Identify:
   - BACnet/IP (UDP/47808)
   - Modbus/TCP (TCP/502)
   - Siemens S7 (TCP/102)
   - DNP3 (TCP/UDP 20000)
   - EtherNet/IP (TCP/44818)
   - SNMP, HTTP/HTTPS to front-ends
4. Note top talkers, broadcast/multicast rate, VLANs carrying OT.

Outputs:
- Protocol list
- IP↔MAC↔VLAN mapping
- Any storms/loops

### Phase 2 – Safe Active Discovery (Nmap)
Start conservative on known OT subnets only.

    sudo nmap -sS -sU \
      -p 47808,502,102,161,1911,4911,44818,20000 \
      -sV \
      --script=safe,discovery \
      <CIDR>

Focus on BACnet, Modbus, S7, Niagara, ENIP, DNP3.
Outputs:
- Asset inventory (IP, MAC, vendor, services)
- Likely role (server / supervisory / controller / PLC / gateway)

### Phase 3 – Protocol-Level Enumeration (Change Window)
BACnet
- Tools: Nmap “bacnet-info” (safer), “bacnet-discover” (more intrusive), YABE, BAC0
- Goals: device IDs, names/locations, objects, BBMDs

Modbus/TCP
- Tools: Nmap “modbus-discover”, Pymodbus, Modbus Poll/Modscan
- Goals: slave IDs, function codes, read-only registers if allowed

Siemens S7
- Tools: Nmap “s7-info”, Wireshark (s7comm)
- Goals: PLC identity, slots/racks, programming/SCADA endpoints

### Phase 4 – Documentation & Baseline Pack
Deliver:
- IP & VLAN plan for OT
- L3 diagram (subnets/routes)
- Device & protocol inventories
- Risk register: SPOFs, aging kit, shared IT/OT VLANs, vendor remote access

---

## 3. Segmentation Principles
- Separate IT and OT; contain broadcast domains
- Prefer routed L3 over large flat L2
- Use zones/conduits with firewalls/ACLs at boundaries

BACnet specifics
- Broadcast-heavy discovery
- Cross-subnet comms needs BBMD/BACnet routers (not NAT)
- Keep BACnet broadcast domains small and intentional

---

## 4. Operational DOs & DON’Ts

DO
- Capture before change
- Plan rollback and validate after
- Coordinate with estates/plant
- Keep accurate VLAN/IP docs and backups

DON’T
- Mass-scan entire ranges
- Reboot controllers “to see if it helps”
- Upgrade firmware in hours without a rollback
- Merge OT & IT VLANs “for convenience”

---

## 5. Red Flags (Takeover)
- No drawings, IP plan, or inventory
- Single aging BMS server, no backup/cluster
- Controllers share VLAN with user PCs
- Unmanaged switches in risers/plant rooms
- Direct vendor VPN into OT with no oversight
- Wi-Fi/4G routers patched into OT switches
- No UPS; no monitoring/logging

---

## 6. Pre-Migration Checklist (Condensed)
- [ ] Stakeholders aligned (IT/OT/estates/vendor)
- [ ] Scope confirmed (buildings/VLANs/window)
- [ ] OT servers/controllers inventoried
- [ ] OT VLANs & IP ranges documented
- [ ] Passive captures archived
- [ ] Integrations identified (FM, cloud, tenant)
- [ ] Backups verified (servers/controllers if possible)
- [ ] Rollback documented and realistic
- [ ] Post-change validation tests agreed
