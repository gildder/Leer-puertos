# Definir la dirección IP de la máquina local y el rango de puertos a escanear
$localIP = "127.0.0.1"
$startPort = 1
$endPort = 1024
$openPorts = @()

# Iterar a través del rango de puertos
for ($port = $startPort; $port -le $endPort; $port++) {
    $connection = New-Object System.Net.Sockets.TcpClient
    $connection.ReceiveTimeout = 1000
    $connection.SendTimeout = 1000

    try {
        $connection.Connect($localIP, $port)
        if ($connection.Connected) {
            $openPorts += $port
            $connection.Close()
        }
    } catch {
        # Ignorar excepciones, que indican que el puerto está cerrado
    }
}

# Obtener información de netstat
$netstatOutput = netstat -aon | Select-String -Pattern "\bTCP\b.*\b$localIP\b.*LISTENING"

# Filtrar la salida de netstat para obtener detalles del puerto y el PID
$portInfo = $openPorts | ForEach-Object {
    $currentPort = $_
    $processInfo = $netstatOutput | Where-Object { $_ -match ":$currentPort\s" }
    if ($processInfo) {
        $_PID = ($processInfo -split "\s+")[-1]
        $processName = (Get-Process -Id $_PID -ErrorAction SilentlyContinue).Name
        if ($processName) {
            "$currentPort - $processName (PID: $_PID)"
        } else {
            "$currentPort - PID: $_PID (No se pudo obtener el nombre del proceso)"
        }
    } else {
        "$currentPort - No se encontró el proceso"
    }
}

# Exportar la información a un archivo
$portInfo | Out-File "OpenPortsAndProcesses.txt"

# Mensaje de finalización
Write-Host "Escaneo completado. Puertos abiertos y detalles de los procesos exportados a 'OpenPortsAndProcesses.txt'."
