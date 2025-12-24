local surface = surface
local Color = Color
local SKIN = {}
SKIN.PrintName = "Half-Life 2"
SKIN.Author = "Copilot"
SKIN.DermaVersion = 1
-- Colors
SKIN.bg_color = Color(60, 60, 60, 255)
SKIN.bg_color_sleep = Color(50, 50, 50, 255)
SKIN.bg_color_dark = Color(40, 40, 40, 255)
SKIN.bg_color_bright = Color(80, 80, 80, 255)
SKIN.frame_border = Color(100, 100, 100, 255)
-- Fonts
if HL2Scheme then
    SKIN.fontFrame = HL2Scheme.GetFont("UiBold", "DefaultBold", "SourceScheme")
else
    SKIN.fontFrame = "DefaultBold"
end

SKIN.control_color = Color(120, 120, 120, 255)
SKIN.control_color_highlight = Color(150, 150, 150, 255)
SKIN.control_color_active = Color(110, 150, 250, 255)
SKIN.control_color_bright = Color(255, 200, 100, 255)
SKIN.control_color_dark = Color(100, 100, 100, 255)
SKIN.bg_alt1 = Color(50, 50, 50, 255)
SKIN.bg_alt2 = Color(55, 55, 55, 255)
SKIN.listview_hover = Color(70, 70, 70, 255)
SKIN.listview_selected = Color(100, 170, 220, 255)
SKIN.text_bright = Color(255, 255, 255, 255)
SKIN.text_normal = Color(180, 180, 180, 255)
SKIN.text_dark = Color(20, 20, 20, 255)
SKIN.text_highlight = Color(255, 20, 20, 255)
SKIN.texGradientUp = Material("gui/gradient_up")
SKIN.texGradientDown = Material("gui/gradient_down")
SKIN.combobox_selected = SKIN.listview_selected
SKIN.panel_transback = Color(255, 255, 255, 50)
SKIN.tooltip = Color(255, 245, 175, 255)
SKIN.colPropertySheet = Color(170, 170, 170, 255)
SKIN.colTab = SKIN.colPropertySheet
SKIN.colTabInactive = Color(140, 140, 140, 255)
SKIN.colTabShadow = Color(0, 0, 0, 170)
SKIN.colTabText = Color(255, 255, 255, 255)
SKIN.colTabTextInactive = Color(0, 0, 0, 200)
SKIN.fontTab = "DermaDefault"
SKIN.colCollapsibleCategory = Color(255, 255, 255, 20)
SKIN.colCategoryText = Color(255, 255, 255, 255)
SKIN.colCategoryTextInactive = Color(200, 200, 200, 255)
SKIN.fontCategoryHeader = "TabLarge"
SKIN.colNumberWangBG = Color(255, 240, 150, 255)
SKIN.colTextEntryBG = Color(240, 240, 240, 255)
SKIN.colTextEntryBorder = Color(20, 20, 20, 255)
SKIN.colTextEntryText = Color(20, 20, 20, 255)
SKIN.colTextEntryTextHighlight = Color(20, 200, 250, 255)
SKIN.colTextEntryTextCursor = Color(0, 0, 100, 255)
SKIN.colTextEntryTextPlaceholder = Color(128, 128, 128, 255)
SKIN.colNumSliderNotch = Color(0, 0, 0, 100)
SKIN.colMenuBG = Color(255, 255, 255, 200)
SKIN.colMenuBorder = Color(0, 0, 0, 200)
SKIN.colButtonText = Color(255, 255, 255, 255)
SKIN.colButtonTextDisabled = Color(255, 255, 255, 55)
SKIN.colButtonBorder = Color(20, 20, 20, 255)
SKIN.colButtonBorderHighlight = Color(255, 255, 255, 50)
SKIN.colButtonBorderShadow = Color(0, 0, 0, 100)
function SKIN:PaintFrame(panel, w, h)
    if not HL2Scheme then return end

    -- Background (FrameBorder uses backgroundtype "2" = rounded corners)
    -- Colors from sourceschemebase.res
    local activeCol = HL2Scheme.GetColor("Frame.BgColor", Color(160, 160, 160, 128), "SourceScheme")
    local inactiveCol = HL2Scheme.GetColor("Frame.OutOfFocusBgColor", Color(160, 160, 160, 32), "SourceScheme")
    local focusWeight = panel.FocusWeight or (panel:IsActive() and 1 or 0)

    -- Interpolate based on FocusWeight
    local r = Lerp(focusWeight, inactiveCol.r, activeCol.r)
    local g = Lerp(focusWeight, inactiveCol.g, activeCol.g)
    local b = Lerp(focusWeight, inactiveCol.b, activeCol.b)
    local a = Lerp(focusWeight, inactiveCol.a, activeCol.a)
    local bgColor = Color(r, g, b, a)

    -- Draw rounded frame background (FrameBorder has backgroundtype "2")
    draw.RoundedBox(8, 0, 0, w, h, bgColor)

    -- Title bar background (if drawing title bar)
    if panel.GetTitle and _drawTitleBar ~= false then
        -- FrameTitleBar.BgColor defaults to "Blank" in sourceschemebase.res
        local titleBarBg = panel:IsActive() and
            HL2Scheme.GetColor("FrameTitleBar.BgColor", Color(0, 0, 0, 0), "SourceScheme") or
            HL2Scheme.GetColor("FrameTitleBar.DisabledBgColor", Color(0, 0, 0, 0), "SourceScheme")

        -- Frame.ClientInsetX/Y define the insets
        local inset = 5
        local captionHeight = 28

        surface.SetDrawColor(titleBarBg)
        surface.DrawRect(inset, inset, w - inset, captionHeight)

        -- Title text
        local title = panel:GetTitle()
        if title and title ~= "" then
            local font = HL2Scheme.GetFont("UiBold", "DefaultBold", "SourceScheme")
            -- FrameTitleBar.TextColor defaults to "White" in sourceschemebase.res
            local titleColor = panel:IsActive() and
                HL2Scheme.GetColor("FrameTitleBar.TextColor", Color(255, 255, 255, 255), "SourceScheme") or
                HL2Scheme.GetColor("FrameTitleBar.DisabledTextColor", Color(255, 255, 255, 192), "SourceScheme")

            surface.SetFont(font)
            surface.SetTextColor(titleColor)
            -- Frame.TitleTextInsetX is 16 in sourceschemebase.res
            local titleInsetX = tonumber(HL2Scheme.GetResourceString("Frame.TitleTextInsetX", nil, "SourceScheme")) or 16
            surface.SetTextPos(titleInsetX, 9)
            surface.DrawText(title)
        end
    end
