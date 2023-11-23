# Definir la dirección IP de la máquina local y el rango de puertos a escanear
$localIP = "127.0.0.1"
$startPort = 1
$endPort = 1024

# Iterar a través del rango de puertos
for ($port = $startPort; $port -le $endPort; $port++) {
    $connection = New-Object System.Net.Sockets.TcpClient
    $connection.ReceiveTimeout = 1000
    $connection.SendTimeout = 1000

    try {
        $connection.Connect($localIP, $port)
        if ($connection.Connected) {
            Write-Host "Puerto $port está abierto."
            $connection.Close()
        }
    } catch {
        # Ignorar excepciones, que indican que el puerto está cerrado        
    }
}
