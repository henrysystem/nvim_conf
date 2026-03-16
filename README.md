# Mi Configuración de Neovim

Configuración personalizada de Neovim con soporte multi-host y integración con OpenCode.

## Características

- ✅ **Multi-host**: Configuración adaptable a diferentes máquinas (Windows/Mac/Linux)
- ✅ **Sistema de favoritos**: Rutas y comandos personalizados por máquina
- ✅ **Integración OpenCode**: Plugin y configuración para usar OpenCode dentro de nvim
- ✅ **LazyVim**: Basado en LazyVim con plugins personalizados
- ✅ **SDD Orchestrator**: Configuración para desarrollo guiado por especificaciones
- ✅ **Veil.nvim**: Oculta API keys y secrets automáticamente al editar

## Instalación

### 1. Clonar el repositorio

```bash
# En Windows (PowerShell)
git clone https://github.com/henrysystem/nvim_conf.git $env:LOCALAPPDATA\nvim

# En Mac/Linux
git clone https://github.com/henrysystem/nvim_conf.git ~/.config/nvim
```

### 2. Configurar tu máquina

Al abrir nvim por primera vez, te preguntará qué máquina usas. También podés configurarlo manualmente:

```bash
# Windows
set NVIM_HOST=windows_main

# Mac/Linux
export NVIM_HOST=macbook
```

O editar `hosts.json` para agregar tu máquina:

```vim
:EditHosts
```

### 3. Instalar tema de terminal (recomendado)

Para que los colores se vean idénticos:

**Nota**: Se recomienda usar la variante **Snazzy Soft** para OpenCode (colores menos saturados en contexto MCP/LSP).

```bash
# Terminal.app (Mac) - Snazzy Soft recomendado
open terminal-themes/snazzy.terminal
# Luego: Terminal → Preferences → Profiles → Set as Default

# Alacritty - Snazzy Soft
cat terminal-themes/snazzy-soft-alacritty.yml >> ~/.config/alacritty/alacritty.yml

# Windows Terminal - Snazzy Soft
# Copiar contenido de snazzy-soft-windows-terminal.json a settings.json
# Luego en tu perfil: "colorScheme": "Snazzy Soft"
```

### 4. Configurar secrets (IMPORTANTE)

```bash
# Copiar ejemplo de variables de entorno
cp .env.example .env

# Editar .env y agregar tus API keys reales
nvim .env  # veil.nvim ocultará los valores automáticamente

# NUNCA subir .env a git (ya está en .gitignore)
```

### 5. Instalar OpenCode config (opcional)

```bash
# Windows
Copy-Item opencode\opencode.json $env:USERPROFILE\.config\opencode\opencode.json

# Mac/Linux
cp opencode/opencode.json ~/.config/opencode/opencode.json

# Editar y poner tu API key (será ocultada por veil.nvim)
nvim ~/.config/opencode/opencode.json
```

## Estructura

```
nvim_conf/
├── init.lua                    # Punto de entrada principal
├── hosts.json                  # Configuración de hosts/máquinas
├── lua/
│   ├── config/
│   │   ├── hosts.lua          # Sistema de hosts
│   │   ├── paths.lua          # Helper de rutas
│   │   ├── assistant.lua      # Comandos Do personalizados
│   │   ├── keymaps.lua        # Atajos de teclado
│   │   └── ...
│   └── plugins/               # Configuración de plugins
├── opencode/
│   ├── opencode.json          # Config de OpenCode
│   └── README.md              # Instrucciones de OpenCode
├── terminal-themes/           # Temas de terminal (Snazzy)
│   ├── snazzy.terminal        # Para Terminal.app (Mac)
│   ├── snazzy-alacritty.yml   # Para Alacritty
│   ├── snazzy-kitty.conf      # Para Kitty
│   └── snazzy-windows-terminal.json  # Para Windows Terminal
└── skills/                    # Skills para nvim
```

## Configuración de Hosts

El archivo `hosts.json` define rutas y comandos para cada máquina:

```json
{
  "hosts": {
    "windows_main": {
      "name": "Windows Principal",
      "paths": {
        "dynasif": "D:/Pintulac/01_PRODUCCION/dynasif",
        "trading": "D:/Proyectos/Activos/trading/TradingManager"
      },
      "favorites": { ... },
      "commands": [ ... ]
    }
  }
}
```

### Agregar tu máquina

1. Editar `hosts.json`
2. Agregar entrada con tus rutas
3. Ejecutar `:SelectHost` en nvim

## Comandos útiles

| Comando | Descripción |
|---------|-------------|
| `:SelectHost` | Cambiar de máquina |
| `:ShowHost` | Ver máquina actual |
| `:EditHosts` | Editar hosts.json |
| `:ReloadHosts` | Recargar configuración |
| `:Asistente` | Menú de comandos personalizados |

## Sistema "Do"

Comandos personalizados según tu máquina:

- `Do abrir dynasif` - Abre proyecto dynasif
- `Do abrir trading` - Abre proyecto trading
- `Do ejecutar trading gui` - Ejecuta el GUI de trading
- Y más comandos configurables en `hosts.json`

## Plugins principales

- **LazyVim**: Configuración base
- **OpenCode**: Integración con OpenCode AI
- **Oil**: Navegador de archivos
- **Blink**: Autocompletado
- **Avante/Claude-Code**: Integración con Claude
- **Copilot**: GitHub Copilot

## Dependencias

- Neovim >= 0.9.0
- Node.js >= 18
- Git
- (Opcional) OpenCode CLI
- (Opcional) Engram para memoria persistente

## Personalización

### Modificar favoritos/comandos

Editar `hosts.json` y agregar/modificar en la sección de tu host:

```json
"commands": [
  { 
    "text": "mi comando", 
    "cmd": "cd /mi/ruta + Oil", 
    "category": "abrir" 
  }
]
```

### Agregar plugins

Crear archivo en `lua/plugins/`:

```lua
return {
  "autor/plugin-nombre",
  opts = { ... }
}
```

## Troubleshooting

### No aparecen mis favoritos

1. Verificar que `NVIM_HOST` esté configurado o ejecutar `:SelectHost`
2. Revisar que `hosts.json` tenga tu máquina configurada

### OpenCode no funciona

1. Instalar OpenCode CLI: https://opencode.ai
2. Copiar `opencode/opencode.json` a `~/.config/opencode/`
3. Instalar skills con `/ai-bootstrap` en OpenCode

## Licencia

MIT

## Autor

Henry System
