# ===============================================
# BlockStore | Jornada 365
# ===============================================
# Site: https://jornada365.cloud
# "Faca parte desta jornada voce tambem!"
# Compatibilidade:
# - Windows 10 Pro
# - Windows 11 Pro
# ===============================================
# Este script bloqueia a instalacao de novos aplicativos 
# na Microsoft Store e habilita atualizacoes automaticas 
# para aplicativos ja instalados. Totalmente compativel
# com Microsoft Intune.
# ===============================================

try {
    # Verifica se o script está sendo executado com permissões de administrador
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        throw "O script deve ser executado com permissões de administrador."
    }

    # Caminho da GPO para bloquear a Microsoft Store (via registro)
    $gpoPath = "HKLM:\Software\Policies\Microsoft\WindowsStore"
    $gpoName = "RemoveWindowsStore"
    $gpoValue = 1

    # Cria o caminho da política se ele não existir
    if (-not (Test-Path $gpoPath)) {
        New-Item -Path $gpoPath -Force
    }

    # Bloqueia a Store via política de grupo
    Set-ItemProperty -Path $gpoPath -Name $gpoName -Value $gpoValue
    Write-Host "Política de bloqueio da Microsoft Store aplicada com sucesso."

    # Habilita atualizações automáticas dos aplicativos da Microsoft Store
    $autoUpdatePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate"
    if (-not (Test-Path $autoUpdatePath)) {
        New-Item -Path $autoUpdatePath -Force
    }
    Set-ItemProperty -Path $autoUpdatePath -Name "AutoDownload" -Value 4  # Habilita atualizações automáticas
    Write-Host "Atualizações automáticas dos aplicativos da Store habilitadas."

    # Regras de Firewall para bloquear o tráfego da Microsoft Store
    Write-Host "Aplicando regras de firewall para bloquear o tráfego da Microsoft Store..."

    # Cria uma regra para bloquear a Store
    netsh advfirewall firewall add rule name="Block Microsoft Store" dir=out action=block remoteip=13.107.4.50,13.107.5.50 enable=yes

    Write-Host "Regras de firewall aplicadas com sucesso."

} catch {
    Write-Host "Erro ao aplicar a política de bloqueio: $_"
    $error | Out-File -FilePath "C:\Logs\MicrosoftStore_Block_Firewall_Error.log" -Append
} finally {
    Write-Host "Processo de bloqueio concluído."
}

# ===============================================
# Fim do Script
# ===============================================
