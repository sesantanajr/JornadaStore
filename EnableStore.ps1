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

# Função para registrar log
function Write-Log {
    param($message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $message"
    Write-Output $logMessage
    Add-Content -Path "$env:ProgramData\MicrosoftStoreBlockLog.txt" -Value $logMessage
}

try {
    # Bloquear a Microsoft Store
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    if (!(Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }
    Set-ItemProperty -Path $registryPath -Name "RemoveWindowsStore" -Value 1 -Type DWord -Force
    Write-Log "Microsoft Store bloqueada através da chave de registro."

    # Desabilitar a instalação de aplicativos
    Set-ItemProperty -Path $registryPath -Name "DisableStoreApps" -Value 1 -Type DWord -Force
    Write-Log "Instalação de aplicativos desabilitada."

    # Desabilitar atualizações automáticas de aplicativos
    Set-ItemProperty -Path $registryPath -Name "AutoDownload" -Value 2 -Type DWord -Force
    Write-Log "Atualizações automáticas de aplicativos desabilitadas."

    # Forçar atualização das políticas de grupo
    gpupdate /force
    Write-Log "Políticas de grupo atualizadas."

    Write-Log "Processo de bloqueio da Microsoft Store concluído com sucesso."
    exit 0
} catch {
    Write-Log "Erro ao bloquear a Microsoft Store: $_"
    exit 1
}

# ===============================================
# Fim do Script
# ===============================================
