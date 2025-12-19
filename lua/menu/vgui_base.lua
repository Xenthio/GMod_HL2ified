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
    local bgColor = HL2Scheme.GetColor( "Frame.BgColor", Color( 0, 0, 0, 196 ) )
    
    -- Draw rounded background (Corner radius usually 8-10 in Source)
    draw.RoundedBox( 8, 0, 0, w, h, bgColor )
    
    -- Border
    -- Source frames usually have a border color
    local borderColor = HL2Scheme.GetColor( "Frame.AutoSelectionBoxColor", Color( 255, 255, 255, 20 ) )
    if ( HL2Scheme.Colors["Border.Bright"] ) then borderColor = HL2Scheme.Colors["Border.Bright"] end
    
    -- We can't easily draw a rounded outline with standard surface functions without a texture or poly
    -- For now, we'll draw a rectangular outline which is "close enough" or try to be clever
    -- Actually, let's just draw the title divider
    
    surface.SetDrawColor( borderColor )
    -- surface.DrawOutlinedRect( 0, 0, w, h ) -- Rectangular border looks bad on rounded bg
    
    -- Title bar divider
    surface.SetDrawColor( borderColor )
    surface.DrawLine( 0, 36, w, 36 )
    
    -- Title
    if ( self.TitleText ) then
        -- Use the scheme-defined title font (usually UiBold or DefaultLarge)
        -- User requested "same size as normal thing but bold", which matches UiBold.
        -- SourceScheme.res sometimes defines it as DefaultLarge (too big). We force UiBold if available.
        local font = "UiBold"
        if ( !HL2Scheme.Fonts[font] ) then
            font = HL2Scheme.GetFont( "FrameTitleBar.Font", "DefaultBold" )
        end
        
        surface.SetFont( font )
        surface.SetTextColor( HL2Scheme.GetColor( "FrameTitleBar.TextColor", Color( 255, 255, 255 ) ) )
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
    self:SetFont( "Default" ) -- Default font from scheme
    self:SetText( "" )
end

function BUTTON:Paint( w, h )
    local isDown = self:IsDown()
    local isHovered = self:IsHovered()
    local isDisabled = !self:IsEnabled()
    
    -- Colors
    local textColor = HL2Scheme.GetColor( "Button.TextColor", Color( 255, 255, 255 ) )
    local bgColor = HL2Scheme.GetColor( "Button.BgColor", Color( 0, 0, 0, 0 ) )
    
    -- Borders
    local colLight = HL2Scheme.GetColor( "Border.Bright", Color( 255, 255, 255, 100 ) )
    local colDark = HL2Scheme.GetColor( "Border.Dark", Color( 0, 0, 0, 100 ) )
    
    if ( isDisabled ) then
        textColor = HL2Scheme.GetColor( "Button.DisabledTextColor", Color( 100, 100, 100 ) )
    elseif ( isDown ) then
        textColor = HL2Scheme.GetColor( "Button.DepressedTextColor", textColor )
        bgColor = HL2Scheme.GetColor( "Button.DepressedBgColor", Color( 0, 0, 0, 200 ) )
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
    
    return false 
end

vgui.Register( "HL2Button", BUTTON, "DButton" )
