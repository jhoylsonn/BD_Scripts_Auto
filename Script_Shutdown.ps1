

Requisitos para funcionar sem erro
Todos os computadores devem:

.Ter o mesmo usuário e senha 
.Ter o WinRM habilitado (Enable-PSRemoting -Force)
.Permitir autenticação básica e tráfego não criptografado:




1-No Host (sua máquina que envia os comandos)
Execute os seguintes comandos no PowerShell como administrador:

#Liberar e configurar Os serviços Winrm
winrm quickconfig 

# Permitir tráfego não criptografado
Set-Item WSMan:\localhost\Client\AllowUnencrypted -Value $true




2-No Cliente (máquina que recebe os comandos)
Na máquina remota, também no PowerShell como administrador, execute:


# Habilitar PowerShell Remoting
Enable-PSRemoting -Force

# Permitir autenticação básica
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true

# Permitir tráfego não criptografado
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true

# Liberar Area de Trabalho Remota
Enable-NetFirewallRule -DisplayGroup "Área de Trabalho Remota" 

# Liberar porta 5985 no firewall (WinRM HTTP)
New-NetFirewallRule -Name "WinRM-HTTP" -DisplayName "WinRM over HTTP" `
  -Protocol TCP -LocalPort 5985 -Action Allow

# Liberar Ping (ICMPv4) em todos os perfis de rede
New-NetFirewallRule -Name "Allow-Ping" -DisplayName "Allow ICMPv4-In" `
  -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow -Profile Any

# Instalar Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = `
  [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString(`
  'https://community.chocolatey.org/install.ps1'))

# Instalar Remote Desktop Manager Agent (sem confirmação)
choco install rdmagent -y

# Iniciar o agente após instalação
 Start-Process "C:\Program Files (x86)\Devolutions\Remote Desktop Manager Agent\RDMAgent.exe" -Verb RunAs

















