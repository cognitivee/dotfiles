#!/usr/bin/env bash
# ==============================================================================
# SCRIPT INTERACTIVO DE INSTALACIÓN AUTOMÁTICA DE ARCH LINUX (LIVE USB)
# Disco Destino: /dev/nvme0n1 (Wipe total -> EFI + Raíz / unificada)
# Target Hardware: Intel Xeon E3-1230 v2 | NVIDIA GTX 1060 | 16GB RAM
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

TARGET_DISK="/dev/nvme0n1"
NEW_HOSTNAME="arch-pc"

echo -e "${CYAN}====================================================================${NC}"
echo -e "${CYAN}   SCRIPT DE INSTALACIÓN INTERACTIVA DE ARCH LINUX${NC}"
echo -e "${CYAN}====================================================================${NC}"
echo ""

# 1. Diálogo interactivo para Nombre de Usuario
read -p "--> Ingresa el nombre para tu usuario principal [infunde]: " NEW_USER
NEW_USER=${NEW_USER:-infunde}

# 2. Diálogo interactivo para Contraseña (oculta al escribir)
while true; do
    echo -n "--> Ingresa la contraseña para '${NEW_USER}' y 'root': "
    read -s USER_PASS
    echo ""
    echo -n "--> Confirma la contraseña: "
    read -s USER_PASS_CONFIRM
    echo ""
    
    if [ "$USER_PASS" = "$USER_PASS_CONFIRM" ] && [ -n "$USER_PASS" ]; then
        echo -e "${GREEN}✓ Contraseña verificada correctamente.${NC}"
        break
    else
        echo -e "${RED}✗ Las contraseñas no coinciden o están vacías. Inténtalo de nuevo.${NC}\n"
    fi
done

echo ""
echo -e "${RED}====================================================================${NC}"
echo -e "${RED}  ¡ATENCIÓN! ESTE SCRIPT BORRARÁ TODO EL DISCO ${TARGET_DISK}${NC}"
echo -e "${RED}  Se instalará Arch Linux para el usuario '${NEW_USER}'.${NC}"
echo -e "${RED}====================================================================${NC}"
read -p "Presiona ENTER para formatear el disco e instalar o CTRL+C para cancelar..."

# 3. Limpieza de tablas y particionado de disco
echo -e "${YELLOW}[1/7] Formateando y particionando ${TARGET_DISK}...${NC}"
umount -R /mnt 2>/dev/null || true
parted -s "${TARGET_DISK}" mklabel gpt
parted -s "${TARGET_DISK}" mkpart ESP fat32 1MiB 1024MiB
parted -s "${TARGET_DISK}" set 1 esp on
parted -s "${TARGET_DISK}" mkpart primary ext4 1024MiB 100%

# Particiones resultantes
PART_EFI="${TARGET_DISK}p1"
PART_ROOT="${TARGET_DISK}p2"

# 4. Formato de sistemas de archivos
echo -e "${YELLOW}[2/7] Formateando particiones (EFI FAT32 + Raíz Ext4)...${NC}"
mkfs.fat -F32 "${PART_EFI}"
mkfs.ext4 -F "${PART_ROOT}"

# 5. Montaje de particiones
echo -e "${YELLOW}[3/7] Montando sistemas de archivos en /mnt...${NC}"
mount "${PART_ROOT}" /mnt
mount --mkdir "${PART_EFI}" /mnt/boot

# 6. Instalación del sistema base y Kernel Zen / CachyOS + Microcode Intel + Nvidia
echo -e "${YELLOW}[4/7] Ejecutando pacstrap (Kernel Zen + Microcode Intel + Nvidia 580xx)...${NC}"
pacstrap -K /mnt base base-devel linux-zen linux-zen-headers linux-firmware intel-ucode \
    nvidia-dkms nvidia-utils lib32-nvidia-utils egl-wayland \
    networkmanager grub efibootmgr sudo git zsh nano

# 7. Generación de fstab
echo -e "${YELLOW}[5/7] Generando /etc/fstab...${NC}"
genfstab -U /mnt >> /mnt/etc/fstab

# 8. Configuración dentro de chroot (Zona horaria, usuario, bootloader)
echo -e "${YELLOW}[6/7] Configurando el nuevo sistema...${NC}"
arch-chroot /mnt /bin/bash -e <<EOF
# Zona horaria y reloj
ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime
hwclock --systohc

# Idioma y Localización
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "es_CL.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=es_CL.UTF-8" > /etc/locale.conf

# Hostname
echo "${NEW_HOSTNAME}" > /etc/hostname

# Establecer contraseña de Root
echo "root:${USER_PASS}" | chpasswd

# Crear Usuario principal y establecer contraseña
useradd -m -g users -G wheel,storage,power,video -s /bin/zsh "${NEW_USER}"
echo "${NEW_USER}:${USER_PASS}" | chpasswd
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/wheel

# Habilitar NetworkManager
systemctl enable NetworkManager

# Configurar GRUB con parametros Nvidia DRM para Wayland (GTX 1060)
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 nvidia-drm.fbdev=1 /' /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

EOF

echo -e "${GREEN}====================================================================${NC}"
echo -e "${GREEN} ¡INSTALACIÓN DE ARCH LINUX COMPLETADA CON ÉXITO! ${NC}"
echo -e "${GREEN} Usuario creado: ${NEW_USER} ${NC}"
echo -e "${GREEN} Ahora puedes escribir 'reboot' para reiniciar en tu nuevo sistema. ${NC}"
echo -e "${GREEN}====================================================================${NC}"
