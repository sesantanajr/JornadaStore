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

# Script para desbloquear a Microsoft Store (compatível com Intune)

# Função para registrar log
function Write-Log {
    param($message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $message"
    Write-Output $logMessage
    Add-Content -Path "$env:ProgramData\MicrosoftStoreUnblockLog.txt" -Value $logMessage
}

try {
    # Remover políticas que bloqueiam a Microsoft Store
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    Remove-ItemProperty -Path $registryPath -Name "RemoveWindowsStore" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $registryPath -Name "DisableStoreApps" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $registryPath -Name "AutoDownload" -ErrorAction SilentlyContinue
    Write-Log "Políticas de bloqueio da Microsoft Store removidas."

    # Habilitar o serviço da Microsoft Store
    Set-Service -Name "InstallService" -StartupType Automatic
    Start-Service -Name "InstallService"
    Write-Log "Serviço da Microsoft Store habilitado e iniciado."

    # Reinstalar a Microsoft Store
    Get-AppXPackage *WindowsStore* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction SilentlyContinue}
    Write-Log "Tentativa de reinstalação da Microsoft Store concluída."

    # Resetar a Microsoft Store
    Start-Process "wsreset.exe" -NoNewWindow -Wait
    Write-Log "Reset do cache da Microsoft Store concluído."

    # Forçar atualização das políticas de grupo
    gpupdate /force
    Write-Log "Atualização das políticas de grupo concluída."

    Write-Log "Processo de desbloqueio da Microsoft Store concluído com sucesso."
    exit 0
} catch {
    Write-Log "Erro ao desbloquear a Microsoft Store: $_"
    exit 1
}

# ===============================================
# Fim do Script
# ===============================================
