local copas = require 'copas'
local http = require 'copas.http'
local mX, mY = getScreenResolution()
local script_path = thisScript().path
local inicfg = require 'inicfg'
local ev = require 'lib.samp.events'
local imgui = require 'imgui'
local mem = require 'memory'
local vkeys = require 'vkeys'
local fa = require 'fAwesome5'
local memory = require 'memory'
local ia = require "imgui_addons"
local requests = require('requests')
local effil = require("effil")
local locked = false
local arizona = false
local menu = 1
local ot = 0
local aServer = 0
local captcha = ''
local captchaTable = {}
local t = 0
local sync = true
local changePos = false
local oldVersion = false
local timeSettings = false
local resetConfig = false
local messageSettings = false
local version_n = 17
local version = '1.3k'
local author = 'blackw1ndow'
local dlstatus = require('moonloader').download_status
local script_url = 'https://raw.githubusercontent.com/blackw1ndow/shapez/main/Shapez.lua'
script_name('Shapez '..version..'')
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local modes = {u8'Обычная', u8'Новая', u8'Серверная'}
local keyboard_modes = {u8'Только цифры', u8'Компактные цифры', u8'Только NumPad'}
local tmodes = {u8'Фиолетовая', u8'Бирюзовая', u8'Красная', u8'Салатовая', u8'Синяя', u8'Серая', u8'Кастомная [beta]'}

local config = inicfg.load({
    main = {
        disableautoupdate = false,
        timer = false,
        jt = false,
        msg = false,
        text = '',
        texttime = false,
        textcap = false,
        recolor = false,
        captrain = false,
        trainmode = 'old',
        fd = false,
        dist = '600',
        theme = 0,
    },
    binds = {
        trainkey = encodeJson({U}),
        fastnrg = false,
    },
    commands = {
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
        stime = false,
    },
    captcha = {
        record = 0,
        vcode = 0,
        ncode = 0,
        code = 0,
    },
    messages = {
        chat = true,
        console = false,
        silent = false,
    }
}, "Shapez")

function reqFunc(funcName, server) --own function handler
    if funcName == "updates" then --update request
        local response = requests.get('https://pastebin.com/raw/wJnQFAA9')
        updates = decodeJson(response.text)
        return updates
    elseif funcName == "gs" then
        local ffi = require("ffi")
        ffi.cdef[[
        int __stdcall GetVolumeInformationA(
            const char* lpRootPathName,
            char* lpVolumeNameBuffer,
            uint32_t nVolumeNameSize,
            uint32_t* lpVolumeSerialNumber,
            uint32_t* lpMaximumComponentLength,
            uint32_t* lpFileSystemFlags,
            char* lpFileSystemNameBuffer,
            uint32_t nFileSystemNameSize
        );
        ]]
        local serial = ffi.new("unsigned long[1]", 0)
        ffi.C.GetVolumeInformationA(nil, nil, 0, serial, nil, nil, nil, 0)
        return serial[0]
    end
end

local trainkey = {
    v = decodeJson(config.binds.trainkey)
}

function trainmode()
    if config.main.trainmode == 'old' then result = imgui.ImInt(0)
    elseif config.main.trainmode == 'new' then result = imgui.ImInt(1)
    end
end

ffgoodcolor = 'B886E9'
ffbadcolor = '8729E4' 
goodcolor = '{b886e9}'
badcolor = '{8729e4}'
ownname = 'Shapez Legacy'
tag = badcolor..'['..ownname..']: {FFFFFF}'
gtag = goodcolor..'['..ownname..']: {FFFFFF}'

buffer = imgui.ImBuffer(tostring(config.main.text), 256)
buffer.v = string.gsub(tostring(buffer.v), '"', '')
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

function msg(text, mode)
    if mode == "chat" then sampAddChatMessage(tag ..""..text.."", -1)
        elseif mode == "console" then sampfuncsLog(tag .. ""..text.."")
    end
