# Overview

Operational Technology (OT) networks are increasingly converging with traditional IT networks as buildings, campuses, and industrial sites adopt intelligent control systems. Modern Building Management Systems (BMS)—covering HVAC, lighting, access control, energy metering, and environmental monitoring—now rely heavily on IP-based infrastructure and standard networking protocols.

This manual is written for **network engineers** who are entering or working within the OT/BMS domain. Its goal is to explain the technologies, architectures, protocols, and security controls that underpin modern building automation so that network engineers can design, deploy, and troubleshoot BMS networks with confidence.

---

## Why This Manual Exists

BMS networks historically evolved without strong IT governance. As a result:

- Proprietary protocols dominated (BACnet MS/TP, Modbus RTU, LON).  
- Network segmentation was rarely planned.  
- Security was minimal or non-existent.  
- Vendor-managed systems often created operational blind spots.  
- Remote access was bolted on through insecure methods (PPTP, RDP over WAN, etc.).

Today, BMS infrastructure is a critical operational service and a key cyber-security concern. HVAC systems affect compliance, health, comfort, energy performance, and sometimes life-safety functions.

Network engineers are now expected to:

- Evaluate and design BMS networks.
- Support legacy and modern control systems.
- Secure OT/BMS traffic.
- Maintain uptime and service performance.
- Enable safe remote access for engineers and integrators.

This manual bridges the gap between the BMS world and network engineering best practices.

---

## What You Will Learn

By the end of this manual, you will understand:

- How BMS controllers, sensors, and field buses operate.
- How BACnet/IP, Modbus TCP, OPC-UA, KNX, and other OT protocols function at the packet level.
- How to design segmented OT networks with VLANs, firewalls, and HA.
- How to secure BMS infrastructure using Zero Trust principles.
- How to deploy scalable BMS topologies for sites of different sizes.
- How to troubleshoot OT networks methodically across Layer 1–7.
- How to commission new BMS infrastructure safely and systematically.

---

## How to Use This Manual

- **New to OT/BMS?**  
  Start with Fundamentals → Protocols → Architecture.

- **Designing a network?**  
  Jump to Architecture → Deployment Patterns.

- **Troubleshooting?**  
  Use the Troubleshooting section combined with protocol specifics.

- **Security or remote access planning?**  
  Focus on Security → Examples (VPN/BACnet).

---

## Assumptions

You are familiar with:

- TCP/IP networking  
- VLANs, routing, switching  
- Firewalls and ACLs  
- Basic cyber-security principles  

No prior experience in OT or BMS systems is assumed.

---

## Document Conventions

### Terminology
Where abbreviations are used, the full term is given first—for example:  
**BACnet/IP (Building Automation and Control Network over IP)**.

### Diagrams
Mermaid diagrams are used for topologies and flows:

```mermaid
flowchart LR
    Sensor --> Controller --> BMS-Supervisor
    Controller --> Network
