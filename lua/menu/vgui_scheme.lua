if ( SERVER ) then return end

HL2Scheme = {}
HL2Scheme.Schemes = {}

local function ParseColor( str, contextColors )
    if ( !str ) then return nil end
    
    -- Check if it's a reference to an existing color in this scheme
    if ( contextColors and contextColors[str] ) then
        return contextColors[str]
    end

    local r, g, b, a = str:match( "(%d+)%s+(%d+)%s+(%d+)%s+(%d+)" )
    if ( r ) then
        return Color( tonumber(r), tonumber(g), tonumber(b), tonumber(a) )
    end
    
    r, g, b = str:match( "(%d+)%s+(%d+)%s+(%d+)" )
    if ( r ) then
        return Color( tonumber(r), tonumber(g), tonumber(b), 255 )
    end
    
    return nil
end

-- Helper to check if string starts with
function string.StartWith(String, Start)
   return string.sub(String,1,string.len(Start))==Start
end

local function EvaluateConditional( tag )
    if ( !tag ) then return true end
    local inner = tag:match( "%[(.+)%]" )
    if ( !inner ) then return true end
    
    local invert = false
    if ( inner:StartWith( "!" ) ) then
        invert = true
        inner = inner:sub( 2 )
    end
    
    local active = false
    if ( inner == "$WIN32" or inner == "$WINDOWS" ) then
        active = system.IsWindows()
    elseif ( inner == "$LINUX" ) then
        active = system.IsLinux()
    elseif ( inner == "$OSX" ) then
        active = system.IsOSX()
    elseif ( inner == "$POSIX" ) then
        active = system.IsLinux() or system.IsOSX()
    elseif ( inner == "$X360" ) then
        active = false
    end
    
    if ( invert ) then return !active end
    return active
end