end

local main_window_state = imgui.ImBool(false)
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
    tag = badcolor..'['..ownname..']: {FFFFFF}' 
    gtag = goodcolor..'['..ownname..']: {FFFFFF}'
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
    tag = badcolor..'['..ownname..']: {FFFFFF}' 
    gtag = goodcolor..'['..ownname..']: {FFFFFF}'
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
    style.ChildWindowRounding = 6.0
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
    tag = badcolor..'['..ownname..']: {FFFFFF}' 
    gtag = goodcolor..'['..ownname..']: {FFFFFF}'
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
    tag = badcolor..'['..ownname..']: {FFFFFF}' 
    gtag = goodcolor..'['..ownname..']: {FFFFFF}'
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
    tag = badcolor..'['..ownname..']: {FFFFFF}' 
    gtag = goodcolor..'['..ownname..']: {FFFFFF}'
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
    tag = badcolor..'['..ownname..']: {FFFFFF}' 
    gtag = goodcolor..'['..ownname..']: {FFFFFF}'
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
            ffgoodcolor = 'FFFFFF' 
    ffbadcolor = '1F1F1F' 
    goodcolor = '{FFFFFF}' 
    badcolor = '{1F1F1F}' 
    tag = badcolor..'['..ownname..'C]: {FFFFFF}' 
    gtag = goodcolor..'['..ownname..'C]: {FFFFFF}'
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
    if oldVersion then imgui.OpenPopup(u8'Уведомление о наличии новой версии') end
        if (imgui.BeginPopupModal(u8'Уведомление о наличии новой версии', true, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)) then
            imgui.CenterText(u8'Вышла новая обновленная версия, рекомендуем обновиться.')
            imgui.CenterText(u8'Текущая версия: '..version..'')
            imgui.CenterText(u8'Новая версия: '..updates.info["version"]..'')
            if updt ~= '' then imgui.CenterText(u8'Изменения: '..updates.info["version_info"]..'') end
            imgui.UpdateButton(u8'Обновить')
            if imgui.Button(u8'Потом', imgui.SameLine()) then imgui.CloseCurrentPopup() oldVersion = false if config.messages.chat then msg("Вы всегда можете обновиться в последней вкладке", "chat") elseif config.messages.console then msg("Вы всегда можете обновиться в последней вкладке", "console") elseif config.messages.silent then end end
        imgui.EndPopup()
    end
    if messageSettings then imgui.OpenPopup(u8'Настройки сообщений в чат или консоль') end
        if (imgui.BeginPopupModal(u8'Настройки сообщений в чат или консоль', true, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)) then
            if imgui.Checkbox(u8'Включить все сообщения в чат', imgui.ImBool(config.messages.chat)) then config.messages.console = false config.messages.silent = false config.messages.chat = not config.messages.chat end
            if imgui.Checkbox(u8'Вывод всех сообщения в консоль', imgui.ImBool(config.messages.console)) then config.messages.chat = false config.messages.silent = false config.messages.console = not config.messages.console end
            if imgui.Checkbox(u8'Выключить любые сообщения от скрипта', imgui.ImBool(config.messages.silent)) then config.messages.chat = false config.messages.console = false  config.messages.silent = not config.messages.silent end
            imgui.Separator()
            imgui.Separator()
            imgui.CenterButton(u8'Закрыть')
        imgui.EndPopup()
    end
    if timeSettings then imgui.OpenPopup(u8'Настройки показа времени') end
        if (imgui.BeginPopupModal(u8'Настройки показа времени', true, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)) then
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
                imgui.CenterButton(u8'Изменить расположение')
                if styleTimeinput.v < 0 then styleTimeinput.v = 0 end
                if sizeTimeinput.v < 0 then sizeTimeinput.v = 0 end
                imgui.CenterButton(u8'Закрыть')
        imgui.EndPopup()
    end
        imgui.SetNextWindowSize(imgui.ImVec2(480, 360), imgui.Cond.FirstUseEver)
        imgui.Begin(u8''..ownname..' | '..version..' | Activation: F11##main', main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
           imgui.SetWindowPos(imgui.ImVec2(mX / 3, mY / 3), imgui.Cond.FirstUseEver)
            imgui.BeginChild('top', imgui.ImVec2(465, 95), true) 
                imgui.PushFont(fa_font2)
                if imgui.Button(fa.ICON_FA_COGS ..u8'', imgui.ImVec2(145, 78)) then menu = 1
                elseif imgui.Button(fa.ICON_FA_PLUS ..u8'', imgui.ImVec2(145, 78), imgui.SameLine()) then menu = 2
                elseif imgui.Button(fa.ICON_FA_ADJUST ..u8'', imgui.ImVec2(145, 78), imgui.SameLine()) then menu = 4 end
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
                        else config.main.trainmode = config.main.trainmode trainmode()
                    end
                    imgui.PopItemWidth()
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
                    if imgui.Button(fa.ICON_FA_TRASH ..u8'') then sampUnregisterChatCommand(config.commands.fdc) if config.messages.chat then msg("Команда удалена", "chat") elseif config.messages.console then msg("Команда удалена", "console") elseif config.messages.silent then end end
                    imgui.Hint('sdasdasdwd', u8'Удалить команду для смены прорисовки.')
                    imgui.SameLine()
                    if imgui.Button(fa.ICON_FA_SAVE ..u8'') then inicfg.save(config, "Shapez") fogdist() if config.messages.chat then msg("Команда сохранена, а прорисовка применена", "chat") elseif config.messages.console then msg("Команда сохранена, а прорисовка применена", "console") elseif config.messages.silent then end end
                    imgui.Hint('fgeyhg5ry456456', u8'Активировать и сохранить команду для смены прорисовки.')
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
                    if imgui.Button(fa.ICON_FA_COGS ..u8'') then timeSettings = true end
                end
            end
            if menu == 4 then
                imgui.PushItemWidth(110)
                if imgui.Combo(u8'Темы скрипта', temki, tmodes) then styles[temki.v]() end
                if imgui.Checkbox(u8'Отключить авто-обновление скрипта', imgui.ImBool(config.main.disableautoupdate)) then config.main.disableautoupdate = not config.main.disableautoupdate end
                imgui.Hint('disableautoupdatesforever', u8'Кнопка, если вы не хотите обновляться')
                imgui.PopItemWidth()
                imgui.SameLine(436)
                if imgui.Button(fa.ICON_FA_COMMENT ..'') then messageSettings = true end 
                imgui.Hint('banana', u8'Настройка всех сообщений в чат или консоль.') 
                imgui.Separator()
                imgui.Text(u8'Информация по вводу капчи:')
                imgui.Text(u8'Всего капч введено: '..config.captcha.vcode + config.captcha.ncode)
                imgui.Text(u8'Верных кодов: '..config.captcha.vcode)
                imgui.Text(u8'Неверных кодов: '..config.captcha.ncode)
                imgui.Text(u8'Рекорд ввода капчи: '..config.captcha.record)
                imgui.Text('')
                if tonumber(updates.info["version_n"]) > version_n then 
                    imgui.SameLine(432)
                    if imgui.Button(fa.ICON_FA_CLOUD_DOWNLOAD_ALT..'') then 
                        update_state = true
                        if config.messages.chat then msg("Обновляемся, подождите", "chat") elseif config.messages.console then msg("Обновляемся, подождите", "console") elseif config.messages.silent then end
                    end
                    imgui.Hint('updaaaaaaate', u8'Кнопка для обновления скрипта, если вы этого ещё не сделали.') 
                end
                if imgui.Button(fa.ICON_FA_POWER_OFF ..'') then thisScript():unload() end
                imgui.Hint('offnitvar', u8'Выключить скрипт.') 
                if imgui.Button(fa.ICON_FA_TRASH ..'', imgui.SameLine()) then
                    if doesFileExist(thisScript().filename)then
                        os.remove(thisScript().filename)
                    end
                    if doesFileExist('moonloader\\config\\Shapez.ini') then
                        os.remove('moonloader\\config\\Shapez.ini')
                    end
                    thisScript():unload()
                end
                imgui.Hint('nenadadyadya', u8'Удалить скрипт.') 
                if imgui.Button(fa.ICON_FA_SYNC ..'', imgui.SameLine()) then thisScript():reload() end
                imgui.Hint('rebut', u8'Перезагрузить скрипт.') 
                if imgui.Button(fa.ICON_FA_SAVE ..'', imgui.SameLine()) then if config.messages.chat then msg("Настройки успешно сохранены", "chat") elseif config.messages.console then msg("Настройки успешно сохранены", "console") elseif config.messages.silent then end inicfg.save(config, "Shapez")  end
                imgui.Hint('sohrnastr', u8'Сохранить настройки.')  
                if imgui.Button(fa.ICON_FA_FILE_CONTRACT ..'', imgui.SameLine()) then 
                    if doesFileExist('moonloader\\config\\Shapez.ini') then
                        resetConfig = true
                        thisScript():reload()
                    end
                    msg("Настройки успешно сброшены", "chat")
                end
                imgui.Hint('stoknastr', u8'Вернуть скрипт к стандартным настройкам.')   
            end
            imgui.EndChild()
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
                    imgui.SetCursorPosY(72) -- fix
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
       
    math.randomseed(os.time()+os.clock())
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
       
    math.randomseed(os.time()+os.clock())
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

function imgui.CenterButton(text)
	local width = imgui.GetWindowWidth()
	local calc = imgui.CalcTextSize(text)
	imgui.SetCursorPosX( width / 2 - calc.x / 2 )
	if text == u8'Закрыть' then 
		if imgui.Button(text) then imgui.CloseCurrentPopup() timeSettings = false messageSettings = false end
    elseif text == u8'Изменить расположение' then
        if imgui.Button(text) then imgui.CloseCurrentPopup() timeSettings = false messageSettings = false changePos = true if config.messages.chat then msg("Измените расположение времени курсором мыши и нажмите ЛКМ", "chat") elseif config.messages.console then msg("Измените расположение времени курсором мыши и нажмите ЛКМ", "console") elseif config.messages.silent then end end
    else
		imgui.Button(text)
	end
end

function imgui.UpdateButton(text)
	local width = imgui.GetWindowWidth()
	local calc = imgui.CalcTextSize(text)
	imgui.SetCursorPosX( width / 2.35 - calc.x / 2 )
	if text == u8'Обновить' then 
		if imgui.Button(text) then imgui.CloseCurrentPopup() oldVersion = false update_state = true end
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
                if config.messages.chat then msg('Используйте: '..goodcolor..'/'..config.commands.fdc..' [0-3600]', "chat") elseif config.messages.console then msg('Используйте: '..goodcolor..'/'..config.commands.fdc..' [0-3600]', "console") elseif config.messages.silent then end
            else
                config.main.dist = dist
                memory.setfloat(12044272, config.main.dist, false)
                inicfg.save(config, "Shapez")
                if config.messages.chat then msg('Установлена дальность прорисовки: '..badcolor..''..config.main.dist, "chat") elseif config.messages.console then msg('Установлена дальность прорисовки: '..badcolor..''..config.main.dist, "console") elseif config.messages.silent then end
            end
        end)
        memory.setfloat(12044272, config.main.dist, false)
    end