end

function SKIN:PaintButton(panel, w, h)
    if not HL2Scheme then return end

    local isDown = panel:IsDown()
    local isArmed = panel.Hovered or panel:IsHovered() -- Armed = hovering
    local isDisabled = not panel:IsEnabled()

    -- Colors from scheme (matching Source SDK Button.cpp)
    local defaultFgColor = HL2Scheme.GetColor("Button.TextColor", Color(255, 255, 255, 255), "SourceScheme")
    local armedFgColor = HL2Scheme.GetColor("Button.ArmedTextColor", defaultFgColor, "SourceScheme")
    local depressedFgColor = HL2Scheme.GetColor("Button.DepressedTextColor", defaultFgColor, "SourceScheme")
    -- Disabled text uses Label.DisabledFgColor1 and DisabledFgColor2 for inset effect
    local disabledFgColor1 = HL2Scheme.GetColor("Label.DisabledFgColor1", Color(117, 117, 117, 255), "SourceScheme")
    local disabledFgColor2 = HL2Scheme.GetColor("Label.DisabledFgColor2", Color(30, 30, 30, 255), "SourceScheme")

    local defaultBgColor = HL2Scheme.GetColor("Button.BgColor", Color(0, 0, 0, 0), "SourceScheme")
    local armedBgColor = HL2Scheme.GetColor("Button.ArmedBgColor", defaultBgColor, "SourceScheme")
    local depressedBgColor = HL2Scheme.GetColor("Button.DepressedBgColor", Color(0, 0, 0, 0), "SourceScheme")

    -- Handle title buttons differently (no borders)
    if panel.IsTitleButton then
        local textColor = HL2Scheme.GetColor("FrameTitleButton.FgColor", Color(200, 200, 200, 196), "SourceScheme")
        if isDisabled then
            textColor = HL2Scheme.GetColor("FrameTitleButton.DisabledFgColor", Color(255, 255, 255, 192), "SourceScheme")
        end
        panel:SetTextColor(textColor)
        return
    end

    -- Determine colors based on state
    local textColor, bgColor
    if isDisabled then
        -- Disabled uses Label.DisabledFgColor2 (darker color for better readability)
        textColor = disabledFgColor2
        bgColor = defaultBgColor
    elseif isDown then
        textColor = depressedFgColor
        bgColor = depressedBgColor
    elseif isArmed then
        textColor = armedFgColor
        bgColor = armedBgColor
    else
        textColor = defaultFgColor
        bgColor = defaultBgColor
    end

    -- Draw background
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)

    -- Draw borders (ButtonBorder or ButtonDepressedBorder style)
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(200, 200, 200, 196), "SourceScheme")
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")

    if isDown or isDisabled then
        -- Depressed/disabled border: dark on top/left, light on bottom/right (inset look)
        surface.SetDrawColor(colDark)
        surface.DrawLine(0, 0, w - 1, 0) -- Top
        surface.DrawLine(0, 0, 0, h - 1) -- Left
        surface.SetDrawColor(colLight)
        surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
        surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
    else
        -- Normal border: light on top/left, dark on bottom/right
        surface.SetDrawColor(colLight)
        surface.DrawLine(0, 0, w - 1, 0) -- Top
        surface.DrawLine(0, 0, 0, h - 1) -- Left
        surface.SetDrawColor(colDark)
        surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
        surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
    end

    panel:SetTextColor(textColor)
    -- Buttons should be left-aligned by default (a_west)
    if not panel.m_bAlignmentSet then
        panel:SetContentAlignment(4) -- 4 = west/left alignment
    end
