local version_n = 5
local version = '1.2.4'
local author = 'blackw1ndow'
script_name('Shapez '..version..'')
local mX, mY = getScreenResolution()
local dlstatus = require('moonloader').download_status
local update_url = 'https://raw.githubusercontent.com/blackw1ndow/shapez/main/update.ini'
local update_path = getWorkingDirectory() .. "/update.ini"
local inicfg = require 'inicfg'
local ev = require 'lib.samp.events'
local imgui = require 'imgui'
local mem = require 'memory'
local vkeys = require 'vkeys'
local fa = require 'fAwesome5'
local memory = require 'memory'
local ia = require "imgui_addons"
local arenaMode = false
local supremeMode = false
local locked = false
local delplayers = false
local delcars = false
local menu = 1
local ot = 0
local captcha = ''
local captchaTable = {}
local t = 0
local sync = true
local changePos = false

local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local modes = {u8'Обычная', u8'Новая', u8'Серверная'}
local keyboard_modes = {u8'Только цифры', u8'Компактные цифры', u8'Только NumPad'}
local tmodes = {u8'Фиолетовая', u8'Бирюзовая', u8'Красная', u8'Салатовая', u8'Синяя', u8'Серая'}

local config = inicfg.load({
    main = {
        timer = false,
        jt = false,
        msg = false,
        text = '',
        texttime = false,
        textcap = false,
        recolor = false,
        captrain = false,
        shorten = false,
        trainmode = 'old',
        ar = false,
        delp = false,
		newdelp = false,
        delc = false,
		newdelc = false,
        fd = false,
        dist = '600',
        customlogo = false,
        theme = 0,
        antipodkid = false,
    },
    binds = {
        trainkey = encodeJson({U}),
        fastnrg = false,
        nrgkey = encodeJson({X}),
        fastspawn = false,
        spawnkey = encodeJson({insert}),
        fasthp = false,
        hpkey = encodeJson({delete}),
        fastflip = false,
        flipkey = encodeJson({F1}),
        fastfill = false,
        fillkey = encodeJson({F2}),
        fastslet = false,
        sletkey = encodeJson({F3}),
    },
    commands = {
        arc = 'ar',
        delpc = 'delp',
        delcc = 'delc',
        fdc = 'fogdist',
        fhc = 'fh',
        fbc = 'fb',
    },
    keyboard = {
        active = false,
        mode = 0,
        move = false,
        x = 500,
        y = 10
    },
    servertime = {
        timeX = mX / 2,
        timeY = mY / 2,
        timeR = 255,
        timeG = 255,
        timeB = 255,
        timeStyle = 13,
        timeFont = 'Arial',
        timeSize = 20,
        stime = false
    },
    captcha = {
        record = 0,
        vcode = 0,
        ncode = 0,
        code = 0,
    },
}, "Shapez")

local trainkey = {
    v = decodeJson(config.binds.trainkey)
}

local sletkey = {
    v = decodeJson(config.binds.sletkey)
}

local nrgkey = {
    v = decodeJson(config.binds.nrgkey)
}

local spawnkey = {
    v = decodeJson(config.binds.spawnkey)
}

local hpkey = {
    v = decodeJson(config.binds.hpkey)
}

local flipkey = {
    v = decodeJson(config.binds.flipkey)
}

local fillkey = {
    v = decodeJson(config.binds.fillkey)
}

function trainmode()
    if config.main.trainmode == 'old' then result = imgui.ImInt(0)
    elseif config.main.trainmode == 'new' then result = imgui.ImInt(1)
    elseif config.main.trainmode == 'supreme' and (arenaMode or supremeMode) then result = imgui.ImInt(2) end
end

ffgoodcolor = 'B886E9'
ffbadcolor = '8729E4' 
goodcolor = '{b886e9}'
badcolor = '{8729e4}'
tag = badcolor..'[Shapez]: {FFFFFF}'
gtag = goodcolor..'[Shapez]: {FFFFFF}'

buffer = imgui.ImBuffer(tostring(config.main.text), 256)
buffer.v = string.gsub(tostring(buffer.v), '"', '')
arbuf = imgui.ImBuffer(tostring(config.commands.arc), 100)
arbuf.v = string.gsub(tostring(arbuf.v), '"', '')
delpbuf = imgui.ImBuffer(tostring(config.commands.delpc), 100)
delpbuf.v = string.gsub(tostring(delpbuf.v), '"', '')
delcbuf = imgui.ImBuffer(tostring(config.commands.delcc), 100)
delcbuf.v = string.gsub(tostring(delcbuf.v), '"', '')
fdbuf = imgui.ImBuffer(tostring(config.commands.fdc), 100)
fdbuf.v = string.gsub(tostring(fdbuf.v), '"', '')
distbuf = imgui.ImBuffer(tostring(config.main.dist), 100)
distbuf.v = string.gsub(tostring(distbuf.v), '"', '')
fhb = imgui.ImBuffer(tostring(config.commands.fhc), 100)
fhb.v = string.gsub(tostring(fhb.v), '"', '')
fbb = imgui.ImBuffer(tostring(config.commands.fbc), 100)
fbb.v = string.gsub(tostring(fbb.v), '"', '')
result = imgui.ImInt(0)
keyboard_pos = imgui.ImVec2(config.keyboard.x, config.keyboard.y)
keyboard_type = imgui.ImInt(config.keyboard.mode)
temki = imgui.ImInt(config.main.theme)
styleTimeinput = imgui.ImInt(config.servertime.timeStyle)
sizeTimeinput = imgui.ImInt(config.servertime.timeSize)
timeColour = imgui.ImFloat3(config.servertime.timeR/255, config.servertime.timeG/255, config.servertime.timeB/255)
fontBTinput = imgui.ImBuffer(tostring(config.servertime.biztextFont), 30)
fontTimeinput = imgui.ImBuffer(tostring(config.servertime.timeFont), 30)

local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true

        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 15.0, font_config, fa_glyph_ranges)
        fa_font2 = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 22.0, font_config2, fa_glyph_ranges)
    end
end

local main_window_state = imgui.ImBool(false)
local vip_window_state = imgui.ImBool(false)
local servertime = imgui.ImBool(false)
local keyboard = imgui.ImBool(config.keyboard.active)

function isKeysDown(keylist)
    local tKeys = keylist
    local bool = false
    local isDownIndex = 0
    local key = #tKeys < 2 and tonumber(tKeys[1]) or tonumber(tKeys[#tKeys])
    if #tKeys < 2 then
        if not isKeyDown(VK_RMENU) and not isKeyDown(VK_LMENU) and not isKeyDown(VK_LSHIFT) and not isKeyDown(VK_RSHIFT) and not isKeyDown(VK_LCONTROL) and not isKeyDown(VK_RCONTROL) then
            if wasKeyPressed(key) then
                bool = true
            end
        end
    else
        if isKeyDown(tKeys[1])  then
            if isKeyDown(tKeys[2]) then
                if tKeys[3] ~= nil then
                    if isKeyDown(tKeys[3]) then
                        if tKeys[4] ~= nil then
                            if isKeyDown(tKeys[4]) then
                                if tKeys[5] ~= nil then
                                    if isKeyDown(tKeys[5]) then
                                        if wasKeyPressed(key) then
                                            bool = true
                                        end
                                    end
                                else
                                    if wasKeyPressed(key) then
                                        bool = true
                                    end
                                end
                            end
                        else
                            if wasKeyPressed(key) then
                                bool = true
                            end
                        end
                    end
                else
                    if wasKeyPressed(key) then
                        bool = true
                    end
                end
            end
        end
    end
    if nextLockKey == keylist then
        bool = false
        nextLockKey = ""
    end
    return bool
end

