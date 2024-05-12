local author = 'xtr'

local ev = require('lib.samp.events')
local imgui = require('mimgui')
local ia = require('ADDONS')
local hotkey = require('mimgui_hotkeys')
local ffi = require('ffi')
local encoding = require('encoding')
local faicons = require('fAwesome6')
local inicfg = require('inicfg')
local vkeys = require('vkeys')
local memory = require('memory')
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local wm = require 'windows.message'
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof

local dlstatus = require('moonloader').download_status
local script_url = 'https://raw.githubusercontent.com/blackw1ndow/shapez/main/Shapez.lua'

local config = inicfg.load({
    main = {
        timer = false,
        jt = false,
        textlovlya = false,
        text = '',
        texttime = false,
        textcap = false,
    },
    additional = {
        captrain = false,
        captrainkey = '[85]',
        customizeddelay = false,
        fd = false,
        dist = 600,
        fdc = 'fogdist',
    },
    customization = {
        disableautoupdate = false,
        recolor = false,
    },
    messages = {
        silent = false,
        console = false,
        chat = true,
    },
    captcha = {
        record = 0,
        vcode = 0,
        ncode = 0,
        code = 0,
    }
}, "Project Butterfly")

local captcha = ''
local captchaTable = {}
local t = 0
local trainbuff
buffer = imgui.new.char[256](u8(config.main.text))
fdbuf = imgui.new.char[64](u8(config.additional.fdc))
distbuf = imgui.new.float[3600](config.additional.dist)

resX, resY = getScreenResolution()
posX, posY = resX / 1.5, resY / 1.5
local logo = {
    file = getWorkingDirectory()..'\\resource\\logo.png',
    handle = nil
}

ffgoodcolor = 'C0C0C0'
ffbadcolor = '808080' 
goodcolor = '{C0C0C0}'
badcolor = '{808080}'
ownname = 'Project Butterfly'
btag = badcolor..'['..ownname..']: {FFFFFF}'
gtag = goodcolor..'['..ownname..']: {FFFFFF}'
version = '2.0 beta'
version_n = 20
menu = 1
update_state = false
messageSettings = false
resetConfig = false

function msg(text, tag)
    if config.messages.chat then 
        if tag == "good" then 
            sampAddChatMessage(gtag ..""..text.."", -1)
        elseif tag == "bad" then
            sampAddChatMessage(btag ..""..text.."", -1)
        else
            sampAddChatMessage(text, -1)
        end
    elseif config.messages.console then 
        if tag == "good" then 
            sampfuncsLog(gtag .. ""..text.."")
        elseif tag == "bad" then
            sampfuncsLog(btag .. ""..text.."")
        else
            sampfuncsLog(text)
        end
    elseif config.messages.silent then
        return false
    end
end

function reqFunc(funcName, var) --own function handler
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

function gotofunc(fnc)
    if fnc == "all" then
        memory.write(5499541, 12044272, 4, false) -- я ВСЁ ЕЩЁ НЕ ПЕРЕПИСАЛ ПАНОС
        memory.write(8381985, 13213544, 4, false)
    end
end

function fogdist()
    if config.additional.fd then
        sampRegisterChatCommand(config.additional.fdc, function(arg)
            local dist = arg:match("(%d+)")
            dist = tonumber(dist)
            if type(dist) ~= 'number' or dist > 3600 or dist < 0 then
                msg('Используйте: '..goodcolor..'/'..config.additional.fdc..' [0-3600]', "bad")
            else
                config.additional.dist = dist
                memory.setfloat(12044272, config.additional.dist, false)
                inicfg.save(config, "Project Butterfly")
                msg('Установлена дальность прорисовки: '..badcolor..''..config.additional.dist, "good")
            end
        end)
        memory.setfloat(12044272, config.additional.dist, false)
    end
end

function imgui.Theme()
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 1
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 1

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 5
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
    ffgoodcolor = 'C0C0C0'
    ffbadcolor = '808080' 
    goodcolor = '{C0C0C0}'
    badcolor = '{808080}'
    tag = badcolor..'['..ownname..']: {FFFFFF}' 
    gtag = goodcolor..'['..ownname..']: {FFFFFF}'
end

local renderWindow = new.bool()

