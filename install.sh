#!/usr/bin/env bash
# ==============================================================================
# ARCH LINUX AUTO-INSTALLER & OPTIMIZED HYPRLAND DOTFILES SETUP
# Hardware Target: Intel Xeon E3-1230 v2 | 16 GB DDR3 | NVIDIA GTX 1060
# ==============================================================================

set -e

GREEN='\030[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}   Instalador y Optimizador para Arch Linux + Hyprland${NC}"
echo -e "${CYAN}====================================================${NC}"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Configurar repositorios de CachyOS (Kernel optimizado BBO / Bore / LTO)
echo -e "${YELLOW}[1/6] Configurando repositorios de CachyOS para rendimiento máximo...${NC}"
if ! grep -q "cachyos" /etc/pacman.conf; then
    curl https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz
    tar -xvf cachyos-repo.tar.xz
    cd cachyos-repo
    sudo ./cachyos-repo.sh
    cd .. && rm -rf cachyos-repo cachyos-repo.tar.xz
fi

# 2. Actualizar sistema e instalar paquetes principales y kernel CachyOS / Zen
echo -e "${YELLOW}[2/6] Instalando Kernel CachyOS, Drivers Nvidia 580xx y Entorno...${NC}"
sudo pacman -Sy --needed \
    linux-cachyos linux-cachyos-headers \
    nvidia-dkms nvidia-utils lib32-nvidia-utils egl-wayland \
    hyprland waybar rofi-wayland kitty mako thunar \
    polkit-gnome network-manager-applet cliphist wl-clipboard \
    zsh starship fastfetch firefox \
    zram-generator ananicy-cpp git base-devel

# 3. Optimización de Memoria RAM (ZRAM con compresión zstd para 16GB DDR3)
echo -e "${YELLOW}[3/6] Configurando ZRAM (RAM ultrarrápida)...${NC}"
sudo tee /etc/systemd/zram-generator.conf > /dev/null << 'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
EOF
sudo systemctl daemon-reload
sudo systemctl start /dev/zram0 || true

# 4. Configurar Nvidia DRM para Wayland/Hyprland sin lag
echo -e "${YELLOW}[4/6] Configurando parametros del Kernel para Nvidia GTX 1060...${NC}"
if [ -f /etc/default/grub ]; then
    if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 nvidia-drm.fbdev=1 /' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg || true
    fi
fi

# 5. Clonar repositorios externos (SDDM qylock, Greyline wallpaper, Mechabar)
echo -e "${YELLOW}[5/6] Descargando repositorios externos de GitHub...${NC}"
mkdir -p ~/.config

# Waybar (mechabar)
if [ ! -d ~/.config/waybar ]; then
    git clone https://github.com/sejjy/mechabar.git ~/.config/waybar
fi

# Greyline (Wallpaper Thinkpad timezones)
if [ ! -d ~/greyline ]; then
    git clone https://github.com/cothinking-dev/greyline.git ~/greyline
fi

# Qylock (SDDM theme)
if [ ! -d ~/qylock ]; then
    git clone https://github.com/Darkkal44/qylock.git ~/qylock
fi

# 6. Vincular/Copiar Dotfiles personales
echo -e "${YELLOW}[6/6] Aplicando tus Dotfiles personales (Hyprland, Kitty, Rofi, Zsh)...${NC}"
mkdir -p ~/.config/hypr ~/.config/kitty ~/.config/rofi

cp -f "$DOTFILES_DIR/config/hypr/hyprland.lua" ~/.config/hypr/
cp -rf "$DOTFILES_DIR/config/kitty/"* ~/.config/kitty/
cp -rf "$DOTFILES_DIR/config/rofi/"* ~/.config/rofi/
cp -f "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc

# Cambiar shell a ZSH
sudo chsh -s /usr/bin/zsh $USER || true

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}  ¡Instalación y optimización completadas con éxito! ${NC}"
echo -e "${GREEN}====================================================${NC}"
