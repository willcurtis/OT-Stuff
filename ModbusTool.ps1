<#
.SYNOPSIS
    Simple Modbus TCP query tool.

.DESCRIPTION
    Implements basic Modbus TCP client functions in pure PowerShell:
    - Read Coils (FC=1)
    - Read Discrete Inputs (FC=2)
    - Read Holding Registers (FC=3)
    - Read Input Registers (FC=4)

.EXAMPLE
    # Read 10 holding registers starting at 40001 (address 0) from unit 1
    Invoke-ModbusQuery -Ip 10.0.0.10 -Function HoldingRegisters -Address 0 -Count 10

.EXAMPLE
    # Read 16 coils starting at address 0
    Invoke-ModbusQuery -Ip 10.0.0.20 -Function Coils -Address 0 -Count 16

.NOTES
    - This is Modbus *TCP* only.
    - For RTU/RS-485 you’d need a serial implementation or a TCP-to-RTU gateway.
#>

# Script-scoped transaction ID counter for MBAP header
if (-not $script:ModbusTransactionId) {
    $script:ModbusTransactionId = 1
}

function Invoke-ModbusQuery {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Ip,

        [int]$Port = 502,

        [byte]$UnitId = 1,

        [Parameter(Mandatory)]
        [ValidateSet('Coils','DiscreteInputs','HoldingRegisters','InputRegisters')]
        [string]$Function,

        [int]$Address = 0,

        [int]$Count = 1,

        [int]$TimeoutMs = 2000
    )

    # Map function name to Modbus function code
    $functionCode = switch ($Function) {
        'Coils'            { 1 }
        'DiscreteInputs'   { 2 }
        'HoldingRegisters' { 3 }
        'InputRegisters'   { 4 }
    }

    # Helper: split UInt16 into high/low bytes
    function Get-HighByte([UInt16]$v) { [byte]($v -shr 8) }
    function Get-LowByte ([UInt16]$v) { [byte]($v -band 0xFF) }

    # Build MBAP + PDU request frame
    $txId = [UInt16]$script:ModbusTransactionId
    $script:ModbusTransactionId = ($script:ModbusTransactionId + 1) -band 0xFFFF

    $protocolId = 0      # Modbus TCP
    $length     = 6      # UnitId (1) + Function (1) + Address (2) + Count (2)

    $address16 = [UInt16]$Address
    $count16   = [UInt16]$Count

    # MBAP header (7 bytes)
    $mbap = [byte[]]@(
        (Get-HighByte $txId),
        (Get-LowByte  $txId),
        0x00, 0x00,                    # Protocol ID = 0
        (Get-HighByte $length),
        (Get-LowByte  $length),
        [byte]$UnitId
    )

    # PDU: Function + Start Address + Quantity
    $pdu = [byte[]]@(
        [byte]$functionCode,
        (Get-HighByte $address16),
        (Get-LowByte  $address16),
        (Get-HighByte $count16),
        (Get-LowByte  $count16)
    )

    $request = New-Object byte[] ($mbap.Length + $pdu.Length)
    [Array]::Copy($mbap, 0, $request, 0, $mbap.Length)
    [Array]::Copy($pdu,  0, $request, $mbap.Length, $pdu.Length)

    # Create TCP client and send
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $connectTask = $client.ConnectAsync($Ip, $Port)
        if (-not $connectTask.Wait($TimeoutMs)) {
            throw "Timeout connecting to $Ip`:$Port"
        }

        $client.ReceiveTimeout = $TimeoutMs
        $client.SendTimeout    = $TimeoutMs

        $stream = $client.GetStream()
        $stream.Write($request, 0, $request.Length)

        # Read response MBAP header first (7 bytes)
        $header = New-Object byte[] 7
        $bytesRead = $stream.Read($header, 0, 7)
        if ($bytesRead -ne 7) {
            throw "Incomplete MBAP header received (bytes: $bytesRead)."
        }

        # Parse MBAP header -> transaction, protocol, length, unit
        $respTxId    = [UInt16]($header[0] -shl 8 -bor $header[1])
        $respProtId  = [UInt16]($header[2] -shl 8 -bor $header[3])
        $respLength  = [UInt16]($header[4] -shl 8 -bor $header[5])
        $respUnitId  = $header[6]

        if ($respProtId -ne 0) {
            throw "Invalid protocol ID in response: $respProtId (expected 0)."
        }

        # Now read remaining bytes from response according to length
        # length = UnitId + PDU, we have already consumed UnitId in header,
        # so remaining bytes = length - 1
        $remaining = $respLength - 1
        $payload   = New-Object byte[] $remaining
        $offset    = 0

        while ($remaining -gt 0) {
            $chunk = $stream.Read($payload, $offset, $remaining)
            if ($chunk -le 0) {
                throw "Connection closed while reading response payload."
            }
            $remaining -= $chunk
            $offset    += $chunk
        }

        # payload[0] = Function code or Exception function code
        $respFn = $payload[0]

        if ($respFn -band 0x80) {
            # Exception
            $exceptionCode = $payload[1]
            $msg = switch ($exceptionCode) {
                1 { "Illegal Function" }
                2 { "Illegal Data Address" }
                3 { "Illegal Data Value" }
                4 { "Slave Device Failure" }
                5 { "Acknowledge" }
                6 { "Slave Device Busy" }
                8 { "Memory Parity Error" }
                10 { "Gateway Path Unavailable" }
                11 { "Gateway Target Device Failed to Respond" }
                default { "Unknown error code $exceptionCode" }
            }
            throw "Modbus exception: code $exceptionCode ($msg)"
        }

        # Standard response: payload[1] = byte count, then data bytes
        $byteCount = $payload[1]
        $data      = $payload[2..(1 + $byteCount)]

        switch ($Function) {
            'HoldingRegisters' { return Parse-ModbusRegisters -Data $data -StartAddress $Address }
            'InputRegisters'   { return Parse-ModbusRegisters -Data $data -StartAddress $Address }
            'Coils'            { return Parse-ModbusBits      -Data $data -StartAddress $Address -Count $Count }
            'DiscreteInputs'   { return Parse-ModbusBits      -Data $data -StartAddress $Address -Count $Count }
        }
    }
    finally {
        if ($client.Connected) { $client.Close() }
    }
}