styles = {
    [0] = function()
   imgui.SwitchContext()
   local style = imgui.GetStyle()
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4
   local ImVec2 = imgui.ImVec2

    style.WindowRounding = 7.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ChildWindowRounding = 4.0
    style.FrameRounding = 5.0
    style.ItemSpacing = imgui.ImVec2(7.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.Text]                 = ImVec4(0.86, 0.93, 0.89, 0.78)
    colors[clr.TextDisabled]         = ImVec4(0.36, 0.42, 0.47, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.11, 0.15, 0.17, 1.00)
    colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.FrameBgHovered]       = ImVec4(0.19, 0.12, 0.28, 1.00)
    colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
    colors[clr.TitleBg]              = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]        = ImVec4(0.41, 0.19, 0.63, 1.00)
    colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
    colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.20, 0.09, 0.31, 1.00)
    colors[clr.ComboBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.CheckMark]            = ImVec4(0.59, 0.28, 1.00, 1.00)
    colors[clr.SliderGrab]           = ImVec4(0.41, 0.19, 0.63, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(0.41, 0.19, 0.63, 1.00)
    colors[clr.Button]               = ImVec4(0.41, 0.19, 0.63, 0.44)
    colors[clr.ButtonHovered]        = ImVec4(0.41, 0.19, 0.63, 0.86)
    colors[clr.ButtonActive]         = ImVec4(0.64, 0.33, 0.94, 1.00)
    colors[clr.Header]               = ImVec4(0.20, 0.25, 0.29, 0.55)
    colors[clr.HeaderHovered]        = ImVec4(0.51, 0.26, 0.98, 0.80)
    colors[clr.HeaderActive]         = ImVec4(0.53, 0.26, 0.98, 1.00)
    colors[clr.Separator]            = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.SeparatorHovered]     = ImVec4(0.60, 0.60, 0.70, 1.00)
    colors[clr.SeparatorActive]      = ImVec4(0.70, 0.70, 0.90, 1.00)
    colors[clr.ResizeGrip]           = ImVec4(0.59, 0.26, 0.98, 0.25)
    colors[clr.ResizeGripHovered]    = ImVec4(0.61, 0.26, 0.98, 0.67)
    colors[clr.ResizeGripActive]     = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.CloseButton]          = ImVec4(0.40, 0.39, 0.38, 0.16)
    colors[clr.CloseButtonHovered]   = ImVec4(0.40, 0.39, 0.38, 0.39)
    colors[clr.CloseButtonActive]    = ImVec4(0.40, 0.39, 0.38, 1.00)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.25, 1.00, 0.00, 0.43)
    colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
    ffgoodcolor = 'B886E9' 
    ffbadcolor = '8729E4' 
    goodcolor = '{b886e9}' 
    badcolor = '{8729e4}' 
    tag = badcolor..'[Shapez]: {FFFFFF}' 
    gtag = goodcolor..'[Shapez]: {FFFFFF}'
    end,
    function()
   imgui.SwitchContext()
   local style = imgui.GetStyle()
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4
   local ImVec2 = imgui.ImVec2

    style.WindowRounding = 7.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ChildWindowRounding = 4.0
    style.FrameRounding = 5.0
    style.ItemSpacing = imgui.ImVec2(7.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.Text]                 = ImVec4(0.86, 0.93, 0.89, 0.78)
    colors[clr.TextDisabled]         = ImVec4(0.36, 0.42, 0.47, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.11, 0.15, 0.17, 1.00)
    colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.FrameBgHovered]       = ImVec4(0.12, 0.20, 0.28, 1.00)
    colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
    colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.09, 0.21, 0.31, 1.00)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.30)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 0.50)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 0.50)
    colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Separator]            = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.SeparatorHovered]     = ImVec4(0.60, 0.60, 0.70, 1.00)
    colors[clr.SeparatorActive]      = ImVec4(0.70, 0.70, 0.90, 1.00)
    colors[clr.ResizeGrip]           = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]    = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]     = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.CloseButton]          = ImVec4(0.40, 0.39, 0.38, 0.16)
    colors[clr.CloseButtonHovered]   = ImVec4(0.40, 0.39, 0.38, 0.39)
    colors[clr.CloseButtonActive]    = ImVec4(0.40, 0.39, 0.38, 1.00)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.25, 1.00, 0.00, 0.43)
    colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
    ffgoodcolor = '6CCEBA' 
    ffbadcolor = '1FB092' 
    goodcolor = '{6CCEBA}' 
    badcolor = '{1FB092}' 
    tag = badcolor..'[Shapez]: {FFFFFF}' 
    gtag = goodcolor..'[Shapez]: {FFFFFF}'
    end,
    function()
   imgui.SwitchContext()
   local style = imgui.GetStyle()
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4
   local ImVec2 = imgui.ImVec2

    style.WindowRounding = 7.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ChildWindowRounding = 4.0
    style.FrameRounding = 5.0
    style.ItemSpacing = imgui.ImVec2(7.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 0.78)
    colors[clr.TextDisabled]         = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.11, 0.15, 0.17, 1.00)
    colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.FrameBgHovered]       = ImVec4(0.12, 0.20, 0.28, 1.00)
    colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
    colors[clr.TitleBg]              = ImVec4(0.53, 0.20, 0.16, 0.65)
    colors[clr.TitleBgActive]        = ImVec4(0.56, 0.14, 0.14, 1.00)
    colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
    colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.09, 0.21, 0.31, 1.00)
    colors[clr.ComboBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.CheckMark]            = ImVec4(1.00, 0.28, 0.28, 1.00)
    colors[clr.SliderGrab]           = ImVec4(0.64, 0.14, 0.14, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(1.00, 0.37, 0.37, 1.00)
    colors[clr.Button]               = ImVec4(0.59, 0.13, 0.13, 1.00)
    colors[clr.ButtonHovered]        = ImVec4(0.69, 0.15, 0.15, 1.00)
    colors[clr.ButtonActive]         = ImVec4(0.67, 0.13, 0.07, 1.00)
    colors[clr.Header]               = ImVec4(0.20, 0.25, 0.29, 0.55)
    colors[clr.HeaderHovered]        = ImVec4(0.98, 0.38, 0.26, 0.80)
    colors[clr.HeaderActive]         = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]            = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.SeparatorHovered]     = ImVec4(0.60, 0.60, 0.70, 1.00)
    colors[clr.SeparatorActive]      = ImVec4(0.70, 0.70, 0.90, 1.00)
    colors[clr.ResizeGrip]           = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]    = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]     = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.CloseButton]          = ImVec4(0.40, 0.39, 0.38, 0.16)
    colors[clr.CloseButtonHovered]   = ImVec4(0.40, 0.39, 0.38, 0.39)
    colors[clr.CloseButtonActive]    = ImVec4(0.40, 0.39, 0.38, 1.00)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.25, 1.00, 0.00, 0.43)
    colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
    ffgoodcolor = 'E85D5D' 
    ffbadcolor = 'B62626' 
    goodcolor = '{E85D5D}' 
    badcolor = '{B62626}' 
    tag = badcolor..'[Shapez]: {FFFFFF}' 
    gtag = goodcolor..'[Shapez]: {FFFFFF}'
    end,
    function()
   imgui.SwitchContext()
   local style = imgui.GetStyle()
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4
   local ImVec2 = imgui.ImVec2

    style.WindowRounding = 7.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ChildWindowRounding = 4.0
    style.FrameRounding = 5.0
    style.ItemSpacing = imgui.ImVec2(7.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 0.78)
            colors[clr.TextDisabled]         = ImVec4(0.36, 0.42, 0.47, 1.00)
            colors[clr.WindowBg]             = ImVec4(0.11, 0.15, 0.17, 1.00)
            colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
            colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
            colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
            colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
            colors[clr.FrameBg]              = ImVec4(0.25, 0.29, 0.20, 1.00)
            colors[clr.FrameBgHovered]       = ImVec4(0.12, 0.20, 0.28, 1.00)
            colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
            colors[clr.TitleBg]              = ImVec4(0.09, 0.12, 0.14, 0.65)
            colors[clr.TitleBgActive]        = ImVec4(0.35, 0.58, 0.06, 1.00)
            colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
            colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
            colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
            colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
            colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
            colors[clr.ScrollbarGrabActive]  = ImVec4(0.09, 0.21, 0.31, 1.00)
            colors[clr.ComboBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
            colors[clr.CheckMark]            = ImVec4(0.72, 1.00, 0.28, 1.00)
            colors[clr.SliderGrab]           = ImVec4(0.43, 0.57, 0.05, 1.00)
            colors[clr.SliderGrabActive]     = ImVec4(0.55, 0.67, 0.15, 1.00)
            colors[clr.Button]               = ImVec4(0.40, 0.57, 0.01, 1.00)
            colors[clr.ButtonHovered]        = ImVec4(0.45, 0.69, 0.07, 1.00)
            colors[clr.ButtonActive]         = ImVec4(0.27, 0.50, 0.00, 1.00)
            colors[clr.Header]               = ImVec4(0.20, 0.25, 0.29, 0.55)
            colors[clr.HeaderHovered]        = ImVec4(0.72, 0.98, 0.26, 0.80)
            colors[clr.HeaderActive]         = ImVec4(0.74, 0.98, 0.26, 1.00)
            colors[clr.Separator]            = ImVec4(0.50, 0.50, 0.50, 1.00)
            colors[clr.SeparatorHovered]     = ImVec4(0.60, 0.60, 0.70, 1.00)
            colors[clr.SeparatorActive]      = ImVec4(0.70, 0.70, 0.90, 1.00)
            colors[clr.ResizeGrip]           = ImVec4(0.68, 0.98, 0.26, 0.25)
            colors[clr.ResizeGripHovered]    = ImVec4(0.72, 0.98, 0.26, 0.67)
            colors[clr.ResizeGripActive]     = ImVec4(0.06, 0.05, 0.07, 1.00)
            colors[clr.CloseButton]          = ImVec4(0.40, 0.39, 0.38, 0.16)
            colors[clr.CloseButtonHovered]   = ImVec4(0.40, 0.39, 0.38, 0.39)
            colors[clr.CloseButtonActive]    = ImVec4(0.40, 0.39, 0.38, 1.00)
            colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
            colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
            colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
            colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
            colors[clr.TextSelectedBg]       = ImVec4(0.25, 1.00, 0.00, 0.43)
            colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
            ffgoodcolor = 'AFDE33' 
    ffbadcolor = '7EDA22' 
    goodcolor = '{AFDE33}' 
    badcolor = '{7EDA22}' 
    tag = badcolor..'[Shapez]: {FFFFFF}' 
    gtag = goodcolor..'[Shapez]: {FFFFFF}'
    end,
    function()
   imgui.SwitchContext()
   local style = imgui.GetStyle()
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4
   local ImVec2 = imgui.ImVec2

    style.WindowRounding = 7.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ChildWindowRounding = 4.0
    style.FrameRounding = 5.0
    style.ItemSpacing = imgui.ImVec2(7.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.Text] = ImVec4(0.860, 0.930, 0.890, 0.78)
            colors[clr.TextDisabled] = ImVec4(0.860, 0.930, 0.890, 0.28)
                colors[clr.Text]                 = ImVec4(0.86, 0.93, 0.89, 0.78)
                colors[clr.TextDisabled]         = ImVec4(0.36, 0.42, 0.47, 1.00)
                colors[clr.WindowBg]             = ImVec4(0.11, 0.15, 0.17, 1.00)
                colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
                colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
                colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
                colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
                colors[clr.FrameBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
                colors[clr.FrameBgHovered]       = ImVec4(0.12, 0.20, 0.28, 1.00)
                colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
                colors[clr.TitleBg]              = ImVec4(0.09, 0.12, 0.14, 0.65)
                colors[clr.TitleBgActive]        = ImVec4(0.11, 0.30, 0.59, 1.00)
                colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
                colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
                colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
                colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
                colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
                colors[clr.ScrollbarGrabActive]  = ImVec4(0.09, 0.21, 0.31, 1.00)
                colors[clr.ComboBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
                colors[clr.CheckMark]            = ImVec4(0.28, 0.56, 1.00, 1.00)
                colors[clr.SliderGrab]           = ImVec4(0.28, 0.56, 1.00, 1.00)
                colors[clr.SliderGrabActive]     = ImVec4(0.37, 0.61, 1.00, 1.00)
                colors[clr.Button]               = ImVec4(0.08, 0.33, 0.55, 1.00)
                colors[clr.ButtonHovered]        = ImVec4(0.28, 0.56, 1.00, 1.00)
                colors[clr.ButtonActive]         = ImVec4(0.25, 0.75, 1.00, 1.00)
                colors[clr.Header]               = ImVec4(0.20, 0.25, 0.29, 0.55)
                colors[clr.HeaderHovered]        = ImVec4(0.26, 0.59, 0.98, 0.80)
                colors[clr.HeaderActive]         = ImVec4(0.26, 0.59, 0.98, 1.00)
                colors[clr.Separator]            = ImVec4(0.50, 0.50, 0.50, 1.00)
                colors[clr.SeparatorHovered]     = ImVec4(0.60, 0.60, 0.70, 1.00)
                colors[clr.SeparatorActive]      = ImVec4(0.70, 0.70, 0.90, 1.00)
                colors[clr.ResizeGrip]           = ImVec4(0.26, 0.59, 0.98, 0.25)
                colors[clr.ResizeGripHovered]    = ImVec4(0.26, 0.59, 0.98, 0.67)
                colors[clr.ResizeGripActive]     = ImVec4(0.06, 0.05, 0.07, 1.00)
                colors[clr.CloseButton]          = ImVec4(0.40, 0.39, 0.38, 0.16)
                colors[clr.CloseButtonHovered]   = ImVec4(0.40, 0.39, 0.38, 0.39)
                colors[clr.CloseButtonActive]    = ImVec4(0.40, 0.39, 0.38, 1.00)
                colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
                colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
                colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
                colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
                colors[clr.TextSelectedBg]       = ImVec4(0.25, 1.00, 0.00, 0.43)
                colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
            ffgoodcolor = '579EF7' 
    ffbadcolor = '226BB8' 
    goodcolor = '{579EF7}' 
    badcolor = '{226BB8}' 
    tag = badcolor..'[Shapez]: {FFFFFF}' 
    gtag = goodcolor..'[Shapez]: {FFFFFF}'
    end,
    function()
   imgui.SwitchContext()
   local style = imgui.GetStyle()
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4
   local ImVec2 = imgui.ImVec2

    style.WindowRounding = 7.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ChildWindowRounding = 4.0
    style.FrameRounding = 5.0
    style.ItemSpacing = imgui.ImVec2(7.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

      colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
      colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
      colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
      colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
      colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
      colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
      colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
      colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
      colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
      colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
      colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
      colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
      colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
      colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
      colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
      colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
      colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.CheckMark] = ImVec4(0.85, 0.85, 0.85, 0.65)
      colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
      colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
      colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.ButtonHovered] = ImVec4(0.09, 0.12, 0.14, 0.65)
      colors[clr.ButtonActive] = ImVec4(0.09, 0.12, 0.14, 0.84)
      colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
      colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
      colors[clr.HeaderActive] = ImVec4(0.11, 0.15, 0.17, 1.00)
      colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
      colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
      colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
      colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
      colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
      colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
      colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
      colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
      colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
      colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
      colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
      colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
            ffgoodcolor = 'ECECEC' 
    ffbadcolor = 'B6B6B6' 
    goodcolor = '{ECECEC}' 
    badcolor = '{B6B6B6}' 
    tag = badcolor..'[Shapez]: {FFFFFF}' 
    gtag = goodcolor..'[Shapez]: {FFFFFF}'
    end,
}
styles[temki.v]()

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end

function imgui.Hint(str_id, hint, delay, width)
        local hovered = imgui.IsItemHovered()
        local col = imgui.GetStyle().Colors[imgui.Col.ButtonHovered]
        local animTime = 0.2
        local delay = delay or 0.00
        local show = true

        if not allHints then allHints = {} end
        if not allHints[str_id] then
            allHints[str_id] = {
                status = false,
                timer = 0
            }
        end

        if hovered then
            for k, v in pairs(allHints) do
                if k ~= str_id and os.clock() - v.timer <= animTime  then
                    show = false
                end
            end
        end

        if show and allHints[str_id].status ~= hovered then
            allHints[str_id].status = hovered
            allHints[str_id].timer = os.clock() + (hovered == false and 0.00 or delay)
        end

        local showHint = function(text, alpha, max_width)
            imgui.PushStyleVar(imgui.StyleVar.Alpha, alpha)
            imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 5)
            imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
            imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.15, 0.15, 0.15, 1.00))
            imgui.BeginTooltip()
            imgui.PushTextWrapPos(max_width or 450)
            imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 0))
            imgui.TextColoredRGB(u8:decode(text))
            imgui.PopStyleVar()
            imgui.PopTextWrapPos()
            imgui.EndTooltip()
            imgui.PopStyleColor()
            imgui.PopStyleVar(3)
        end

        if show then
            local btw = os.clock() - allHints[str_id].timer
            if btw <= animTime then
                local s = function(f) 
                    return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
                end
                local alpha = hovered and s(btw / animTime) or s(1.00 - btw / animTime)
                showHint(hint, alpha, width)
            elseif hovered then
                showHint(hint, 1.00, width)
            end
        end
