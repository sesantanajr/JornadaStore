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
    # Define the registry path
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"

    # Define the name and value for the registry key
    $registryName = "RequirePrivateStoreOnly"
    $registryValue = 0

    # Check if the registry path exists, create it if it doesn't
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force
    }

    # Set the registry key value
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type DWord

    Write-Host "Registry key set successfully."
} catch {
    Write-Host "An error occurred: $_"
}

# ===============================================
# Fim do Script
# ===============================================
