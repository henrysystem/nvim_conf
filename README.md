# Mi Configuración de Neovim

Configuración personalizada de Neovim con soporte multi-host, integración con OpenCode y gestión visual de secrets.

## Características

- ✅ **Multi-host**: Configuración adaptable a diferentes máquinas (Windows/Mac/Linux)
- ✅ **Sistema de favoritos**: Rutas y comandos personalizados por máquina
- ✅ **Integración OpenCode**: Plugin y configuración para usar OpenCode dentro de nvim
- ✅ **LazyVim**: Basado en LazyVim con plugins personalizados
- ✅ **SDD Orchestrator**: Configuración para desarrollo guiado por especificaciones
- ✅ **veil.nvim**: Oculta API keys y secrets visualmente al editar archivos sensibles.

## Instalación Completa

Para una instalación completa y funcional en una nueva máquina, sigue estos pasos:

### 1. Clonar el repositorio de Neovim

Este repositorio contiene tu configuración de Neovim y los scripts de soporte.

```bash
# En Windows (PowerShell)
git clone https://github.com/henrysystem/nvim_conf.git $env:LOCALAPPDATA\\nvim

# En Mac/Linux
git clone https://github.com/henrysystem/nvim_conf.git ~/.config/nvim
```

### 2. Clonar el repositorio Canónico de Skills (para OpenCode)

Este repositorio contiene los skills que OpenCode utiliza. **Es crucial que esté en una ubicación accesible por OpenCode.**

```bash
# En Windows (PowerShell) - Ejemplo de ruta, ajusta según tu preferencia
git clone https://github.com/henrysystem/ai-canonical.git D:\\Recursos\\tools\\cognitive-canonical

# En Mac/Linux - Ejemplo de ruta, ajusta según tu preferencia
git clone https://github.com/henrysystem/ai-canonical.git ~/tools/cognitive-canonical
```

### 3. Instalar veil.nvim (Ocultador de Secrets)

Dado que `Lazy.nvim` ha tenido problemas para cargar `veil.nvim` automáticamente, **lo instalaremos manualmente**.

```bash
# En Windows (PowerShell)
mkdir -p "$env:LOCALAPPDATA\nvim-data\site\pack\plugins\start"
git clone --depth 1 https://github.com/Gentleman-Programming/veil.nvim.git "$env:LOCALAPPDATA\nvim-data\site\pack\plugins\start\veil.nvim"

# En Mac/Linux
mkdir -p ~/.local/share/nvim/site/pack/plugins/start/
git clone --depth 1 https://github.com/Gentleman-Programming/veil.nvim.git ~/.local/share/nvim/site/pack/plugins/start/veil.nvim
```
**Importante:** `veil.nvim` se configura en tu `init.lua` para ocultar automáticamente valores en archivos como `.env*`, `opencode.json`, `*credentials*`, `*secrets*`, etc. Usa `<leader>sv` para alternar la visibilidad y `<leader>sp` para ver temporalmente el secret en la línea actual.


### 4. Configurar tu máquina (Hosts)

Al abrir Neovim por primera vez, te preguntará qué máquina estás usando. Si no, puedes configurarlo manualmente o editar `hosts.json`.

```bash
# Windows
set NVIM_HOST=windows_main

# Mac/Linux
export NVIM_HOST=macbook
```

O editar `hosts.json` para agregar o modificar tu máquina:

```vim
:EditHosts
```

### 5. Configurar secrets (IMPORTANTÍSIMO)

**NUNCA SUBAS TUS KEYS REALES A GITHUB.** Este paso es crucial para la seguridad.

```bash
# Copiar el archivo de ejemplo para tus variables globales
cp .env.example ~/.env.global

# Editar ~/.env.global y agregar tus API keys reales (veil.nvim las ocultará)
nvim ~/.env.global

# Copiar el archivo de ejemplo para las variables específicas de Neovim
cp .env.example ~/.config/nvim/.env

# Editar ~/.config/nvim/.env y agregar tus API keys reales si son específicas de Neovim
nvim ~/.config/nvim/.env

# Para proyectos específicos, crea un .env en la raíz del proyecto
# cp .env.example ./tu_proyecto/.env
# nvim ./tu_proyecto/.env
```
**Asegúrate de que `.env` y `.env.global` estén en tu `.gitignore` local.** El `.gitignore` de este repo ya incluye los patrones comunes.

### 6. Instalar y Configurar OpenCode CLI

