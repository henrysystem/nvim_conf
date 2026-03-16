#!/bin/bash
# Script para cargar variables de entorno antes de OpenCode
# Carga: Global primero, luego local (local override global)

load_env() {
	local file=$1
	if [ -f "$file" ]; then
		echo "Loading env from: $file"
		export $(grep -v '^#' "$file" | xargs)
	fi
}

# 1. Cargar global primero
load_env "$HOME/.env.global"

# 2. Cargar de nvim config (override si existe)
load_env "$HOME/.config/nvim/.env"

# 3. Cargar del proyecto actual si existe (override)
load_env ".env"

# Ejecutar OpenCode con las variables cargadas
opencode "$@"