end

function floorStep(num, step)
    return num - num % step
end

function checkBeforeLoad()
    reqFunc("updates")
    ip, port = sampGetCurrentServerAddress()
    if thisScript().filename ~= 'Shapez.lua' then os.rename(getGameDirectory() .. "/moonloader/" .. thisScript().filename, getGameDirectory() .. "/moonloader/Shapez.lua") end
    if tonumber(updates.info["version_n"]) > version_n and config.main.disableautoupdate == false then
        oldVersion = true
        if config.messages.chat then msg("Есть обновление! Версия: " .. updates.info["version"], "chat") elseif config.messages.console then msg("Есть обновление! Версия: " .. updates.info["version"], "console") elseif config.messages.silent then end
        if config.messages.chat then msg("Что бы узнать больше, откройте меню скрипта", "chat") elseif config.messages.console then msg("Что бы узнать больше, откройте меню скрипта", "console") elseif config.messages.silent then end
    end
    trainmode()
    if config.main.fd then 
        gotofunc("all")
        fogdist() 
    end
end

function main()
    while not isSampAvailable() do wait(0) end
    checkBeforeLoad() wait(500)
    sampRegisterChatCommand('msgchat', function(arg) msg(""..arg.."", "chat") end)
    sampRegisterChatCommand('msgconsole', function(arg) msg(""..arg.."", "console") end)
    renderTimeFont = renderCreateFont(config.servertime.timeFont, config.servertime.timeSize, config.servertime.timeStyle)
    colorOfTime = join_argb(255, config.servertime.timeR, config.servertime.timeG, config.servertime.timeB)
    if config.messages.chat then msg('Загружен! Автор: '..goodcolor..''..author..'{ffffff}. Версия: '..goodcolor..''..version..'{ffffff}, активация: '..goodcolor..'F11.', "chat") elseif config.messages.console then msg('Загружен! Автор: '..goodcolor..''..author..'{ffffff}. Версия: '..goodcolor..''..version..'{ffffff}, активация: '..goodcolor..'F11.', "console") elseif config.messages.silent then end
    while true do wait(0)
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    if config.messages.chat then msg("Скрипт успешно обновлен!", "chat") elseif config.messages.console then msg("Скрипт успешно обновлен!", "console") elseif config.messages.silent then end
                    thisScript():reload()
                end
            end)
            break
        end
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
                if config.messages.chat then msg("Расположение времени сохранено", "chat") elseif config.messages.console then msg("Расположение времени сохранено", "console") elseif config.messages.silent then end
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
                if input == captcha..'0' then if config.messages.chat then msg(string.format('{ffffff}Код верный [%.3f]', os.clock() - captime), "chat") elseif config.messages.console then msg(string.format('{ffffff}Код верный [%.3f]', os.clock() - captime), "console") elseif config.messages.silent then end
                config.captcha.vcode = config.captcha.vcode + 1 
                if os.clock() - captime < config.captcha.record or config.captcha.record == 0 then
                    config.captcha.record = floorStep(os.clock() - captime, 0.001)
                    if config.messages.chat then msg('Новый рекорд ввода капчи: '..goodcolor..''..config.captcha.record..' {ffffff}сек!', "chat") elseif config.messages.console then msg('Новый рекорд ввода капчи: '..goodcolor..''..config.captcha.record..' {ffffff}сек!', "console") elseif config.messages.silent then end
                end
                elseif input ~= captcha..'0' then if config.messages.chat then msg(string.format('{ffffff}Неверный код! [%.3f] ('..captcha..'0|'..input..')', os.clock() - captime), "chat") elseif config.messages.console then msg(string.format('{ffffff}Неверный код! [%.3f] ('..captcha..'0|'..input..')', os.clock() - captime), "console") elseif config.messages.silent then end
                    config.captcha.ncode = config.captcha.ncode + 1 
                end
            end
            removeTextdraws()
        end
        if not sampIsCursorActive() and isPlayerPlaying(PLAYER_PED) then
            if config.main.captrain then 
                if isKeysDown(trainkey.v) then
                    if config.main.trainmode == 'old' then showOldCaptcha()
                    elseif config.main.trainmode == 'new' then showCaptcha()
                    end
                end
            end
            
        end
        config.binds.trainkey = encodeJson(trainkey.v)
        config.keyboard.active = keyboard.v
        imgui.ShowCursor = main_window_state.v
        imgui.Process = main_window_state.v or keyboard.v
    end
