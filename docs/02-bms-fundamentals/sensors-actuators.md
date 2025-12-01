# Sensors and Actuators

Sensors and actuators form the lowest tier of a Building Management System (BMS). They provide the real-world data that controllers use and carry out the physical adjustments required to maintain environmental conditions. While these devices do not typically communicate directly over IP networks, understanding them is essential for diagnosing upstream network issues and determining whether a reported fault is caused by the control system, field wiring, or the network.

This document provides a detailed overview of sensor and actuator types, signal behaviours, electrical interfaces, and common failure modes.

---

## Role of Sensors and Actuators in BMS Architecture

### Sensors
Sensors measure environmental conditions including:
- Temperature  
- Humidity  
- Pressure (static, differential, gauge)  
- Carbon dioxide (CO₂)  
- Volatile organic compounds (VOCs)  
- Airflow  
- Water flow  
- Electrical usage (via pulse or serial meters)  

Their outputs are fed into controllers that perform logic such as comparing values against setpoint thresholds.

### Actuators
Actuators perform the mechanical response required by the controller:
- Valve movement  
- Damper position adjustment  
- Fan speed modulation  
- Relay switching for pumps, heaters, or compressors  

Actuators always require a control output signal and sometimes return a position or feedback signal.

---

## Sensor Signal Types

Most field sensors fall into one of several categories depending on their output type.

### 1. Analog Voltage (0–10V)
Common for:
- Temperature sensors  
- Pressure sensors  
- Valve/damper position feedback  

Properties:
- Linear scaling  
- Susceptible to electrical noise  
- Limited cable distance  

Controllers must correctly map the voltage to engineering units.

### 2. Analog Current (4–20mA)
Used for:
- Critical or long-distance sensing  
- Industrial-grade installations  

Properties:
- More immune to electrical noise  
- Fault detection is built-in (below 4mA indicates open circuit)  
- Long cable distances supported  

Incorrect termination or grounding causes drift and incorrect readings.

### 3. Digital Inputs (On/Off)
Used for:
- Fan status signals  
- Filter dirty alarms  
- Pump fault relays  
- Door contacts in security systems  

Typically dry contact or 24V signals.

### 4. Pulse Inputs
Used mainly for:
- Energy meters  
- Water meters  
- Gas meters  

Controllers convert pulses into consumption and/or flow rates.

### 5. Resistive Sensors (NTC/PTC)
Temperature sensors using:
- Negative Temperature Coefficient (NTC) thermistors  
- Positive Temperature Coefficient (PTC) thermistors  
- RTDs such as PT100/PT1000  

These require accurate input module calibration.

### 6. Serial Sensors (Modbus RTU)
Sensors with embedded logic may export data via:
- RS-485 (Modbus RTU)  
- Manufacturer-specific protocols  

These often require gateway devices to bring data into IP networks.

---

## Actuator Types

### 1. Floating (3-point) Actuators
Three wires:
- Open  
- Close  
- Common  

Movement occurs while the corresponding input is energised.

Advantages:
- Simple, robust  
Disadvantages:
- No precise feedback  
- Requires tuning to avoid drift  

### 2. Analog Modulating Actuators (0–10V or 4–20mA)
Used when precise control is required:
- PICVs (Pressure Independent Control Valves)  
- Modulating dampers  
- Variable-flow hydronic circuits  

Controller manages continuous positioning.

### 3. On/Off Actuators
Relay-based control for:
- Solenoid valves  
- Heater stages  
- Fans and pumps (via contactors)  

Suitable for binary operation.

### 4. Smart Actuators (BACnet, Modbus, KNX)
Actuators with embedded communication interfaces provide:
- Detailed feedback  
- Runtime statistics  
- Fault codes  
- Positioning accuracy  

These communicate via:
- Modbus RTU  
- BACnet MS/TP  
- KNX TP1  

They may require a gateway for IP integration.

---

## Scaling and Calibration

Sensors often require calibration and scaling to convert electrical signals into meaningful engineering units.

Examples:
- A 0–10V pressure sensor may represent 0–3000 Pa.  
- A 4–20mA flow meter may represent 0–4000 L/h.  
- An NTC 10k temperature sensor requires a lookup curve.

If controllers use incorrect scaling:
- Values appear inaccurate or reversed  
- Equipment runs inefficiently  
- PIDs become unstable  
- Energy consumption increases  

Network engineers should consider scaling issues when BMS values appear incorrect but communication is functioning correctly.

---

## How Sensors and Actuators Affect the Network (Indirectly)

Although field devices rarely sit on IP networks, they influence network traffic and system behaviour:

### 1. High point counts increase supervisor-controller traffic
More sensors → more data points → more polling or subscription traffic.

### 2. Fast-changing values increase bandwidth
Rapid airflow or pressure changes may generate high COV (Change of Value) traffic.

### 3. Control instability can appear as network faults
Incorrect feedback can:
- Cause controllers to oscillate  
- Trigger excessive writes to actuators  
- Produce alarm floods that saturate the supervisor  

### 4. Faulty sensors lead to misleading troubleshooting paths
Network engineers are frequently called for:
- "Communication issues"  
- "Controller offline"  
- "BACnet values incorrect"

But many of these originate from:
- Sensor miswiring  
- Power supply issues  
- Ground loops  
- Failed actuators  

---

## Common Field Device Failure Modes

### 1. Electrical Noise and Interference
Symptoms:
- Fluctuating readings  
- Intermittent faults  

Causes:
- Long cable runs  
- Parallel routing with high-voltage lines  
- Poor shielding  

### 2. Ground Loops
Symptoms:
- Off-scale values  
- Drift  
Causes:
- Incorrect earthing  
- Multiple grounding points  

### 3. Incorrect Sensor Type Installed
Example:
- PT100 expected, NTC10k installed  
- Results in wildly inaccurate temperature readings  

### 4. Actuator Feedback Failure
Symptoms:
- Valve or damper does not reach commanded position  
- Controller logs control-loop instability  

### 5. Mechanical Wear
Valves and dampers eventually:
- Stick  
- Stall  
- Overshoot  
- Develop backlash  

These issues mimic PID tuning or network latency problems.

### 6. Power Supply Instability
Low-voltage supplies in control panels cause:
- Sensor brownouts  
- Unexpected controller resets  

---

## Best Practices for Network Engineers

Even though sensors and actuators are not networked, network engineers should:

1. Understand the field device tier to interpret network-level symptoms.  
2. Validate that incorrect sensor values are not mistaken for communication failures.  
3. Consider point count and update rates when designing controller VLANs.  
4. Ensure correct time synchronisation to align logs, trends, and alarms.  
5. Confirm gateways correctly map sensor/actuator data to BACnet or Modbus registers.  
6. Liaise with BMS engineers to diagnose field-level anomalies.  

---

## Summary

Sensors and actuators provide the real-world data and physical control actions that define building automation. While they do not communicate over IP in most deployments, their behaviour and health strongly influence network traffic patterns, supervisory load, and troubleshooting workflows.

Understanding the sensor/actuator ecosystem is essential for any network engineer supporting a modern BMS deployment.
