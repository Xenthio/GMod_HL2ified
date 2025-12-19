if ( SERVER ) then return end

-- ---------------------------------------------------------
-- HL2Frame
-- ---------------------------------------------------------
local PANEL = {}

function PANEL:Init()
    self:SetTitle( "" )
    self:ShowCloseButton( false )
    self:SetDraggable( true )
end

function PANEL:Paint( w, h )
    -- Background
    local bgColor = HL2Scheme.GetColor( "Frame.BgColor", Color( 0, 0, 0, 196 ), "SourceScheme" )
    
    if ( self.IsActive and !self:IsActive() ) then
        bgColor = HL2Scheme.GetColor( "Frame.OutOfFocusBgColor", bgColor, "SourceScheme" )
    end

    -- Draw rounded background (Corner radius usually 8-10 in Source)
    draw.RoundedBox( 8, 0, 0, w, h, bgColor )
    
    -- Border
    -- Source frames usually have a border color
    local borderColor = HL2Scheme.GetColor( "Frame.AutoSelectionBoxColor", Color( 255, 255, 255, 20 ), "SourceScheme" )
    -- Check if Border.Bright exists in SourceScheme
    local bright = HL2Scheme.GetColor( "Border.Bright", nil, "SourceScheme" )
    if ( bright ) then borderColor = bright end
    
    -- We can't easily draw a rounded outline with standard surface functions without a texture or poly
    -- For now, we'll draw a rectangular outline which is "close enough" or try to be clever
    -- Actually, let's just draw the title divider
    
    surface.SetDrawColor( borderColor )
    -- surface.DrawOutlinedRect( 0, 0, w, h ) -- Rectangular border looks bad on rounded bg
    
    -- Title bar divider
    -- surface.SetDrawColor( borderColor )
    -- surface.DrawLine( 0, 28, w, 28 )
    
    -- Title
    if ( self.TitleText ) then
        -- Use the scheme-defined title font (usually UiBold or DefaultLarge)
        -- User requested "same size as normal thing but bold", which matches UiBold.
        -- SourceScheme.res sometimes defines it as DefaultLarge (too big). We force UiBold if available.
        local font = HL2Scheme.GetFont( "UiBold", "DefaultBold", "SourceScheme" )
        
        surface.SetFont( font )
        surface.SetTextColor( HL2Scheme.GetColor( "FrameTitleBar.TextColor", Color( 255, 255, 255 ), "SourceScheme" ) )
        surface.SetTextPos( 16, 6 ) -- Adjusted inset (Frame.TitleTextInsetX is 16)
        surface.DrawText( self.TitleText )
    end
end

function PANEL:SetTitleText( str )
    self.TitleText = str
end

vgui.Register( "HL2Frame", PANEL, "DFrame" )

-- ---------------------------------------------------------
-- HL2Button
-- ---------------------------------------------------------
local BUTTON = {}

function BUTTON:Init()
    self:SetFont( HL2Scheme.GetFont( "Default", "Default", "SourceScheme" ) ) -- Default font from scheme
    self:SetText( "" )
end

