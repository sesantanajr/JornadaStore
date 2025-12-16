# ===============================================
# EnableStore | Jornada 365
# Reverte bloqueios da Microsoft Store
# ===============================================

$ErrorActionPreference = 'Stop'

try {
    Write-Host "Revertendo políticas e habilitando Microsoft Store..."

    # Caminho principal de políticas da Store
    $storePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    if (-not (Test-Path $storePolicyPath)) {
        New-Item -Path $storePolicyPath -Force | Out-Null
    }

    # 1) RequirePrivateStoreOnly = 0 (não força só Private Store)
    New-ItemProperty -Path $storePolicyPath -Name "RequirePrivateStoreOnly" `
        -PropertyType DWord -Value 0 -Force | Out-Null

    # 2) RemoveWindowsStore - remove se existir
    Remove-ItemProperty -Path $storePolicyPath -Name "RemoveWindowsStore" `
        -ErrorAction SilentlyContinue

    # 3) AutoDownload - remove qualquer policy que altere o comportamento padrão
    Remove-ItemProperty -Path $storePolicyPath -Name "AutoDownload" `
        -ErrorAction SilentlyContinue

    # 4) NoWindowsStore em Explorer - remove se existir
    $explorerPolicyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    if (Test-Path $explorerPolicyPath) {
        Remove-ItemProperty -Path $explorerPolicyPath -Name "NoWindowsStore" `
            -ErrorAction SilentlyContinue
    }

    Write-Host "Microsoft Store habilitada. Reinicie o dispositivo ou rode 'gpupdate /force'."
    exit 0
}
catch {
    Write-Host "Erro ao reverter políticas: $($_.Exception.Message)"
    exit 1
}
