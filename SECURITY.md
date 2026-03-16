# Manejo de Secrets y Credenciales

Este repo incluye **veil.nvim** para ocultar valores sensibles visualmente cuando editas archivos de configuración.

## ⚠️ Importante

**veil.nvim NO encripta ni almacena secrets**. Solo los oculta visualmente en pantalla para streaming/screen sharing.

## Estrategia de Seguridad

### 1. Variables de Entorno (Recomendado)

```bash
# ~/.bashrc o ~/.zshrc (Mac/Linux)
export GEMINI_API_KEY="tu_api_key_aqui"
export OPENAI_API_KEY="tu_otra_key"
export DB_PASSWORD="tu_password"

# Windows PowerShell Profile
$env:GEMINI_API_KEY = "tu_api_key_aqui"
```

### 2. Archivo .env (NO subir a git)

```bash
# .env (en .gitignore)
GEMINI_API_KEY=AIzaSy...
OPENAI_API_KEY=sk-proj-...
DATABASE_URL=postgresql://user:pass@host/db
```

**Asegurar que `.env` esté en `.gitignore`:**

```gitignore
.env
.env.*
!.env.example
*.secret
credentials.json
secrets.yaml
```

### 3. Usar veil.nvim

Cuando edites archivos con secrets:

```vim
" Toggle ocultación
<leader>sv

" Ver valor temporalmente (en la línea actual)
<leader>sp
```

## Archivos Protegidos por Veil

- `.env`, `.env.*`
- `opencode.json` (tu config de OpenCode)
- `credentials.json`
- `secrets.yaml`
- `.npmrc`, `.pypirc`

## OpenCode con Variables de Entorno

En lugar de poner la API key directamente en `opencode.json`, usa variables de entorno:

### Opción A: Referencia directa (si OpenCode lo soporta)

```json
{
  "provider": {
    "google": {
      "options": {
        "apiKey": "${GEMINI_API_KEY}"
      }
    }
  }
}
```

### Opción B: Script wrapper

Crear un script que lee del environment:

```bash
#!/bin/bash
# ~/.local/bin/opencode-secure

export GEMINI_API_KEY=$(cat ~/.secrets/gemini_key)
opencode "$@"
```

## Crear archivo .env.example

Para el repo, incluir un `.env.example` sin valores reales:

```bash
# .env.example
GEMINI_API_KEY=tu_api_key_aqui
OPENAI_API_KEY=sk-proj-xxx
DATABASE_URL=postgresql://user:password@localhost/db
EMAIL_USER=tu_email@ejemplo.com
EMAIL_PASSWORD=tu_password
```

## Comandos Útiles

```bash
# Verificar qué NO está en git
git status --ignored

# Ver qué archivos están en .gitignore
cat .gitignore

# Eliminar archivo ya trackeado de git (sin borrarlo localmente)
git rm --cached archivo_secreto.json
git commit -m "Remove secret file from tracking"
```

## Flujo Recomendado

1. **Desarrollo local**: Usar `.env` con valores reales (NO subirlo)
2. **En el repo**: Subir `.env.example` con placeholders
3. **Otras máquinas**: Copiar `.env.example` a `.env` y completar valores
4. **Streaming/Sharing**: veil.nvim oculta automáticamente los valores

## Herramientas Adicionales (Opcional)

| Herramienta | Para qué |
|-------------|----------|
| **pass** | Password manager CLI con GPG |
| **1Password CLI** | Integración con 1Password |
| **AWS Secrets Manager** | Para producción/equipos |
| **git-crypt** | Encriptar archivos específicos en git |

## Verificar Seguridad

```bash
# Ver si hay secrets en el historial de git
git log -p | grep -i "api_key\|password\|secret"

# Escanear con gitleaks (si lo tienes instalado)
gitleaks detect --source .
```