end

function SKIN:PaintWindowCloseButton(panel, w, h)
    if not HL2Scheme then return end
    local font = HL2Scheme.GetFont("Marlett", "Marlett", "SourceScheme")
    local col = HL2Scheme.GetColor("FrameTitleButton.FgColor", Color(200, 200, 200, 196), "SourceScheme")
    if panel:GetDisabled() then
        col = HL2Scheme.GetColor("FrameTitleButton.DisabledFgColor", Color(255, 255, 255, 192), "SourceScheme")
    elseif panel:IsDown() then
        col = Color(255, 255, 255, 255) -- Brighter when pressed?
    elseif panel.Hovered then
        col = Color(255, 255, 255, 255)
    end

    surface.SetFont(font)
    local tw, th = surface.GetTextSize("r")
    surface.SetTextPos((w - tw) / 2, (h - th) / 2)
    surface.SetTextColor(col)
    surface.DrawText("r")
end

function SKIN:PaintWindowMaximizeButton(panel, w, h)
    if not HL2Scheme then return end
    local font = HL2Scheme.GetFont("Marlett", "Marlett", "SourceScheme")
    local col = HL2Scheme.GetColor("FrameTitleButton.FgColor", Color(200, 200, 200, 196), "SourceScheme")
    if panel:GetDisabled() then
        col = HL2Scheme.GetColor("FrameTitleButton.DisabledFgColor", Color(255, 255, 255, 192), "SourceScheme")
    elseif panel:IsDown() then
        col = Color(255, 255, 255, 255)
    elseif panel.Hovered then
        col = Color(255, 255, 255, 255)
    end

    surface.SetFont(font)
    local tw, th = surface.GetTextSize("1")
    surface.SetTextPos((w - tw) / 2, (h - th) / 2)
    surface.SetTextColor(col)
    surface.DrawText("1")
end

function SKIN:PaintWindowMinimizeButton(panel, w, h)
    if not HL2Scheme then return end
    local font = HL2Scheme.GetFont("Marlett", "Marlett", "SourceScheme")
    local col = HL2Scheme.GetColor("FrameTitleButton.FgColor", Color(200, 200, 200, 196), "SourceScheme")
    if panel:GetDisabled() then
        col = HL2Scheme.GetColor("FrameTitleButton.DisabledFgColor", Color(255, 255, 255, 192), "SourceScheme")
    elseif panel:IsDown() then
        col = Color(255, 255, 255, 255)
    elseif panel.Hovered then
        col = Color(255, 255, 255, 255)
    end

    surface.SetFont(font)
    local tw, th = surface.GetTextSize("0")
    surface.SetTextPos((w - tw) / 2, (h - th) / 2)
    surface.SetTextColor(col)
    surface.DrawText("0")
end

function SKIN:PaintButtonUp(panel, w, h)
    if not HL2Scheme then return end

    local isDown = panel.Depressed or panel:IsDown()

    -- ScrollBarButton uses transparent background with borders
    local bgColor = HL2Scheme.GetColor("ScrollBarButton.BgColor", Color(0, 0, 0, 0), "SourceScheme")
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)

    -- Draw borders like regular buttons
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(200, 200, 200, 196), "SourceScheme")
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")

    if isDown then
        -- Depressed border
        surface.SetDrawColor(colDark)
        surface.DrawLine(0, 0, w - 1, 0)
        surface.DrawLine(0, 0, 0, h - 1)
        surface.SetDrawColor(colLight)
        surface.DrawLine(w - 1, 0, w - 1, h - 1)
        surface.DrawLine(0, h - 1, w - 1, h - 1)
    else
        -- Raised border
        surface.SetDrawColor(colLight)
        surface.DrawLine(0, 0, w - 1, 0)
        surface.DrawLine(0, 0, 0, h - 1)
        surface.SetDrawColor(colDark)
        surface.DrawLine(w - 1, 0, w - 1, h - 1)
        surface.DrawLine(0, h - 1, w - 1, h - 1)
    end

    -- Draw Marlett 't' (up arrow)
    local marlettFont = HL2Scheme.GetFont("Marlett", "Marlett", "SourceScheme")
    surface.SetFont(marlettFont)
    local fgColor = HL2Scheme.GetColor("ScrollBarButton.FgColor", Color(255, 255, 255, 255), "SourceScheme")
    surface.SetTextColor(fgColor)
    local tw, th = surface.GetTextSize("t")
    surface.SetTextPos((w - tw) / 2, (h - th) / 2)
    surface.DrawText("t")