function Parse-ModbusRegisters {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][byte[]]$Data,
        [int]$StartAddress = 0
    )

    if (($Data.Length % 2) -ne 0) {
        throw "Register data length ($($Data.Length)) is not even."
    }

    $results = @()
    $regCount = $Data.Length / 2

    for ($i = 0; $i -lt $regCount; $i++) {
        $hi = $Data[2*$i]
        $lo = $Data[2*$i + 1]
        $raw = [UInt16]($hi -shl 8 -bor $lo)
        $signed = [Int16]$raw

        $results += [pscustomobject]@{
            Address      = $StartAddress + $i
            RawUInt16    = $raw
            Int16        = $signed
            Hex          = ('0x{0:X4}' -f $raw)
        }
    }

    return $results
}

function Parse-ModbusBits {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][byte[]]$Data,
        [int]$StartAddress = 0,
        [int]$Count
    )

    $results = @()
    $bitIndex = 0

    foreach ($b in $Data) {
        for ($bit = 0; $bit -lt 8; $bit++) {
            if ($bitIndex -ge $Count) { break }

            $value = [bool]($b -band (1 -shl $bit))
            $results += [pscustomobject]@{
                Address = $StartAddress + $bitIndex
                Value   = $value
            }
            $bitIndex++
        }
    }

    return $results
}

<#
USAGE EXAMPLES
--------------

# Dot-source the script in your session:
. .\ModbusTool.ps1

# Read 10 holding registers from 40001
Invoke-ModbusQuery -Ip 10.0.0.10 -Function HoldingRegisters -Address 0 -Count 10 |
    Format-Table

# Read 16 coils from address 0
Invoke-ModbusQuery -Ip 10.0.0.20 -Function Coils -Address 0 -Count 16 |
    Format-Table

# Read input registers and export to CSV
Invoke-ModbusQuery -Ip 10.0.0.30 -Function InputRegisters -Address 100 -Count 8 |
    Export-Csv .\modbus_inputregs.csv -NoTypeInformation
#>
