# Configuración de OpenCode

Esta carpeta contiene la configuración de OpenCode para trabajar con el SDD Orchestrator.

## Instalación

### En Windows:

```powershell
# Copiar la configuración
Copy-Item opencode.json $env:USERPROFILE\.config\opencode\opencode.json
```

### En Mac/Linux:

```bash
# Copiar la configuración
cp opencode/opencode.json ~/.config/opencode/opencode.json
```

## Qué incluye

- **opencode.json**: Configuración de agentes y comandos SDD
  - `sdd-orchestrator`: Agente principal para Spec-Driven Development
  - Comandos: `/sdd-init`, `/sdd-explore`, `/sdd-propose`, `/sdd-design`, `/sdd-apply`, `/sdd-verify`, `/sdd-archive`
  - Integración con MCP Engram para persistencia

## Skills SDD

Los skills SDD se instalan desde el repositorio canónico usando:

```bash
# Dentro de OpenCode
/ai-bootstrap
```

O manualmente desde: https://github.com/henrysystem/ai-canonical

## Dependencias

- **OpenCode**: Instalar desde https://opencode.ai
- **Engram MCP**: Para persistencia de memoria (opcional pero recomendado)
- **ai-canonical**: Repositorio con skills y profiles
