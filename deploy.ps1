param(
    [string]$GModPath = "e:\SteamLibrary\steamapps\common\GarrysMod",
    [string]$BuildDirName = "GMod_Runtime_Build"
)

$SourcePath = $PSScriptRoot
# Build path will be created as a sibling to the current folder
$BuildPath = Join-Path (Split-Path $SourcePath -Parent) $BuildDirName

Write-Host "=========================================="
Write-Host "   GMod Additive Dev Environment Setup"
Write-Host "=========================================="
Write-Host "Source: $SourcePath"
Write-Host "Target: $BuildPath"
Write-Host "Base:   $GModPath"
Write-Host ""

# 1. Prepare Build Directory
if (!(Test-Path $BuildPath)) {
    New-Item -ItemType Directory -Path $BuildPath | Out-Null
    Write-Host "[+] Created build directory"
}

# wipe directory contents
Get-ChildItem -Path $BuildPath | ForEach-Object {
    Remove-Item -Path $_.FullName -Recurse -Force
}

# 2. Symlink Engine Files (The "Skeleton")
# These allow hl2.exe to run from this new folder while using the original engine binaries
$filesToLink = @("gmod.exe", "steam_appid.txt")
foreach ($file in $filesToLink) {
    $src = Join-Path $GModPath $file
    $dest = Join-Path $BuildPath $file
    if (!(Test-Path $dest)) {
        cmd /c mklink /H "$dest" "$src" | Out-Null
        Write-Host "[+] Linked File: $file"
    }
}

$foldersToLink = @("bin", "sourceengine", "platform")
foreach ($folder in $foldersToLink) {
    $src = Join-Path $GModPath $folder
    $dest = Join-Path $BuildPath $folder
    if (!(Test-Path $dest)) {
        cmd /c mklink /J "$dest" "$src" | Out-Null
        Write-Host "[+] Linked Folder: $folder"
    }
}

# 3. Prepare 'garrysmod' folder in Build
$BuildGModPath = Join-Path $BuildPath "garrysmod"
if (!(Test-Path $BuildGModPath)) {
    New-Item -ItemType Directory -Path $BuildGModPath | Out-Null
    Write-Host "[+] Created local garrysmod folder"
}

# 3.5 Symlink VPKs from base garrysmod
Write-Host "[*] Linking VPKs..."
$vpkFiles = Get-ChildItem -Path (Join-Path $GModPath "garrysmod") -Filter "*.vpk"
foreach ($vpk in $vpkFiles) {
    $dest = Join-Path $BuildGModPath $vpk.Name
    if (!(Test-Path $dest)) {
        # Using symbolic links for VPKs
        cmd /c mklink "$dest" "$($vpk.FullName)" | Out-Null
        Write-Host "    -> Linked VPK: $($vpk.Name)"
    }
}

# 3.6 Copy Base Lua (so we have a working base to modify)
Write-Host "[*] Copying base Lua files..."
$srcLua = Join-Path $GModPath "garrysmod\lua"
$destLua = Join-Path $BuildGModPath "lua"
if (Test-Path $srcLua) {
    # We copy instead of link so we can modify/overwrite without affecting base game
    Copy-Item -Path $srcLua -Destination $destLua -Recurse -Force
    Write-Host "    -> Copied lua folder"
}

# 3.7 Copy Base Gamemodes
Write-Host "[*] Copying base gamemodes..."
$destGamemodes = Join-Path $BuildGModPath "gamemodes"
if (!(Test-Path $destGamemodes)) {
    New-Item -ItemType Directory -Path $destGamemodes | Out-Null
}

$gamemodesToCopy = @("base", "sandbox")
foreach ($gm in $gamemodesToCopy) {
    $srcGm = Join-Path $GModPath "garrysmod\gamemodes\$gm"
    $destGm = Join-Path $destGamemodes $gm
    if (Test-Path $srcGm) {
        Copy-Item -Path $srcGm -Destination $destGm -Recurse -Force
        Write-Host "    -> Copied gamemode: $gm"
    }
}

# 3.8 Copy Essential Resources Only
Write-Host "[*] Copying essential resources..."
$srcResource = Join-Path $GModPath "garrysmod\resource"
$destResource = Join-Path $BuildGModPath "resource"
if (!(Test-Path $destResource)) {
    New-Item -ItemType Directory -Path $destResource | Out-Null
}

# Copy language file
$langFile = Join-Path $srcResource "garrysmod_english.txt"
if (Test-Path $langFile) {
    Copy-Item -Path $langFile -Destination (Join-Path $destResource "garrysmod_english.txt") -Force
    Write-Host "    -> Copied garrysmod_english.txt"
}

# Copy fonts
$srcFonts = Join-Path $srcResource "fonts"
$destFonts = Join-Path $destResource "fonts"
if (Test-Path $srcFonts) {
    Copy-Item -Path $srcFonts -Destination $destFonts -Recurse -Force
    Write-Host "    -> Copied fonts"
}

# 4. Setup Base Config (gameinfo.txt and mount.cfg)
# Copy base gameinfo.txt so it acts like GMod
$baseGameInfo = Join-Path $GModPath "garrysmod\gameinfo.txt"
$destGameInfo = Join-Path $BuildGModPath "gameinfo.txt"
Copy-Item -Path $baseGameInfo -Destination $destGameInfo -Force
Write-Host "[+] Copied base gameinfo.txt"

# # Create mount.cfg to load the actual GMod content
# $cfgPath = Join-Path $BuildGModPath "cfg"
# if (!(Test-Path $cfgPath)) { New-Item -ItemType Directory -Path $cfgPath | Out-Null }

# $mountContent = @"
# "mountcfg"
# {
#     "garrysmod"    "$GModPath\garrysmod"
# }
# "@
# Set-Content -Path (Join-Path $cfgPath "mount.cfg") -Value $mountContent
# Write-Host "[+] Configured mount.cfg to load base GMod content"

# symlink bin folder from GMod to the build garrysmod folder
$srcBin = Join-Path $GModPath "garrysmod\bin"
$destBin = Join-Path $BuildGModPath "bin"
if (!(Test-Path $destBin)) {
    cmd /c mklink /J "$destBin" "$srcBin" | Out-Null
    Write-Host "[+] Linked garrysmod\bin folder"
}

# 5. Copy Mod Content (The "Additive" part)
# We copy everything from SourcePath to BuildGModPath, overwriting if necessary.
# This allows you to keep your source folder clean and minimal.
Write-Host "[*] Copying mod files from source..."
$excludeList = @("deploy.ps1", ".git", ".vscode", "setup_dev_env.ps1", "bin", "obj")
Get-ChildItem -Path $SourcePath -Exclude $excludeList | ForEach-Object {
    $targetItem = Join-Path $BuildGModPath $_.Name
    
    if ($_.PSIsContainer) {
        # It's a directory
        if (!(Test-Path $targetItem)) {
            # Destination doesn't exist, just copy the folder
            Copy-Item -Path $_.FullName -Destination $targetItem -Recurse -Force
        } else {
            # Destination exists (e.g. lua folder), merge contents
            # Copy-Item "Folder/*" to "Dest/Folder" merges correctly
            Copy-Item -Path "$($_.FullName)\*" -Destination $targetItem -Recurse -Force
        }
    } else {
        # It's a file
        Copy-Item -Path $_.FullName -Destination $targetItem -Force
    }
    
    Write-Host "    -> Copied $($_.Name)"
}

Write-Host ""
Write-Host "SUCCESS! Environment ready."
Write-Host "Run this command to start:"
Write-Host "& '$BuildPath\hl2.exe'"
