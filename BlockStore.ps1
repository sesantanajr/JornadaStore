# ===============================================
# BlockStore | Jornada 365
# ===============================================
# Site: https://jornada365.cloud
# "Faca parte desta jornada voce tambem!"
# Compatibilidade:
# - Windows 10 (20H2 e posterior)
# - Windows 11 (todas as versoes)
# ===============================================
# Este script bloqueia a instalacao de novos aplicativos 
# na Microsoft Store e habilita atualizacoes automaticas 
# para aplicativos ja instalados. Totalmente compativel
# com Microsoft Intune.
# ===============================================

# Forca a execucao com privilegios de administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script requer privilegios de administrador. Execute novamente com direitos administrativos."
    exit
}

# Bloco try/catch para garantir que erros sejam tratados corretamente
try {
    # ============================
    # BLOQUEAR INSTALACAO DE APPS
    # ============================

    # Caminho do registro onde a politica para bloquear instalacao sera aplicada
    $registryPathStore = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    
    # Nome da chave de registro que sera criada/modificada
    $registryNameStore = "DisableStoreApps"
    $registryValueStore = 1 # 1 = Bloquear instalacao de apps
    
    # Verifica se o caminho do registro ja existe
    if (-not (Test-Path $registryPathStore)) {
        Write-Host "O caminho do registro da Microsoft Store nao existe. Criando o caminho..."
        # Cria o caminho do registro
        New-Item -Path $registryPathStore -Force | Out-Null
    }

    # Define o valor da chave de registro para bloquear a instalacao de apps pela Microsoft Store
    Set-ItemProperty -Path $registryPathStore -Name $registryNameStore -Value $registryValueStore -Type DWord
    Write-Host "Instalacao de aplicativos bloqueada com sucesso na Microsoft Store."
    
    # ================================
    # HABILITAR ATUALIZACOES AUTOMATICAS
    # ================================

    # Nome da chave de registro para habilitar as atualizacoes automaticas
    $registryNameAutoUpdate = "AutoDownload"
    $registryValueAutoUpdate = 4 # 4 = Baixar e instalar atualizacoes automaticamente
    
    # Define o valor da chave de registro para habilitar as atualizacoes automaticas da Microsoft Store
    Set-ItemProperty -Path $registryPathStore -Name $registryNameAutoUpdate -Value $registryValueAutoUpdate -Type DWord
    Write-Host "Atualizacoes automaticas habilitadas com sucesso para a Microsoft Store e aplicativos existentes."

    # ============================
    # FORCAR ATUALIZACAO DE POLITICAS SEM REINICIAR
    # ============================

    # Utiliza Invoke-Expression para garantir que o gpupdate seja executado sem falhas no Intune
    Write-Host "Forcando a atualizacao das politicas de grupo..."
    Invoke-Expression -Command 'gpupdate /target:computer /force'
    Invoke-Expression -Command 'gpupdate /target:user /force'
    Write-Host "As politicas foram aplicadas com sucesso sem reiniciar o sistema."

    # ============================
    # RENOVACAO DE POLITICAS NO INTUNE
    # ============================

    # Utiliza secedit para forcar a renovacao de politicas de cache
    Write-Host "Renovando politicas de cache do Windows..."
    Invoke-Expression -Command 'secedit /refreshpolicy machine_policy /enforce'
    Invoke-Expression -Command 'secedit /refreshpolicy user_policy /enforce'
    Write-Host "Politicas de cache renovadas com sucesso."

} catch {
    # Exibe uma mensagem de erro detalhada caso ocorra algum problema durante a execucao
    Write-Host "Ocorreu um erro ao tentar configurar as politicas: $_"
}

# ===============================================
# Fim do Script
# ===============================================
