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
    -- Background
    local activeCol = HL2Scheme.GetColor("Frame.BgColor", Color(0, 0, 0, 196), "SourceScheme")
    local inactiveCol = HL2Scheme.GetColor("Frame.OutOfFocusBgColor", Color(160, 160, 160, 32), "SourceScheme")
    local focusWeight = panel.FocusWeight or (panel:IsActive() and 1 or 0)
    -- Interpolate based on FocusWeight
    local r = Lerp(focusWeight, inactiveCol.r, activeCol.r)
    local g = Lerp(focusWeight, inactiveCol.g, activeCol.g)
    local b = Lerp(focusWeight, inactiveCol.b, activeCol.b)
    local a = Lerp(focusWeight, inactiveCol.a, activeCol.a)
    local bgColor = Color(r, g, b, a)
    draw.RoundedBox(8, 0, 0, w, h, bgColor)

    -- Title
    if panel.GetTitle then
        local title = panel:GetTitle()
        if title and title ~= "" then
            local font = HL2Scheme.GetFont("UiBold", "DefaultBold", "SourceScheme")
            surface.SetFont(font)
            surface.SetTextColor(HL2Scheme.GetColor("FrameTitleBar.TextColor", Color(255, 255, 255), "SourceScheme"))
            -- Source uses 28, 9 for title inset
            -- User requested it to be less far right
            surface.SetTextPos(15, 9)
            surface.DrawText(title)
        end
    end
end

function SKIN:PaintButton(panel, w, h)
    if not HL2Scheme then return end
    local isDown = panel:IsDown()
    local isDisabled = not panel:IsEnabled()

    -- Colors
    local textColor = HL2Scheme.GetColor("Button.TextColor", Color(255, 255, 255), "SourceScheme")
    local bgColor = HL2Scheme.GetColor("Button.BgColor", Color(0, 0, 0, 0), "SourceScheme")
    if panel.IsTitleButton then
        textColor = HL2Scheme.GetColor("FrameTitleButton.FgColor", Color(200, 200, 200, 196), "SourceScheme")
        if isDisabled then textColor = HL2Scheme.GetColor("FrameTitleButton.DisabledFgColor", Color(255, 255, 255, 192), "SourceScheme") end
        panel:SetTextColor(textColor)
        return
    end

    -- Borders
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(255, 255, 255, 100), "SourceScheme")
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(0, 0, 0, 100), "SourceScheme")
    if isDisabled then
        textColor = HL2Scheme.GetColor("Button.DisabledTextColor", Color(100, 100, 100), "SourceScheme")
    elseif isDown then
        textColor = HL2Scheme.GetColor("Button.DepressedTextColor", textColor, "SourceScheme")
        bgColor = HL2Scheme.GetColor("Button.DepressedBgColor", Color(0, 0, 0, 200), "SourceScheme")
        surface.SetDrawColor(bgColor)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(colDark)
        surface.DrawLine(0, 0, w - 1, 0) -- Top
        surface.DrawLine(0, 0, 0, h - 1) -- Left
        surface.SetDrawColor(colLight)
        surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
        surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
    else
        surface.SetDrawColor(bgColor)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(colLight)
        surface.DrawLine(0, 0, w - 1, 0)
        surface.DrawLine(0, 0, 0, h - 1)
        surface.SetDrawColor(colDark)
        surface.DrawLine(w - 1, 0, w - 1, h - 1)
        surface.DrawLine(0, h - 1, w - 1, h - 1)
    end

    panel:SetTextColor(textColor)
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

function SKIN:PaintTextEntry(panel, w, h)
    if not HL2Scheme then return end
    local isEnabled = panel:IsEnabled()
    local isFocused = panel:HasFocus()
    -- Background color
    local bgColor = HL2Scheme.GetColor("TextEntry.BgColor", Color(60, 60, 60, 255), "SourceScheme")
    local disabledBgColor = HL2Scheme.GetColor("TextEntry.DisabledBgColor", Color(50, 50, 50, 255), "SourceScheme")
    local selectedBgColor = HL2Scheme.GetColor("TextEntry.SelectedBgColor", Color(80, 80, 80, 255), "SourceScheme")
    -- Border colors
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(136, 136, 136, 255), "SourceScheme")
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(60, 60, 60, 255), "SourceScheme")
    -- Draw background
    if not isEnabled then
        surface.SetDrawColor(disabledBgColor)
    elseif isFocused then
        surface.SetDrawColor(selectedBgColor)
    else
        surface.SetDrawColor(bgColor)
    end

    surface.DrawRect(0, 0, w, h)
    -- Draw inset border (dark on top/left, light on bottom/right)
    surface.SetDrawColor(colDark)
    surface.DrawLine(0, 0, w - 1, 0) -- Top
    surface.DrawLine(0, 0, 0, h - 1) -- Left
    surface.SetDrawColor(colLight)
    surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
    surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
    -- Text color
    local textColor = HL2Scheme.GetColor("TextEntry.TextColor", Color(200, 200, 200, 255), "SourceScheme")
    local disabledTextColor = HL2Scheme.GetColor("TextEntry.DisabledTextColor", Color(128, 128, 128, 255), "SourceScheme")
    if not isEnabled then
        panel:SetTextColor(disabledTextColor)
    else
        panel:SetTextColor(textColor)
    end

    -- Cursor and highlight color
    panel:SetCursorColor(HL2Scheme.GetColor("TextEntry.CursorColor", Color(255, 255, 255, 255), "SourceScheme"))
    panel:SetHighlightColor(HL2Scheme.GetColor("TextEntry.SelectedTextColor", Color(255, 255, 0, 255), "SourceScheme"))