end

function SKIN:PaintButtonDown(panel, w, h)
    if not HL2Scheme then return end

    local isDown = panel.Depressed or panel:IsDown()

    -- ScrollBarButton uses transparent background with borders
    local bgColor = HL2Scheme.GetColor("ScrollBarButton.BgColor", Color(0, 0, 0, 0), "SourceScheme")
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)

    -- Draw borders
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(200, 200, 200, 196), "SourceScheme")
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")

    if isDown then
        surface.SetDrawColor(colDark)
        surface.DrawLine(0, 0, w - 1, 0)
        surface.DrawLine(0, 0, 0, h - 1)
        surface.SetDrawColor(colLight)
        surface.DrawLine(w - 1, 0, w - 1, h - 1)
        surface.DrawLine(0, h - 1, w - 1, h - 1)
    else
        surface.SetDrawColor(colLight)
        surface.DrawLine(0, 0, w - 1, 0)
        surface.DrawLine(0, 0, 0, h - 1)
        surface.SetDrawColor(colDark)
        surface.DrawLine(w - 1, 0, w - 1, h - 1)
        surface.DrawLine(0, h - 1, w - 1, h - 1)
    end

    -- Draw Marlett 'u' (down arrow)
    local marlettFont = HL2Scheme.GetFont("Marlett", "Marlett", "SourceScheme")
    surface.SetFont(marlettFont)
    local fgColor = HL2Scheme.GetColor("ScrollBarButton.FgColor", Color(255, 255, 255, 255), "SourceScheme")
    surface.SetTextColor(fgColor)
    local tw, th = surface.GetTextSize("u")
    surface.SetTextPos((w - tw) / 2, (h - th) / 2)
    surface.DrawText("u")
end

function SKIN:PaintButtonLeft(panel, w, h)
    if not HL2Scheme then return end

    local isDown = panel.Depressed or panel:IsDown()

    local bgColor = HL2Scheme.GetColor("ScrollBarButton.BgColor", Color(0, 0, 0, 0), "SourceScheme")
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)

    local colLight = HL2Scheme.GetColor("Border.Bright", Color(200, 200, 200, 196), "SourceScheme")
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")

    if isDown then
        surface.SetDrawColor(colDark)
        surface.DrawLine(0, 0, w - 1, 0)
        surface.DrawLine(0, 0, 0, h - 1)
        surface.SetDrawColor(colLight)
        surface.DrawLine(w - 1, 0, w - 1, h - 1)
        surface.DrawLine(0, h - 1, w - 1, h - 1)
    else
        surface.SetDrawColor(colLight)
        surface.DrawLine(0, 0, w - 1, 0)
        surface.DrawLine(0, 0, 0, h - 1)
        surface.SetDrawColor(colDark)
        surface.DrawLine(w - 1, 0, w - 1, h - 1)
        surface.DrawLine(0, h - 1, w - 1, h - 1)
    end

    local marlettFont = HL2Scheme.GetFont("Marlett", "Marlett", "SourceScheme")
    surface.SetFont(marlettFont)
    local fgColor = HL2Scheme.GetColor("ScrollBarButton.FgColor", Color(255, 255, 255, 255), "SourceScheme")
    surface.SetTextColor(fgColor)
    local tw, th = surface.GetTextSize("3")
    surface.SetTextPos((w - tw) / 2, (h - th) / 2)
    surface.DrawText("3")
end

function SKIN:PaintButtonRight(panel, w, h)
    if not HL2Scheme then return end

    local isDown = panel.Depressed or panel:IsDown()

    local bgColor = HL2Scheme.GetColor("ScrollBarButton.BgColor", Color(0, 0, 0, 0), "SourceScheme")
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)

    local colLight = HL2Scheme.GetColor("Border.Bright", Color(200, 200, 200, 196), "SourceScheme")
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")

    if isDown then
        surface.SetDrawColor(colDark)
        surface.DrawLine(0, 0, w - 1, 0)
        surface.DrawLine(0, 0, 0, h - 1)
        surface.SetDrawColor(colLight)
        surface.DrawLine(w - 1, 0, w - 1, h - 1)
        surface.DrawLine(0, h - 1, w - 1, h - 1)
    else
        surface.SetDrawColor(colLight)
        surface.DrawLine(0, 0, w - 1, 0)
        surface.DrawLine(0, 0, 0, h - 1)
        surface.SetDrawColor(colDark)
        surface.DrawLine(w - 1, 0, w - 1, h - 1)
        surface.DrawLine(0, h - 1, w - 1, h - 1)
    end

    local marlettFont = HL2Scheme.GetFont("Marlett", "Marlett", "SourceScheme")
    surface.SetFont(marlettFont)
    local fgColor = HL2Scheme.GetColor("ScrollBarButton.FgColor", Color(255, 255, 255, 255), "SourceScheme")
    surface.SetTextColor(fgColor)
    local tw, th = surface.GetTextSize("4")
    surface.SetTextPos((w - tw) / 2, (h - th) / 2)
    surface.DrawText("4")