imgui.OnInitialize(function()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    imgui.GetIO().Fonts:Clear()
    if doesFileExist(getWorkingDirectory()..'\\resource\\fonts\\shapez.ttf') then 
        imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'\\resource\\fonts\\shapez.ttf', 16, nil, glyph_ranges) 
        else
            sampAddChatMessage(gtag..'Fonts not found', -1)
        imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\Arial.ttf', 16, nil, glyph_ranges) 
    end
    imgui.GetIO().IniFilename = nil
    imgui.Theme()
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 14, config, iconRanges)
    if doesFileExist(logo.file) then
        logo.handle = imgui.CreateTextureFromFile(logo.file)
    end
end)

local newFrame = imgui.OnFrame(
    function() return renderWindow[0] end,
    function(player)
        if messageSettings then imgui.OpenPopup(u8'Настройки сообщений в чат или консоль')
            if (imgui.BeginPopupModal(u8'Настройки сообщений в чат или консоль', _, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)) then
            if imgui.Checkbox(u8'Включить все сообщения в чат', imgui.new.bool(config.messages.chat)) then config.messages.console = false config.messages.silent = false config.messages.chat = not config.messages.chat end
            if imgui.Checkbox(u8'Вывод всех сообщения в консоль', imgui.new.bool(config.messages.console)) then config.messages.chat = false config.messages.silent = false config.messages.console = not config.messages.console end
            if imgui.Checkbox(u8'Выключить любые сообщения от скрипта', imgui.new.bool(config.messages.silent)) then config.messages.chat = false config.messages.console = false  config.messages.silent = not config.messages.silent end
                imgui.Separator()
                if ia.MaterialButton(u8'Закрыть') then
                    imgui.CloseCurrentPopup()
                    messageSettings = false
                end
                imgui.EndPopup()
            end
        end
        imgui.SetNextWindowPos(imgui.ImVec2(posX, posY), imgui.Cond.FirstUseEver, imgui.ImVec2(1, 1))
        imgui.SetNextWindowSize(imgui.ImVec2(650, 395), imgui.Cond.Always)
        imgui.Begin(u8'Version: '..version..'##main', renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        if imgui.ImageButton(logo.handle, imgui.ImVec2(630,100)) then menu = 0 end
        imgui.BeginChild('##left', imgui.ImVec2(200, 244), true)
            if ia.MaterialButton(faicons('wrench')..u8'     Main settings', imgui.ImVec2(190, 75)) then
                menu = 1
            elseif ia.MaterialButton(faicons('shapes')..u8'     Additional settings', imgui.ImVec2(190, 75)) then
                menu = 2
            elseif ia.MaterialButton(faicons('eye')..u8'    Customization', imgui.ImVec2(190, 75)) then
                menu = 3
            end
        imgui.EndChild()
        imgui.BeginChild('##right', imgui.ImVec2(435, 244), true, imgui.SameLine())
            if menu == 0 then 
                imgui.Text(u8'Большое спасибо Матвею Ахмедову за поддержку <3')
                imgui.Separator()
                imgui.Text(u8'Информация по вводу капчи:')
                imgui.Text(u8'Всего капч введено: '..config.captcha.vcode + config.captcha.ncode)
                imgui.Text(u8'Верных кодов: '..config.captcha.vcode)
                imgui.Text(u8'Неверных кодов: '..config.captcha.ncode)
                imgui.Text(u8'Рекорд ввода капчи: '..config.captcha.record)
                imgui.Dummy(imgui.ImVec2(0, 80))
                
            elseif menu == 1 then
                if ia.ToggleButton('Captcha timer', imgui.new.bool(config.main.timer)) then 
                    config.main.timer = not config.main.timer 
                end
                ia.Hint('##captchatimer', u8'Таймер ввода капчи', imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                if ia.ToggleButton('Captcha time in buying string', imgui.new.bool(config.main.jt)) then 
                    config.main.jt = not config.main.jt 
                end
                ia.Hint('##jtimer', u8'Время ввода в строке покупки', imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                if ia.ToggleButton('Text message after buying property', imgui.new.bool(config.main.textlovlya)) then 
                    config.main.textlovlya = not config.main.textlovlya 
                end
                ia.Hint('##textlovlya', u8'Сообщение после покупки имущества', imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                if config.main.textlovlya then
                    if imgui.InputText('##textbuffer', buffer, sizeof(buffer) - 1) then
                        config.main.text = u8:decode(str(buffer))
                    end
                    if ia.ToggleButton('Time in message', imgui.new.bool(config.main.texttime)) then 
                        config.main.texttime = not config.main.texttime 
                    end
                    ia.Hint('##texttime', u8'Время в сообщении', imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                    if ia.ToggleButton('Captcha in message', imgui.new.bool(config.main.textcap)) then 
                        config.main.textcap = not config.main.textcap 
                    end
                    ia.Hint('##textcap', u8'Капча в сообщении', imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                end
            elseif menu == 2 then
                if ia.ToggleButton('Captcha training', imgui.new.bool(config.additional.captrain)) then 
                    config.additional.captrain = not config.additional.captrain 
                end
                ia.Hint('##captchatraining', u8'Тренировка капчи на клавишу', imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                if config.additional.captrain then
                    imgui.SameLine()    
                    if trainbuff:ShowHotKey() then 
                        config.additional.captrainkey = encodeJson(trainbuff:GetHotKey()) 
                        inicfg.save(config, "Project Butterfly")
                        print(config.additional.captrainkey)
                    end
                    if ia.ToggleButton('Customized delay', imgui.new.bool(config.additional.customizeddelay)) then
                        config.additional.customizeddelay = not config.additional.customizeddelay 
                    end
                    ia.Hint('##customizeddelay', u8'Задержка после нажатия клавиши открытия капчи', imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                end
                if ia.ToggleButton('Fogdist', imgui.new.bool(config.additional.fd)) then
                    config.additional.fd = not config.additional.fd 
                end
                ia.Hint('##fogdist', u8'Смена прорисовки по команде в чат. На лаунчере крашит, не пофиксить', imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                if config.additional.fd then
                    imgui.SameLine()
                    imgui.PushItemWidth(90)
                    if imgui.InputText('##fdcommand', fdbuf, sizeof(fdbuf) - 1) then
                        config.additional.fdc = string.format('%s', tostring(fdbuf))
                    end
                    imgui.PopItemWidth()
                    ia.Hint('##fdcom', u8'Команда для смены прорисовки', imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                    imgui.SameLine()
                    --[[imgui.PushItemWidth(150)
                    imgui.SliderFloat(u8"", distbuf, 0, 3600)
                    imgui.PopItemWidth()
                    ia.Hint('##distcom', u8'Значение прорисовки', imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                    imgui.SameLine()]]
                    if ia.AnimButton(faicons('trash')) then sampUnregisterChatCommand(config.commands.fdc) msg("Команда удалена", "bad") end
                    ia.Hint('##delfdcom', u8'Удалить команду для смены прорисовки.')
                    imgui.SameLine()
                    if ia.AnimButton(faicons('bookmark')) then inicfg.save(config, "Project Butterfly") fogdist() msg("Команда сохранена, а прорисовка применена", "good") end
                    ia.Hint('##activfdcom', u8'Активировать и сохранить команду для смены прорисовки.')
                end
            elseif menu == 3 then
                if ia.ToggleButton('Disable auto-updates', imgui.new.bool(config.customization.disableautoupdate)) then 
                    config.customization.disableautoupdate = not config.customization.disableautoupdate 
                end
                ia.Hint('##disableautoupdate', u8'Кнопка, что бы отключить авто-обновление скрипта', imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                imgui.SameLine(402)
                if ia.MaterialButton(faicons('comments')..'') then 
                    messageSettings = true
                end
                ia.Hint('##messagesettings', u8'Кнопка для настройки сообщений', imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                if ia.ToggleButton('Recolor messages about buying property', imgui.new.bool(config.customization.recolor)) then 
                    config.customization.recolor = not config.customization.recolor 
                end
                ia.Hint('##recolor', u8'Перекраска сообщений о покупке имущества', imgui.GetStyle().Colors[imgui.Col.TextDisabled])
            end
        imgui.EndChild()

        imgui.End()
    end
)

function beforeLoad()
    reqFunc("updates")
    ip, port = sampGetCurrentServerAddress()
    if thisScript().filename ~= 'Project Butterfly.lua' then os.rename(getGameDirectory() .. "/moonloader/" .. thisScript().filename, getGameDirectory() .. "/moonloader/Project Butterfly.lua") end
    if tonumber(updates.info["version_n"]) > version_n and config.customization.disableautoupdate == false then
        oldVersion = true
        msg("Есть обновление! Версия: " .. updates.info["version"], "good")
        msg("Что бы узнать больше, откройте меню скрипта", "good")
    end
end

function main()
    while not isSampAvailable() do wait(0) end
    if config.additional.fd then 
        gotofunc("all")
        fogdist() 
    end
    trainbuff = hotkey.RegisterHotKey('trainbuff', false, decodeJson(config.additional.captrainkey), function()
        lua_thread.create(function()
            if not sampIsCursorActive() and isPlayerPlaying(PLAYER_PED) then
                if config.additional.captrain then
                    if config.additional.customizeddelay then
                        wait(math.random() * (340 - 40) + 40)
                        showCaptcha()
                    else
                        wait(34)
                        showCaptcha()
                    end
                end
            end
        end)
    end)
    hotkey.Text.WaitForKey = u8'Waiting for key...'
    msg('Loaded! Author: '..goodcolor..''..author..'{ffffff}. Version: '..goodcolor..''..version..'{ffffff}, activation: '..goodcolor..'F12.', "bad")
    addEventHandler('onWindowMessage', function(var_msg, wparam, lparam)
        if var_msg == wm.WM_KEYDOWN or var_msg == wm.WM_SYSKEYDOWN then
            if wparam == vkeys.VK_F12 then
                renderWindow[0] = not renderWindow[0]
            end
        end
        if var_msg == 0x100 or var_msg == 0x101 then
            if wparam == vkeys.VK_ESCAPE and renderWindow[0] and not isPauseMenuActive() then
                consumeWindowMessage(true, false)
                renderWindow[0] = false
            end
        end
    end)
    while true do
        wait(0)
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    msg("Script updated successfully!", "good")
                    thisScript():reload()
                end
            end)
            break
        end
        local result, button, list, input = sampHasDialogRespond(8812)
        if result then
            if button == 1 then
                if input == captcha..'0' then msg(string.format('{ffffff}Right code [%.3f]', os.clock() - captime), "good")
                    config.captcha.vcode = config.captcha.vcode + 1
                    if os.clock() - captime < config.captcha.record or config.captcha.record == 0 then
                        config.captcha.record = floorStep(os.clock() - captime, 0.001)
                        msg('New record: '..goodcolor..''..config.captcha.record..' {ffffff}sec!', "bad")
                    end
                elseif input ~= captcha..'0' then msg(string.format('{ffffff}Wrong code! [%.3f] ('..captcha..'0|'..input..')', os.clock() - captime), "bad")
                    config.captcha.ncode = config.captcha.ncode + 1 
                end

            end
            removeTextdraws()
        end
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
    end
    if config.main.timer and time ~= nil then
        msg('You entered captcha: '.. goodcolor ..'['..input..']{FFFFFF}, time: '.. goodcolor ..'['..time1..']{FFFFFF}', "good")
    end
end

function ev.onServerMessage(color, text)
    if text:find('этот бизнес ваш!') and color == 1941201407 then
      config.captcha.vcode = config.captcha.vcode + 1
      if time < config.captcha.record or config.captcha.record == 0 then
          config.captcha.record = floorStep(time, 0.001)
          msg('Новый рекорд ввода капчи: '..goodcolor..''..config.captcha.record..' {ffffff}сек!', "chat")
      end
      if config.main.textlovlya then
          if config.main.texttime and config.main.textcap then sampSendChat(u8:decode(str.format('%s [%.3f] ['..sampGetCurrentDialogEditboxText()..']', config.main.text, time)))
              elseif config.main.texttime then sampSendChat(u8:decode(str.format('%s [%.3f]', config.main.text, time)))
              elseif config.main.textcap then sampSendChat(u8:decode(str.format('%s ['..sampGetCurrentDialogEditboxText()..']', config.main.text)))
          else sampSendChat(u8:decode(config.main.text)) end
      end
      if config.customization.recolor and config.main.jt and time ~= nil then 
        sampAddChatMessage(string.format(goodcolor ..'[Информация] {FFFFFF}Поздравляю! Теперь этот бизнес ваш! [%.3f]', time), -1)
        return false
    elseif config.main.jt and time ~= nil then 
        sampAddChatMessage(string.format('{73B461}[Информация] {FFFFFF}Поздравляю! Теперь этот бизнес ваш! [%.3f]', time), -1)
        return false
    elseif config.customization.recolor then
          sampAddChatMessage(goodcolor ..'[Информация] {FFFFFF}Поздравляю! Теперь этот бизнес ваш!', -1)
          return false
      end
    end
    if text:find('этот дом ваш!') and color == 1941201407 then 
      config.captcha.vcode = config.captcha.vcode + 1
      if time < config.captcha.record or config.captcha.record == 0 then
          config.captcha.record = floorStep(time, 0.001)
          msg('Новый рекорд ввода капчи: '..goodcolor..''..config.captcha.record..' {ffffff}сек!', "chat")
      end
      if config.main.textlovlya then
          if config.main.texttime and config.main.textcap then sampSendChat(u8:decode(string.format('%s [%.3f] ['..sampGetCurrentDialogEditboxText()..']', config.main.text, time)))
              elseif config.main.texttime then sampSendChat(u8:decode(string.format('%s [%.3f]', config.main.text, time)))
              elseif config.main.textcap then sampSendChat(u8:decode(string.format('%s ['..sampGetCurrentDialogEditboxText()..']', config.main.text)))
          else sampSendChat(u8:decode(config.main.text)) end
      end
      if config.customization.recolor and config.main.jt and time ~= nil then 
        sampAddChatMessage(string.format(goodcolor ..'[Информация] {FFFFFF}Поздравляю! Теперь этот дом ваш! [%.3f]', time), -1)
        return false
    elseif config.main.jt and time ~= nil then 
        sampAddChatMessage(string.format('{73B461}[Информация] {FFFFFF}Поздравляю! Теперь этот дом ваш! [%.3f]', time), -1)
        return false
    elseif config.customization.recolor then
          sampAddChatMessage(goodcolor ..'[Информация] {FFFFFF}Поздравляю! Теперь этот дом ваш!', -1)
          return false
      end
    end
    if text:find('Ответ неверный!') and color == -10270721 then 
      config.captcha.ncode = config.captcha.ncode + 1
      if config.customization.recolor and config.main.jt and time ~= nil then
          sampAddChatMessage(string.format(badcolor ..'[Ошибка] {FFFFFF}Ответ неверный! [%.3f]', time), -1)
          return false
      elseif config.main.jt and time ~= nil then
          sampAddChatMessage(string.format('{FF6347}[Ошибка] {FFFFFF}Ответ неверный! [%.3f]', time), -1)
          return false
      elseif config.customization.recolor then
          sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Ответ неверный!', -1)
          return false
      end
    end
    if text:find('Неверный код!') and color == -10270721 then 
      config.captcha.ncode = config.captcha.ncode + 1
      if config.customization.recolor and config.main.jt and time ~= nil then 
          sampAddChatMessage(string.format(badcolor ..'[Ошибка] {FFFFFF}Неверный код! [%.3f]', time), -1)
          return false
      elseif config.main.jt and time ~= nil then 
          sampAddChatMessage(string.format('{FF6347}[Ошибка] {FFFFFF}Неверный код! [%.3f]', time), -1)
          return false
      elseif config.customization.recolor then
          sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Неверный код!', -1)
          return false
      end
    end
    if text:find('Этот дом уже куплен!') and color == -10270721 then 
      if config.customization.recolor and config.main.jt and time ~= nil then 
          sampAddChatMessage(string.format(badcolor ..'[Ошибка] {FFFFFF}Этот дом уже куплен! [%.3f]', time), -1)
          return false
      elseif config.main.jt and time ~= nil then 
          sampAddChatMessage(string.format('{FF6347}[Ошибка] {FFFFFF}Этот дом уже куплен! [%.3f]', time), -1)
          return false
      elseif config.customization.recolor then
          sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Этот дом уже куплен!', -1)
          return false
      end
    end
    if text:find('Этот дом уже кем то куплен!') and color == -10270721 then 
      if config.customization.recolor and config.main.jt and time ~= nil then
          sampAddChatMessage(string.format(badcolor ..'[Ошибка] {FFFFFF}Этот дом уже кем то куплен! [%.3f]', time), -1)
          return false
      elseif config.main.jt and time ~= nil then
          sampAddChatMessage(string.format('{FF6347}[Ошибка] {FFFFFF}Этот дом уже кем то куплен! [%.3f]', time), -1)
          return false
      elseif config.customization.recolor then
          sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Этот дом уже кем то куплен!', -1)
          return false
      end
    end
    if text:find('Этот бизнес уже кем то куплен') and (color == -10270721 or color == -1347440641) then
      if config.customization.recolor and config.main.jt and time ~= nil then
          sampAddChatMessage(string.format(badcolor ..'[Ошибка] {FFFFFF}Этот бизнес уже кем то куплен! [%.3f]', time), -1)
          return false
      elseif config.main.jt and time ~= nil then
          sampAddChatMessage(string.format('{FF6347}[Ошибка] {FFFFFF}Этот бизнес уже кем то куплен! [%.3f]', time), -1)
          return false
      elseif config.customization.recolor then
          sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Этот бизнес уже кем то куплен!', -1)
          return false
      end
    end
    if text:find('Не флуди!') and color == -10270721 then
      if config.customization.recolor then
          sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Не флуди!', -1)
          return false
      end
    end
    if text:find('Вы продали ваш бизнес') and color == 1941201407 then
      if config.customization.recolor then
          sampAddChatMessage(goodcolor ..'[Информация] {FFFFFF}Вы продали ваш бизнес!', -1)
          return false
      end
    end
    if text:find('Вы продали ваш дом') and color == 1941201407 then
      if config.customization.recolor then
          sampAddChatMessage(goodcolor ..'[Информация] {FFFFFF}Вы продали ваш дом!', -1)
          return false
      end
    end
    if text:find('Этот дом только недавно слетел, он будет доступен для покупки в течении 3 часов.') and color == -10270721 then
      if config.customization.recolor then
          sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Этот дом только недавно слетел, он будет доступен для покупки в течении 3 часов.', -1)
          return false
      end
    end
    if text:find('Этот бизнес только недавно слетел, он будет доступен для покупки в течении 3 часов.') and color == -10270721 then
      if config.customization.recolor then
          sampAddChatMessage(badcolor ..'[Ошибка] {FFFFFF}Этот дом только недавно слетел, он будет доступен для покупки в течении 3 часов.', -1)
          return false
      end
    end
    if text:find('Капча введена верно!') and color == 1941201407 then
      if config.customization.recolor then
          sampAddChatMessage(goodcolor ..'[Информация] {FFFFFF}Капча введена верно!', -1)
          return false
      end
    end
end

function floorStep(num, step)
    return num - num % step
end

function showCaptcha()
    removeTextdraws()
    t = t + 1
    sampTextdrawCreate(t, "LD_SPAC:white", 240, 124)
    sampTextdrawSetLetterSizeAndColor(t, 0, 7.3, 0x80808080)
    sampTextdrawSetBoxColorAndSize(t, 1, 0xFF1A2432, 404, 0.000000)
       
    t = t + 1
    sampTextdrawCreate(t, "LD_SPAC:white", 242, 127)
    sampTextdrawSetLetterSizeAndColor(t, 0, 6.5, 0x80808080)
    sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, 400, 0.000000)
    nextPos = math.random() * (31 - 30) - 30.5;

       
    math.randomseed(os.time()+os.clock())
    for i = 1, 4 do
        a = math.random(0, 9)
        table.insert(captchaTable, a)
        captcha = captcha..a
    end
       
    for i = 0, 4 do
        nextPos = nextPos + math.random() * (31 - 30) + 29.5
        t = t + 1
        sampTextdrawCreate(t, "usebox", 259 + nextPos, 131)
        sampTextdrawSetLetterSizeAndColor(t, 0, math.random() * (5.3 - 5) + 5, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF1A2432, 30, math.random() * (26.5 - 25) + 25)
        sampTextdrawSetAlign(t, 2)
        if i < 4 then GenerateTextDraw(captchaTable[i + 1], 259 + nextPos, 131, 3 + i * 2)
        else GenerateTextDraw(0, 259 + nextPos, 131, 3 + i * 10) end 
    end
    captchaTable = {}
    sampShowDialog(8812, '{F89168}Captcha training', '{FFFFFF}Enter {C6FB4A}5{FFFFFF} symbols, that\nyou see {C6FB4A}on{FFFFFF} the screen.', 'Accept', 'Cancel', 1)
    captime = os.clock()
end

function removeTextdraws()
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
    sampTextdrawSetLetterSizeAndColor(t, 0, math.random() * (4 - 3) + 3, 0x80808080)
    sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX+8, 0.000000)
  elseif id == 1 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then offsetX = 2; offsetBX = 17 else offsetX = -3; offsetBX = -17; end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX - offsetX, PosY)
        sampTextdrawSetLetterSizeAndColor(t, 0, 5.7, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-offsetBX, 0.000000)
    end
  elseif id == 2 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then offsetX = -8; offsetY = 8 offsetBX = 16 else offsetX = 8; offsetY = 28 offsetBX = -15; end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX - offsetX, PosY + offsetY)
        sampTextdrawSetLetterSizeAndColor(t, 0, 0.85, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-offsetBX, 0.000000)
    end
  elseif id == 3 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then size = 1.1; offsetY = 6 else size = 1.3; offsetY = 25 end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX+10, PosY+offsetY)
        sampTextdrawSetLetterSizeAndColor(t, 0, size, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-16.5, 0.000000)
    end
  elseif id == 4 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then size = 1.6 offsetX = -10; offsetY = 0 offsetBX = 7 else size = 2.75; offsetX = -10; offsetY = 25 offsetBX = 16; end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX - offsetX, PosY + offsetY)
        sampTextdrawSetLetterSizeAndColor(t, 0, size, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-offsetBX, 0.000000)
    end
  elseif id == 5 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then size = 0.8; offsetX = 6; offsetY = 7 offsetBX = -15 else size = 1.2; offsetX = -10; offsetY = 26 offsetBX = 16; end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX - offsetX, PosY + offsetY)
        sampTextdrawSetLetterSizeAndColor(t, 0, size, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-offsetBX, 0.000000)
    end
  elseif id == 6 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then size = 1; offsetX = 7.5; offsetY = 7 offsetBX = -15 else size = 1.1; offsetX = -10; offsetY = math.random() * (29 - 27) + 27 offsetBX = 10; end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX - offsetX, PosY + offsetY)
        sampTextdrawSetLetterSizeAndColor(t, 0, size, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-offsetBX, 0.000000)
    end
  elseif id == 7 then
    t = t + 1
    sampTextdrawCreate(t, "LD_SPAC:white", PosX - 14, PosY + 6)
    sampTextdrawSetLetterSizeAndColor(t, 0, 5.1, 0x80808080)
    sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX+7, 0.000000)
  elseif id == 8 then
    sizefor8 = math.random() * (9 - 8) + 8
    for i = 0, 1 do
        t = t + 1
        if i == 0 then size = 1.275; offsetY = 8 else size = 1.2; offsetY = 28 end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX+sizefor8, PosY+offsetY)
        sampTextdrawSetLetterSizeAndColor(t, 0, size, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-6, 0.000000)
    end
  elseif id == 9 then
    for i = 0, 1 do
        t = t + 1
        if i == 0 then size = 1.25; offsetY = 7; offsetBX = 7; else size = 1.275; offsetY = 26; offsetBX = 16; end
        sampTextdrawCreate(t, "LD_SPAC:white", PosX+7, PosY+offsetY)
        sampTextdrawSetLetterSizeAndColor(t, 0, size, 0x80808080)
        sampTextdrawSetBoxColorAndSize(t, 1, 0xFF759DA3, PosX-offsetBX, 0.000000)
    end
  end
end

function onScriptTerminate(script, quitGame)
    if script == thisScript() then
        inicfg.save(config, "Project Butterfly")
    end
    if resetConfig then 
        if doesFileExist('moonloader\\config\\Project Butterfly.ini') then
            os.remove('moonloader\\config\\Project Butterfly.ini')
        end
    end
end

function onQuitGame()
    inicfg.save(config, "Project Butterfly")
end