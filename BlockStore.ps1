# ===============================================
# BlockStore | Jornada 365
# Bloqueia a Microsoft Store (UI/catalogo)
# Mantém atualizações automáticas dos apps já instalados
# Compatível com Windows 10/11 (Pro/Enterprise/Education)
# ===============================================

$ErrorActionPreference = 'Stop'

try {
    Write-Host "Aplicando políticas para Microsoft Store..."

    # 1) Políticas da Store
    $storePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    if (-not (Test-Path $storePolicyPath)) {
        New-Item -Path $storePolicyPath -Force | Out-Null
    }

    # Bloqueia o catálogo público da Store e força apenas loja privada
    # (RequirePrivateStoreOnly = 1)
    New-ItemProperty -Path $storePolicyPath -Name "RequirePrivateStoreOnly" `
        -PropertyType DWord -Value 1 -Force | Out-Null

    # Tenta desabilitar o app da Store completamente onde suportado
    # (RemoveWindowsStore = 1)
    New-ItemProperty -Path $storePolicyPath -Name "RemoveWindowsStore" `
        -PropertyType DWord -Value 1 -Force | Out-Null

    # 2) Política extra usada por versões mais antigas / algumas builds
    # NoWindowsStore = 1 (equivalente ao GPO "Turn off the Store application")
    $explorerPolicyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    if (-not (Test-Path $explorerPolicyPath)) {
        New-Item -Path $explorerPolicyPath -Force | Out-Null
    }

    New-ItemProperty -Path $explorerPolicyPath -Name "NoWindowsStore" `
        -PropertyType DWord -Value 1 -Force | Out-Null

    # 3) Mantém ATUALIZAÇÕES automáticas dos apps
    # A Store, por padrão, atualiza apps automaticamente.
    # Políticas que usam 'AutoDownload' servem para DESLIGAR o auto-update. :contentReference[oaicite:1]{index=1}
    # Então aqui apenas removemos qualquer AutoDownload que possa ter sido configurado.
    if (Get-ItemProperty -Path $storePolicyPath -Name "AutoDownload" -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $storePolicyPath -Name "AutoDownload" -ErrorAction SilentlyContinue
        Write-Host "Removida política que alterava AutoDownload (apps voltam a atualizar automaticamente)."
    }

    Write-Host "Políticas aplicadas com sucesso. Reinicie o dispositivo ou rode 'gpupdate /force' para efetivar."
}
catch {
    Write-Host "Ocorreu um erro ao aplicar as políticas: $_"
    exit 1
}

exit 0