end

function SKIN:PaintTextEntry(panel, w, h)
    if not HL2Scheme then return end

    local isEnabled = panel:IsEnabled()

    -- Colors from scheme (matching Source SDK TextEntry.cpp)
    -- TextEntry.BgColor is TransparentBlack (0 0 0 128) from sourceschemebase.res
    -- Use a lighter version for better visibility - light gray
    local bgColor = Color(62, 62, 66, 255) -- Lighter gray for better text visibility
    -- TextEntry.DisabledBgColor is Blank (0 0 0 0)
    local disabledBgColor = HL2Scheme.GetColor("TextEntry.DisabledBgColor", Color(0, 0, 0, 0), "SourceScheme")

    -- Draw background
    if not isEnabled then
        surface.SetDrawColor(disabledBgColor)
    else
        surface.SetDrawColor(bgColor)
    end
    surface.DrawRect(0, 0, w, h)

    -- Draw ButtonDepressedBorder style (inset border: dark on top/left, light on bottom/right)
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(200, 200, 200, 196), "SourceScheme")

    surface.SetDrawColor(colDark)
    surface.DrawLine(0, 0, w - 1, 0) -- Top
    surface.DrawLine(0, 0, 0, h - 1) -- Left

    surface.SetDrawColor(colLight)
    surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
    surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
end

function SKIN:PaintCheckBox(panel, w, h)
    if not HL2Scheme then return end

    local isChecked = panel:GetChecked()
    local isEnabled = panel:IsEnabled()

    -- Colors from scheme (matching Source SDK CheckButton.cpp)
    -- CheckButton.BgColor is TransparentBlack
    local bgColor = HL2Scheme.GetColor("CheckButton.BgColor", Color(0, 0, 0, 128), "SourceScheme")
    local disabledBgColor = HL2Scheme.GetColor("CheckButton.DisabledBgColor", Color(0, 0, 0, 128), "SourceScheme")
    -- CheckButton.Border1 references Border.Dark (40 40 40 196)
    local borderColor1 = HL2Scheme.GetColor("CheckButton.Border1", Color(40, 40, 40, 196), "SourceScheme")
    -- CheckButton.Border2 references Border.Bright (200 200 200 196)
    local borderColor2 = HL2Scheme.GetColor("CheckButton.Border2", Color(200, 200, 200, 196), "SourceScheme")
    -- CheckButton.Check is White (255 255 255 255)
    local checkColor = HL2Scheme.GetColor("CheckButton.Check", Color(255, 255, 255, 255), "SourceScheme")
    local disabledFgColor = HL2Scheme.GetColor("Label.DisabledFgColor1", Color(117, 117, 117, 255), "SourceScheme")

    -- Use Marlett font for checkbox rendering (like Source SDK)
    local marlettFont = HL2Scheme.GetFont("Marlett", "Marlett", "SourceScheme")
    surface.SetFont(marlettFont)

    -- Draw background box using Marlett 'g' character
    if isEnabled then
        surface.SetTextColor(bgColor)
    else
        surface.SetTextColor(disabledBgColor)
    end
    surface.SetTextPos(0, 1)
    surface.DrawText("g")

    -- Draw border using Marlett 'e' and 'f' characters (creates two-tone border)
    surface.SetTextColor(borderColor1)
    surface.SetTextPos(0, 1)
    surface.DrawText("e")

    surface.SetTextColor(borderColor2)
    surface.SetTextPos(0, 1)
    surface.DrawText("f")

    -- Draw check mark using Marlett 'b' character
    if isChecked then
        if not isEnabled then
            surface.SetTextColor(disabledFgColor)
        else
            surface.SetTextColor(checkColor)
        end
        surface.SetTextPos(0, 2)
        surface.DrawText("b")
    end
end

function SKIN:PaintComboBox(panel, w, h)
    if not HL2Scheme then return end

    -- ComboBox uses ComboBoxBorder which is DepressedBorder in sourceschemebase.res
    -- Use same lighter background as TextEntry for visibility
    local bgColor = Color(62, 62, 66, 255) -- Lighter gray for better text visibility

    -- Draw background
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)

    -- Draw DepressedBorder (ComboBoxBorder = DepressedBorder)
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(200, 200, 200, 196), "SourceScheme")

    -- DepressedBorder: Dark on top/left, Bright on bottom/right
    surface.SetDrawColor(colDark)
    surface.DrawLine(0, 0, w - 1, 0) -- Top
    surface.DrawLine(0, 0, 0, h - 1) -- Left

    surface.SetDrawColor(colLight)
    surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
    surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
end

