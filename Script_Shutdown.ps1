

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




3- Script PowerShell: desligamento remoto com verificação de Ping e WinRM

# Definindo credenciais fixas
$usuario = "admin"  # Nome do usuário local comum a todas as máquinas
$senha = ConvertTo-SecureString "susti@2023" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($usuario, $senha)

# Lista de computadores
$computadores = @(
  "desk1",
  "desk2",
  "desk3",
  "DESKTOP-XYZ789"
  # adicione os outros nomes aqui
)

# Loop para executar remotamente
foreach ($pc in $computadores) {
  Write-Host "`nVerificando conectividade IPv4 com $pc..." -ForegroundColor Yellow

  # Testa se a máquina está online via ping.exe forçando IPv4
  $ping = ((& ping.exe -n 1 -4 $pc) -match "TTL=")

  if ($ping) {
    Write-Host "Máquina $pc está online via IPv4. Verificando WinRM..." -ForegroundColor Cyan

    # Aguarda WinRM ficar disponível (até 10 tentativas de 15 segundos)
    $tentativas = 10
    $intervalo = 15
    $winrmPronto = $false

    for ($i = 1; $i -le $tentativas; $i++) {
      if (Test-WSMan -ComputerName $pc -ErrorAction SilentlyContinue) {
        Write-Host "WinRM disponível em $pc." -ForegroundColor Green
        $winrmPronto = $true
        break
      } else {
        Write-Host "Aguardando WinRM em $pc... (tentativa $i)" -ForegroundColor DarkYellow
        Start-Sleep -Seconds $intervalo
      }
    }

    # Executa comando se WinRM estiver pronto
    if ($winrmPronto) {
      try {
        Invoke-Command -ComputerName $pc `
          -ScriptBlock { shutdown -s -f -t 0 } `
          -Credential $cred `
          -Authentication Basic

        Write-Host "Comando de desligamento enviado para $pc." -ForegroundColor Green
      } catch {
        Write-Host "Erro ao executar comando em ${pc}: $_" -ForegroundColor Red
      }
    } else {
      Write-Host "WinRM não respondeu em $pc após $tentativas tentativas. Pulando..." -ForegroundColor Magenta
    }

  } else {
    Write-Host "Máquina $pc está offline via IPv4. Pulando..." -ForegroundColor DarkGray
  }
}


















