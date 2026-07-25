-- Hyprland Lua Configuration File
-- Refer to https://wiki.hypr.land/ for full documentation

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@60",
    position = "auto",
    scale    = "1.25",
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "rofi -show drun"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function () 
  hl.exec_cmd("xhost +local:")
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  hl.exec_cmd("nm-applet")
  hl.exec_cmd("waybar")
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("sleep 1 && greyline")
  hl.exec_cmd("mako")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Variables de entorno para Nvidia GTX 1060 (Drivers 580xx)
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 15,

        border_size = 2,

    col = {
            active_border   = { colors = {"rgba(e0e0e0ee)", "rgba(505050ee)"}, angle = 45 },
            inactive_border = "rgba(262626aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        -- Configuración optimizada de desenfoque (Blur) integrada correctamente
        blur = {
            enabled           = true,
            size              = 6,
            passes            = 2,
            vibrancy          = 0.20,
            ignore_opacity    = true,
            new_optimizations = true,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Curvas y animaciones veloces (Snappy)
hl.curve("snappy", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })
hl.curve("smooth", { type = "bezier", points = { {0.25, 1},   {0.5, 1}   } })
hl.curve("linear", { type = "bezier", points = { {0, 0},      {1, 1}     } })

hl.animation({ leaf = "windows",     enabled = true, speed = 3.5, bezier = "snappy" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3.5, bezier = "snappy", style = "popin 88%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2.8, bezier = "snappy", style = "popin 88%" })
hl.animation({ leaf = "border",      enabled = true, speed = 4.0, bezier = "snappy" })
hl.animation({ leaf = "fade",        enabled = true, speed = 2.5, bezier = "smooth" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 3.5, bezier = "snappy" })
hl.animation({ leaf = "layers",      enabled = true, speed = 3.0, bezier = "smooth" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    scrolling = {
        fullscreen_on_one_column = true,
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "latam",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Historial del portapapeles 
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"))

-- Capturar una región seleccionada con el ratón y copiarla directo al portapapeles
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))

-- Capturar una región y abrirla en el editor Swappy para rayar o recortar
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))

-- Capturar la pantalla completa (pantalla completa al portapapeles con la tecla PrintScreen)
hl.bind("PRINT", hl.dsp.exec_cmd("grim - | wl-copy"))

-- Atajos principales
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprctl dispatch exit"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + CTRL + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Mover foco de ventanas
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Cambiar de workspace (1-10)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Arrastrar y redimensionar ventanas con el ratón
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Controles de audio y brillo
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Habilitar desenfoque (blur) para la capa de Rofi
hl.layer_rule({
    name  = "rofi-blur",
    match = { namespace = "rofi" },
    blur  = true,
    ignore_alpha = 0.2,
})

-- 1. Regla de protección: Todo lo que esté en Fullscreen pasa a 100% opaco
hl.window_rule({
    name  = "opaque-fullscreen",
    match = { fullscreen = true },
    opacity = "1.0 1.0", -- opacidad activa e inactiva en un solo string
})

-- 2. Regla de exclusión multimedia: Navegadores siempre opacos
hl.window_rule({
    name  = "opaque-browsers",
    match = { class = "^(brave-browser|firefox|chromium|Google-chrome)$" },
    opacity = "1.0 1.0",
})

-- 3. Transparencia selectiva para terminales, gestores de archivos y editores
hl.window_rule({
    name  = "transparency-system-apps",
    match = { class = "^(kitty|thunar|nautilus|codium|rofi)$" },
    opacity = "0.88 0.80",
})