end

function SKIN:PaintCheckBox(panel, w, h)
    if not HL2Scheme then return end
    local isChecked = panel:GetChecked()

    -- Colors
    local bgColor = HL2Scheme.GetColor("CheckButton.BgColor", Color(45, 45, 48, 255), "SourceScheme")
    local checkColor = HL2Scheme.GetColor("CheckButton.Check", Color(255, 255, 255, 255), "SourceScheme")

    -- Draw background
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)

    -- Draw border (inset style)
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(60, 60, 60, 255), "SourceScheme")
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(136, 136, 136, 255), "SourceScheme")
    surface.SetDrawColor(colDark)
    surface.DrawLine(0, 0, w - 1, 0) -- Top
    surface.DrawLine(0, 0, 0, h - 1) -- Left
    surface.SetDrawColor(colLight)
    surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
    surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
    -- Draw check mark
    if isChecked then
        -- Draw an X or checkmark
        surface.SetDrawColor(checkColor)
        -- Simple checkmark using lines
        local mx, my = w / 2, h / 2
        surface.DrawLine(mx - 4, my - 1, mx - 1, my + 2)
        surface.DrawLine(mx - 1, my + 2, mx + 4, my - 3)
        surface.DrawLine(mx - 4, my, mx - 1, my + 3)
        surface.DrawLine(mx - 1, my + 3, mx + 4, my - 2)
    end
end

function SKIN:PaintComboBox(panel, w, h)
    if not HL2Scheme then return end
    local isOpen = panel:IsMenuOpen()
    local isDown = panel:IsDown()

    -- Colors from scheme
    local bgColor = HL2Scheme.GetColor("ComboBoxButton.BgColor", Color(81, 81, 81, 255), "SourceScheme")
    local arrowColor = HL2Scheme.GetColor("ComboBoxButton.ArrowColor", Color(200, 200, 200, 255), "SourceScheme")

    -- Borders
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(136, 136, 136, 255), "SourceScheme")
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(60, 60, 60, 255), "SourceScheme")
    -- Draw background
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)
    -- Draw borders (raised style when not pressed)
    if isDown or isOpen then
        surface.SetDrawColor(colDark)
        surface.DrawLine(0, 0, w - 1, 0) -- Top
        surface.DrawLine(0, 0, 0, h - 1) -- Left
        surface.SetDrawColor(colLight)
        surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
        surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
    else
        surface.SetDrawColor(colLight)
        surface.DrawLine(0, 0, w - 1, 0) -- Top
        surface.DrawLine(0, 0, 0, h - 1) -- Left
        surface.SetDrawColor(colDark)
        surface.DrawLine(w - 1, 0, w - 1, h - 1) -- Right
        surface.DrawLine(0, h - 1, w - 1, h - 1) -- Bottom
    end

    -- Draw dropdown arrow on the right
    local arrowSize = 4
    local arrowX = w - 12
    local arrowY = h / 2
    surface.SetDrawColor(arrowColor)
    -- Draw downward pointing triangle
    for i = 0, arrowSize do
        surface.DrawLine(arrowX - i, arrowY - arrowSize + i, arrowX + i, arrowY - arrowSize + i)
    end
end

function SKIN:PaintSlider(panel, w, h)
    if not HL2Scheme then return end

    -- Track background
    local trackColor = HL2Scheme.GetColor("Slider.TrackColor", Color(60, 60, 60, 255), "SourceScheme")
    -- Draw track
    local trackHeight = 4
    local trackY = (h - trackHeight) / 2
    surface.SetDrawColor(trackColor)
    surface.DrawRect(0, trackY, w, trackHeight)
    -- Borders on track
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(60, 60, 60, 255), "SourceScheme")
    surface.SetDrawColor(colDark)
    surface.DrawOutlinedRect(0, trackY, w, trackHeight)
end

function SKIN:PaintNumSlider(panel, w, h)
    -- NumSlider is typically just a container, actual slider is inside
    -- We can draw a simple background if needed
end

function SKIN:PaintScrollBarGrip(panel, w, h)
    if not HL2Scheme then return end
    local isDown = panel:IsDown()

    -- Colors
    local bgColor = HL2Scheme.GetColor("ScrollBar.GripColor", Color(100, 100, 100, 255), "SourceScheme")
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(136, 136, 136, 255), "SourceScheme")
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(60, 60, 60, 255), "SourceScheme")
    -- Draw background
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)
    -- Draw raised border
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
end