end

function imgui.OnDrawFrame()
    if main_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(480, 360), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Shapez | '..version..' | Activation: F11##main', main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
           imgui.SetWindowPos(imgui.ImVec2(mX / 3, mY / 3), imgui.Cond.FirstUseEver)
            imgui.BeginChild('top', imgui.ImVec2(465, 95), true) 
                imgui.PushFont(fa_font2)
                if imgui.Button(fa.ICON_FA_COGS ..u8'', imgui.ImVec2(107, 78)) then menu = 1
                elseif imgui.Button(fa.ICON_FA_PLUS ..u8'', imgui.ImVec2(107, 78), imgui.SameLine()) then menu = 2
                elseif imgui.Button(fa.ICON_FA_CROWN ..u8'', imgui.ImVec2(107, 78), imgui.SameLine()) and (supremeMode or arenaMode) then menu = 3
                elseif imgui.Button(fa.ICON_FA_ADJUST ..u8'', imgui.ImVec2(107, 78), imgui.SameLine()) then menu = 4 end
                imgui.PopFont()
            imgui.EndChild()
            imgui.BeginChild('bot', imgui.ImVec2(465, 226), true) 
            if menu == 1 then
                if imgui.Checkbox(u8'Таймер ввода капчи', imgui.ImBool(config.main.timer)) then config.main.timer = not config.main.timer end
                if imgui.Checkbox(u8'Время ввода в строке с покупкой дома/бизнеса', imgui.ImBool(config.main.jt)) then config.main.jt = not config.main.jt end
                if imgui.Checkbox(u8'Перекраска сообщений о покупке дома/бизнеса', imgui.ImBool(config.main.recolor)) then config.main.recolor = not config.main.recolor end
                if imgui.Checkbox(u8'Сообщение в чат после покупки имущества', imgui.ImBool(config.main.msg)) then config.main.msg = not config.main.msg end

                if config.main.msg then
                        if imgui.InputText('##1', buffer) then
                            config.main.text = string.format('%s', tostring(buffer.v))
                        end
                    if imgui.Checkbox(u8'Добавлять время во фразу', imgui.ImBool(config.main.texttime)) then config.main.texttime = not config.main.texttime end 
                    if imgui.Checkbox(u8'Добавлять капчу во фразу', imgui.ImBool(config.main.textcap)) then config.main.textcap = not config.main.textcap end 
                end
                if imgui.Checkbox(u8'Укороченные команды поиска домов/бизнесов', imgui.ImBool(config.main.shorten)) then config.main.shorten = not config.main.shorten end

                if config.main.shorten then
                    imgui.SameLine()
                    if imgui.Button(fa.ICON_FA_TRASH ..u8'') then 
                        sampAddChatMessage(tag ..'Укороченные команды удалены!', -1) 
                        sampUnregisterChatCommand(config.commands.fhc) 
                        sampUnregisterChatCommand(config.commands.fbc) 
                    end
                    imgui.SameLine()
                    if imgui.Button(fa.ICON_FA_SAVE ..u8'') then 
                        sampAddChatMessage(tag ..'Укороченные команды добавлены!', -1) 
                        sampRegisterChatCommand(config.commands.fhc, function(num) sampSendChat('/findihouse '..num) end) 
                        sampRegisterChatCommand(config.commands.fbc, function(num) sampSendChat('/findibiz '..num) end)
                    end
                    imgui.PushItemWidth(80)
                    if imgui.InputText('##7', fhb) then
                        config.commands.fhc = string.format('%s', tostring(fhb.v))
                    end
					imgui.PopItemWidth()
                    imgui.SameLine()
                    imgui.PushItemWidth(80)
                    if imgui.InputText('##8', fbb) then
                        config.commands.fbc = string.format('%s', tostring(fbb.v))
                    end
					imgui.PopItemWidth()
                end
            end
            if menu == 2 then
                if imgui.Checkbox(u8'Тренировка капчи', imgui.ImBool(config.main.captrain)) then config.main.captrain = not config.main.captrain end 
                if config.main.captrain then 
                    imgui.SameLine()
                    ia.HotKey('##captrain', trainkey, {}, 100)
                    imgui.PushItemWidth(120)
                    imgui.SameLine()
                    imgui.Combo('##1', result, modes, #modes)
                    if result.v == 0 then config.main.trainmode = 'old'
                        elseif result.v == 1 then config.main.trainmode = 'new'
                        elseif result.v == 2 and (arenaMode or supremeMode) then config.main.trainmode = 'supreme'
						elseif result.v == 2 and locked then result.v = 1 config.main.trainmode = 'new'
                    end
					imgui.PopItemWidth()
                end
                if imgui.Checkbox(u8'Антирванка', imgui.ImBool(config.main.ar)) then config.main.ar = not config.main.ar end 
                if config.main.ar then
                    imgui.SameLine()
                    imgui.PushItemWidth(110)
                    if imgui.InputText('##2', arbuf) then
                        config.commands.arc = string.format('%s', tostring(arbuf.v))
                    end
					imgui.PopItemWidth()
                end
                if imgui.Checkbox(u8'Удаление людей', imgui.ImBool(config.main.delp)) then config.main.delp = not config.main.delp end  
                if config.main.delp then
                    imgui.SameLine()
                    imgui.PushItemWidth(90)
                    if imgui.InputText('##3', delpbuf) then
                        config.commands.delpc = string.format('%s', tostring(delpbuf.v))
                    end
					imgui.PopItemWidth()
					imgui.SameLine()
					if imgui.Checkbox(u8'', imgui.ImBool(config.main.newdelp)) then config.main.newdelp = not config.main.newdelp end
					imgui.Hint('delplayersss', u8'Удаляет людей до тех пор, пока вы не отключите удаление командой /'..config.commands.delpc..'') 
                end
                if imgui.Checkbox(u8'Удаление машин', imgui.ImBool(config.main.delc)) then config.main.delc = not config.main.delc end 
                if config.main.delc then
                    imgui.SameLine()
                    imgui.PushItemWidth(90)
                    if imgui.InputText('##4', delcbuf) then
                        config.commands.delcc = string.format('%s', tostring(delcbuf.v))
                    end
					imgui.PopItemWidth()
					imgui.SameLine()
					if imgui.Checkbox(' ', imgui.ImBool(config.main.newdelc)) then config.main.newdelc = not config.main.newdelc end 
					imgui.Hint('delcarssss', u8'Удаляет машины до тех пор, пока вы не отключите удаление командой /'..config.commands.delcc..'\nНе рекомендуем включать при игре, только на слетах') 					
                end
                if imgui.Checkbox(u8'Изменение прорисовки', imgui.ImBool(config.main.fd)) then config.main.fd = not config.main.fd end 
                if config.main.fd then
                    imgui.SameLine()
                    imgui.PushItemWidth(90)
                    if imgui.InputText('##5', fdbuf) then
                        config.commands.fdc = string.format('%s', tostring(fdbuf.v))
                    end
					imgui.PopItemWidth()
                    imgui.SameLine()
                    imgui.PushItemWidth(50)
                    if imgui.InputText('##6', distbuf) then
                        config.main.dist = string.format('%s', tostring(distbuf.v))
                    end
					imgui.PopItemWidth()
                    imgui.SameLine()
                    if imgui.Button(fa.ICON_FA_TRASH ..u8'') then sampUnregisterChatCommand(config.commands.fdc) end
                    imgui.SameLine()
                    if imgui.Button(fa.ICON_FA_SAVE ..u8'') then inicfg.save(config, "Shapez") fogdist() end
                end
                imgui.Checkbox(u8'KeyBoard', keyboard)
                if config.keyboard.active then
                    imgui.SameLine()
                    imgui.PushItemWidth(150)
                    imgui.Combo(u8'##9', keyboard_type, keyboard_modes, #keyboard_modes)
                    if keyboard_type.v == 0 then config.keyboard.mode = 0
                        elseif keyboard_type.v == 1 then config.keyboard.mode = 1
                        elseif keyboard_type.v == 2 then config.keyboard.mode = 2
                    end	
					imgui.PopItemWidth()
                    if imgui.Checkbox(u8'Перемещать клавиатуру', imgui.ImBool(config.keyboard.move)) then config.keyboard.move = not config.keyboard.move end
                end
                if imgui.Checkbox(u8'Время на экране', imgui.ImBool(config.servertime.stime)) then config.servertime.stime = not config.servertime.stime end
                if config.servertime.stime then
                    imgui.SameLine()
                    if imgui.Button(fa.ICON_FA_COGS ..u8'') then servertime.v = not servertime.v end
                end
            end
            if menu == 3 then
                if imgui.Checkbox(u8'Бинд на быстрый вызор NRG-500', imgui.ImBool(config.binds.fastnrg)) then config.binds.fastnrg = not config.binds.fastnrg end
                if config.binds.fastnrg then
                imgui.SameLine()
                ia.HotKey('##nrgkey', nrgkey, {}, 100)
                end 
                if imgui.Checkbox(u8'Бинд на быстрый спавн', imgui.ImBool(config.binds.fastspawn)) then config.binds.fastspawn = not config.binds.fastspawn end
                if config.binds.fastspawn then
                imgui.SameLine()
                ia.HotKey('##spawnkey', spawnkey, {}, 100)
                end 
                if imgui.Checkbox(u8'Бинд на быстрое пополнение 100 хп', imgui.ImBool(config.binds.fasthp)) then config.binds.fasthp = not config.binds.fasthp end
                if config.binds.fasthp then
                imgui.SameLine()
                ia.HotKey('##hpkey', hpkey, {}, 100)
                end 
                if imgui.Checkbox(u8'Бинд на быстрый флип', imgui.ImBool(config.binds.fastflip)) then config.binds.fastflip = not config.binds.fastflip end
                if config.binds.fastflip then
                imgui.SameLine()
                ia.HotKey('##flipkey', flipkey, {}, 100)
                end 
                if imgui.Checkbox(u8'Бинд на быструю заправку', imgui.ImBool(config.binds.fastfill)) then config.binds.fastfill = not config.binds.fastfill end
                if config.binds.fastfill then
                imgui.SameLine()
                ia.HotKey('##fillkey', fillkey, {}, 100)
                end 
                if supremeMode or locked then if imgui.Checkbox(u8'Бинд на быструю проверку слетов в /sletmenu', imgui.ImBool(config.binds.fastslet)) then config.binds.fastslet = not config.binds.fastslet end
				elseif arenaMode then if imgui.Checkbox(u8'Бинд на быструю телепортацию своего авто к себе', imgui.ImBool(config.binds.fastslet)) then config.binds.fastslet = not config.binds.fastslet end
				end
                if config.binds.fastslet then
                imgui.SameLine()
                ia.HotKey('##sletkey', sletkey, {}, 100)
                end
                imgui.Separator()
                imgui.Text(u8'Подсказка: випменю открывайте через /vip.\n/vipmenu отключено мною, что бы работали бинды. \nЗато там есть крутая менюшка, удобная...')
            end
            if menu == 4 then
                imgui.PushItemWidth(110)
                if imgui.Combo(u8'Темы скрипта', temki, tmodes) then styles[temki.v]() createlogo() end
				imgui.PopItemWidth()
                if imgui.Checkbox(u8'Другие цвета в логотипе', imgui.ImBool(config.main.customlogo)) then config.main.customlogo = not config.main.customlogo end
                if config.main.customlogo then
                    if imgui.Button(fa.ICON_FA_SAVE ..u8'', imgui.SameLine()) then createlogo() end
					if imgui.Button(fa.ICON_FA_TRASH ..u8'', imgui.SameLine()) then deletelogo() end
                end
                if imgui.Checkbox(u8'Анти-подкид лицензий, трейда и скиллов', imgui.ImBool(config.main.antipodkid)) then config.main.antipodkid = not config.main.antipodkid end
				if imgui.Button(u8'Выгрузить скрипт') then thisScript():unload() end
				if imgui.Button(u8'Удалить скрипт', imgui.SameLine()) then
					if doesFileExist(thisScript().filename)then
						os.remove(thisScript().filename)
					end
					if doesFileExist('moonloader\\config\\Shapez.ini') then
						os.remove('moonloader\\config\\Shapez.ini')
					end
				end
				if imgui.Button(u8'Перезапустить скрипт', imgui.SameLine()) then thisScript():reload() end
				imgui.Separator()
                imgui.Text(u8'Информация по вводу капчи:')
                imgui.Text(u8'Всего капч введено: '..config.captcha.vcode + config.captcha.ncode)
                imgui.Text(u8'Верных кодов: '..config.captcha.vcode)
                imgui.Text(u8'Неверных кодов: '..config.captcha.ncode)
                imgui.Text(u8'Рекорд ввода капчи: '..config.captcha.record)
            end
            imgui.EndChild()
        imgui.End()
    end
    if vip_window_state.v then
	    imgui.Begin(u8'Новое вип-меню', vip_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		if supremeMode then
        imgui.SetNextWindowSize(imgui.ImVec2(370, 400), imgui.Cond.FirstUseEver)
        imgui.SetWindowPos(imgui.ImVec2(mX / 3, mY / 3), imgui.Cond.FirstUseEver)
        imgui.BeginChild('vip', imgui.ImVec2(370, 365), true) 
        imgui.BeginChild('supreme', imgui.ImVec2(355, 130), true) 
        if imgui.Button(u8'Пополнить здоровье (раз в 5 минут)') then fasthp() end
        if imgui.Button(u8'Изменить префикс в вип-чате') then prefix() end
        if imgui.Button(u8'Заправить транспорт, в котором я нахожусь') then fastfill() end
        if imgui.Button(u8'Флипнуть транспорт, в котором я нахожусь') then fastflip() end
        if imgui.Button(u8'Выдать себе NRG-500') then fastnrg() end
        imgui.EndChild()
        imgui.BeginChild('solution', imgui.ImVec2(355, 60), true) 
        if imgui.Button(u8'Получить рандомный предмет  (1 раз в 3 часа)') then items() end
        if imgui.Button(u8'Заспавнить себя') then fastspawn() end
        imgui.EndChild()
        imgui.BeginChild('grandrase', imgui.ImVec2(355, 60), true) 
        if imgui.Button(u8'Получить/Продлить ADDVIP') then addvip() end
        if imgui.Button(u8'Выдать себе любой новый автомобиль') then newcars() end
        imgui.EndChild()
        imgui.BeginChild('maniac', imgui.ImVec2(355, 90), true) 
        if imgui.Button(u8'Очистить инвентарь') then clearinvent() end
        if imgui.Button(u8'Передача AZ-коинов') then tradeaz() end
		if imgui.Button(u8'Выдача AZ-рублей (каждые 24 часа от 1 до 100 рублей)') then azrub() end
        imgui.EndChild()
        imgui.EndChild()
		elseif arenaMode then
		imgui.SetNextWindowSize(imgui.ImVec2(340, 260), imgui.Cond.FirstUseEver)
        imgui.SetWindowPos(imgui.ImVec2(835, 350), imgui.Cond.FirstUseEver)
		imgui.BeginChild('arena', imgui.ImVec2(300, 230), true) 
        if imgui.Button(u8'Изменить префикс в вип-чате') then prefix() end
        if imgui.Button(u8'Заправить транспорт, в котором я нахожусь') then fastfill() end
        if imgui.Button(u8'Телепортировать свой транспорт к себе') then fastslet() end
        if imgui.Button(u8'Выдать себе NRG-500') then fastnrg() end
        if imgui.Button(u8'Посмотреть список администрации онлайн') then addvip() end
        if imgui.Button(u8'Получить рандомный предмет  (1 раз в 3 часа)') then items() end
        if imgui.Button(u8'Заспавнить себя') then fastspawn() end
        if imgui.Button(u8'Флипнуть транспорт, в котором я нахожусь') then fastflip() end
        if imgui.Button(u8'Пополнить здоровье') then fasthp() end
        imgui.EndChild()
		end
        imgui.End()
    end
    if keyboard.v then
        imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(5.0, 2.4)) -- Фикс положения клавиш
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0,0,0,0)) -- Убираем фон
        imgui.SetNextWindowPos(keyboard_pos, imgui.Cond.FirstUseEver, imgui.ImVec2(0, 0))
        imgui.Begin('##keyboard', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + (config.keyboard.move and 0 or imgui.WindowFlags.NoMove) )
            keyboard_pos = imgui.GetWindowPos()
            for i, line in ipairs(keyboards[keyboard_type.v+1]) do
                if (keyboard_type.v == 0 or keyboard_type.v == 1) and i == 4 then 
                    imgui.SetCursorPosY(68) -- fix
                elseif (keyboard_type.v == 0 or keyboard_type.v == 1) and i == 6 then 
                    imgui.SetCursorPosY(112) -- fix
                end
                for key, v in ipairs(line) do
                    local size = imgui.CalcTextSize(v[1])
                    if isKeyDown(v[2]) then
                        imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.GetStyle().Colors[imgui.Col.ButtonActive])
                    else
                        imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0,0,0,0.4))
                    end
                    imgui.BeginChild('##'..i..key, imgui.ImVec2(size.x+11, (v[1] == '\n+' or v[1] == '\nE') and size.y + 14 or size.y + 5), true)
                        imgui.Text(v[1])
                    imgui.EndChild()
                    imgui.PopStyleColor()
                    if key ~= #line then
                        imgui.SameLine()
                        if v[3] then imgui.SameLine(imgui.GetCursorPosX()+v[3]) end
                    end
                end
            end
        imgui.End()
        imgui.PopStyleColor()
        imgui.PopStyleVar()
    end
    if servertime.v then
        imgui.SetNextWindowSize(imgui.ImVec2(194, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(mX / 2, mY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8'Настройки показа времени', servertime, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse)
        imgui.Text(u8'Шрифт')
        imgui.PushItemWidth(170)
        imgui.SameLine()
            if imgui.InputText('##11', fontTimeinput) then
                config.servertime.timeFont = string.format('%s', tostring(fontTimeinput.v))
                renderTimeFont = renderCreateFont(config.servertime.timeFont, config.servertime.timeSize, config.servertime.timeStyle)
            end
			imgui.PopItemWidth()
            imgui.Text(u8'Стиль')
            imgui.PushItemWidth(90)
            imgui.SameLine()
            if imgui.InputInt('##12', styleTimeinput, 0, 0) then
                config.servertime.timeStyle = tonumber(styleTimeinput.v)
                renderTimeFont = renderCreateFont(config.servertime.timeFont, config.servertime.timeSize, config.servertime.timeStyle)
                inicfg.save(config, "Shapez")
            end
			imgui.PopItemWidth()
            imgui.Text(u8'Размер')
            imgui.PushItemWidth(90)
            imgui.SameLine()
            if imgui.InputInt('##13', sizeTimeinput, 0, 0) then
                config.servertime.timeSize = tonumber(sizeTimeinput.v)
                renderTimeFont = renderCreateFont(config.servertime.timeFont, config.servertime.timeSize, config.servertime.timeStyle)
                inicfg.save(config, "Shapez")
            end
            if imgui.ColorEdit3(u8'Цвет времени', timeColour, imgui.ColorEditFlags.NoInputs) then
                config.servertime.timeR = timeColour.v[1]*255
                config.servertime.timeG = timeColour.v[2]*255
                config.servertime.timeB = timeColour.v[3]*255
                colorOfTime = join_argb(255, config.servertime.timeR, config.servertime.timeG, config.servertime.timeB)
                inicfg.save(config, "Shapez")
            end
			imgui.PopItemWidth()
            if imgui.Button(u8'Изменить расположение') then servertime.v = false changePos = true sampAddChatMessage(gtag ..'Измените расположение времени курсором мыши и нажмите ЛКМ', -1) end
            if styleTimeinput.v < 0 then styleTimeinput.v = 0 end
            if sizeTimeinput.v < 0 then sizeTimeinput.v = 0 end
        imgui.End()
    end
end

keyboards = {
    { -- Только цифры
        {
            {'1', 0x31},
            {'2', 0x32},
            {'3', 0x33},
            {'4', 0x34},
            {'5', 0x35},
            {'6', 0x36},
            {'7', 0x37},
            {'8', 0x38},
            {'9', 0x39},
            {'0', 0x30},
        },
        {
            {'N', 0x4E},
            {' Enter ', 0x0D},
        }
    },
    { -- Компактные цифры
        {
            {'1', 0x31},
            {'2', 0x32},
            {'3', 0x33},
        },
        {
            {'4', 0x34},
            {'5', 0x35},
            {'6', 0x36},
        },
        {
            {'7', 0x37},
            {'8', 0x38},
            {'9', 0x39},
        },
        {

            {'0', 0x30},
            {'N', 0x4E},
        },
        {
            {' Enter ', 0x0D},
        }
    },
    { -- Только NumPad
        {
            {'7', 0x67},
            {'8', 0x68},
            {'9', 0x69},
        },
        {
            {'4', 0x64},
            {'5', 0x65},
            {'6', 0x66},
        },
        {
            {'1', 0x61},
            {'2', 0x62},
            {'3', 0x63},
            {'E', 0x0D},
        },
        {
            {'0       ', 0x60},
            {'N', 0x4E},
        }
    }
}

function showCaptcha()
    removeNewTextdraws()
    t = t + 1
    sampTextdrawCreate(t, "LD_SPAC:white", 240, 124)
    sampTextdrawSetLetterSizeAndColor(t, 0, 5.6, 0x80808080)
    sampTextdrawSetBoxColorAndSize(t, 1, 0xFF1A2432, 398, 0.000000)
       
    t = t + 1
    sampTextdrawCreate(t, "LD_SPAC:white", 242, 127)
    sampTextdrawCreate(t, "LD_SPAC:white", 242, 127)
    sampTextdrawSetLetterSizeAndColor(t, 0, 5, 0x80808080)
    sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, 396, 0.000000)
    nextPos = -30.0;
       
    math.randomseed(os.time())
    for i = 1, 4 do
        a = math.random(0, 9)
        table.insert(captchaTable, a)
        captcha = captcha..a
    end
       
    for i = 0, 4 do
        nextPos = nextPos + 30
        t = t + 1
        sampTextdrawCreate(t, "usebox", 259 + nextPos, 131)
        sampTextdrawSetLetterSizeAndColor(t, 0, 4.3, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF1A2432, 30, 25)
        sampTextdrawSetAlign(t, 2)
        if i < 4 then GenerateTextDraw(captchaTable[i + 1], 259 + nextPos, 131, 3 + i * 2)
        else GenerateTextDraw(0, 259 + nextPos, 131, 3 + i * 10) end 
    end
    captchaTable = {}
    sampShowDialog(8812, '{F89168}Проверка на робота', '{FFFFFF}Введите {C6FB4A}5{FFFFFF} символов, которые\nвидно на {C6FB4A}вашем{FFFFFF} экране.', 'Принять', 'Отмена', 1)
    captime = os.clock()
end

function removeNewTextdraws()
  if t > 0 then
    for i = 1, t do sampTextdrawDelete(i) end
    t = 0
    captcha = ''
    captime = nil
  end
end

function GenerateTextDraw(id, PosX, PosY)
  if id == 0 then
    t = t + 1
    sampTextdrawCreate(t, "LD_SPAC:white", PosX - 5, PosY + 5)
    sampTextdrawSetLetterSizeAndColor(t, 0, 3.2, 0x80808080)
    sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX+8, 0.000000)
  elseif id == 1 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then offsetX = 2; offsetBX = 17 else offsetX = -3; offsetBX = -17; end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX - offsetX, PosY)
        sampTextdrawSetLetterSizeAndColor(t, 0, 4.4, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-offsetBX, 0.000000)
    end
  elseif id == 2 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then offsetX = -8; offsetY = 6 offsetBX = 16 else offsetX = 6; offsetY = 25 offsetBX = -15; end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX - offsetX, PosY + offsetY)
        sampTextdrawSetLetterSizeAndColor(t, 0, 0.85, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-offsetBX, 0.000000)
    end
  elseif id == 3 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then size = 1.1; offsetY = 6 else size = 1; offsetY = 25 end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX+10, PosY+offsetY)
        sampTextdrawSetLetterSizeAndColor(t, 0, size, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-16.5, 0.000000)
    end
  elseif id == 4 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then size = 1.7; offsetX = -10; offsetY = 0 offsetBX = 7 else size = 1.55; offsetX = -10; offsetY = 25 offsetBX = 16; end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX - offsetX, PosY + offsetY)
        sampTextdrawSetLetterSizeAndColor(t, 0, size, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-offsetBX, 0.000000)
    end
  elseif id == 5 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then size = 0.9; offsetX = 6; offsetY = 7 offsetBX = -15 else size = 0.8; offsetX = -10; offsetY = 26 offsetBX = 16; end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX - offsetX, PosY + offsetY)
        sampTextdrawSetLetterSizeAndColor(t, 0, size, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-offsetBX, 0.000000)
    end
  elseif id == 6 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then size = 1; offsetX = 7.5; offsetY = 7 offsetBX = -15 else size = 1; offsetX = -10; offsetY = 25 offsetBX = 10; end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX - offsetX, PosY + offsetY)
        sampTextdrawSetLetterSizeAndColor(t, 0, size, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-offsetBX, 0.000000)
    end
  elseif id == 7 then
    t = t + 1
    sampTextdrawCreate(t, "LD_SPAC:white", PosX - 14, PosY + 6)
    sampTextdrawSetLetterSizeAndColor(t, 0, 3.9, 0x80808080)
    sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX+7, 0.000000)
  elseif id == 8 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then size = 1.3; offsetY = 5 else size = 0.9; offsetY = 24 end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX+10, PosY+offsetY)
        sampTextdrawSetLetterSizeAndColor(t, 0, 1.1, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-10, 0.000000)
    end
  elseif id == 9 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then size = 0.9; offsetY = 7; offsetBX = 7; else size = 0.8; offsetY = 26; offsetBX = 15; end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX+10, PosY+offsetY)
        sampTextdrawSetLetterSizeAndColor(t, 0, size, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-offsetBX, 0.000000)
    end
  end
