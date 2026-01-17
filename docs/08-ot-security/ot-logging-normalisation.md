# OT Logging Normalisation  
**Normalising BACnet, Modbus, MQTT, KNX, OPC-UA, and Lighting Protocol Logs for SIEM / OT SOC Ingestion**

OT protocols do **not** produce standard log messages.  
Normalisation converts vendor-specific messages into consistent event structures that can be searched, correlated, and alerted on.

This chapter defines:

- Field taxonomy  
- Normalisation schemas  
- Syslog/JSON examples  
- Mapping tables  
- SIEM-ready formats  
- Ingestion recommendations  

---

# 1. Normalisation Goals

1. Make OT protocol events searchable  
2. Enable SOC correlation rules  
3. Standardise field names  
4. Reduce false positives  
5. Preserve forensic detail  

Normalisation should be applied *before* events reach SIEM.

---

# 2. OT Protocol Field Taxonomy (Master Schema)

All protocols share a core set of fields.

### Required fields:

timestamp
protocol
src_ip
dst_ip
src_port
dst_port
action
result

### Recommended fields:

device_id
device_type
vlan
site
building

### Extended fields (contextual):

object_type
object_name
function_code
register
value
topic
session_id
client_id
certificate_status
user

---

# 3. BACnet Normalisation Schema

### Raw BACnet log example (vendor-specific):

WriteProperty tag=analogValue-103 newValue=25 src=10.0.42.11 dst=10.0.50.5

### Normalised JSON:
```json
{
  "timestamp": "2025-01-12T14:22:55Z",
  "protocol": "BACnet/IP",
  "action": "WriteProperty",
  "object_type": "analogValue",
  "object_name": "103",
  "value": 25,
  "src_ip": "10.0.42.11",
  "dst_ip": "10.0.50.5",
  "vlan": "OT_HVAC_03",
  "result": "success"
}

## Field Mapping Table:

Raw Field
Normalised Field
tag
object_type/object_name
newValue
value
src
src_ip
dst
dst_ip

# 4. Modbus Normalisation Schema

## Raw log example:

FNC=WRITE_SINGLE_REGISTER REG=3012 VAL=99 SRC=10.10.10.5 DST=10.20.20.8

## JSON:

{
  "timestamp": "2025-01-12T14:23:11Z",
  "protocol": "ModbusTCP",
  "action": "WriteSingleRegister",
  "register": 3012,
  "value": 99,
  "src_ip": "10.10.10.5",
  "dst_ip": "10.20.20.8",
  "vlan": "OT_MODBUS_01",
  "result": "success"
}

Notes:
	•	function_code → renamed to action
	•	Only include register OR coil depending on function

# 5. MQTT Normalisation Schema


