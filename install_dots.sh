#!/usr/bin/env bash
# ==============================================================================
# SCRIPT DE POST-INSTALACIÓN: DOTFILES & OPTIMIZACIONES HYPRLAND / CACHYOS
# Ejecutar este script DENTRO de la nueva instalación de Arch Linux
# Hardware: Intel Xeon E3-1230 v2 | 16 GB DDR3 | NVIDIA GTX 1060
# ==============================================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}====================================================================${NC}"
echo -e "${CYAN}   POST-INSTALACIÓN: RESTAURACIÓN DE DOTFILES Y OPTIMIZACIONES ${NC}"
echo -e "${CYAN}====================================================================${NC}"
echo ""

# 1. Configurar repositorios de CachyOS (Kernel optimizado BBO / BORE / LTO)
echo -e "${YELLOW}[1/5] Configurando repositorio de CachyOS (Kernel optimizado)...${NC}"
if ! grep -q "cachyos" /etc/pacman.conf 2>/dev/null; then
    curl -s https://mirror.cachyos.org/cachyos-repo.tar.xz -o /tmp/cachyos-repo.tar.xz
    tar -xvf /tmp/cachyos-repo.tar.xz -C /tmp/
    cd /tmp/cachyos-repo && sudo ./cachyos-repo.sh && cd ~
    sudo pacman -Sy --needed linux-cachyos linux-cachyos-headers
fi

# 2. Instalación de paquetes de entorno escritorio y utilidades
echo -e "${YELLOW}[2/5] Instalando Hyprland, Waybar, Kitty, Rofi y utilidades...${NC}"
sudo pacman -S --needed \
    hyprland waybar rofi-wayland kitty mako thunar \
    polkit-gnome network-manager-applet cliphist wl-clipboard \
    zsh starship fastfetch firefox \
    zram-generator ananicy-cpp git

# 3. Optimización de Memoria RAM (ZRAM zstd para 16GB RAM DDR3)
echo -e "${YELLOW}[3/5] Configurando ZRAM (RAM ultra rápida)...${NC}"
sudo tee /etc/systemd/zram-generator.conf > /dev/null << 'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
EOF
sudo systemctl daemon-reload
sudo systemctl start /dev/zram0 || true

# 4. Clonar repositorios externos (Mechabar, Greyline, Qylock)
echo -e "${YELLOW}[4/5] Clonando repositorios externos de GitHub...${NC}"
mkdir -p ~/.config

if [ ! -d ~/.config/waybar ]; then
    git clone https://github.com/sejjy/mechabar.git ~/.config/waybar
fi

if [ ! -d ~/greyline ]; then
    git clone https://github.com/cothinking-dev/greyline.git ~/greyline
fi

if [ ! -d ~/qylock ]; then
    git clone https://github.com/Darkkal44/qylock.git ~/qylock
fi

# 5. Restaurar Dotfiles limpios (Hyprland, Kitty, Rofi, Zsh)
echo -e "${YELLOW}[5/5] Aplicando tus Dotfiles (Hyprland, Kitty, Rofi, Zsh)...${NC}"
mkdir -p ~/.config/hypr ~/.config/kitty ~/.config/rofi

cp -f "$DOTFILES_DIR/config/hypr/hyprland.lua" ~/.config/hypr/
cp -rf "$DOTFILES_DIR/config/kitty/"* ~/.config/kitty/
cp -rf "$DOTFILES_DIR/config/rofi/"* ~/.config/rofi/
cp -f "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc

echo -e "${GREEN}====================================================================${NC}"
echo -e "${GREEN} ¡RESTAURACIÓN Y OPTIMIZACIÓN COMPLETADAS CON ÉXITO! ${NC}"
echo -e "${GREEN} Reinicia o inicia sesión en Hyprland para disfrutar tu entorno. ${NC}"
echo -e "${GREEN}====================================================================${NC}"