function SKIN:PaintComboDownArrow(panel, w, h)
    if not HL2Scheme then return end

    -- The ComboBox button uses Marlett font with 'u' character (down arrow)
    -- ComboBoxButton has SetTextInset(3, 0) in Source SDK
    local comboBox = panel.ComboBox
    if not comboBox then return end

    local isDisabled = not comboBox:IsEnabled()
    local isPressed = comboBox.Depressed or comboBox:IsMenuOpen()
    local isHovered = comboBox.Hovered

    -- Colors from scheme
    local bgColor = HL2Scheme.GetColor("ComboBoxButton.BgColor", Color(0, 0, 0, 0), "SourceScheme")
    local arrowColor
    if isDisabled then
        arrowColor = HL2Scheme.GetColor("ComboBoxButton.ArrowColor", Color(127, 127, 127, 255), "SourceScheme")
        bgColor = HL2Scheme.GetColor("ComboBoxButton.DisabledBgColor", Color(0, 0, 0, 0), "SourceScheme")
    elseif isPressed or isHovered then
        arrowColor = HL2Scheme.GetColor("ComboBoxButton.ArmedArrowColor", Color(255, 255, 255, 255), "SourceScheme")
    else
        arrowColor = HL2Scheme.GetColor("ComboBoxButton.ArrowColor", Color(221, 221, 221, 255), "SourceScheme")
    end

    -- Draw background
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)

    -- Draw Marlett 'u' character (down arrow) with inset of 3 pixels from left
    local marlettFont = HL2Scheme.GetFont("Marlett", "Marlett", "SourceScheme")
    surface.SetFont(marlettFont)
    surface.SetTextColor(arrowColor)

    local tw, th = surface.GetTextSize("u")
    -- SetTextInset(3, 0) means 3 pixels from left, vertically centered
    surface.SetTextPos(3, (h - th) / 2)
    surface.DrawText("u")
end

function SKIN:PaintSlider(panel, w, h)
    if not HL2Scheme then return end

    -- Track background (drawn in PaintBackground in Source SDK)
    local trackColor = HL2Scheme.GetColor("Slider.TrackColor", Color(31, 31, 31, 255), "SourceScheme")
    -- Draw track
    local trackHeight = 4
    local trackY = (h - trackHeight) / 2
    surface.SetDrawColor(trackColor)
    surface.DrawRect(0, trackY, w, trackHeight)
    -- Draw inset border on track (DepressedBorder style)
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(200, 200, 200, 196), "SourceScheme")
    surface.SetDrawColor(colDark)
    surface.DrawLine(0, trackY, w - 1, trackY) -- Top
    surface.DrawLine(0, trackY, 0, trackY + trackHeight - 1) -- Left
    surface.SetDrawColor(colLight)
    surface.DrawLine(w - 1, trackY, w - 1, trackY + trackHeight - 1) -- Right
    surface.DrawLine(0, trackY + trackHeight - 1, w - 1, trackY + trackHeight - 1) -- Bottom
end

function SKIN:PaintSliderKnob(panel, w, h)
    if not HL2Scheme then return end

    local isDown = panel.Depressed
    local isDisabled = panel:GetDisabled()

    -- Slider nob color
    local nobColor = HL2Scheme.GetColor("Slider.NobColor", Color(108, 108, 108, 255), "SourceScheme")

    -- Draw knob background
    surface.SetDrawColor(nobColor)
    surface.DrawRect(0, 0, w, h)

    -- Draw raised border on knob
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(200, 200, 200, 196), "SourceScheme")

    if isDown then
        -- Depressed border
        surface.SetDrawColor(colDark)
        surface.DrawLine(0, 0, w - 1, 0) -- Top
        surface.DrawLine(0, 0, 0, h - 1) -- Left
        surface.SetDrawColor(colLight)
        surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
        surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
    else
        -- Raised border
        surface.SetDrawColor(colLight)
        surface.DrawLine(0, 0, w - 1, 0) -- Top
        surface.DrawLine(0, 0, 0, h - 1) -- Left
        surface.SetDrawColor(colDark)
        surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
        surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
    end
end

function SKIN:PaintNumSlider(panel, w, h)
    -- DNumSlider is a container - the slider track is painted by PaintSlider
    -- which should be called for the DSlider child control
end

function SKIN:PaintScrollBarGrip(panel, w, h)
    if not HL2Scheme then return end

    -- ScrollBarSlider.FgColor is the nob color (Blank = transparent)
    local nobColor = HL2Scheme.GetColor("ScrollBarSlider.FgColor", Color(0, 0, 0, 0), "SourceScheme")
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(200, 200, 200, 196), "SourceScheme")
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")

    -- Draw background
    surface.SetDrawColor(nobColor)
    surface.DrawRect(0, 0, w, h)

    -- ScrollBar grip always has inset/depressed borders in HL2 (not changing based on state)
    -- DepressedBorder: Dark on top/left, Bright on bottom/right
    surface.SetDrawColor(colDark)
    surface.DrawLine(0, 0, w - 1, 0) -- Top
    surface.DrawLine(0, 0, 0, h - 1) -- Left
    surface.SetDrawColor(colLight)
    surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
    surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
