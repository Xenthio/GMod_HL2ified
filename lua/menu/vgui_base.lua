if ( SERVER ) then return end

-- ---------------------------------------------------------
-- HL2Frame
-- ---------------------------------------------------------
local PANEL = {}

function PANEL:Init()
    self:SetSkin( "HL2" )
    self:SetTitle( "" )
    self:ShowCloseButton( true )
    self:SetDraggable( true )
    
    if ( self.lblTitle ) then self.lblTitle:SetVisible( false ) end
    
    if ( self.btnClose ) then
        self.btnClose:SetFont( HL2Scheme.GetFont( "Marlett", "Marlett", "SourceScheme" ) )
        self.btnClose:SetText( "r" )
        self.btnClose:SetSkin( "HL2" )
        self.btnClose:SetSize( 18, 18 )
        -- Override Paint to ensure it uses HL2Button style (DFrame's close button might have custom paint)
        self.btnClose.Paint = function( s, w, h )
            local skin = s:GetSkin()
            if ( skin and skin.PaintButton ) then
                skin:PaintButton( s, w, h )
            end
            -- Draw text manually since we overrode Paint
            surface.SetFont( s:GetFont() )
            local tw, th = surface.GetTextSize( s:GetText() )
            surface.SetTextPos( (w-tw)/2, (h-th)/2 )
            surface.SetTextColor( s:GetTextColor() )
            surface.DrawText( s:GetText() )
            return true
        end
    end

    self.FocusWeight = 1
    self.Closing = false
    self.LastVisible = false
    self:SetAlpha( 0 )
end

function PANEL:PerformLayout()
    if ( self.btnClose ) then
        local w, h = self:GetSize()
        -- Source: (wide-side_border_offset)-offset, top_border_offset
        -- side_border_offset = 5, offset = 20 (if only close button)
        -- top_border_offset = 8
        -- So x = w - 5 - 20 = w - 25?
        -- Wait, offset starts at 20.
        -- _closeButton->SetPos((wide-5)-20, 8) -> w-25, 8.
        -- Button size is 18x18.
        self.btnClose:SetPos( w - 25, 8 )
        self.btnClose:SetSize( 18, 18 )
    end
end

function PANEL:Think()
    local dframe = vgui.GetControlTable( "DFrame" )
    if ( dframe and dframe.Think ) then
        dframe.Think( self )
    end

    -- Detect visibility change (Open)
    if ( self:IsVisible() != self.LastVisible ) then
        if ( self:IsVisible() ) then
            self:SetAlpha( 0 )
            self.Closing = false
        end
        self.LastVisible = self:IsVisible()
    end

    -- Handle Focus Transition
    local focusTime = tonumber( HL2Scheme.GetResourceString( "Frame.FocusTransitionEffectTime", nil, "SourceScheme" ) ) or 0.3
    local targetWeight = self:IsActive() and 1 or 0
    
    if ( self.FocusWeight != targetWeight ) then
        self.FocusWeight = math.Approach( self.FocusWeight, targetWeight, (1 / focusTime) * FrameTime() )
    end
    
    -- Handle Visibility Fade
    local transitionTime = tonumber( HL2Scheme.GetResourceString( "Frame.TransitionEffectTime", nil, "SourceScheme" ) ) or 0.3
    
    if ( self.Closing ) then
        local alpha = self:GetAlpha()
        alpha = math.Approach( alpha, 0, (255 / transitionTime) * FrameTime() )
        self:SetAlpha( alpha )
        
        if ( alpha == 0 ) then
            self.Closing = false
            self:SetVisible( false )
            if ( self:GetDeleteOnClose() ) then self:Remove() end
        end
    elseif ( self:IsVisible() and self:GetAlpha() < 255 ) then
        local alpha = self:GetAlpha()
        alpha = math.Approach( alpha, 255, (255 / transitionTime) * FrameTime() )
        self:SetAlpha( alpha )
    end
end

function PANEL:Close()
    self.Closing = true
end

function PANEL:SetTitleText( str )
    self:SetTitle( str )
end

vgui.Register( "HL2Frame", PANEL, "DFrame" )

-- ---------------------------------------------------------
-- HL2Button
-- ---------------------------------------------------------
local BUTTON = {}

function BUTTON:Init()
    self:SetSkin( "HL2" )
    self:SetFont( HL2Scheme.GetFont( "Default", "Default", "SourceScheme" ) ) -- Default font from scheme
    self:SetText( "" )
    self:SetCursor( "arrow" ) -- Don't change cursor to hand
    self:SetTextInset( 6, 0 ) -- Match Source Button.cpp
end

vgui.Register( "HL2Button", BUTTON, "DButton" )