function SKIN:PaintVScrollBar(panel, w, h)
    if not HL2Scheme then return end
    local bgColor = HL2Scheme.GetColor("ScrollBar.BgColor", Color(45, 45, 48, 255), "SourceScheme")
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintListView(panel, w, h)
    if not HL2Scheme then return end
    local bgColor = HL2Scheme.GetColor("ListPanel.BgColor", Color(45, 45, 48, 255), "SourceScheme")
    -- Draw background
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)
    -- Draw border
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(60, 60, 60, 255), "SourceScheme")
    local colLight = HL2Scheme.GetColor("Border.Bright", Color(136, 136, 136, 255), "SourceScheme")
    surface.SetDrawColor(colDark)
    surface.DrawLine(0, 0, w - 1, 0)
    surface.DrawLine(0, 0, 0, h - 1)
    surface.SetDrawColor(colLight)
    surface.DrawLine(w - 1, 0, w - 1, h - 1)
    surface.DrawLine(0, h - 1, w - 1, h - 1)
end

function SKIN:PaintListViewLine(panel, w, h)
    if not HL2Scheme then return end
    if panel:IsSelected() then
        local selectedColor = HL2Scheme.GetColor("ListPanel.SelectedBgColor", Color(255, 155, 0, 255), "SourceScheme")
        surface.SetDrawColor(selectedColor)
        surface.DrawRect(0, 0, w, h)
    elseif panel:IsHovered() then
        local hoverColor = HL2Scheme.GetColor("ListPanel.HoverBgColor", Color(70, 70, 70, 255), "SourceScheme")
        surface.SetDrawColor(hoverColor)
        surface.DrawRect(0, 0, w, h)
    elseif panel.m_bAlt then
        local altColor = HL2Scheme.GetColor("ListPanel.AltBgColor", Color(40, 40, 40, 255), "SourceScheme")
        surface.SetDrawColor(altColor)
        surface.DrawRect(0, 0, w, h)
    end
end

function SKIN:PaintMenuOption(panel, w, h)
    if not HL2Scheme then return end
    if panel.m_bBackground then
        local bgColor = HL2Scheme.GetColor("Menu.BgColor", Color(62, 62, 62, 255), "SourceScheme")
        surface.SetDrawColor(bgColor)
        surface.DrawRect(0, 0, w, h)
    end

    if panel:GetHovered() then
        local hoverColor = HL2Scheme.GetColor("Menu.HoverBgColor", Color(255, 155, 0, 255), "SourceScheme")
        surface.SetDrawColor(hoverColor)
        surface.DrawRect(0, 0, w, h)
    end
end

function SKIN:PaintMenu(panel, w, h)
    if not HL2Scheme then return end
    local bgColor = HL2Scheme.GetColor("Menu.BgColor", Color(62, 62, 62, 255), "SourceScheme")
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)
    -- Draw border
    local borderColor = HL2Scheme.GetColor("Menu.BorderColor", Color(120, 120, 120, 255), "SourceScheme")
    surface.SetDrawColor(borderColor)
    surface.DrawOutlinedRect(0, 0, w, h)
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
    -- But we can ensure proper text color
    if not HL2Scheme then return end
    if not panel.m_bCustomTextColor then
        local textColor = HL2Scheme.GetColor("Label.TextColor", Color(200, 200, 200, 255), "SourceScheme")
        panel:SetTextColor(textColor)
    end
end

function SKIN:PaintPanel(panel, w, h)
    -- Generic panel, can have a background
    if panel.m_bPaintBackground then
        if not HL2Scheme then return end
        local bgColor = HL2Scheme.GetColor("Panel.BgColor", Color(62, 62, 62, 255), "SourceScheme")
        surface.SetDrawColor(bgColor)
        surface.DrawRect(0, 0, w, h)
    end
end

function SKIN:PaintProgress(panel, w, h)
    if not HL2Scheme then return end
    -- Background
    local bgColor = HL2Scheme.GetColor("ProgressBar.BgColor", Color(60, 60, 60, 255), "SourceScheme")
    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)
    -- Progress bar
    local barColor = HL2Scheme.GetColor("ProgressBar.FgColor", Color(255, 155, 0, 255), "SourceScheme")
    local fraction = panel:GetFraction() or 0
    local barWidth = w * fraction
    surface.SetDrawColor(barColor)
    surface.DrawRect(0, 0, barWidth, h)
    -- Border
    local colDark = HL2Scheme.GetColor("Border.Dark", Color(60, 60, 60, 255), "SourceScheme")
    surface.SetDrawColor(colDark)
    surface.DrawOutlinedRect(0, 0, w, h)
end

derma.DefineSkin("HL2", "Half-Life 2 VGUI Skin", SKIN)
