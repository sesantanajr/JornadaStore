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

# Forca a execucao com privilegios de administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script requer privilegios de administrador. Execute novamente com direitos administrativos."
    exit
}

# Bloco try/catch para garantir que erros sejam tratados corretamente
try {
    # ============================
    # HABILITAR INSTALACAO DE APPS
    # ============================

    # Caminho do registro onde a politica para habilitar instalacao sera aplicada
    $registryPathStore = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\WindowsStore"
    
    # Nome da chave de registro que sera criada/modificada
    $registryNameStore = "DisableStoreApps"
    $registryValueStore = 0 # 0 = Habilitar instalacao de apps
    
    # Verifica se o caminho do registro ja existe
    if (-not (Test-Path $registryPathStore)) {
        Write-Host "O caminho do registro da Microsoft Store nao existe. Criando o caminho..."
        # Cria o caminho do registro
        New-Item -Path $registryPathStore -Force | Out-Null
    }

    # Define o valor da chave de registro para habilitar a instalacao de apps pela Microsoft Store
    Set-ItemProperty -Path $registryPathStore -Name $registryNameStore -Value $registryValueStore -Type DWord
    Write-Host "Instalacao de aplicativos habilitada com sucesso na Microsoft Store."
    
    # ================================
    # MANTER ATUALIZACOES AUTOMATICAS
    # ================================

    # Nome da chave de registro para habilitar as atualizacoes automaticas
    $registryNameAutoUpdate = "AutoDownload"
    $registryValueAutoUpdate = 4 # 4 = Baixar e instalar atualizacoes automaticamente
    
    # Define o valor da chave de registro para habilitar as atualizacoes automaticas da Microsoft Store
    Set-ItemProperty -Path $registryPathStore -Name $registryNameAutoUpdate -Value $registryValueAutoUpdate -Type DWord
    Write-Host "Atualizacoes automaticas mantidas com sucesso para a Microsoft Store e aplicativos existentes."

    # ============================
    # FORCAR ATUALIZACAO DE POLITICAS SEM REINICIAR
    # ============================

    # Utiliza gpupdate para forcar a atualizacao de politicas de grupo sem interrupcoes para o usuario
    Write-Host "Forcando a atualizacao das politicas de grupo..."
    gpupdate /target:computer /force | Out-Null
    gpupdate /target:user /force | Out-Null
    Write-Host "As politicas foram aplicadas com sucesso sem reiniciar o sistema."

    # Opcional: Invalida e atualiza as politicas de cache para garantir que qualquer politica armazenada seja renovada
    Write-Host "Renovando politicas de cache do Windows..."
    secedit /refreshpolicy machine_policy /enforce | Out-Null
    secedit /refreshpolicy user_policy /enforce | Out-Null
    Write-Host "Politicas de cache renovadas com sucesso."

} catch {
    # Exibe uma mensagem de erro detalhada caso ocorra algum problema durante a execucao
    Write-Host "Ocorreu um erro ao tentar configurar as politicas: $_"
}

# ===============================================
# Fim do Script
# ===============================================