1.  **Instalar OpenCode CLI:**
    Sigue las instrucciones en [https://opencode.ai](https://opencode.ai)

2.  **Copiar la configuración de OpenCode:**
    Copia tu `opencode.json` limpio (del repo `nvim_conf`) a la carpeta de configuración de OpenCode.

    ```bash
    # En Windows (PowerShell)
    Copy-Item opencode\opencode.json $env:USERPROFILE\.config\opencode\opencode.json

    # En Mac/Linux
    cp opencode/opencode.json ~/.config/opencode/opencode.json
    ```

3.  **Configurar la API Key de Gemini en OpenCode:**
    Ejecuta el script de PowerShell para inyectar tu `GEMINI_API_KEY` desde `~/.env.global` directamente en el `opencode.json` de OpenCode.

    ```powershell
    # En Windows (PowerShell)
    powershell -ExecutionPolicy Bypass -File scripts/configure-gemini.ps1
    ```
    (Para Mac/Linux, se necesitaría un script bash similar que actualice el `opencode.json` de la misma manera, ya que OpenCode no expande variables de entorno en su `apiKey` directamente).

4.  **Instalar los Skills de OpenCode:**
    Una vez que OpenCode esté instalado y su `opencode.json` configurado, abre OpenCode y ejecuta el comando para instalar los skills:

    ```bash
    opencode
    # Una vez dentro de OpenCode, escribe:
    /ai-bootstrap
    ```

### 7. Instalar tema de terminal (recomendado)

Para que los colores de tu terminal y de Neovim se vean idénticos:

**Nota**: Se recomienda usar la variante **Snazzy Soft** para OpenCode (colores menos saturados en contexto MCP/LSP).

```bash
# Terminal.app (Mac) - Snazzy Soft recomendado
open terminal-themes/snazzy.terminal
# Luego: Abre Preferencias de Terminal -> Perfiles -> Selecciona "Snazzy" y establece como predeterminado.

# Alacritty - Snazzy Soft
cat terminal-themes/snazzy-soft-alacritty.yml >> ~/.config/alacritty/alacritty.yml

# Kitty - Snazzy Soft
cat terminal-themes/snazzy-soft-kitty.conf >> ~/.config/kitty/kitty.conf

# Windows Terminal - Snazzy Soft
# Copiar el contenido de `snazzy-soft-windows-terminal.json` en la sección `"schemes"` de tu `settings.json` de Windows Terminal.
# Luego, en la configuración de tu perfil de terminal, establece: `"colorScheme": "Snazzy Soft"`
```

## Estructura

```
nvim_conf/
├── init.lua                    # Punto de entrada principal
├── hosts.json                  # Configuración de hosts/máquinas
├── .env.example                # Ejemplo de variables de entorno
├── SECURITY.md                 # Guía de manejo de secrets
├── scripts/                    # Scripts de soporte (e.g., configure-gemini.ps1)
├── lua/
│   ├── config/                 # Configuraciones Lua
│   └── plugins/                # Configuraciones de plugins
├── opencode/                   # Configuración de OpenCode para el repo
│   ├── opencode.json          # Config de OpenCode (sin API keys reales)
│   └── README.md              # Instrucciones de OpenCode
├── terminal-themes/           # Temas de terminal (Snazzy y Snazzy Soft)
│   └── ...                    # Archivos de tema para varias terminales
└── skills/                    # Skills específicos para nvim (si se agregan localmente)
```

## Configuración de Hosts

El archivo `hosts.json` define rutas y comandos para cada máquina.

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
    },
    "macbook": {
      "name": "MacBook Pro",
      "paths": {
        "dynasif": "/Users/bengy/Proyectos/dynasif",
        ...
      },
      "favorites": { ... },
      "commands": [ ... ]
    }
  }
}
```

### Agregar tu máquina

1.  Editar `hosts.json` con tus rutas y comandos específicos.
2.  Al abrir Neovim, selecciona tu máquina o usa la variable de entorno `NVIM_HOST`.

## Comandos útiles

| Comando | Descripción |
|---------|-------------|
| `:SelectHost` | Cambiar de máquina |
| `:ShowHost` | Ver máquina actual |
| `:EditHosts` | Editar `hosts.json` |
| `:ReloadHosts` | Recargar configuración de hosts |
| `:Asistente` | Menú de comandos personalizados |
| `<leader>sv` | Alternar visibilidad de secrets en archivos sensibles |
| `<leader>sp` | Ver temporalmente el secret en la línea actual |

## Plugins principales

- **LazyVim**: Configuración base del gestor de plugins.
- **veil.nvim**: Oculta visualmente secrets en archivos de configuración.
- **OpenCode**: Integración con OpenCode AI.
- **Oil**: Navegador de archivos avanzado.
- **Blink**: Autocompletado inteligente.
- **Avante/Claude-Code**: Integración con Claude.
- **Copilot**: GitHub Copilot.

## Dependencias

- Neovim >= 0.9.0
- Node.js >= 18
- Git
- OpenCode CLI (opcional, pero necesario para la integración completa)
- Engram para memoria persistente (opcional, pero recomendado)

## Personalización

### Modificar favoritos/comandos

Editar `hosts.json` y agregar/modificar entradas en la sección `favorites` y `commands` de tu host.

### Agregar plugins

Crear un nuevo archivo `.lua` en `lua/plugins/` con la definición del plugin, por ejemplo:

```lua
-- lua/plugins/mi-plugin.lua
return {
  "autor/nombre-del-plugin",
  opts = {
    -- Opciones de configuración
  },
  -- otras propiedades de Lazy.nvim
}
```

## Troubleshooting

### No aparecen mis favoritos

1.  Verificar que la variable de entorno `NVIM_HOST` esté configurada o ejecutar `:SelectHost` en Neovim y elegir tu máquina.
2.  Revisar que `hosts.json` tenga tu máquina correctamente configurada.

### OpenCode no funciona

1.  Asegurarte de que OpenCode CLI esté instalado ([https://opencode.ai](https://opencode.ai)).
2.  Confirmar que `opencode/opencode.json` fue copiado a la ubicación correcta (`~/.config/opencode/opencode.json` en Mac/Linux o `%USERPROFILE%\.config\opencode\opencode.json` en Windows).
3.  Ejecutar el script `configure-gemini.ps1` (en Windows) para inyectar tu API key en `opencode.json`.
4.  Instalar los skills ejecutando `/ai-bootstrap` dentro de OpenCode.

### Los secrets no se ocultan en Neovim

1.  Asegurarse de que `veil.nvim` fue instalado manualmente en la ruta correcta (Paso 3 de "Instalación Completa").
2.  Verificar que `conceallevel` esté en `2` (`:echo &conceallevel` en Neovim).
3.  Confirmar que el tipo de archivo (`.env.global`, `opencode.json`, etc.) coincide con los patrones en `init.lua`.
    *   Puedes depurar abriendo el archivo y ejecutando `:set filetype?` y `:echo &filetype` para ver cómo Neovim lo identifica.

## Licencia

MIT

## Autor

Henry System

