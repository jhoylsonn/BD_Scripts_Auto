# Importa o módulo do Active Directory
Import-Module ActiveDirectory

# Define a OU de busca
$ouDN = "OU=HPS-Platao,OU=UnidadesSaude,DC=saude,DC=am,DC=gov,DC=br"

do {
    # Pergunta o nome do usuário
    $nomeUsuario = Read-Host "Digite o nome (ou parte do nome) do usuário que deseja verificar (ou 'sair' para encerrar)"

    if ($nomeUsuario -eq "sair") {
        break
    }

    # Busca o usuário na OU
    $usuarios = Get-ADUser -Filter "Name -like '*$nomeUsuario*'" -SearchBase $ouDN -Properties Name, SamAccountName, Enabled, LastLogonDate

    if ($usuarios.Count -eq 0) {
        Write-Host "⚠️ Nenhum usuário encontrado com o nome informado."
    } else {
        foreach ($usuario in $usuarios) {
            $ultimoLogin = $usuario.LastLogonDate

            if ($ultimoLogin) {
                $mesUltimoLogin = $ultimoLogin.ToString("MM/yyyy")
                $diasInativo = (New-TimeSpan -Start $ultimoLogin -End (Get-Date)).Days
            } else {
                $mesUltimoLogin = "Sem registro"
                $diasInativo = "Sem registro"
            }

            Write-Host "`nUsuário encontrado: $($usuario.Name)"

            # Corrigido: imprime status com if/else
            if ($usuario.Enabled -eq $true) {
                Write-Host "Status: Ativo"
            } else {
                Write-Host "Status: Desativado"
            }

            Write-Host "Último login: $ultimoLogin"
            Write-Host "Último mês de login: $mesUltimoLogin"
            Write-Host "Dias de inatividade: $diasInativo"

            # Pergunta se deseja desativar
            $resposta = Read-Host "Deseja desativar este usuário? (S/N)"
            if ($resposta -eq "S") {
                Disable-ADAccount -Identity $usuario.SamAccountName
                Write-Host "✅ Usuário desativado: $($usuario.Name)"
            } else {
                Write-Host "⏭️ Usuário mantido ativo: $($usuario.Name)"
            }
        }
    }

} while ($true)

Write-Host "`n🔚 Script encerrado."
