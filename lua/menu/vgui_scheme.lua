if ( SERVER ) then return end

HL2Scheme = {}
HL2Scheme.Colors = {}
HL2Scheme.Fonts = {}
HL2Scheme.Settings = {}

local function ParseColor( str )
    if ( !str ) then return nil end
    
    -- Check if it's a reference to an existing color
    if ( HL2Scheme.Colors[str] ) then
        return HL2Scheme.Colors[str]
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

function HL2Scheme.Load()
    local data = LoadSchemeFile( "SourceScheme.res" )
    
    -- If the root is "Scheme", go inside
    if ( data.Scheme ) then data = data.Scheme end
    
    -- 1. Parse Colors
    if ( data.Colors ) then
        for k, v in pairs( data.Colors ) do
            local col = ParseColor( v )
            if ( col ) then
                HL2Scheme.Colors[k] = col
            end
        end
    end
    
    -- 2. Parse BaseSettings (Logical colors and other settings)
    if ( data.BaseSettings ) then
        for k, v in pairs( data.BaseSettings ) do
            local col = ParseColor( v )
            if ( col ) then
                HL2Scheme.Settings[k] = col
            else
                -- Store raw value (e.g. font names, numbers)
                HL2Scheme.Settings[k] = v
            end
        end
    end
    
    -- 3. Parse Fonts
    if ( data.Fonts ) then
        local screenH = ScrH()
        
        for fontName, fontDefs in pairs( data.Fonts ) do
            -- Find the best match for current resolution
            local bestDef = nil
            
            for _, def in pairs( fontDefs ) do
                if ( istable(def) ) then
                    -- Check yres
                    local minRes = tonumber( def.yres and def.yres:match( "(%d+)%s+%d+" ) or 0 )
                    local maxRes = tonumber( def.yres and def.yres:match( "%d+%s+(%d+)" ) or 99999 )
                    
                    if ( !minRes ) then minRes = 0 end
                    if ( !maxRes ) then maxRes = 99999 end
                    
                    if ( screenH >= minRes and screenH <= maxRes ) then
                        bestDef = def
                        break -- Found a match for our resolution
                    end
                    
                    -- Fallback to the first one if we haven't found one yet
                    if ( !bestDef ) then bestDef = def end
                end
            end
            
            if ( bestDef ) then
                local flags = 0
                if ( tobool( bestDef.italic ) ) then flags = bit.bor( flags, 0x002 ) end -- ITALIC
                if ( tobool( bestDef.underline ) ) then flags = bit.bor( flags, 0x004 ) end -- UNDERLINE
                if ( tobool( bestDef.strikeout ) ) then flags = bit.bor( flags, 0x008 ) end -- STRIKEOUT
                if ( tobool( bestDef.symbol ) ) then flags = bit.bor( flags, 0x010 ) end -- SYMBOL
                if ( tobool( bestDef.antialias ) ) then flags = bit.bor( flags, 0x020 ) end -- ANTIALIAS
                if ( tobool( bestDef.blur ) ) then flags = bit.bor( flags, 0x040 ) end -- BLUR
                if ( tobool( bestDef.outline ) ) then flags = bit.bor( flags, 0x080 ) end -- OUTLINE
                if ( tobool( bestDef.dropshadow ) ) then flags = bit.bor( flags, 0x100 ) end -- SHADOW
                
                -- Handle "name" being a table (sometimes happens in KeyValuesToTable if multiple names?)
                -- Usually it's a string.
                local face = bestDef.name or "Tahoma"
                
                surface.CreateFont( fontName, {
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
                
                HL2Scheme.Fonts[fontName] = true
            end
        end
    end
    
    print( "[HL2Scheme] Loaded SourceScheme.res with " .. table.Count(HL2Scheme.Fonts) .. " fonts" )
    
    -- Fallback for critical fonts if they failed to load
    if ( !HL2Scheme.Fonts["DefaultBold"] ) then
        surface.CreateFont( "DefaultBold", { font = "Tahoma", size = 13, weight = 1000, antialias = true } )
        print( "[HL2Scheme] Created fallback DefaultBold" )
    end
    if ( !HL2Scheme.Fonts["Default"] ) then
        surface.CreateFont( "Default", { font = "Tahoma", size = 13, weight = 500, antialias = true } )
        print( "[HL2Scheme] Created fallback Default" )
    end
end

function HL2Scheme.GetColor( name, default )
    -- Check Settings first (Logical names like "Border.Bright")
    if ( HL2Scheme.Settings[name] ) then return HL2Scheme.Settings[name] end
    -- Then raw Colors
    if ( HL2Scheme.Colors[name] ) then return HL2Scheme.Colors[name] end
    
    return default or Color( 255, 255, 255 )
end

function HL2Scheme.GetFont( name, default )
    -- 1. Check if 'name' is a setting key that points to a font (e.g. "FrameTitleBar.Font" -> "UiBold")
    local settingValue = HL2Scheme.Settings[name]
    if ( settingValue and HL2Scheme.Fonts[settingValue] ) then
        return settingValue
    end

    -- 2. Check if 'name' is directly a valid font name
    if ( HL2Scheme.Fonts[name] ) then return name end
    
    return default or "Default"
end

HL2Scheme.Load()
