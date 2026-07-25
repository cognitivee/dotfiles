# My Clean Arch Linux & Hyprland Dotfiles

Optimizaciones y configuración limpia para **Arch Linux + Hyprland**.

## 💻 Especificaciones de Hardware objetivo
- **Procesador:** Intel Xeon E3-1230 v2 (4 núcleos / 8 hilos Ivy Bridge)
- **Memoria RAM:** 16 GB DDR3 (con ZRAM zstd comprimido)
- **Gráfica:** NVIDIA GeForce GTX 1060 (Drivers 580xx + DRM Wayland modeset)
- **Kernel:** Linux CachyOS (`linux-cachyos` con programador BORE/LTO)

## 🚀 Restaurar en una nueva instalación
En la nueva instalación de Arch Linux recién instalada desde el USB:

```bash
# 1. Clonar este repositorio
git clone https://github.com/cognitivee/dotfiles.git ~/dotfiles

# 2. Ejecutar el script automatizado
cd ~/dotfiles
./install.sh
```

El script se encargará automáticamente de:
- Añadir el repositorio de **CachyOS** e instalar el Kernel optimizado.
- Instalar drivers de **Nvidia 580xx** con optimizaciones Wayland.
- Configurar **ZRAM** para tus 16 GB de RAM.
- Clonar automáticamente los repositorios externos (`mechabar`, `greyline`, `qylock`).
- Restaurar tus archivos de configuración limpios (`hyprland.lua`, `kitty`, `rofi`, `zshrc`).
