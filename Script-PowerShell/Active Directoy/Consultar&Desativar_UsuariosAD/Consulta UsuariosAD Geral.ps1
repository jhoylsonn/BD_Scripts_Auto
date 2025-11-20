# Define o limite de inatividade (6 meses atrás)
$limiteInatividade = (Get-Date).AddMonths(-6)

# Obtém todos os usuários habilitados do AD
$usuarios = Get-ADUser -Filter {Enabled -eq $true -and LastLogonDate -lt $limiteInatividade} -Properties Name, LastLogonDate

# Exibe os usuários inativos
Write-Host "Usuários inativos há mais de 6 meses:`n"
foreach ($usuario in $usuarios) {
    Write-Host "Nome: $($usuario.Name) | Último Login: $($usuario.LastLogonDate)"
}

# Confirmação antes de desativar
$confirmar = Read-Host "`nDeseja desativar esses usuários? (S/N)"
if ($confirmar -eq "S") {
    foreach ($usuario in $usuarios) {
        Disable-ADAccount -Identity $usuario.SamAccountName
        Write-Host "Usuário desativado: $($usuario.Name)"
    }
} else {
    Write-Host "Nenhum usuário foi desativado."
}