end

function SKIN:PaintVScrollBar(panel, w, h)
    if not HL2Scheme then return end
    local bgColor = HL2Scheme.GetColor("ScrollBarSlider.BgColor", Color(255, 255, 255, 64), "SourceScheme")
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintHScrollBar(panel, w, h)
    if not HL2Scheme then return end
    local bgColor = HL2Scheme.GetColor("ScrollBarSlider.BgColor", Color(255, 255, 255, 64), "SourceScheme")
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)
end


function SKIN:PaintListView(panel, w, h)
    if not HL2Scheme then return end
    -- ListPanel.BgColor is TransparentBlack in scheme
    local bgColor = HL2Scheme.GetColor("ListPanel.BgColor", Color(0, 0, 0, 128), "SourceScheme")
    -- Draw background
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)

    -- Draw depressed border (inset border for list panels)
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(200, 200, 200, 196), "SourceScheme")

    -- DepressedBorder: Dark on top/left, Bright on bottom/right
    surface.SetDrawColor(colDark)
    surface.DrawLine(0, 0, w - 1, 0) -- Top
    surface.DrawLine(0, 0, 0, h - 1) -- Left
    surface.SetDrawColor(colLight)
    surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
    surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
end

function SKIN:PaintListViewLine(panel, w, h)
    if not HL2Scheme then return end
    if panel:IsSelected() then
        -- Use ListPanel.SelectedBgColor which is Orange
        local selectedColor = HL2Scheme.GetColor("ListPanel.SelectedBgColor", Color(255, 155, 0, 255), "SourceScheme")
        surface.SetDrawColor(selectedColor)
        surface.DrawRect(0, 0, w, h)
    end
    -- Note: ListPanel doesn't have hover states in Source SDK, only selected
end

function SKIN:PaintMenuOption(panel, w, h)
    if not HL2Scheme then return end

    if panel.Hovered then
        -- Menu.ArmedBgColor is used for hovered items
        local armedBgColor = HL2Scheme.GetColor("Menu.ArmedBgColor", Color(255, 155, 0, 255), "SourceScheme")
        surface.SetDrawColor(armedBgColor)
        surface.DrawRect(0, 0, w, h)
        -- Set armed text color
        local armedTextColor = HL2Scheme.GetColor("Menu.ArmedTextColor", Color(255, 255, 255, 255), "SourceScheme")
        panel:SetTextColor(armedTextColor)
    else
        -- Set normal text color
        local textColor = HL2Scheme.GetColor("Menu.TextColor", Color(255, 255, 255, 255), "SourceScheme")
        panel:SetTextColor(textColor)
    end
end

function SKIN:PaintMenu(panel, w, h)
    if not HL2Scheme then return end
    -- Menu.BgColor from scheme
    local bgColor = HL2Scheme.GetColor("Menu.BgColor", Color(160, 160, 160, 64), "SourceScheme")
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)

    -- MenuBorder uses RaisedBorder in sourceschemebase.res
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(200, 200, 200, 196), "SourceScheme")
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")

    -- RaisedBorder: Bright on top/left, Dark on bottom/right
    surface.SetDrawColor(colLight)
    surface.DrawLine(0, 0, w - 1, 0) -- Top
    surface.DrawLine(0, 0, 0, h - 1) -- Left
    surface.SetDrawColor(colDark)
    surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
    surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
end

function SKIN:PaintMenuRightArrow(panel, w, h)
    if not HL2Scheme then return end
    -- Draw right arrow using Marlett font '4' character
    local marlettFont = HL2Scheme.GetFont("Marlett", "Marlett", "SourceScheme")
    surface.SetFont(marlettFont)

    local arrowColor = HL2Scheme.GetColor("Menu.TextColor", Color(255, 255, 255, 255), "SourceScheme")
    surface.SetTextColor(arrowColor)

    local tw, th = surface.GetTextSize("4")
    surface.SetTextPos((w - tw) / 2, (h - th) / 2)
    surface.DrawText("4")
end

function SKIN:PaintMenuSpacer(panel, w, h)
    if not HL2Scheme then return end
    -- Draw a horizontal line separator
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")
    surface.SetDrawColor(colDark)
    surface.DrawLine(4, h / 2, w - 4, h / 2)
end

