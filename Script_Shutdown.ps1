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
