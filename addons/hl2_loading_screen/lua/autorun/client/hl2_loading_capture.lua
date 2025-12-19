-- HL2 Loading Screen - Client Side Capture
-- Updates _rt_fullframefb every frame so menu state can access the last rendered frame

-- PreDrawHUD hook runs after most things - captures the 3D scene
hook.Add( "PreDrawHUD", "HL2LoadingCapture", function()
	render.UpdateScreenEffectTexture( 0 )
end )

print( "[HL2 Loading] Screen capture system initialized" )


-- test convar, just creates a vgui panel showing the last frame
local HL2TestPanel = nil
concommand.Add( "hl2_test_loading_capture", function()
    if IsValid( HL2TestPanel ) then
        HL2TestPanel:Remove()
        HL2TestPanel = nil
        return
    end
    
    HL2TestPanel = vgui.Create( "Frame" )
    HL2TestPanel:SetSize( 800, 600 )
    HL2TestPanel:Center()
HL2TestPanel:SetVisible( true )
    --HL2TestPanel:SetBackgroundColor( Color( 0, 0, 0, 255 ) )
    --HL2TestPanel:SetTitle( "HL2 Loading Capture Test" )
    HL2TestPanel:MakePopup()
    
    HL2TestPanel.Paint = function( self, w, h )
        local mat = CreateMaterial( "hl2_test_loading_capture_mat", "UnlitGeneric", {
            ["$basetexture"] = "_rt_fullframefb"
        } )
        
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( mat )
        surface.DrawTexturedRect( 0, 0, w, h )
    end
end )