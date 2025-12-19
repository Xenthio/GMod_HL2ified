
if ( SERVER ) then return end

local chapters = {}

local function LoadChapters()
	chapters = {}
	local files, dirs = file.Find( "cfg/chapter*.cfg", "GAME" )
	
	for _, f in ipairs( files ) do
		local num = string.match( f, "chapter(%d+).cfg" )
		if ( num ) then
			table.insert( chapters, {
				file = f,
				num = tonumber( num ),
                image = "chapters/chapter" .. num
			} )
		end
	end
    
    if ( file.Exists( "cfg/chapter9a.cfg", "GAME" ) ) then
         table.insert( chapters, {
            file = "chapter9a.cfg",
            num = 9.5,
            image = "chapters/chapter9a"
        } )
    end
	
	table.SortByMember( chapters, "num", true )
end

-- ---------------------------------------------------------
-- CGameChapterPanel
-- ---------------------------------------------------------
local CHAPTER_PANEL = {}

function CHAPTER_PANEL:Init()
    self:SetSize( 172, 150 )
    
    self.ChapterLabel = vgui.Create( "DLabel", self )
    self.ChapterLabel:SetPos( 0, 4 )
    self.ChapterLabel:SetSize( 172, 20 )
    self.ChapterLabel:SetFont( "DefaultBold" ) -- Use standard scheme font
    self.ChapterLabel:SetText( "CHAPTER" )
    self.ChapterLabel:SetContentAlignment( 4 ) 
    self.ChapterLabel:SetTextColor( HL2Scheme.GetColor( "NewGame.TextColor", Color( 255, 255, 255, 255 ) ) )
    
    self.ChapterNameLabel = vgui.Create( "DLabel", self )
    self.ChapterNameLabel:SetPos( 0, 20 )
    self.ChapterNameLabel:SetSize( 172, 20 )
    self.ChapterNameLabel:SetFont( "DefaultBold" )
    self.ChapterNameLabel:SetText( "NAME" )
    self.ChapterNameLabel:SetContentAlignment( 4 )
    self.ChapterNameLabel:SetTextColor( HL2Scheme.GetColor( "NewGame.TextColor", Color( 255, 255, 255, 255 ) ) )
    
    self.LevelPicBorder = vgui.Create( "Panel", self )
    self.LevelPicBorder:SetPos( 0, 40 )
    self.LevelPicBorder:SetSize( 168, 106 )
    self.LevelPicBorder.Paint = function( s, w, h )
        surface.SetDrawColor( s.Color or HL2Scheme.GetColor( "NewGame.FillColor", Color( 0, 0, 0, 255 ) ) )
        surface.DrawRect( 0, 0, w, h )
    end
    
    self.LevelPic = vgui.Create( "DImage", self )
    self.LevelPic:SetPos( 10, 50 )
    self.LevelPic:SetSize( 152, 86 )
    
    self.Button = vgui.Create( "Button", self )
    self.Button:SetSize( 172, 150 )
    self.Button:SetText( "" )
    self.Button.Paint = function() end
    self.Button.DoClick = function() 
        if ( self.DoClick ) then self:DoClick() end
    end
end

function CHAPTER_PANEL:SetData( data )
    self.Data = data
    self.ChapterLabel:SetText( "CHAPTER " .. math.floor(data.num) )
    self.ChapterNameLabel:SetText( "Chapter " .. math.floor(data.num) )
    self.LevelPic:SetImage( data.image )
end

function CHAPTER_PANEL:SetSelected( bSelected )
    local textColor = HL2Scheme.GetColor( "NewGame.TextColor", Color( 255, 255, 255, 255 ) )
    local selColor = HL2Scheme.GetColor( "NewGame.SelectionColor", Color( 255, 155, 0, 255 ) )
    local fillColor = HL2Scheme.GetColor( "NewGame.FillColor", Color( 0, 0, 0, 255 ) )

    if ( bSelected ) then
        self.LevelPicBorder.Color = selColor
        self.ChapterLabel:SetTextColor( selColor )
        self.ChapterNameLabel:SetTextColor( selColor )
    else
        self.LevelPicBorder.Color = fillColor
        self.ChapterLabel:SetTextColor( textColor )
        self.ChapterNameLabel:SetTextColor( textColor )
    end
end

vgui.Register( "CGameChapterPanel", CHAPTER_PANEL, "EditablePanel" )

-- ---------------------------------------------------------
-- CNewGameDialog
-- ---------------------------------------------------------
local PANEL = {}