function BUTTON:Paint( w, h )
    local isDown = self:IsDown()
    local isHovered = self:IsHovered()
    local isDisabled = !self:IsEnabled()
    
    -- Colors
    local textColor = HL2Scheme.GetColor( "Button.TextColor", Color( 255, 255, 255 ), "SourceScheme" )
    local bgColor = HL2Scheme.GetColor( "Button.BgColor", Color( 0, 0, 0, 0 ), "SourceScheme" )
    
    -- Borders
    local colLight = HL2Scheme.GetColor( "Border.Bright", Color( 255, 255, 255, 100 ), "SourceScheme" )
    local colDark = HL2Scheme.GetColor( "Border.Dark", Color( 0, 0, 0, 100 ), "SourceScheme" )
    
    if ( isDisabled ) then
        textColor = HL2Scheme.GetColor( "Button.DisabledTextColor", Color( 100, 100, 100 ), "SourceScheme" )
    elseif ( isDown ) then
        textColor = HL2Scheme.GetColor( "Button.DepressedTextColor", textColor, "SourceScheme" )
        bgColor = HL2Scheme.GetColor( "Button.DepressedBgColor", Color( 0, 0, 0, 200 ), "SourceScheme" )
        -- Depressed: Dark Top/Left, Light Bottom/Right
        surface.SetDrawColor( bgColor )
        surface.DrawRect( 0, 0, w, h )
        
        surface.SetDrawColor( colDark )
        surface.DrawLine( 0, 0, w-1, 0 ) -- Top
        surface.DrawLine( 0, 0, 0, h-1 ) -- Left
        
        surface.SetDrawColor( colLight )
        surface.DrawLine( w-1, 0, w-1, h-1 ) -- Right
        surface.DrawLine( 0, h-1, w-1, h-1 ) -- Bottom
        
    elseif ( isHovered ) then
        textColor = HL2Scheme.GetColor( "Button.ArmedTextColor", textColor )
        bgColor = HL2Scheme.GetColor( "Button.ArmedBgColor", Color( 255, 255, 255, 10 ) )
        
        -- Armed: Light Top/Left, Dark Bottom/Right
        surface.SetDrawColor( bgColor )
        surface.DrawRect( 0, 0, w, h )
        
        surface.SetDrawColor( colLight )
        surface.DrawLine( 0, 0, w-1, 0 ) -- Top
        surface.DrawLine( 0, 0, 0, h-1 ) -- Left
        
        surface.SetDrawColor( colDark )
        surface.DrawLine( w-1, 0, w-1, h-1 ) -- Right
        surface.DrawLine( 0, h-1, w-1, h-1 ) -- Bottom
    else
        -- Normal: Usually just text, or faint border?
        -- In NewGameDialog, buttons are visible boxes.
        -- Let's assume they are Raised by default but less opaque?
        -- Or maybe just a border?
        -- Let's draw a faint raised border
        surface.SetDrawColor( bgColor )
        surface.DrawRect( 0, 0, w, h )
        
        surface.SetDrawColor( colLight )
        surface.DrawLine( 0, 0, w-1, 0 )
        surface.DrawLine( 0, 0, 0, h-1 )
        
        surface.SetDrawColor( colDark )
        surface.DrawLine( w-1, 0, w-1, h-1 )
        surface.DrawLine( 0, h-1, w-1, h-1 )
    end
    
    -- Draw Text
    self:SetTextColor( textColor )
    -- DButton:Paint calls DrawLabel if we don't return true?
    -- Actually DButton:Paint does:
    -- if ( self.m_bBorder ) then self.Skin:PaintButton( self, w, h ) end
    -- return false
    -- But we are overriding Paint completely.
    -- We need to call the base class Paint to draw the text, OR draw it ourselves.
    -- DLabel:Paint (which DButton inherits) draws the text.
    -- So we should call BaseClass.Paint( self, w, h ) but that might draw the skin's button background.
    -- Instead, let's just rely on DLabel's ApplySchemeSettings or just call DrawLabel?
    -- DLabel doesn't have a DrawLabel method exposed easily usually, it's in Paint.
    -- Wait, DButton is a DLabel. DLabel:Paint() draws text.
    -- If we return false, does it call base? No, Paint is the function.
    
    -- We must draw the text manually or call a method to do it.
    -- DLabel has :SetText() and :SetFont().
    -- We can use self:ApplySchemeSettings() to update colors?
    -- Let's just use the standard way to draw text in a button if we are overriding Paint.
    
    local font = self:GetFont()
    surface.SetFont( font )
    local tw, th = surface.GetTextSize( self:GetText() )
    
    local tx, ty = 0, 0
    local align = self:GetContentAlignment() -- 4 = left, 5 = center, 6 = right
    
    if ( align == 4 ) then -- Left
        tx = 10
        ty = (h - th) / 2
    elseif ( align == 6 ) then -- Right
        tx = w - tw - 10
        ty = (h - th) / 2
    else -- Center (5)
        tx = (w - tw) / 2
        ty = (h - th) / 2
    end
    
    -- Offset if depressed
    if ( isDown ) then
        tx = tx + 1
        ty = ty + 1
    end
    
    surface.SetTextColor( textColor )
    surface.SetTextPos( tx, ty )
    surface.DrawText( self:GetText() )
    
    return true
end

vgui.Register( "HL2Button", BUTTON, "DButton" )