end

function showOldCaptcha()
    removeOldTextdraws()
    ot = ot + 1
    sampTextdrawCreate(ot, "LD_SPAC:white", 220, 120)
    sampTextdrawSetLetterSizeAndColor(ot, 0, 6.5, 0x80808080)
    sampTextdrawSetBoxColorAndSize(ot, 1, 0xFF1A2432, 380, 0.000000)
       
    ot = ot + 1
    sampTextdrawCreate(ot, "LD_SPAC:white", 225, 125)
    sampTextdrawSetLetterSizeAndColor(ot, 0, 5.5, 0x80808080)
    sampTextdrawSetBoxColorAndSize(ot, 1, 0xFF759DA3, 375, 0.000000)
    onextPos = -30.0;
       
    math.randomseed(os.time())
    for oi = 1, 4 do
        oa = math.random(0, 9)
        table.insert(captchaTable, oa)
        captcha = captcha..oa
    end
       
    for i = 0, 4 do
        onextPos = onextPos + 30
        ot = ot + 1
        sampTextdrawCreate(ot, "usebox", 240 + onextPos, 130)
        sampTextdrawSetLetterSizeAndColor(ot, 0, 4.5, 0x80808080)
        sampTextdrawSetBoxColorAndSize(ot, 1, 0xFF1A2432, 30, 25.000000)
        sampTextdrawSetAlign(ot, 2)
        if i < 4 then GenerateOldTextDraw(captchaTable[i + 1], 240 + onextPos, 130, 3 + i * 2)
        else GenerateOldTextDraw(0, 240 + onextPos, 130, 3 + i * 10) end
    end
    captchaTable = {}
    sampShowDialog(8812, '{F89168}Проверка на робота', '{FFFFFF}Введите {C6FB4A}5{FFFFFF} символов, которые\nвидно на {C6FB4A}вашем{FFFFFF} экране.', 'Принять', 'Отмена', 1)
    captime = os.clock()
