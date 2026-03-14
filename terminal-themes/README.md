# Snazzy Color Scheme

Tema de terminal usado en la configuración principal.

## Variantes

- **Snazzy**: Colores originales brillantes
- **Snazzy Soft**: Colores suavizados (recomendado para OpenCode) - cyan y magenta menos saturados

## Colores

| Color | Hex | Uso |
|-------|-----|-----|
| Background | `#282A36` | Fondo |
| Foreground | `#EFF0EB` | Texto normal |
| Yellow | `#F3F99D` | Amarillo (notas, warnings) |
| Bright Yellow | `#F3F99D` | Amarillo brillante |
| Green | `#5AF78E` | Verde (success) |
| Blue | `#57C7FF` | Azul (info) |
| Red | `#FF5C57` | Rojo (errors) |
| Purple | `#FF6AC1` | Púrpura |
| Cyan | `#9AEDFE` | Cyan |

## Instalación

### Windows Terminal

1. Abrir `settings.json` (Ctrl+Shift+,)
2. Copiar el contenido de `snazzy-windows-terminal.json` en la sección `"schemes"`
3. En tu perfil, agregar: `"colorScheme": "Snazzy"`

### iTerm2 (Mac)

1. Preferences → Profiles → Colors
2. Color Presets → Import
3. Seleccionar `snazzy.itermcolors`

### Terminal.app (Mac)

1. Terminal → Preferences → Profiles
2. Click en el botón de engranaje → Import
3. Seleccionar `snazzy.terminal`
4. Seleccionar como Default

### Alacritty

Copiar el contenido de `snazzy-alacritty.yml` a tu `~/.config/alacritty/alacritty.yml`

### Kitty

Copiar el contenido de `snazzy-kitty.conf` a tu `~/.config/kitty/kitty.conf`