function SKIN:PaintPropertySheet(panel, w, h)
    if not HL2Scheme then return end
    local bgColor = HL2Scheme.GetColor("PropertySheet.BgColor", Color(45, 45, 48, 255), "SourceScheme")
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintTab(panel, w, h)
    if not HL2Scheme then return end
    local isActive = panel:IsActive()
    local bgColor = HL2Scheme.GetColor("PropertySheet.TabBgColor", Color(81, 81, 81, 255), "SourceScheme")
    local activeBgColor = HL2Scheme.GetColor("PropertySheet.ActiveTabBgColor", Color(62, 62, 62, 255), "SourceScheme")
    if isActive then
        surface.SetDrawColor(activeBgColor)
    else
        surface.SetDrawColor(bgColor)
    end

    surface.DrawRect(0, 0, w, h)
    -- Draw top and side borders
    local borderColor = HL2Scheme.GetColor("Border.Bright", Color(120, 120, 120, 255), "SourceScheme")
    surface.SetDrawColor(borderColor)
    surface.DrawLine(0, 0, w - 1, 0) -- Top
    surface.DrawLine(0, 0, 0, h - 1) -- Left
    surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
end

function SKIN:PaintLabel(panel, w, h)
    -- Labels typically don't need special painting, text is rendered by the panel itself
    -- Label.TextColor is OffWhite in scheme
    if not HL2Scheme then return end
    if not panel.m_bCustomTextColor then
        local textColor = HL2Scheme.GetColor("Label.TextColor", Color(221, 221, 221, 255), "SourceScheme")
        panel:SetTextColor(textColor)
    end
end

function SKIN:PaintPanel(panel, w, h)
    -- Generic panel, Panel.BgColor is "Blank" (transparent) in scheme
    -- Panels typically don't draw backgrounds unless specifically enabled
    if panel.m_bPaintBackground then
        if not HL2Scheme then return end
        local bgColor = HL2Scheme.GetColor("Panel.BgColor", Color(0, 0, 0, 0), "SourceScheme")
        surface.SetDrawColor(bgColor)
        surface.DrawRect(0, 0, w, h)
    end
end

function SKIN:PaintProgress(panel, w, h)
    if not HL2Scheme then return end
    -- Background - ProgressBar.BgColor is TransparentBlack
    local bgColor = HL2Scheme.GetColor("ProgressBar.BgColor", Color(0, 0, 0, 128), "SourceScheme")
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)

    -- Progress bar - ProgressBar.FgColor is White
    local barColor = HL2Scheme.GetColor("ProgressBar.FgColor", Color(255, 255, 255, 255), "SourceScheme")
    local fraction = panel:GetFraction() or 0
    local barWidth = w * fraction
    surface.SetDrawColor(barColor)
    surface.DrawRect(0, 0, barWidth, h)

    -- Border - depressed inset style
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(200, 200, 200, 196), "SourceScheme")

    -- DepressedBorder
    surface.SetDrawColor(colDark)
    surface.DrawLine(0, 0, w - 1, 0) -- Top
    surface.DrawLine(0, 0, 0, h - 1) -- Left
    surface.SetDrawColor(colLight)
    surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
    surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
end

function SKIN:PaintTooltip(panel, w, h)
    if not HL2Scheme then return end
    -- Tooltip.BgColor from scheme (Orange in sourceschemebase.res)
    local bgColor = HL2Scheme.GetColor("Tooltip.BgColor", Color(255, 155, 0, 255), "SourceScheme")
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)

    -- ToolTipBorder - all sides dark
    local borderColor = HL2Scheme.GetColor("Border.Dark", Color(40, 40, 40, 196), "SourceScheme")
    surface.SetDrawColor(borderColor)
    surface.DrawLine(0, 0, w - 1, 0) -- Top
    surface.DrawLine(0, 0, 0, h - 1) -- Left
    surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
    surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
end

function SKIN:PaintNumberUp(panel, w, h)
    -- Number widget up button - uses Marlett 't' (up arrow)
    if not HL2Scheme then return end
    local marlettFont = HL2Scheme.GetFont("Marlett", "Marlett", "SourceScheme")
    surface.SetFont(marlettFont)

    local fgColor = HL2Scheme.GetColor("Button.TextColor", Color(255, 255, 255, 255), "SourceScheme")
    surface.SetTextColor(fgColor)

    local tw, th = surface.GetTextSize("t")
    surface.SetTextPos((w - tw) / 2, (h - th) / 2)
    surface.DrawText("t")
end

function SKIN:PaintNumberDown(panel, w, h)
    -- Number widget down button - uses Marlett 'u' (down arrow)
    if not HL2Scheme then return end
    local marlettFont = HL2Scheme.GetFont("Marlett", "Marlett", "SourceScheme")
    surface.SetFont(marlettFont)

    local fgColor = HL2Scheme.GetColor("Button.TextColor", Color(255, 255, 255, 255), "SourceScheme")
    surface.SetTextColor(fgColor)

    local tw, th = surface.GetTextSize("u")
    surface.SetTextPos((w - tw) / 2, (h - th) / 2)
    surface.DrawText("u")
end

derma.DefineSkin("HL2", "Half-Life 2 VGUI Skin", SKIN)
