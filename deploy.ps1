param(
    [string]$GModPath,
    [string]$BuildDirName = "GMod_Runtime_Build"
)

# Resolve GMod Path
if ([string]::IsNullOrEmpty($GModPath)) {
    $ConfigPath = Join-Path $PSScriptRoot "gmod_path.txt"
    if (Test-Path $ConfigPath) {
        $GModPath = (Get-Content $ConfigPath -Raw).Trim()
        Write-Host "[*] Read GModPath from $ConfigPath"
    } else {
        $GModPath = "e:\SteamLibrary\steamapps\common\GarrysMod"
    }
}

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
# Preserve common user-data folders using case-insensitive lookup.
# GMod/user content sometimes uses singular/plural variants (e.g., save/saves, download/downloads), so keep both to avoid accidental deletion.
$preserveGarrysmodItems = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@(
    "saves", "save",
    "cache",
    "data",
    "download", "downloads",
    "cfg",   # keep full cfg so all user configs (autoexec.cfg, addonnomount.txt, etc.) remain intact
    "addons",
    "dupes",
    "demos",
    "screenshots"
) | ForEach-Object { [void]$preserveGarrysmodItems.Add($_) }
$logPrefix = "    ->"
Get-ChildItem -Path $BuildPath | ForEach-Object {
    if ($_.Name -eq "garrysmod" -and $_.PSIsContainer) {
        # Inside garrysmod, delete everything EXCEPT preserved user data folders (saves, cache, data, downloads, cfg, addons, etc.)
        Get-ChildItem -Path $_.FullName | ForEach-Object {
            if ($preserveGarrysmodItems.Contains($_.Name)) {
                Write-Host "$logPrefix Preserving $($_.Name)"
            } else {
                Remove-Item -Path $_.FullName -Recurse -Force
            }
        }
    } else {
        # Delete everything else in root
        Remove-Item -Path $_.FullName -Recurse -Force
    }
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

# 3.5 Copy VPKs from base garrysmod (Copy instead of Link to allow patching)
Write-Host "[*] Copying VPKs..."
$vpkFiles = Get-ChildItem -Path (Join-Path $GModPath "garrysmod") -Filter "*.vpk"
foreach ($vpk in $vpkFiles) {
    $dest = Join-Path $BuildGModPath $vpk.Name
    
    # Check if destination exists
    if (Test-Path $dest) {
        # Check if it's a symlink/reparse point
        $item = Get-Item $dest
        if ($item.Attributes -match "ReparsePoint") {
            # It's a symlink, delete it so we can copy
            Remove-Item $dest -Force
            Write-Host "    -> Removed symlink for $($vpk.Name)"
        }
    }
    
    # Copy if doesn't exist (or was just deleted)
    if (!(Test-Path $dest)) {
        Copy-Item -Path $vpk.FullName -Destination $dest -Force
        Write-Host "    -> Copied VPK: $($vpk.Name)"
    }
}

# 3.5.1 Patch VPKs if source folder exists
$vpkPatchFolder = Join-Path $SourcePath "garrysmod.vpk"
if (Test-Path $vpkPatchFolder) {
    Write-Host "[*] Patching garrysmod_dir.vpk with content from garrysmod.vpk folder..."
    
    $vpkTool = Join-Path $GModPath "bin\vpk.exe"
    if (Test-Path $vpkTool) {
        $targetVpk = Join-Path $BuildGModPath "garrysmod_dir.vpk"
        
        # Create a temporary response file listing all files to add
        $responseFile = Join-Path $BuildGModPath "vpk_patch_list.txt"
        
        # Change to patch directory to get relative paths
        Push-Location $vpkPatchFolder
        try {
            # Get all files recursively
            $files = Get-ChildItem -Recurse -File
            if ($files.Count -gt 0) {
                # Write relative paths to response file
                $files | ForEach-Object {
                    # Get relative path
                    $relPath = $_.FullName.Substring($vpkPatchFolder.Length + 1)
                    $relPath
                } | Set-Content $responseFile
                
                # Run vpk.exe to add files
                Write-Host "    -> Adding $($files.Count) files to VPK..."
                $proc = Start-Process -FilePath $vpkTool -ArgumentList "a `"$targetVpk`" `@`"$responseFile`"" -Wait -NoNewWindow -PassThru
                
                if ($proc.ExitCode -eq 0) {
                    Write-Host "    -> VPK Patching Successful"
                } else {
                    Write-Host "    -> VPK Patching Failed with exit code $($proc.ExitCode)"
                }
            } else {
                Write-Host "    -> No files found in patch folder."
            }
        } finally {
            Pop-Location
            if (Test-Path $responseFile) { Remove-Item $responseFile }
        }
    } else {
        Write-Host "    -> ERROR: vpk.exe not found at $vpkTool"
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

# 3.6 Copy Scenes
Write-Host "[*] Copying base scenes..."
$srcScenes = Join-Path $GModPath "garrysmod\scenes"
$destScenes = Join-Path $BuildGModPath "scenes"
if (Test-Path $srcScenes) {
    Copy-Item -Path $srcScenes -Destination $destScenes -Recurse -Force
    Write-Host "    -> Copied scenes folder"
}

# 3.7 copy particles
Write-Host "[*] Copying base particles..."
$srcParticles = Join-Path $GModPath "garrysmod\particles"
$destParticles = Join-Path $BuildGModPath "particles"
if (Test-Path $srcParticles) {
    Copy-Item -Path $srcParticles -Destination $destParticles -Recurse -Force
    Write-Host "    -> Copied particles folder"
}

# 3.7.5 Symlink Cache and Download folders
$foldersToLinkInGmod = @("cache", "download")
foreach ($folder in $foldersToLinkInGmod) {
    $src = Join-Path $GModPath "garrysmod\$folder"
    $dest = Join-Path $BuildGModPath $folder
    
    # Create source if it doesn't exist (so we have something to link to)
    if (!(Test-Path $src)) {
        New-Item -ItemType Directory -Path $src | Out-Null
    }

    if (!(Test-Path $dest)) {
        cmd /c mklink /J "$dest" "$src" | Out-Null
        Write-Host "[+] Linked Folder: garrysmod\$folder"
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

# Copy HL2MP.ttf
$hl2mpFont = Join-Path $srcResource "HL2MP.ttf"
if (Test-Path $hl2mpFont) {
    Copy-Item -Path $hl2mpFont -Destination (Join-Path $destResource "HL2MP.ttf") -Force
    Write-Host "    -> Copied HL2MP.ttf"
}

# copy resource/language folder
$srcLanguages = Join-Path $srcResource "language"
$destLanguages = Join-Path $destResource "language"
if (Test-Path $srcLanguages) {
    Copy-Item -Path $srcLanguages -Destination $destLanguages -Recurse -Force
    Write-Host "    -> Copied language"
}

# copy resource/localization folder
$srcLocalization = Join-Path $srcResource "localization"
$destLocalization = Join-Path $destResource "localization"
if (Test-Path $srcLocalization) {
    Copy-Item -Path $srcLocalization -Destination $destLocalization -Recurse -Force
    Write-Host "    -> Copied localization"
}

# Copy fonts
$srcFonts = Join-Path $srcResource "fonts"
$destFonts = Join-Path $destResource "fonts"
if (Test-Path $srcFonts) {
    Copy-Item -Path $srcFonts -Destination $destFonts -Recurse -Force
    Write-Host "    -> Copied fonts"
}

# copy maps/gm_construct.bsp and maps/gm_flatgrass.bsp
$srcMaps = Join-Path $GModPath "garrysmod\maps"
$destMaps = Join-Path $BuildGModPath "maps"
$mapsToCopy = @("gm_construct.bsp", "gm_flatgrass.bsp")
if (!(Test-Path $destMaps)) {
    New-Item -ItemType Directory -Path $destMaps | Out-Null
}
foreach ($map in $mapsToCopy) {
    $srcMap = Join-Path $srcMaps $map
    if (Test-Path $srcMap) {
        Copy-Item -Path $srcMap -Destination (Join-Path $destMaps $map) -Force
        Write-Host "    -> Copied map: $map"
    }
}

# copy default spawn menus
$srcSpawnMenus = Join-Path $GModPath "garrysmod\settings\spawnlist_default"
$destSpawnMenus = Join-Path $BuildGModPath "settings\spawnlist"
if (Test-Path $srcSpawnMenus) {
    Copy-Item -Path $srcSpawnMenus -Destination $destSpawnMenus -Recurse -Force
    Write-Host "    -> Copied default spawn menus"
}

# 4. Setup Base Config (gameinfo.txt and mount.cfg)
# Copy base gameinfo.txt so it acts like GMod
$baseGameInfo = Join-Path $GModPath "garrysmod\gameinfo.txt"
$destGameInfo = Join-Path $BuildGModPath "gameinfo.txt"
Copy-Item -Path $baseGameInfo -Destination $destGameInfo -Force
Write-Host "[+] Copied base gameinfo.txt"

# copy garrysmod\garrysmod.ver
$baseVerFile = Join-Path $GModPath "garrysmod\garrysmod.ver"
$destVerFile = Join-Path $BuildGModPath "garrysmod.ver"
Copy-Item -Path $baseVerFile -Destination $destVerFile -Force
Write-Host "[+] Copied garrysmod.ver"

# copy steam.inf
$baseSteamInf = Join-Path $GModPath "garrysmod\steam.inf"
$destSteamInf = Join-Path $BuildGModPath "steam.inf"   
Copy-Item -Path $baseSteamInf -Destination $destSteamInf -Force
Write-Host "[+] Copied steam.inf"

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
            if ($_.Name -eq "cfg") {
                # Special handling for cfg to protect autoexec.cfg
                Get-ChildItem -Path $_.FullName | ForEach-Object {
                    $destFile = Join-Path $targetItem $_.Name
                    if ($_.Name -eq "autoexec.cfg" -and (Test-Path $destFile)) {
                        Write-Host "    -> Skipping autoexec.cfg (already exists)"
                    } else {
                        Copy-Item -Path $_.FullName -Destination $targetItem -Recurse -Force
                    }
                }
            } else {
                Copy-Item -Path "$($_.FullName)\*" -Destination $targetItem -Recurse -Force
            }
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