end

function removeOldTextdraws()
  if ot > 0 then
    for oi = 1, ot do sampTextdrawDelete(oi) end
    ot = 0
    captcha = ''
    captime = nil
  end
end

function GenerateOldTextDraw(id, PosX, PosY)
  if id == 0 then
    ot = ot + 1
    sampTextdrawCreate(ot, "LD_SPAC:white", PosX - 5, PosY + 7)
    sampTextdrawSetLetterSizeAndColor(ot, 0, 3, 0x80808080)
    sampTextdrawSetBoxColorAndSize(ot, 1, 0xFF759DA3, PosX+5, 0.000000)
  elseif id == 1 then
    for oi = 0, 1 do
        ot = ot + 1
        if oi == 0 then ooffsetX = 3; ooffsetBX = 15 else ooffsetX = -3; ooffsetBX = -15; end
        sampTextdrawCreate(ot, "LD_SPAC:white", PosX - ooffsetX, PosY)
        sampTextdrawSetLetterSizeAndColor(ot, 0, 4.5, 0x80808080)
        sampTextdrawSetBoxColorAndSize(ot, 1, 0xFF759DA3, PosX-ooffsetBX, 0.000000)
    end
  elseif id == 2 then
    for oi = 0, 1 do
        ot = ot + 1
        if oi == 0 then ooffsetX = -8; ooffsetY = 7 ooffsetBX = 15 else ooffsetX = 6; ooffsetY = 25 ooffsetBX = -15; end
        sampTextdrawCreate(ot, "LD_SPAC:white", PosX - ooffsetX, PosY + ooffsetY)
        sampTextdrawSetLetterSizeAndColor(ot, 0, 0.8, 0x80808080)
        sampTextdrawSetBoxColorAndSize(ot, 1, 0xFF759DA3, PosX-ooffsetBX, 0.000000)
    end
  elseif id == 3 then
    for oi = 0, 1 do
        ot = ot + 1
        if oi == 0 then osize = 0.8; ooffsetY = 7 else osize = 1; ooffsetY = 25 end
        sampTextdrawCreate(ot, "LD_SPAC:white", PosX+10, PosY+ooffsetY)
        sampTextdrawSetLetterSizeAndColor(ot, 0, 1, 0x80808080)
        sampTextdrawSetBoxColorAndSize(ot, 1, 0xFF759DA3, PosX-15, 0.000000)
    end
  elseif id == 4 then
    for oi = 0, 1 do
        ot = ot + 1
        if oi == 0 then osize = 1.8; ooffsetX = -10; ooffsetY = 0 ooffsetBX = 10 else osize = 2; ooffsetX = -10; ooffsetY = 25 ooffsetBX = 15; end
        sampTextdrawCreate(ot, "LD_SPAC:white", PosX - ooffsetX, PosY + ooffsetY)
        sampTextdrawSetLetterSizeAndColor(ot, 0, osize, 0x80808080)
        sampTextdrawSetBoxColorAndSize(ot, 1, 0xFF759DA3, PosX-ooffsetBX, 0.000000)
    end
  elseif id == 5 then
    for oi = 0, 1 do
        ot = ot + 1
        if oi == 0 then osize = 0.8; ooffsetX = 8; ooffsetY = 7 ooffsetBX = -15 else osize = 1; ooffsetX = -10; ooffsetY = 25 ooffsetBX = 15; end
        sampTextdrawCreate(ot, "LD_SPAC:white", PosX - ooffsetX, PosY + ooffsetY)
        sampTextdrawSetLetterSizeAndColor(ot, 0, osize, 0x80808080)
        sampTextdrawSetBoxColorAndSize(ot, 1, 0xFF759DA3, PosX-ooffsetBX, 0.000000)
    end
  elseif id == 6 then
    for oi = 0, 1 do
        ot = ot + 1
        if oi == 0 then osize = 0.8; ooffsetX = 7.5; ooffsetY = 7 ooffsetBX = -15 else osize = 1; ooffsetX = -10; ooffsetY = 25 ooffsetBX = 10; end
        sampTextdrawCreate(ot, "LD_SPAC:white", PosX - ooffsetX, PosY + ooffsetY)
        sampTextdrawSetLetterSizeAndColor(ot, 0, osize, 0x80808080)
        sampTextdrawSetBoxColorAndSize(ot, 1, 0xFF759DA3, PosX-ooffsetBX, 0.000000)
    end
  elseif id == 7 then
    ot = ot + 1
    sampTextdrawCreate(ot, "LD_SPAC:white", PosX - 13, PosY + 7)
    sampTextdrawSetLetterSizeAndColor(ot, 0, 3.75, 0x80808080)
    sampTextdrawSetBoxColorAndSize(ot, 1, 0xFF759DA3, PosX+5, 0.000000)
  elseif id == 8 then
    for oi = 0, 1 do
        ot = ot + 1
        if oi == 0 then osize = 0.8; ooffsetY = 7 else osize = 1; ooffsetY = 25 end
        sampTextdrawCreate(ot, "LD_SPAC:white", PosX+10, PosY+ooffsetY)
        sampTextdrawSetLetterSizeAndColor(ot, 0, 1, 0x80808080)
        sampTextdrawSetBoxColorAndSize(ot, 1, 0xFF759DA3, PosX-10, 0.000000)
    end
  elseif id == 9 then
    for oi = 0, 1 do
        ot = ot + 1
        if oi == 0 then osize = 0.8; ooffsetY = 6; ooffsetBX = 10; else osize = 1; ooffsetY = 25; ooffsetBX = 15; end
        sampTextdrawCreate(ot, "LD_SPAC:white", PosX+10, PosY+ooffsetY)
        sampTextdrawSetLetterSizeAndColor(ot, 0, 1, 0x80808080)
        sampTextdrawSetBoxColorAndSize(ot, 1, 0xFF759DA3, PosX-ooffsetBX, 0.000000)
    end
  end
end

function removeTextdraws()
    if config.main.trainmode == 'old' then removeOldTextdraws()
    elseif config.main.trainmode == 'new' then removeNewTextdraws()
    end
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function imgui.Link(link, text)
    text = text or link
    local tSize = imgui.CalcTextSize(text)
    local p = imgui.GetCursorScreenPos()
    local DL = imgui.GetWindowDrawList()
    local col = { 0xFFFF7700, 0xFFFF9900 }
    if imgui.InvisibleButton("##" .. link, tSize) then os.execute("explorer " .. link) end
    local color = imgui.IsItemHovered() and col[1] or col[2]
    DL:AddText(p, color, text)
    DL:AddLine(imgui.ImVec2(p.x, p.y + tSize.y), imgui.ImVec2(p.x + tSize.x, p.y + tSize.y), color)
end

function prefix()
	if not locked then
		sampSendChat('/vipmenu')
		if supremeMode then
			sampSendDialogResponse(2760, 1, 1, "")
		elseif arenaMode then
			sampSendDialogResponse(7760, 1, 0, "")
		end
	end
end

function addvip()
	if not locked then
		sampSendChat('/vipmenu')
		if supremeMode then
			sampSendDialogResponse(2760, 1, 7, "")
		elseif arenaMode then
			sampSendDialogResponse(7760, 1, 4, "")
		end
	end
end

function newcars()
	if not locked then
		sampSendChat('/vipmenu')
		sampSendDialogResponse(2760, 1, 8, "")
	end
end

function items()
	if not locked then
		sampSendChat('/vipmenu')
		if supremeMode then
			sampSendDialogResponse(2760, 1, 5, "")
		elseif arenaMode then
			sampSendDialogResponse(7760, 1, 5, "")
		end
	end
end

function fastnrg()
	if not locked then
		sampSendChat('/vipmenu')
		if supremeMode then
			sampSendDialogResponse(2760, 1, 4, "")
		elseif arenaMode then
			sampSendDialogResponse(7760, 1, 3, "")
		end
	end
end

function fastspawn()
	if not locked then
		sampSendChat('/vipmenu')
		if supremeMode then
			sampSendDialogResponse(2760, 1, 6, "")
		elseif arenaMode then
			sampSendDialogResponse(7760, 1, 6, "")
		end
	end
end

function fasthp()
	if not locked then
		sampSendChat('/vipmenu')
		if supremeMode then
			sampSendDialogResponse(2760, 1, 0, "")
		elseif arenaMode then
			sampSendDialogResponse(7760, 1, 8, "")
		end
	end
end

