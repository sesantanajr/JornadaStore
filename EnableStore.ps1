# ===============================================
# EnableStore | Jornada 365
# ===============================================
# Site: https://jornada365.cloud
# "Faca parte desta jornada voce tambem!"
# Compatibilidade:
# - Windows 10 (20H2 e posterior)
# - Windows 11 (todas as versoes)
# ===============================================
# Este script habilita a instalacao de novos aplicativos 
# na Microsoft Store e tambem mantem habilitadas as 
# atualizacoes automaticas para aplicativos ja instalados. 
# Totalmente compativel com Microsoft Intune.
# ===============================================

try {
    # Verifica se o script está sendo executado com permissões de administrador
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        throw "O script deve ser executado com permissões de administrador."
    }

    # Remover a política de grupo que bloqueia a Microsoft Store
    $gpoPath = "HKLM:\Software\Policies\Microsoft\WindowsStore"
    $gpoName = "RemoveWindowsStore"

    # Verifica se a política existe antes de remover
    if (Test-Path $gpoPath) {
        $currentPolicy = Get-ItemProperty -Path $gpoPath -Name $gpoName -ErrorAction SilentlyContinue
        if ($currentPolicy) {
            Remove-ItemProperty -Path $gpoPath -Name $gpoName -ErrorAction Stop
            Write-Host "Política de bloqueio da Microsoft Store removida com sucesso."
        } else {
            Write-Host "Política de bloqueio da Microsoft Store já não existe."
        }
    } else {
        Write-Host "Política de bloqueio da Microsoft Store não foi encontrada."
    }

    # Remover qualquer outra política de restrição da Store via registro
    $additionalPoliciesPath = "HKLM:\Software\Microsoft\PolicyManager\default\ApplicationManagement"
    $additionalPolicyName = "RequirePrivateStoreOnly"

    if (Test-Path $additionalPoliciesPath) {
        $additionalPolicy = Get-ItemProperty -Path $additionalPoliciesPath -Name $additionalPolicyName -ErrorAction SilentlyContinue
        if ($additionalPolicy) {
            Remove-ItemProperty -Path $additionalPoliciesPath -Name $additionalPolicyName -ErrorAction Stop
            Write-Host "Configuração de restrição da Private Store removida."
        }
    }

    # Remover as regras de firewall que bloqueiam a Store
    Write-Host "Removendo regras de firewall que bloqueiam o tráfego da Microsoft Store..."
    $firewallRule = netsh advfirewall firewall show rule name="Block Microsoft Store"

    # Verifica se a regra de firewall existe e a remove
    if ($firewallRule -match "Block Microsoft Store") {
        netsh advfirewall firewall delete rule name="Block Microsoft Store"
        Write-Host "Regras de firewall removidas com sucesso."
    } else {
        Write-Host "Nenhuma regra de firewall encontrada para a Microsoft Store."
    }

} catch {
    Write-Host "Erro ao remover as configurações: $_"
    $error | Out-File -FilePath "C:\Logs\MicrosoftStore_Unblock_Error.log" -Append
} finally {
    Write-Host "Processo de desbloqueio concluído."
}

# ===============================================
# Fim do Script
# ===============================================
