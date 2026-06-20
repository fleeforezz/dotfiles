-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 7,

        border_size = 2,

        col = {
            active_border   = "rgba(4b4b4bdd)",
            inactive_border = "rgba(0b0e1400)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 3,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = true,
            size      = 7,
            passes    = 3,
            vibrancy  = 0.1696,
            ignore_opacity = true,
            new_optimizations = true,
            special = true,
            popups = true,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Layer rules
hl.layer_rule({ 
    match = { namespace = "waybar" }, 
    blur = true,
    ignore_alpha = 0.5,
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

--------------------
---- ANIMATIONS ----
--------------------
hl.config({
    animations = {
        enabled = true,
    },
})

-- Beziers
hl.curve("water", {
    type = "bezier",
    points = {
        { 0.22, 0.9 },
        { 0.36, 1.0 },
    },
})

hl.curve("flow", {
    type = "bezier",
    points = {
        { 0.25, 0.1 },
        { 0.25, 1.0 },
    },
})

hl.curve("ripple", {
    type = "bezier",
    points = {
        { 0.33, 0.0 },
        { 0.2, 1.0 },
    },
})

hl.curve("stream", {
    type = "bezier",
    points = {
        { 0.4, 0.0 },
        { 0.4, 1.0 },
    },
})

hl.curve("cascade", {
    type = "bezier",
    points = {
        { 0.19, 1.0 },
        { 0.22, 1.0 },
    },
})

hl.curve("md3_standard", {
    type = "bezier",
    points = {
        { 0.2, 0.0 },
        { 0.0, 1.0 },
    },
})

hl.curve("md3_accel", {
    type = "bezier",
    points = {
        { 0.3, 0.0 },
        { 0.8, 0.15 },
    },
})

hl.curve("overshot", {
    type = "bezier",
    points = {
        { 0.05, 0.9 },
        { 0.1, 1.05 },
    },
})

-- Animations
hl.animation({ leaf = "windows",          enabled = true, speed = 3.0, bezier = "water" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 2.5, bezier = "cascade", style = "slide" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 2.4, bezier = "stream",  style = "slide" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 1.6, bezier = "flow" })
hl.animation({ leaf = "fade",             enabled = true, speed = 2.4, bezier = "water" })
hl.animation({ leaf = "fadeIn",           enabled = true, speed = 2.0, bezier = "cascade" })
hl.animation({ leaf = "fadeOut",          enabled = true, speed = 1.8, bezier = "ripple" })
hl.animation({ leaf = "fadeDim",          enabled = true, speed = 2.0, bezier = "water" })
hl.animation({ leaf = "fadeSwitch",       enabled = true, speed = 1.4, bezier = "flow" })
hl.animation({ leaf = "layersIn",         enabled = true, speed = 1.5, bezier = "overshot",     style = "popin 80%" })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 1.3, bezier = "md3_accel",    style = "popin 90%" })
hl.animation({ leaf = "layers",           enabled = true, speed = 1.5, bezier = "md3_standard" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 1.5, bezier = "flow" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.5, bezier = "water" })
hl.animation({ leaf = "border",           enabled = true, speed = 2.9, bezier = "water" })
hl.animation({ leaf = "borderangle",      enabled = true, speed = 3.5, bezier = "flow" })

----------------------
---- WINDOW RULES ----
----------------------

-- ================= Floating apps =================

-- Floatterm
hl.window_rule({
    name  = "floatterm",
    match = { class = "^(floatterm)$" },
    float  = true,
    center = true,
    size   = { 800, 500 },
})

-- Impala
hl.window_rule({
    name  = "impala",
    match = { class = "^(impala)$" },
    float  = true,
    center = true,
    size   = { 900, 600 },
})

-- WiFi / BT tool
hl.window_rule({
    name  = "wifibt",
    match = { class = "^(wifibt)$" },
    float  = true,
    center = true,
    size   = { 600, 500 },
})

-- Bluetooth (Blueberry)
-- NOTE: float/center are matched on the window title, size is matched on the
-- class — kept as two separate rules to mirror the original behavior exactly.
hl.window_rule({
    name  = "bluetooth-title",
    match = { title = "^(Bluetooth)$" },
    float  = true,
    center = true,
})

hl.window_rule({
    name  = "blueberry-size",
    match = { class = "^(blueberry\\.py)$" },
    size = { 900, 600 },
})

-- Webapp installer
hl.window_rule({
    name  = "webapp-install",
    match = { title = "^(webapp-install)$" },
    float  = true,
    center = true,
    size   = { 900, 600 },
})

-- Share dialogs
hl.window_rule({
    name  = "share",
    match = { title = "^(share)$" },
    float     = true,
    center    = true,
    size      = { 900, 600 },
    animation = "slide",
})

-- April
hl.window_rule({
    name  = "april",
    match = { class = "^(april)$" },
    float  = true,
    center = true,
    size   = { 800, 500 },
})

-- PulseAudio Volume Control
hl.window_rule({
    name  = "pavucontrol",
    match = { class = "^(org\\.pulseaudio\\.pavucontrol)$" },
    float  = true,
    center = true,
    size   = { 800, 600 },
})

-- LocalSend
hl.window_rule({
    name  = "localsend",
    match = { class = "^(localsend)$" },
    float  = true,
    center = true,
    size   = { 600, 600 },
})

-- ================= Global rules =================

-- Fix XWayland drag issues
hl.window_rule({
    name  = "xwayland-drag-fix",
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

-- Disable maximize event everywhere
hl.window_rule({
    name  = "no-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Default opacity (active / inactive)
hl.window_rule({
    name  = "default-opacity",
    match = { class = ".*" },
    opacity = "0.97 0.9",
})

-- ================= Workspace -> monitor mapping =================

hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1", default = true })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-1" })

hl.workspace_rule({ workspace = "6",  monitor = "DP-1" })
hl.workspace_rule({ workspace = "7",  monitor = "DP-1" })
hl.workspace_rule({ workspace = "8",  monitor = "DP-1" })
hl.workspace_rule({ workspace = "9",  monitor = "DP-1" })
hl.workspace_rule({ workspace = "10", monitor = "DP-1" })

hl.workspace_rule({ workspace = "11", monitor = "DP-2" })
hl.workspace_rule({ workspace = "12", monitor = "DP-2" })
hl.workspace_rule({ workspace = "13", monitor = "DP-2" })
hl.workspace_rule({ workspace = "14", monitor = "DP-2" })
hl.workspace_rule({ workspace = "15", monitor = "DP-2" })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
})