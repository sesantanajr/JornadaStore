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

    # Habilita atualizações automáticas dos aplicativos da Microsoft Store
    $autoUpdatePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate"
    if (-not (Test-Path $autoUpdatePath)) {
        New-Item -Path $autoUpdatePath -Force
    }
    Set-ItemProperty -Path $autoUpdatePath -Name "AutoDownload" -Value 4  # Habilita atualizações automáticas
    Write-Host "Atualizações automáticas dos aplicativos da Store habilitadas."
    # Define the registry path
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"

    # Bloqueia a Store por chave de registro
    $registryName = "RequirePrivateStoreOnly"
    $registryValue = 1

    # Verifica a existência do registro e os cria se não existir
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force
    }

    # Define o valor da chave de registro
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type DWord

    Write-Host "Chave de registro definida com sucesso."
} catch {
    Write-Host "Ocorreu um erro: $_"
}


# ===============================================
# Fim do Script
# ===============================================