function fastfill()
	if not locked then
		sampSendChat('/vipmenu')
		if supremeMode then
			sampSendDialogResponse(2760, 1, 2, "")
		elseif arenaMode then
			sampSendDialogResponse(7760, 1, 1, "")
		end
	end
end

function fastflip()
	if not locked then
		sampSendChat('/vipmenu')
		if supremeMode then
			sampSendDialogResponse(2760, 1, 3, "")
		elseif arenaMode then
			sampSendDialogResponse(7760, 1, 7, "")
		end
	end
end


function fastslet()
	if not locked then
		if supremeMode then
			sampSendChat('/sletmenu')
		elseif arenaMode then
			sampSendChat('/vipmenu')
			sampSendDialogResponse(7760, 1, 2, "")
		end
	end
end

function clearinvent()
	if not locked then
		if supremeMode then
			sampSendChat('/vipmenu')
			sampSendDialogResponse(2760, 1, 9, "")
		end
	end
end

function tradeaz()
	if not locked then
		if supremeMode then
			sampSendChat('/vipmenu')
			sampSendDialogResponse(2760, 1, 10, "")
		end
	end
end

function azrub()
	if not locked then
		if supremeMode then
			sampSendChat('/vipmenu')
			sampSendDialogResponse(2760, 1, 11, "")
		end
	end
end

