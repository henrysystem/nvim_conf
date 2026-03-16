# Scripts de Seguridad

Scripts para cargar variables de entorno antes de ejecutar herramientas.

## opencode-secure

Wrapper para OpenCode que carga variables de entorno en este orden:

1. **Global** (`~/.env.global`) - Keys compartidas entre todos los proyectos
2. **Nvim config** (`~/.config/nvim/.env`) - Keys específicas de nvim
3. **Proyecto actual** (`.env`) - Keys específicas del proyecto

### Instalación

#### Windows (PowerShell)

```powershell
# Copiar script a tu PATH
Copy-Item scripts\opencode-secure.ps1 $env:LOCALAPPDATA\bin\opencode-secure.ps1

# Crear alias en tu $PROFILE
Add-Content $PROFILE "`nSet-Alias oc 'C:\Users\bengy\AppData\Local\bin\opencode-secure.ps1'"

# Recargar perfil
. $PROFILE
```

#### Mac/Linux

```bash
# Copiar y dar permisos
cp scripts/opencode-secure.sh ~/.local/bin/opencode-secure
chmod +x ~/.local/bin/opencode-secure

# Crear alias en ~/.bashrc o ~/.zshrc
echo "alias oc='opencode-secure'" >> ~/.bashrc
source ~/.bashrc
```

### Uso

```bash
# En lugar de: opencode
# Usar:
oc

# O directamente:
opencode-secure
```

## Estructura de archivos .env

```
~/.env.global              # Keys globales (GEMINI_API_KEY, etc.)
~/.config/nvim/.env        # Keys para nvim/herramientas
~/proyecto1/.env           # Keys específicas de proyecto1
~/proyecto2/.env           # Keys específicas de proyecto2
```

## Ejemplo

**~/.env.global**:
```bash
GEMINI_API_KEY=AIzaSy...global
OPENAI_API_KEY=sk-proj-...
```

**~/proyecto-a/.env**:
```bash
# Sobrescribe GEMINI_API_KEY solo para este proyecto
GEMINI_API_KEY=AIzaSy...proyecto_a_especial
DATABASE_URL=postgresql://localhost/proyecto_a
```

Cuando ejecutas `oc` desde `proyecto-a`:
- Carga `OPENAI_API_KEY` de global
- Sobrescribe `GEMINI_API_KEY` con el del proyecto
- Agrega `DATABASE_URL` específico del proyecto
