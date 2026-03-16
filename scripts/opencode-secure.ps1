# Script para cargar variables de entorno antes de OpenCode (Windows)
# Carga: Global primero, luego local (local override global)

function Load-EnvFile {
    param($path)
    if (Test-Path $path) {
        Write-Host "Loading env from: $path" -ForegroundColor Green
        Get-Content $path | ForEach-Object {
            if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                [System.Environment]::SetEnvironmentVariable($key, $value, "Process")
            }
        }
    }
}

# 1. Cargar global primero
Load-EnvFile "$env:USERPROFILE\.env.global"

# 2. Cargar local (override si existe)
Load-EnvFile "$env:LOCALAPPDATA\nvim\.env"

# 3. Cargar del proyecto actual si existe
if (Test-Path ".env") {
    Load-EnvFile ".env"
}

# Ejecutar OpenCode con las variables cargadas
opencode @args