end

function ev.onShowDialog(id, style, title, b1, b2, text)
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
    if config.messages.chat then msg('Вы ввели капчу: '.. goodcolor ..'['..input..']{FFFFFF}, таймер ввода: '.. goodcolor ..'['..time1..']{FFFFFF}', "chat") elseif config.messages.console then msg('Вы ввели капчу: '.. goodcolor ..'['..input..']{FFFFFF}, таймер ввода: '.. goodcolor ..'['..time1..']{FFFFFF}', "console") elseif config.messages.silent then end
    end
  end
end

function ev.onServerMessage(color, text)
  if text:find('этот бизнес ваш!') and color == 1941201407 then
    config.captcha.vcode = config.captcha.vcode + 1
    if time < config.captcha.record or config.captcha.record == 0 then
        config.captcha.record = floorStep(time, 0.001)
        if config.messages.chat then msg('Новый рекорд ввода капчи: '..goodcolor..''..config.captcha.record..' {ffffff}сек!', "chat") elseif config.messages.console then msg('Новый рекорд ввода капчи: '..goodcolor..''..config.captcha.record..' {ffffff}сек!', "console") elseif config.messages.silent then end
    end
    if config.main.msg then
        if config.main.texttime and config.main.textcap then sampSendChat(u8:decode(string.format('%s [%.3f] ['..sampGetCurrentDialogEditboxText()..']', config.main.text, time)))
            elseif config.main.texttime then sampSendChat(u8:decode(string.format('%s [%.3f]', config.main.text, time)))
            elseif config.main.textcap then sampSendChat(u8:decode(string.format('%s ['..sampGetCurrentDialogEditboxText()..']', config.main.text)))
        else sampSendChat(u8:decode(config.main.text)) end
    end
    if config.main.recolor and config.main.jt and time ~= nil then 
      sampAddChatMessage(string.format(goodcolor ..'[Информация] {FFFFFF}Поздравляю! Теперь этот бизнес ваш! [%.3f]', time), -1)
      return false
  elseif config.main.jt and time ~= nil then 
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
        if config.messages.chat then msg('Новый рекорд ввода капчи: '..goodcolor..''..config.captcha.record..' {ffffff}сек!', "chat") elseif config.messages.console then msg('Новый рекорд ввода капчи: '..goodcolor..''..config.captcha.record..' {ffffff}сек!', "console") elseif config.messages.silent then end
    end
    if config.main.msg then
        if config.main.texttime and config.main.textcap then sampSendChat(u8:decode(string.format('%s [%.3f] ['..sampGetCurrentDialogEditboxText()..']', config.main.text, time)))
            elseif config.main.texttime then sampSendChat(u8:decode(string.format('%s [%.3f]', config.main.text, time)))
            elseif config.main.textcap then sampSendChat(u8:decode(string.format('%s ['..sampGetCurrentDialogEditboxText()..']', config.main.text)))
        else sampSendChat(u8:decode(config.main.text)) end
    end
    if config.main.recolor and config.main.jt and time ~= nil then 
      sampAddChatMessage(string.format(goodcolor ..'[Информация] {FFFFFF}Поздравляю! Теперь этот дом ваш! [%.3f]', time), -1)
      return false
  elseif config.main.jt and time ~= nil then 
      sampAddChatMessage(string.format('{73B461}[Информация] {FFFFFF}Поздравляю! Теперь этот дом ваш! [%.3f]', time), -1)
      return false
  elseif config.main.recolor then
        sampAddChatMessage(goodcolor ..'[Информация] {FFFFFF}Поздравляю! Теперь этот дом ваш!', -1)
        return false
    end
  end
  if text:find('Ответ неверный!') and color == -10270721 then 
    config.captcha.ncode = config.captcha.ncode + 1
    if config.main.recolor and config.main.jt and time ~= nil then
        sampAddChatMessage(string.format(badcolor ..'[Ошибка] {FFFFFF}Ответ неверный! [%.3f]', time), -1)
        return false
    elseif config.main.jt and time ~= nil then
        sampAddChatMessage(string.format('{FF6347}[Ошибка] {FFFFFF}Ответ неверный! [%.3f]', time), -1)
        return false
    elseif config.main.recolor then
        sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Ответ неверный!', -1)
        return false
    end
  end
  if text:find('Неверный код!') and color == -10270721 then 
    config.captcha.ncode = config.captcha.ncode + 1
    if config.main.recolor and config.main.jt and time ~= nil then 
        sampAddChatMessage(string.format(badcolor ..'[Ошибка] {FFFFFF}Неверный код! [%.3f]', time), -1)
        return false
    elseif config.main.jt and time ~= nil then 
        sampAddChatMessage(string.format('{FF6347}[Ошибка] {FFFFFF}Неверный код! [%.3f]', time), -1)
        return false
    elseif config.main.recolor then
        sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Неверный код!', -1)
        return false
    end
  end
  if text:find('Этот дом уже куплен!') and color == -10270721 then 
    if config.main.recolor and config.main.jt and time ~= nil then 
        sampAddChatMessage(string.format(badcolor ..'[Ошибка] {FFFFFF}Этот дом уже куплен! [%.3f]', time), -1)
        return false
    elseif config.main.jt and time ~= nil then 
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
        if config.messages.chat then msg('Новый рекорд ввода капчи: '..goodcolor..''..config.captcha.record..' {ffffff}сек!', "chat") elseif config.messages.console then msg('Новый рекорд ввода капчи: '..goodcolor..''..config.captcha.record..' {ffffff}сек!', "console") elseif config.messages.silent then end
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
  if text:find('Этот дом только недавно слетел, он будет доступен для покупки в течении 3 часов.') and color == -10270721 then
    if config.main.recolor then
        sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Этот дом только недавно слетел, он будет доступен для покупки в течении 3 часов.', -1)
        return false
    end
  end
  if text:find('Этот бизнес только недавно слетел, он будет доступен для покупки в течении 3 часов.') and color == -10270721 then
    if config.main.recolor then
        sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Этот дом только недавно слетел, он будет доступен для покупки в течении 3 часов.', -1)
        return false
    end
  end
  if text:find('Капча введена верно!') and color == 1941201407 then
    if config.main.recolor then
        sampAddChatMessage(goodcolor ..'[Информация] {FFFFFF}Капча введена верно!', -1)
        return false
    end
  end
end

function onScriptTerminate(script, quitGame)
    if script == thisScript() then
        config.keyboard.x, config.keyboard.y = keyboard_pos.x, keyboard_pos.y
        config.main.theme = temki.v
        inicfg.save(config, "Shapez")
        sampUnregisterChatCommand(config.commands.fhc)
        sampUnregisterChatCommand(config.commands.fbc)
    end
    if resetConfig then 
        if doesFileExist('moonloader\\config\\Shapez.ini') then
            os.remove('moonloader\\config\\Shapez.ini')
        end
    end
end

function onQuitGame()
    config.keyboard.x, config.keyboard.y = keyboard_pos.x, keyboard_pos.y
    config.main.theme = temki.v
    inicfg.save(config, "Shapez")
end

function onWindowMessage(msg, wparam, lparam)
  if msg == 0x100 or msg == 0x101 then
    if wparam == vkeys.VK_ESCAPE and main_window_state.v and not isPauseMenuActive() then
      consumeWindowMessage(true, false)
      main_window_state.v = false
    end
  end
end

--61 20 73 69 6d 61 6b 20 6c 6f 78
--69 64 69 20 6e 61 78 79 69 20

--л эфшлц чъб