local function Tokenize( content )
    -- Remove comments (// ...)
    content = content:gsub( "//[^\n]*", "" )
    
    local tokens = {}
    local len = #content
    local pos = 1
    
    while pos <= len do
        local char = content:sub( pos, pos )
        
        if ( char:match("%s") ) then
            pos = pos + 1
        elseif ( char == '"' ) then
            local endQuote = content:find( '"', pos + 1 )
            if ( !endQuote ) then break end
            local str = content:sub( pos + 1, endQuote - 1 )
            table.insert( tokens, { type = "string", val = str } )
            pos = endQuote + 1
        elseif ( char == '{' or char == '}' ) then
            table.insert( tokens, { type = "symbol", val = char } )
            pos = pos + 1
        elseif ( char == '[' ) then
            local endBracket = content:find( ']', pos + 1 )
            if ( endBracket ) then
                table.insert( tokens, { type = "condition", val = content:sub( pos, endBracket ) } )
                pos = endBracket + 1
            else
                pos = pos + 1
            end
        else
            -- Unquoted string
            local s, e = content:find( "[^%s{}\"']+", pos )
            if ( s ) then
                table.insert( tokens, { type = "string", val = content:sub( s, e ) } )
                pos = e + 1
            else
                pos = pos + 1
            end
        end
    end
    
    return tokens
end

local function ParseBlock( tokens, index )
    local data = {}
    local i = index
    
    while i <= #tokens do
        local token = tokens[i]
        
        if ( token.type == "symbol" and token.val == "}" ) then
            return data, i + 1
        end
        
        if ( token.type == "string" ) then
            local key = token.val
            i = i + 1
            
            -- Check for conditional after Key
            local conditionMet = true
            if ( tokens[i] and tokens[i].type == "condition" ) then
                conditionMet = EvaluateConditional( tokens[i].val )
                i = i + 1
            end
            
            if ( !conditionMet ) then
                -- Skip Value
                if ( tokens[i] and tokens[i].type == "symbol" and tokens[i].val == "{" ) then
                    -- Skip block
                    local depth = 1
                    i = i + 1
                    while i <= #tokens and depth > 0 do
                        if ( tokens[i].val == "{" ) then depth = depth + 1 end
                        if ( tokens[i].val == "}" ) then depth = depth - 1 end
                        i = i + 1
                    end
                elseif ( tokens[i] and tokens[i].type == "string" ) then
                    -- Skip string
                    i = i + 1
                end
            else
                -- Parse Value
                if ( tokens[i] and tokens[i].type == "symbol" and tokens[i].val == "{" ) then
                    -- Block
                    local blockData, newIndex = ParseBlock( tokens, i + 1 )
                    
                    -- Merge if exists
                    if ( data[key] and istable(data[key]) ) then
                        table.Merge( data[key], blockData )
                    else
                        data[key] = blockData
                    end
                    i = newIndex
                elseif ( tokens[i] and tokens[i].type == "string" ) then
                    -- String
                    local val = tokens[i].val
                    i = i + 1
                    
                    -- Check for conditional after Value
                    local postCond = true
                    if ( tokens[i] and tokens[i].type == "condition" ) then
                        postCond = EvaluateConditional( tokens[i].val )
                        i = i + 1
                    end
                    
                    if ( postCond ) then
                        data[key] = val
                    end
                else
                    -- Unexpected
                    i = i + 1
                end
            end
        else
            i = i + 1
        end
    end
    
    return data, i
end

local function LoadSchemeFile( filename )
    -- Try to find the file
    -- The game usually looks in resource/ inside the mod, then engine
    local path = "resource/" .. filename
    if ( !file.Exists( path, "GAME" ) ) then
        -- Try without resource/ prefix if it was passed with it?
        if ( file.Exists( filename, "GAME" ) ) then
            path = filename
        else
            print( "[HL2Scheme] Could not find " .. filename )
            return {}
        end
    end

    local content = file.Read( path, "GAME" )
    if ( !content ) then return {} end
    
    local data = {}
    
    -- Handle #base directives (simple recursive loader)
    -- Matches: #base "filename"
    for baseFile in content:gmatch( '#base%s+"([^"]+)"' ) do
        local baseData = LoadSchemeFile( baseFile )
        table.Merge( data, baseData )
    end
    
    -- Strip #base lines before parsing
    content = content:gsub( '#base%s+"[^"]+"[^\n]*', "" )
    
    -- Tokenize and Parse
    local tokens = Tokenize( content )
    local currentData, _ = ParseBlock( tokens, 1 )
    
    if ( currentData ) then
        table.Merge( data, currentData )
    else
        print( "[HL2Scheme] Failed to parse " .. filename )
    end
    
    return data
end

function HL2Scheme.LoadSchemeFromFile( filename, schemeName )
    local data = LoadSchemeFile( filename )
    if ( !data ) then return end
    
    -- If the root is "Scheme", go inside
    if ( data.Scheme ) then data = data.Scheme end
    
    local schemeData = {
        Colors = {},
        Fonts = {},
        Settings = {}
    }
    
    -- 1. Parse Colors
    if ( data.Colors and istable(data.Colors) ) then
        for k, v in pairs( data.Colors ) do
            local col = ParseColor( v, schemeData.Colors )
            if ( col ) then
                schemeData.Colors[k] = col
            end
        end
    end
    
    -- 2. Parse BaseSettings
    if ( data.BaseSettings and istable(data.BaseSettings) ) then
        for k, v in pairs( data.BaseSettings ) do
            local col = ParseColor( v, schemeData.Colors )
            if ( col ) then
                schemeData.Settings[k] = col
            else
                schemeData.Settings[k] = v
            end
        end
    end
    
    -- 3. Parse Fonts
    if ( data.Fonts and istable(data.Fonts) ) then
        local screenH = ScrH()
        
        for fontName, fontDefs in pairs( data.Fonts ) do
            if ( !istable(fontDefs) ) then continue end
            local bestDef = nil
            for _, def in pairs( fontDefs ) do
                if ( istable(def) ) then
                    local minRes = tonumber( def.yres and def.yres:match( "(%d+)%s+%d+" ) or 0 )
                    local maxRes = tonumber( def.yres and def.yres:match( "%d+%s+(%d+)" ) or 99999 )
                    if ( !minRes ) then minRes = 0 end
                    if ( !maxRes ) then maxRes = 99999 end
                    
                    if ( screenH >= minRes and screenH <= maxRes ) then
                        bestDef = def
                        break
                    end
                    if ( !bestDef ) then bestDef = def end
                end
            end
            
            if ( bestDef ) then
                local face = bestDef.name or "Tahoma"
                
                -- PREFIX THE FONT NAME
                local uniqueFontName = schemeName .. "_" .. fontName
                
                surface.CreateFont( uniqueFontName, {
                    font = face,
                    size = tonumber(bestDef.tall) or 16,
                    weight = tonumber(bestDef.weight) or 400,
                    antialias = tobool(bestDef.antialias),
                    additive = tobool(bestDef.additive),
                    outline = tobool(bestDef.outline),
                    shadow = tobool(bestDef.dropshadow),
                    scanlines = tobool(bestDef.scanlines),
                    blur = tobool(bestDef.blur),
                    symbol = tobool(bestDef.symbol),
                    rotary = tobool(bestDef.rotary),
                    shadowen = tobool(bestDef.shadowen),
                    italic = tobool(bestDef.italic),
                    underline = tobool(bestDef.underline),
                    strikeout = tobool(bestDef.strikeout),
                } )
                schemeData.Fonts[fontName] = uniqueFontName
            end
        end
    end
    
    -- 4. Parse Borders
    schemeData.Borders = {}
    if ( data.Borders and istable(data.Borders) ) then
        for borderName, borderDef in pairs( data.Borders ) do
            if ( isstring(borderDef) ) then
                -- Simple reference to another border (e.g., "BaseBorder" => "DepressedBorder")
                schemeData.Borders[borderName] = { type = "reference", ref = borderDef }
            elseif ( istable(borderDef) ) then
                -- Complex border definition
                local border = {
                    type = "complex",
                    backgroundtype = borderDef.backgroundtype,
                    inset = borderDef.inset
                }
                
                -- Parse individual sides (Left, Right, Top, Bottom)
                for _, side in ipairs( {"Left", "Right", "Top", "Bottom"} ) do
                    if ( borderDef[side] and istable(borderDef[side]) ) then
                        border[side] = {}
                        for lineNum, lineDef in pairs( borderDef[side] ) do
                            if ( istable(lineDef) ) then
                                local lineData = {
                                    color = lineDef.color, -- Color reference
                                    offset = lineDef.offset, -- Offset string
                                }
                                border[side][lineNum] = lineData
                            end
                        end
                    end
                end
                
                schemeData.Borders[borderName] = border
            end
        end
    end
    
    HL2Scheme.Schemes[schemeName] = schemeData
    print( "[HL2Scheme] Loaded " .. filename .. " as " .. schemeName )
end

function HL2Scheme.GetColor( name, default, schemeName )
    schemeName = schemeName or "ClientScheme"
    local scheme = HL2Scheme.Schemes[schemeName]
    if ( !scheme ) then return default or Color(255,255,255) end
    
    if ( scheme.Settings[name] and IsColor(scheme.Settings[name]) ) then return scheme.Settings[name] end
    if ( scheme.Colors[name] ) then return scheme.Colors[name] end
    
    return default or Color( 255, 255, 255 )
end

function HL2Scheme.GetFont( name, default, schemeName )
    schemeName = schemeName or "ClientScheme"
    local scheme = HL2Scheme.Schemes[schemeName]
    if ( !scheme ) then return default end

    -- Check if name is a setting key (e.g. "MainMenuFont")
    local settingValue = scheme.Settings[name]
    if ( settingValue and scheme.Fonts[settingValue] ) then
        return scheme.Fonts[settingValue]
    end
    
    -- Check if name is a font name directly
    if ( scheme.Fonts[name] ) then return scheme.Fonts[name] end
    
    return default
end

function HL2Scheme.GetResourceString( name, default, schemeName )
    schemeName = schemeName or "ClientScheme"
    local scheme = HL2Scheme.Schemes[schemeName]
    if ( !scheme ) then return default end
    return scheme.Settings[name] or default
end

function HL2Scheme.GetBorder( name, schemeName )
    schemeName = schemeName or "ClientScheme"
    local scheme = HL2Scheme.Schemes[schemeName]
    if ( !scheme or !scheme.Borders ) then return nil end
    
    local border = scheme.Borders[name]
    if ( !border ) then return nil end
    
    -- Resolve references
    if ( border.type == "reference" ) then
        return HL2Scheme.GetBorder( border.ref, schemeName )
    end
    
    return border
end

function HL2Scheme.DrawBorder( borderName, x, y, w, h, schemeName )
    local border = HL2Scheme.GetBorder( borderName, schemeName )
    if ( !border ) then return end
    
    schemeName = schemeName or "ClientScheme"
    
    -- Helper to parse offset string "x y"
    local function parseOffset( str )
        if ( !str ) then return 0, 0 end
        local ox, oy = str:match( "(%S+)%s+(%S+)" )
        return tonumber(ox) or 0, tonumber(oy) or 0
    end
    
    -- Draw each side
    -- Draw borders matching Source SDK Border.cpp logic
    -- Order matters: Left, Top, Right, Bottom (as in Source SDK)
    for _, side in ipairs( {"Left", "Top", "Right", "Bottom"} ) do
        if ( border[side] ) then
            for lineNum, lineDef in pairs( border[side] ) do
                local colorRef = lineDef.color
                local offset_x, offset_y = parseOffset( lineDef.offset )
                
                -- Resolve color reference
                local color = HL2Scheme.GetColor( colorRef, Color(255, 255, 255), schemeName )
                
                -- Draw border lines matching Source SDK Border.cpp Paint() method:
                -- Uses DrawFilledRect(x1, y1, x2, y2) where x2/y2 are exclusive endpoints
                -- We use draw.RoundedBox(0, x, y, w, h, color) which draws a filled rect
                -- Offsets SHORTEN the lines from both ends (startOffset/endOffset), not reposition them
                if ( side == "Left" ) then
                    -- Left: DrawFilledRect(x + i, y + startOffset, x + i + 1, tall - endOffset)
                    -- Draws 1px wide vertical line, offset_y shortens from both ends
                    draw.RoundedBox( 0, x + offset_x, y + offset_y, 1, h - offset_y - offset_y, color )
                elseif ( side == "Right" ) then
                    -- Right: DrawFilledRect(wide - (i+1), y + startOffset, wide - i, tall - endOffset)
                    -- For i=0: wide - 1 to wide (exclusive), so rightmost pixel at wide-1
                    draw.RoundedBox( 0, x + w - 1 - offset_x, y + offset_y, 1, h - offset_y - offset_y, color )
                elseif ( side == "Top" ) then
                    -- Top: DrawFilledRect(x + startOffset, y + i, wide - endOffset, y + i + 1)
                    -- Draws 1px tall horizontal line, offset_x shortens from both ends
                    draw.RoundedBox( 0, x + offset_x, y + offset_y, w - offset_x - offset_x, 1, color )
                elseif ( side == "Bottom" ) then
                    -- Bottom: DrawFilledRect(x + startOffset, tall - (i+1), wide - endOffset, tall - i)
                    -- For i=0: tall - 1 to tall (exclusive), so bottommost pixel at tall-1
                    draw.RoundedBox( 0, x + offset_x, y + h - 1 - offset_y, w - offset_x - offset_x, 1, color )
                end
            end
        end
    end
end

-- Load standard schemes
HL2Scheme.LoadSchemeFromFile( "SourceScheme.res", "SourceScheme" )
HL2Scheme.LoadSchemeFromFile( "ClientScheme.res", "ClientScheme" )

