# Wireshark Display Filter Cheatsheet (OT Protocols)

Practical filters for analysing OT / BMS traffic.

---

## 1) General Tips
- Prefer display filters while learning; keep capture filters simple.
- Create colouring rules for BACnet, Modbus, S7, DNP3, ENIP/CIP.
- Save a Wireshark Profile per site/customer.

---

## 2) BACnet

All BACnet  
    bacnet

Broadcast BACnet  
    bacnet && eth.dst == ff:ff:ff:ff:ff:ff

Who-Is / I-Am (discovery)  
    bacnet.who_is || bacnet.i_am

Read / Write Property  
    bacnet.read_property || bacnet.write_property

Confirmed vs Unconfirmed services  
    bacnet.confirmed_service
    bacnet.unconfirmed_service

Default port only  
    udp.port == 47808 && bacnet

---

## 3) Modbus/TCP

All Modbus  
    modbus

Default port  
    tcp.port == 502 && modbus

Read Holding Registers (FC 3)  
    modbus.func_code == 3

Read Input Registers (FC 4)  
    modbus.func_code == 4

Write Single Coil / Register (FC 5 / 6)  
    modbus.func_code == 5 || modbus.func_code == 6

Common write types (5/6/15/16)  
    modbus.func_code == 5 || modbus.func_code == 6 || modbus.func_code == 15 || modbus.func_code == 16

---

## 4) Siemens S7 (s7comm)

All S7comm  
    s7comm

Default port  
    tcp.port == 102 && s7comm

Read / Write variable  
    s7comm.read.var || s7comm.write.var

Setup communication  
    s7comm.setup_communication

---

## 5) DNP3

All  
    dnp3

Standard ports  
    tcp.port == 20000 || udp.port == 20000

---

## 6) EtherNet/IP (ENIP) / CIP

All EtherNet/IP  
    enip

All CIP  
    cip

Standard port  
    tcp.port == 44818

---

## 7) SNMP (often present on OT/BMS devices)

All  
    snmp

Default port  
    udp.port == 161 && snmp

---

## 8) Generic & Helpful Filters

By IP  
    ip.addr == 10.10.20.15

By MAC  
    eth.addr == aa:bb:cc:dd:ee:ff

Broadcast or multicast  
    eth.dst == ff:ff:ff:ff:ff:ff || eth.dst[0] & 1

Quick OT ports (example bundle)  
    tcp.port == 502 || udp.port == 47808 || tcp.port == 102 || tcp.port == 44818 || tcp.port == 20000

Show BACnet/Modbus/S7 only  
    bacnet || modbus || s7comm

---

## 9) Capture Strategy Notes

- Use SPAN/RSPAN on an OT switch; avoid inline taps unless planned.
- Capture 15–30 minutes of “normal” operations.
- Save as .pcapng; retain originals for baselining.
- Pair captures with switchport/VLAN notes for future correlation.