function PANEL:Init()
    self:SetSize( 600, 296 )
    self:Center()
    self:MakePopup()
    self:SetTitleText( "#GameUI_NewGame" )
    self:SetVisible( true )
    
    -- Dividers
    local div1 = vgui.Create( "Panel", self )
    div1:SetPos( 24, 44 )
    div1:SetSize( 548, 2 )
    div1.Paint = function( s, w, h ) 
        surface.SetDrawColor( HL2Scheme.GetColor("Border.Dark", Color(0,0,0,100)) )
        surface.DrawRect( 0, 0, w, 1 )
        surface.SetDrawColor( HL2Scheme.GetColor("Border.Bright", Color(255,255,255,50)) )
        surface.DrawRect( 0, 1, w, 1 )
    end
    
    local div2 = vgui.Create( "Panel", self )
    div2:SetPos( 24, 236 )
    div2:SetSize( 548, 2 )
    div2.Paint = function( s, w, h ) 
        surface.SetDrawColor( HL2Scheme.GetColor("Border.Dark", Color(0,0,0,100)) )
        surface.DrawRect( 0, 0, w, 1 )
        surface.SetDrawColor( HL2Scheme.GetColor("Border.Bright", Color(255,255,255,50)) )
        surface.DrawRect( 0, 1, w, 1 )
    end
    
    -- Buttons
    self.btnNext = vgui.Create( "HL2Button", self )
    self.btnNext:SetText( "#GameUI_Next" )
    self.btnNext:SetPos( 500, 200 )
    self.btnNext:SetSize( 72, 24 )
    self.btnNext.DoClick = function() self:NextPage() end
    
    self.btnPrev = vgui.Create( "HL2Button", self )
    self.btnPrev:SetText( "#GameUI_Prev" )
    self.btnPrev:SetPos( 24, 200 )
    self.btnPrev:SetSize( 72, 24 )
    self.btnPrev:SetVisible( false )
    self.btnPrev.DoClick = function() self:PrevPage() end
    
    self.btnPlay = vgui.Create( "HL2Button", self )
    self.btnPlay:SetText( "#GameUI_StartNewGame" )
    self.btnPlay:SetPos( 363, 252 )
    self.btnPlay:SetSize( 124, 24 )
    self.btnPlay.DoClick = function() self:StartGame() end
    
    self.btnCancel = vgui.Create( "HL2Button", self )
    self.btnCancel:SetText( "#GameUI_Cancel" )
    self.btnCancel:SetPos( 500, 252 )
    self.btnCancel:SetSize( 72, 24 )
    self.btnCancel.DoClick = function() self:Remove() end
    
    -- Chapter Container
    self.ChapterContainer = vgui.Create( "Panel", self )
    self.ChapterContainer:SetPos( 24, 50 )
    self.ChapterContainer:SetSize( 548, 160 )
    
    LoadChapters()
    self.CurrentIndex = 1
    self:UpdateChapters()
end

function PANEL:UpdateChapters()
    self.ChapterContainer:Clear()
    
    local startX = 10
    local gap = 180
    
    for i = 0, 2 do
        local idx = self.CurrentIndex + i
        local data = chapters[idx]
        if ( data ) then
            local pnl = vgui.Create( "CGameChapterPanel", self.ChapterContainer )
            pnl:SetPos( startX + (i * gap), 5 )
            pnl:SetData( data )
            pnl.DoClick = function()
                self:SelectChapter( idx )
            end
            
            if ( idx == self.SelectedIndex ) then
                pnl:SetSelected( true )
            end
        end
    end
    
    self.btnPrev:SetVisible( self.CurrentIndex > 1 )
    self.btnNext:SetVisible( (self.CurrentIndex + 2) < #chapters )
end

function PANEL:NextPage()
    if ( (self.CurrentIndex + 2) < #chapters ) then
        self.CurrentIndex = self.CurrentIndex + 1
        self:UpdateChapters()
    end
end

function PANEL:PrevPage()
    if ( self.CurrentIndex > 1 ) then
        self.CurrentIndex = self.CurrentIndex - 1
        self:UpdateChapters()
    end
end

function PANEL:SelectChapter( idx )
    self.SelectedIndex = idx
    self:UpdateChapters()
end

function PANEL:StartGame()
    if ( self.SelectedIndex and chapters[self.SelectedIndex] ) then
        local data = chapters[self.SelectedIndex]
        RunConsoleCommand( "disconnect" )
        RunConsoleCommand( "deathmatch", "0" )
        RunConsoleCommand( "progress_enable" )
        RunConsoleCommand( "exec", data.file )
        self:Remove()
    end
end

vgui.Register( "NewGameDialog", PANEL, "HL2Frame" )

function OpenNewGameDialog()
    if ( IsValid( g_NewGameDialog ) ) then g_NewGameDialog:Remove() end
    g_NewGameDialog = vgui.Create( "NewGameDialog" )
end