function emul_rpc(hook, parameters)
    local bs_io = require 'samp.events.bitstream_io'
    local handler = require 'samp.events.handlers'
    local extra_types = require 'samp.events.extra_types'
    local hooks = {

        --[[ Outgoing rpcs
        ['onSendEnterVehicle'] = { 'int16', 'bool8', 26 },
        ['onSendClickPlayer'] = { 'int16', 'int8', 23 },
        ['onSendClientJoin'] = { 'int32', 'int8', 'string8', 'int32', 'string8', 'string8', 'int32', 25 },
        ['onSendEnterEditObject'] = { 'int32', 'int16', 'int32', 'vector3d', 27 },
        ['onSendCommand'] = { 'string32', 50 },
        ['onSendSpawn'] = { 52 },
        ['onSendDeathNotification'] = { 'int8', 'int16', 53 },
        ['onSendDialogResponse'] = { 'int16', 'int8', 'int16', 'string8', 62 },
        ['onSendClickTextDraw'] = { 'int16', 83 },
        ['onSendVehicleTuningNotification'] = { 'int32', 'int32', 'int32', 'int32', 96 },
        ['onSendChat'] = { 'string8', 101 },
        ['onSendClientCheckResponse'] = { 'int8', 'int32', 'int8', 103 },
        ['onSendVehicleDamaged'] = { 'int16', 'int32', 'int32', 'int8', 'int8', 106 },
        ['onSendEditAttachedObject'] = { 'int32', 'int32', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 116 },
        ['onSendEditObject'] = { 'bool', 'int16', 'int32', 'vector3d', 'vector3d', 117 },
        ['onSendInteriorChangeNotification'] = { 'int8', 118 },
        ['onSendMapMarker'] = { 'vector3d', 119 },
        ['onSendRequestClass'] = { 'int32', 128 },
        ['onSendRequestSpawn'] = { 129 },
        ['onSendPickedUpPickup'] = { 'int32', 131 },
        ['onSendMenuSelect'] = { 'int8', 132 },
        ['onSendVehicleDestroyed'] = { 'int16', 136 },
        ['onSendQuitMenu'] = { 140 },
        ['onSendExitVehicle'] = { 'int16', 154 },
        ['onSendUpdateScoresAndPings'] = { 155 },
        ['onSendGiveDamage'] = { 'int16', 'float', 'int32', 'int32', 115 },
        ['onSendTakeDamage'] = { 'int16', 'float', 'int32', 'int32', 115 },]]

        -- Incoming rpcs
        ['onInitGame'] = { 139 },
        ['onPlayerJoin'] = { 'int16', 'int32', 'bool8', 'string8', 137 },
        ['onPlayerQuit'] = { 'int16', 'int8', 138 },
        ['onRequestClassResponse'] = { 'bool8', 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 128 },
        ['onRequestSpawnResponse'] = { 'bool8', 129 },
        ['onSetPlayerName'] = { 'int16', 'string8', 'bool8', 11 },
        ['onSetPlayerPos'] = { 'vector3d', 12 },
        ['onSetPlayerPosFindZ'] = { 'vector3d', 13 },
        ['onSetPlayerHealth'] = { 'float', 14 },
        ['onTogglePlayerControllable'] = { 'bool8', 15 },
        ['onPlaySound'] = { 'int32', 'vector3d', 16 },
        ['onSetWorldBounds'] = { 'float', 'float', 'float', 'float', 17 },
        ['onGivePlayerMoney'] = { 'int32', 18 },
        ['onSetPlayerFacingAngle'] = { 'float', 19 },
        --['onResetPlayerMoney'] = { 20 },
        --['onResetPlayerWeapons'] = { 21 },
        ['onGivePlayerWeapon'] = { 'int32', 'int32', 22 },
        --['onCancelEdit'] = { 28 },
        ['onSetPlayerTime'] = { 'int8', 'int8', 29 },
        ['onSetToggleClock'] = { 'bool8', 30 },
        ['onPlayerStreamIn'] = { 'int16', 'int8', 'int32', 'vector3d', 'float', 'int32', 'int8', 32 },
        ['onSetShopName'] = { 'string256', 33 },
        ['onSetPlayerSkillLevel'] = { 'int16', 'int32', 'int16', 34 },
        ['onSetPlayerDrunk'] = { 'int32', 35 },
        ['onCreate3DText'] = { 'int16', 'int32', 'vector3d', 'float', 'bool8', 'int16', 'int16', 'encodedString4096', 36 },
        --['onDisableCheckpoint'] = { 37 },
        ['onSetRaceCheckpoint'] = { 'int8', 'vector3d', 'vector3d', 'float', 38 },
        --['onDisableRaceCheckpoint'] = { 39 },
        --['onGamemodeRestart'] = { 40 },
        ['onPlayAudioStream'] = { 'string8', 'vector3d', 'float', 'bool8', 41 },
        --['onStopAudioStream'] = { 42 },
        ['onRemoveBuilding'] = { 'int32', 'vector3d', 'float', 43 },
        ['onCreateObject'] = { 44 },
        ['onSetObjectPosition'] = { 'int16', 'vector3d', 45 },
        ['onSetObjectRotation'] = { 'int16', 'vector3d', 46 },
        ['onDestroyObject'] = { 'int16', 47 },
        ['onPlayerDeathNotification'] = { 'int16', 'int16', 'int8', 55 },
        ['onSetMapIcon'] = { 'int8', 'vector3d', 'int8', 'int32', 'int8', 56 },
        ['onRemoveVehicleComponent'] = { 'int16', 'int16', 57 },
        ['onRemove3DTextLabel'] = { 'int16', 58 },
        ['onPlayerChatBubble'] = { 'int16', 'int32', 'float', 'int32', 'string8', 59 },
        ['onUpdateGlobalTimer'] = { 'int32', 60 },
        ['onShowDialog'] = { 'int16', 'int8', 'string8', 'string8', 'string8', 'encodedString4096', 61 },
        ['onDestroyPickup'] = { 'int32', 63 },
        ['onLinkVehicleToInterior'] = { 'int16', 'int8', 65 },
        ['onSetPlayerArmour'] = { 'float', 66 },
        ['onSetPlayerArmedWeapon'] = { 'int32', 67 },
        ['onSetSpawnInfo'] = { 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 68 },
        ['onSetPlayerTeam'] = { 'int16', 'int8', 69 },
        ['onPutPlayerInVehicle'] = { 'int16', 'int8', 70 },
        --['onRemovePlayerFromVehicle'] = { 71 },
        ['onSetPlayerColor'] = { 'int16', 'int32', 72 },
        ['onDisplayGameText'] = { 'int32', 'int32', 'string32', 73 },
        --['onForceClassSelection'] = { 74 },
        ['onAttachObjectToPlayer'] = { 'int16', 'int16', 'vector3d', 'vector3d', 75 },
        ['onInitMenu'] = { 76 },
        ['onShowMenu'] = { 'int8', 77 },
        ['onHideMenu'] = { 'int8', 78 },
        ['onCreateExplosion'] = { 'vector3d', 'int32', 'float', 79 },
        ['onShowPlayerNameTag'] = { 'int16', 'bool8', 80 },
        ['onAttachCameraToObject'] = { 'int16', 81 },
        ['onInterpolateCamera'] = { 'bool', 'vector3d', 'vector3d', 'int32', 'int8', 82 },
        ['onGangZoneStopFlash'] = { 'int16', 85 },
        ['onApplyPlayerAnimation'] = { 'int16', 'string8', 'string8', 'bool', 'bool', 'bool', 'bool', 'int32', 86 },
        ['onClearPlayerAnimation'] = { 'int16', 87 },
        ['onSetPlayerSpecialAction'] = { 'int8', 88 },
        ['onSetPlayerFightingStyle'] = { 'int16', 'int8', 89 },
        ['onSetPlayerVelocity'] = { 'vector3d', 90 },
        ['onSetVehicleVelocity'] = { 'bool8', 'vector3d', 91 },
        ['onServerMessage'] = { 'int32', 'string32', 93 },
        ['onSetWorldTime'] = { 'int8', 94 },
        ['onCreatePickup'] = { 'int32', 'int32', 'int32', 'vector3d', 95 },
        ['onMoveObject'] = { 'int16', 'vector3d', 'vector3d', 'float', 'vector3d', 99 },
        ['onEnableStuntBonus'] = { 'bool', 104 },
        ['onTextDrawSetString'] = { 'int16', 'string16', 105 },
        ['onSetCheckpoint'] = { 'vector3d', 'float', 107 },
        ['onCreateGangZone'] = { 'int16', 'vector2d', 'vector2d', 'int32', 108 },
        ['onPlayCrimeReport'] = { 'int16', 'int32', 'int32', 'int32', 'int32', 'vector3d', 112 },
        ['onGangZoneDestroy'] = { 'int16', 120 },
        ['onGangZoneFlash'] = { 'int16', 'int32', 121 },
        ['onStopObject'] = { 'int16', 122 },
        ['onSetVehicleNumberPlate'] = { 'int16', 'string8', 123 },
        ['onTogglePlayerSpectating'] = { 'bool32', 124 },
        ['onSpectatePlayer'] = { 'int16', 'int8', 126 },
        ['onSpectateVehicle'] = { 'int16', 'int8', 127 },
        ['onShowTextDraw'] = { 134 },
        ['onSetPlayerWantedLevel'] = { 'int8', 133 },
        ['onTextDrawHide'] = { 'int16', 135 },
        ['onRemoveMapIcon'] = { 'int8', 144 },
        ['onSetWeaponAmmo'] = { 'int8', 'int16', 145 },
        ['onSetGravity'] = { 'float', 146 },
        ['onSetVehicleHealth'] = { 'int16', 'float', 147 },
        ['onAttachTrailerToVehicle'] = { 'int16', 'int16', 148 },
        ['onDetachTrailerFromVehicle'] = { 'int16', 149 },
        ['onSetWeather'] = { 'int8', 152 },
        ['onSetPlayerSkin'] = { 'int32', 'int32', 153 },
        ['onSetInterior'] = { 'int8', 156 },
        ['onSetCameraPosition'] = { 'vector3d', 157 },
        ['onSetCameraLookAt'] = { 'vector3d', 'int8', 158 },
        ['onSetVehiclePosition'] = { 'int16', 'vector3d', 159 },
        ['onSetVehicleAngle'] = { 'int16', 'float', 160 },
        ['onSetVehicleParams'] = { 'int16', 'int16', 'bool8', 161 },
        --['onSetCameraBehind'] = { 162 },
        ['onChatMessage'] = { 'int16', 'string8', 101 },
        ['onConnectionRejected'] = { 'int8', 130 },
        ['onPlayerStreamOut'] = { 'int16', 163 },
        ['onVehicleStreamIn'] = { 164 },
        ['onVehicleStreamOut'] = { 'int16', 165 },
        ['onPlayerDeath'] = { 'int16', 166 },
        ['onPlayerEnterVehicle'] = { 'int16', 'int16', 'bool8', 26 },
        ['onUpdateScoresAndPings'] = { 'PlayerScorePingMap', 155 },
        ['onSetObjectMaterial'] = { 84 },
        ['onSetObjectMaterialText'] = { 84 },
        ['onSetVehicleParamsEx'] = { 'int16', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 24 },
        ['onSetPlayerAttachedObject'] = { 'int16', 'int32', 'bool', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 113 }

    }
    local handler_hook = {
        ['onInitGame'] = true,
        ['onCreateObject'] = true,
        ['onInitMenu'] = true,
        ['onShowTextDraw'] = true,
        ['onVehicleStreamIn'] = true,
        ['onSetObjectMaterial'] = true,
        ['onSetObjectMaterialText'] = true
    }
    local extra = {
        ['PlayerScorePingMap'] = true,
        ['Int32Array3'] = true
    }
    local hook_table = hooks[hook]
    if hook_table then
        local bs = raknetNewBitStream()
        if not handler_hook[hook] then
            local max = #hook_table-1
            if max > 0 then
                for i = 1, max do
                    local p = hook_table[i]
                    if extra[p] then extra_types[p]['write'](bs, parameters[i])
                    else bs_io[p]['write'](bs, parameters[i]) end
                end
            end
        else
            if hook == 'onInitGame' then handler.on_init_game_writer(bs, parameters)
            elseif hook == 'onCreateObject' then handler.on_create_object_writer(bs, parameters)
            elseif hook == 'onInitMenu' then handler.on_init_menu_writer(bs, parameters)
            elseif hook == 'onShowTextDraw' then handler.on_show_textdraw_writer(bs, parameters)
            elseif hook == 'onVehicleStreamIn' then handler.on_vehicle_stream_in_writer(bs, parameters)
            elseif hook == 'onSetObjectMaterial' then handler.on_set_object_material_writer(bs, parameters, 1)
            elseif hook == 'onSetObjectMaterialText' then handler.on_set_object_material_writer(bs, parameters, 2) end
        end
        raknetEmulRpcReceiveBitStream(hook_table[#hook_table], bs)
        raknetDeleteBitStream(bs)
    end
end

function delch()
	for _, handle in ipairs(getAllChars()) do
		if doesCharExist(handle) then
	        local _, id = sampGetPlayerIdByCharHandle(handle)
			local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	        if id ~= myid then
	            emul_rpc('onPlayerStreamOut', { id })
			end
		end
	end
end

function delcr()
    for k, v in pairs(getAllVehicles()) do
        if doesVehicleExist(v) and not isCharSittingInCar(PLAYER_PED, v) then
			deleteCar(v)
        end
    end
end

function gotofunc(fnc)
    if fnc == "all" then
        memory.write(5499541, 12044272, 4, false)-- ПАНОС
        memory.write(8381985, 13213544, 4, false)
    end
end

function join_argb(a, r, g, b)
    local argb = b
    argb = bit.bor(argb, bit.lshift(g, 8))
    argb = bit.bor(argb, bit.lshift(r, 16))
    argb = bit.bor(argb, bit.lshift(a, 24))
    return argb
end

function fogdist()
    if config.main.fd then
        sampRegisterChatCommand(config.commands.fdc, function(arg)
            local dist = arg:match("(%d+)")
            dist = tonumber(dist)
            if type(dist) ~= 'number' or dist > 3600 or dist < 0 then
                sampAddChatMessage(tag ..'Используйте: '..goodcolor..'/'..config.commands.fdc..' [0-3600]', -1)
            else
                config.main.dist = dist
                memory.setfloat(12044272, config.main.dist, false)
                inicfg.save(config, "Shapez")
                sampAddChatMessage(gtag ..'Установлена дальность прорисовки: '..badcolor..''..config.main.dist, -1)
            end
        end)
        memory.setfloat(12044272, config.main.dist, false)
    end
end

function create372()
    sampTextdrawCreate(372, 'A', 550, 1)
    sampTextdrawSetAlign(372, 0)
    sampTextdrawSetStyle(372, 0)
    sampTextdrawSetOutlineColor(372, 1, 0xFF000000)
    sampTextdrawSetLetterSizeAndColor(372, 0.550, 2.800, '0xFF'..ffbadcolor)
end

function create373()
    sampTextdrawCreate(373, 'RIZONA', 565, 6)
    sampTextdrawSetAlign(373, 0)
    sampTextdrawSetStyle(373, 3)
    sampTextdrawSetOutlineColor(373, 1, 0xFF000000)
    sampTextdrawSetLetterSizeAndColor(373, 0.320, 1.200, '0xFF'..ffbadcolor)
end

function create374()
    sampTextdrawCreate(374, 'Arena', 563, 14)
    sampTextdrawSetAlign(374, 0)
    sampTextdrawSetStyle(374, 2)
    sampTextdrawSetOutlineColor(374, 1, 0xFF000000)
    sampTextdrawSetLetterSizeAndColor(374, 0.170, 1.400, '0xFFFFFFFF')
end

function create25()
    sampTextdrawCreate(25, 'A', 550, 1)
    sampTextdrawSetAlign(25, 0)
    sampTextdrawSetStyle(25, 0)
    sampTextdrawSetOutlineColor(25, 1, 0xFF000000)
    sampTextdrawSetLetterSizeAndColor(25, 0.550, 2.800, '0xFF'..ffbadcolor)
end

function create26()
    sampTextdrawCreate(26, 'RIZONA', 565, 6)
    sampTextdrawSetAlign(26, 0)
    sampTextdrawSetStyle(26, 3)
    sampTextdrawSetOutlineColor(26, 1, 0xFF000000)
    sampTextdrawSetLetterSizeAndColor(26, 0.320, 1.200, '0xFF'..ffbadcolor)
end

function create27()
    sampTextdrawCreate(27, 'Supreme', 563, 14)
    sampTextdrawSetAlign(27, 0)
    sampTextdrawSetStyle(27, 2)
    sampTextdrawSetOutlineColor(27, 1, 0xFF000000)
    sampTextdrawSetLetterSizeAndColor(27, 0.170, 1.400, '0xFFFFFFFF')
end

function createlogo()
	if config.main.customlogo then
		if supremeMode then 
			sampTextdrawDelete(25) 
			sampTextdrawDelete(26) 
			sampTextdrawDelete(27) 
			create25() 
			create26() 
			create27()
		elseif arenaMode then
			sampTextdrawDelete(372) 
			sampTextdrawDelete(373) 
			sampTextdrawDelete(374) 
			create372() 
			create373() 
			create374()
		else 
		end
	end
end

function deletelogo()
	if ip == '176.32.37.28' then 
		sampTextdrawDelete(25) 
		sampTextdrawDelete(26) 
		sampTextdrawDelete(27) 
	elseif ip == '176.32.39.165' then
		sampTextdrawDelete(372) 
		sampTextdrawDelete(373) 
		sampTextdrawDelete(374)
	else
		sampTextdrawDelete(25) 
		sampTextdrawDelete(26) 
		sampTextdrawDelete(27) 
		sampTextdrawDelete(372) 
		sampTextdrawDelete(373) 
		sampTextdrawDelete(374)
	end
end

function floorStep(num, step)
    return num - num % step
end

function checkBeforeLoad()
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
			print('Список изменений: '..version_info..'')
            if tonumber(updateIni.info.version_n) > version_n then
                sampAddChatMessage(tag .."Есть обновление! Версия: " .. updateIni.info.version, -1)
				sampAddChatMessage(tag .."Список изменений скрипта находится в консоли", -1)
				print("Список изменений: "  .. updateIni.info.version_info, -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)
	if ip == '176.32.39.165' then 
		arenaMode = true 
		supremeMode = false
		locked = false
		elseif ip == '176.32.37.28' then
		supremeMode = true
		arenaMode = false
		locked = false
		else
		supremeMode = false
		arenaMode = false
		locked = true
	end
	if locked then sampAddChatMessage(tag .. 'Вы зашли на не поддерживаемый сервер, некоторые функции не работают', -1) end
	if locked and config.main.trainmode == 'supreme' then config.main.trainmode = 'new' sampAddChatMessage(tag .. 'Тип капчи в тренинге не поддерживается, установлен новый тип капчи', -1) end
    trainmode()
    if config.main.fd then 
	    gotofunc("all")
        fogdist() 
    end
end

function main()
    while not isSampAvailable() do wait(0) end
    ip, port = sampGetCurrentServerAddress()
    checkBeforeLoad() wait(500)
    renderTimeFont = renderCreateFont(config.servertime.timeFont, config.servertime.timeSize, config.servertime.timeStyle)
    colorOfTime = join_argb(255, config.servertime.timeR, config.servertime.timeG, config.servertime.timeB)
    sampAddChatMessage(tag ..'Загружен! Автор: '..goodcolor..''..author..'{ffffff}. Версия: '..goodcolor..''..version..'{ffffff}, активация: '..goodcolor..'F11.', -1)
    if config.main.shorten then
        sampRegisterChatCommand(config.commands.fhc, function(num) 
            sampSendChat('/findihouse '..num) 
        end)
        sampRegisterChatCommand(config.commands.fbc, function(num) 
            sampSendChat('/findibiz '..num) 
        end)
    end
    while true do wait(0)
        if config.servertime.stime then 
            local getTime = os.time()
            local renderTime = os.date("%H:%M:%S", getTime)
            if changePos then
            showCursor(true)
            local cX, cY = getCursorPos()
            renderFontDrawText(renderTimeFont, renderTime, cX, cY, 0xFFFFFFFF, false)
            if isKeyJustPressed(vkeys.VK_LBUTTON) then
                config.servertime.timeX = cX
                config.servertime.timeY = cY 
                changePos = false
                sampAddChatMessage(gtag ..'Расположение времени сохранено', -1)
                showCursor(false)
            end
            else
            renderFontDrawText(renderTimeFont, renderTime, config.servertime.timeX, config.servertime.timeY, colorOfTime, false)
            end
        end
        if isKeyJustPressed(122) then
            main_window_state.v = not main_window_state.v
        end
        local result, button, list, input = sampHasDialogRespond(8812)
        if result then
            if button == 1 then
                if input == captcha..'0' then sampAddChatMessage(string.format(gtag ..'{ffffff}Код верный [%.3f]', os.clock() - captime), -1)
                config.captcha.vcode = config.captcha.vcode + 1 
                if os.clock() - captime < config.captcha.record or config.captcha.record == 0 then
                    config.captcha.record = floorStep(os.clock() - captime, 0.001)
                    sampAddChatMessage(gtag ..'Новый рекорд ввода капчи: '..goodcolor..''..config.captcha.record..' {ffffff}сек!', -1)
                end
                elseif input ~= captcha..'0' then sampAddChatMessage(string.format(tag ..'{ffffff}Неверный код! [%.3f] ('..captcha..'0|'..input..')', os.clock() - captime), -1) 
                    config.captcha.ncode = config.captcha.ncode + 1 
                end
            end
            removeTextdraws()
        end
        if not sampIsCursorActive() and isPlayerPlaying(playerHandle) then
            if config.main.captrain then 
                if isKeysDown(trainkey.v) then
                    if config.main.trainmode == 'old' then showOldCaptcha()
                    elseif config.main.trainmode == 'new' then showCaptcha()
                    elseif config.main.trainmode == 'supreme' then sampSendChat('/captcha') 
                    end
                end
            end
            
            if config.binds.fastnrg and not isCharSittingInAnyCar(PLAYER_PED) then 
                if isKeysDown(nrgkey.v) then
                    fastnrg() 
                end
            end
            if config.binds.fastspawn then 
                if isKeysDown(spawnkey.v) then
                    fastspawn() 
                end
            end
            if config.binds.fasthp then 
                if isKeysDown(hpkey.v) then
                    fasthp() 
                end
            end
            if config.binds.fastfill then 
                if isKeysDown(fillkey.v) then
                    fastfill() 
                end
            end
            if config.binds.fastslet then 
                if isKeysDown(sletkey.v) then
                    fastslet() 
                end
            end
            if config.binds.fastflip then 
                if isKeysDown(flipkey.v) then
                    fastflip() 
                end
            end
        end
        config.binds.nrgkey = encodeJson(nrgkey.v)
        config.binds.trainkey = encodeJson(trainkey.v)
        config.binds.spawnkey = encodeJson(spawnkey.v)
        config.binds.hpkey = encodeJson(hpkey.v)
        config.binds.fillkey = encodeJson(fillkey.v)
        config.binds.flipkey = encodeJson(flipkey.v)
        config.binds.sletkey = encodeJson(sletkey.v)
        config.keyboard.active = keyboard.v
        imgui.ShowCursor = main_window_state.v or vip_window_state.v or servertime.v
        imgui.Process = main_window_state.v or vip_window_state.v or keyboard.v or servertime.v
    end
end

function ev.onUnoccupiedSync()
if not sync then return false end
end

function ev.onVehicleSync()
if not sync then return false end
end

function ev.onPassengerSync()
if not sync then return false end
end

function ev.onSendCommand(int)
    if int == '/vip' and (arenaMode or supremeMode) and not locked then vip_window_state.v = not vip_window_state.v return false end
    if int == '/'..config.commands.arc..'' and config.main.ar then sync = not sync sampAddChatMessage(sync and gtag ..'Синхронизация включена' or tag ..'Синхронизация выключена', -1) return false end
    if int == '/'..config.commands.delpc..'' and config.main.delp then 
		if config.main.delp and config.main.newdelp then
			delplayers = not delplayers
			delch() 
			sampAddChatMessage(tag ..'Постоянное удаление людей '..(delplayers and 'активировано' or 'деактивировано'), -1)
		elseif config.main.delp and not config.main.newdelp then
			delch()
		end
	return false 
	end
    if int == '/'..config.commands.delcc..'' then 
		if config.main.delc and config.main.newdelc and not isCharSittingInAnyCar(PLAYER_PED) then
			delcars = not delcars
			delcr() 
			sampAddChatMessage(tag ..'Постоянное удаление машин '..(delcars and 'активировано' or 'деактивировано'), -1)
		elseif config.main.delc and not config.main.newdelc and not isCharSittingInAnyCar(PLAYER_PED) then
			delcr()
		end
	return false
	end
end

function ev.onShowDialog(id, style, title, b1, b2, text)
    if config.main.antipodkid then
        if id == 7372 and title:find("Торговля") then return false end
        if title:find("Паспорт") then return false end
        if title:find("Лицензии") then return false end
        if title:find("Статистика") and text:find("Навык стрельбы игрока") then return false end
		if text:find('День Прибыль') then return false end
        if text:find('дал вам копию ключей от транспорта') then return false end
    end
    if id == 2760 and supremeMode and not locked then 
		if title:find("{BFBBBA}{ffffff}Arizona Supreme | {9758fc}VIP{ffffff} MENU") then 
			return false 
		end
	end
	if id == 7760 and arenaMode and not locked then
		if title:find("Выбор") then 
			return false 
		end
	end
    if title:find("Проверка на робота") then
    did = id
    start = os.clock()
    end
end

function ev.onSendDialogResponse(id, but, lis, input)
  if id == did then
    time = os.clock() - start
    time1 = string.format("%.3f", time)
  if config.main.timer then
    sampAddChatMessage(tag ..'Вы ввели капчу: '.. goodcolor ..'['..input..']{FFFFFF}, таймер ввода: '.. goodcolor ..'['..time1..']{FFFFFF}', -1)
    end
  end
end

function ev.onPlayerStreamIn()
	if delplayers then
		return false
	end
end

function ev.onVehicleStreamIn()
	if delcars then
		return false
	end
end

function ev.onServerMessage(color, text)
  if text:find('этот бизнес ваш!') and color == 1941201407 then
    config.captcha.vcode = config.captcha.vcode + 1
    if time < config.captcha.record or config.captcha.record == 0 then
        config.captcha.record = floorStep(time, 0.001)
        sampAddChatMessage(gtag ..'Новый рекорд ввода капчи: '..goodcolor..''..config.captcha.record..' {ffffff}сек!', -1)
    end
    if config.main.msg then
        if config.main.texttime and config.main.textcap then sampSendChat(u8:decode(string.format('%s [%.3f] ['..sampGetCurrentDialogEditboxText()..']', config.main.text, time)))
            elseif config.main.texttime then sampSendChat(u8:decode(string.format('%s [%.3f]', config.main.text, time)))
            elseif config.main.textcap then sampSendChat(u8:decode(string.format('%s ['..sampGetCurrentDialogEditboxText()..']', config.main.text)))
        else sampSendChat(u8:decode(config.main.text)) end
    end
    if config.main.recolor and config.main.jt then 
      sampAddChatMessage(string.format(goodcolor ..'[Информация] {FFFFFF}Поздравляю! Теперь этот бизнес ваш! [%.3f]', time), -1)
      return false
  elseif config.main.jt then 
      sampAddChatMessage(string.format('{73B461}[Информация] {FFFFFF}Поздравляю! Теперь этот бизнес ваш! [%.3f]', time), -1)
      return false
  elseif config.main.recolor then
        sampAddChatMessage(goodcolor ..'[Информация] {FFFFFF}Поздравляю! Теперь этот бизнес ваш!', -1)
        return false
    end
  end
  if text:find('этот дом ваш!') and color == 1941201407 then 
    config.captcha.vcode = config.captcha.vcode + 1
    if time < config.captcha.record or config.captcha.record == 0 then
        config.captcha.record = floorStep(time, 0.001)
        sampAddChatMessage(gtag ..'Новый рекорд ввода капчи: '..goodcolor..''..config.captcha.record..' {ffffff}сек!', -1)
    end
    if config.main.msg then
        if config.main.texttime and config.main.textcap then sampSendChat(u8:decode(string.format('%s [%.3f] ['..sampGetCurrentDialogEditboxText()..']', config.main.text, time)))
            elseif config.main.texttime then sampSendChat(u8:decode(string.format('%s [%.3f]', config.main.text, time)))
            elseif config.main.textcap then sampSendChat(u8:decode(string.format('%s ['..sampGetCurrentDialogEditboxText()..']', config.main.text)))
        else sampSendChat(u8:decode(config.main.text)) end
    end
    if config.main.recolor and config.main.jt then 
      sampAddChatMessage(string.format(goodcolor ..'[Информация] {FFFFFF}Поздравляю! Теперь этот дом ваш! [%.3f]', time), -1)
      return false
  elseif config.main.jt then 
      sampAddChatMessage(string.format('{73B461}[Информация] {FFFFFF}Поздравляю! Теперь этот дом ваш! [%.3f]', time), -1)
      return false
  elseif config.main.recolor then
        sampAddChatMessage(goodcolor ..'[Информация] {FFFFFF}Поздравляю! Теперь этот дом ваш!', -1)
        return false
    end
  end
  if text:find('Ответ неверный!') and color == -10270721 then 
    config.captcha.ncode = config.captcha.ncode + 1
    if config.main.recolor and config.main.jt then
        sampAddChatMessage(string.format(badcolor ..'[Ошибка] {FFFFFF}Ответ неверный! [%.3f]', time), -1)
        return false
    elseif config.main.jt then
        sampAddChatMessage(string.format('{FF6347}[Ошибка] {FFFFFF}Ответ неверный! [%.3f]', time), -1)
        return false
    elseif config.main.recolor then
        sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Ответ неверный!', -1)
        return false
    end
  end
  if text:find('Неверный код!') and color == -10270721 then 
    config.captcha.ncode = config.captcha.ncode + 1
    if config.main.recolor and config.main.jt then 
        sampAddChatMessage(string.format(badcolor ..'[Ошибка] {FFFFFF}Неверный код! [%.3f]', time), -1)
        return false
    elseif config.main.jt then 
        sampAddChatMessage(string.format('{FF6347}[Ошибка] {FFFFFF}Неверный код! [%.3f]', time), -1)
        return false
    elseif config.main.recolor then
        sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Неверный код!', -1)
        return false
    end
  end
  if text:find('Этот дом уже куплен!') and color == -10270721 then 
    if config.main.recolor and config.main.jt then 
        sampAddChatMessage(string.format(badcolor ..'[Ошибка] {FFFFFF}Этот дом уже куплен! [%.3f]', time), -1)
        return false
    elseif config.main.jt then 
        sampAddChatMessage(string.format('{FF6347}[Ошибка] {FFFFFF}Этот дом уже куплен! [%.3f]', time), -1)
        return false
    elseif config.main.recolor then
        sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Этот дом уже куплен!', -1)
        return false
    end
  end
  if text:find('Этот дом уже кем то куплен!') and color == -10270721 then 
    if config.main.recolor and config.main.jt and time ~= nil then
        sampAddChatMessage(string.format(badcolor ..'[Ошибка] {FFFFFF}Этот дом уже кем то куплен! [%.3f]', time), -1)
        return false
    elseif config.main.jt and time ~= nil then
        sampAddChatMessage(string.format('{FF6347}[Ошибка] {FFFFFF}Этот дом уже кем то куплен! [%.3f]', time), -1)
        return false
    elseif config.main.recolor then
        sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Этот дом уже кем то куплен!', -1)
        return false
    end
  end
  if text:find('Этот бизнес уже кем то куплен') and (color == -10270721 or color == -1347440641) then
    if config.main.recolor and config.main.jt and time ~= nil then
        sampAddChatMessage(string.format(badcolor ..'[Ошибка] {FFFFFF}Этот бизнес уже кем то куплен! [%.3f]', time), -1)
        return false
    elseif config.main.jt and time ~= nil then
        sampAddChatMessage(string.format('{FF6347}[Ошибка] {FFFFFF}Этот бизнес уже кем то куплен! [%.3f]', time), -1)
        return false
    elseif config.main.recolor then
        sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Этот бизнес уже кем то куплен!', -1)
        return false
    end
  end
  if text:find('Не флуди!') and color == -10270721 then
    if config.main.recolor then
        sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Не флуди!', -1)
        return false
    end
  end
  if text:find('Вы успешно ввели капчу за') and (color == -65281 or color == 1941201407) then
    config.captcha.vcode = config.captcha.vcode + 1
    if time < config.captcha.record or config.captcha.record == 0 then
        config.captcha.record = floorStep(time, 0.001)
        sampAddChatMessage(gtag ..'Новый рекорд ввода капчи: '..goodcolor..''..config.captcha.record..' {ffffff}сек!', -1)
    end
    if config.main.recolor then
        sampAddChatMessage(string.format(goodcolor ..'[Информация] {FFFFFF}Вы успешно ввели капчу в тренинге! [%.3f]', time), -1)
        return false
    end
  end
  if text:find('Вы продали ваш бизнес') and color == 1941201407 then
    if config.main.recolor then
        sampAddChatMessage(goodcolor ..'[Информация] {FFFFFF}Вы продали ваш бизнес!', -1)
        return false
    end
  end
  if text:find('Вы продали ваш дом') and color == 1941201407 then
    if config.main.recolor then
        sampAddChatMessage(goodcolor ..'[Информация] {FFFFFF}Вы продали ваш дом!', -1)
        return false
    end
  end
end

function ev.onShowTextDraw(id, data)
    pX = math.modf(data.position.x)
    pY = math.modf(data.position.y)
    if config.main.customlogo then
        if pX == 550 and pY == 1 and supremeMode or arenaMode then
           createlogo()
		   if supremeMode then return false end
        end
    end
end

function onScriptTerminate(script, quitGame)
    if script == thisScript() then
        config.keyboard.x, config.keyboard.y = keyboard_pos.x, keyboard_pos.y
        config.main.theme = temki.v
        inicfg.save(config, "Shapez")
        sampUnregisterChatCommand(config.commands.fdc)
        sampUnregisterChatCommand(config.commands.fhc)
        sampUnregisterChatCommand(config.commands.fbc)
    end
end

function onQuitGame()
    config.keyboard.x, config.keyboard.y = keyboard_pos.x, keyboard_pos.y
    config.main.theme = temki.v
    inicfg.save(config, "Shapez")
end

function onWindowMessage(msg, wparam, lparam)
  if msg == 0x100 or msg == 0x101 then
    if wparam == vkeys.VK_ESCAPE and vip_window_state.v and not isPauseMenuActive() then
      consumeWindowMessage(true, false)
      vip_window_state.v = false
    end
    if wparam == vkeys.VK_ESCAPE and main_window_state.v and not isPauseMenuActive() then
      consumeWindowMessage(true, false)
      main_window_state.v = false
    end
  end
end

--61 20 73 69 6d 61 6b 20 6c 6f 78
--69 64 69 20 6e 61 78 79 69 20

--л эфшлц чъб
