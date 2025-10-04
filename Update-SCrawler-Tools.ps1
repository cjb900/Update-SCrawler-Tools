# SCrawler Tools Update Script
# This script automatically finds SCrawler installations and updates yt-dlp and gallery-dl
# 
# Features:
#   • Auto-detects SCrawler installations regardless of directory name
#   • Interactive menu to choose between yt-dlp and gallery-dl updates
#   • Searches common locations (Downloads, Desktop, Program Files, etc.)
#   • Identifies SCrawler by presence of SCrawler.exe and Environment folder
#   • Safe updates with automatic backups
# 
# Usage:
#   .\Update-SCrawler-Tools.ps1                    # Interactive menu to choose tool
#   .\Update-SCrawler-Tools.ps1 -Tool "yt-dlp"     # Update yt-dlp directly
#   .\Update-SCrawler-Tools.ps1 -Tool "gallery-dl" # Update gallery-dl directly
#   .\Update-SCrawler-Tools.ps1 -Force             # Force update without prompting
#   .\Update-SCrawler-Tools.ps1 -Quiet             # Run quietly (minimal output)
#   .\Update-SCrawler-Tools.ps1 -EnvironmentPath "C:\Custom\Path"  # Specify custom path

param(
    [string]$EnvironmentPath = "",
    [string]$Tool = "",
    [switch]$Force,
    [switch]$Quiet
)

# Tool configuration
$Tools = @{
    "yt-dlp" = @{
        "Name" = "yt-dlp"
        "Executable" = "yt-dlp.exe"
        "GitHubRepo" = "yt-dlp/yt-dlp"
        "DownloadUrl" = "https://github.com/yt-dlp/yt-dlp/releases/download/{version}/yt-dlp.exe"
    }
    "gallery-dl" = @{
        "Name" = "gallery-dl"
        "Executable" = "gallery-dl.exe"
        "GitHubRepo" = "mikf/gallery-dl"
        "DownloadUrl" = "https://github.com/mikf/gallery-dl/releases/download/{version}/gallery-dl.exe"
    }
}

# Auto-detect SCrawler Environment folder if not specified
if (-not $EnvironmentPath) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $EnvironmentPath = Join-Path $scriptDir "Environment"
    
    # If Environment folder not found in script directory, search for SCrawler installations
    if (-not (Test-Path $EnvironmentPath)) {
        $searchPaths = @(
            $env:USERPROFILE
            $env:USERPROFILE + "\Downloads"
            $env:USERPROFILE + "\Desktop"
            $env:USERPROFILE + "\Documents"
            $env:PROGRAMFILES
            ${env:ProgramFiles(x86)}
            "C:\"
            "D:\"
            "E:\"
            "F:\"
        )
        
        foreach ($searchPath in $searchPaths) {
            if (Test-Path $searchPath) {
                # Look for any directory that contains SCrawler.exe and Environment folder with tools
                try {
                    $scrawlerDirs = Get-ChildItem -Path $searchPath -Directory -Recurse -Depth 2 -ErrorAction SilentlyContinue | 
                        Where-Object { 
                            (Test-Path (Join-Path $_.FullName "SCrawler.exe")) -and 
                            (Test-Path (Join-Path $_.FullName "Environment")) -and
                            ((Test-Path (Join-Path $_.FullName "Environment\yt-dlp.exe")) -or 
                             (Test-Path (Join-Path $_.FullName "Environment\gallery-dl.exe")))
                        }
                    
                    if ($scrawlerDirs) {
                        $EnvironmentPath = Join-Path $scrawlerDirs[0].FullName "Environment"
                        break
                    }
                }
                catch {
                    # Ignore access denied errors and continue searching
                    continue
                }
            }
        }
    }
}

# Check if script is being run with restricted execution policy
if ($ExecutionContext.SessionState.LanguageMode -eq "ConstrainedLanguage") {
    Write-Host "Error: PowerShell execution policy is restricting script execution." -ForegroundColor Red
    Write-Host "Please run this script with one of the following methods:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Method 1 (Recommended): Right-click the script and select 'Run with PowerShell'" -ForegroundColor Cyan
    Write-Host "Method 2: Open PowerShell as Administrator and run:" -ForegroundColor Cyan
    Write-Host "         Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor White
    Write-Host "Method 3: Run from Command Prompt:" -ForegroundColor Cyan
    Write-Host "         powershell -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -ForegroundColor White
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    if (-not $Quiet) {
        Write-Host $Message -ForegroundColor $Color
    }
}

# Function to show interactive menu
function Show-ToolMenu {
    if ($Quiet) { return "yt-dlp" }  # Default to yt-dlp in quiet mode
    
    Write-ColorOutput ""
    Write-ColorOutput "=== SCrawler Tools Update Script ===" "Cyan"
    Write-ColorOutput ""
    Write-ColorOutput "Which tool would you like to check for updates?" "Yellow"
    Write-ColorOutput ""
    Write-ColorOutput "1. yt-dlp (YouTube Downloader)" "White"
    Write-ColorOutput "2. gallery-dl (Gallery Downloader)" "White"
    Write-ColorOutput "3. Both tools" "White"
    Write-ColorOutput "4. Exit" "White"
    Write-ColorOutput ""
    
    do {
        $choice = Read-Host "Enter your choice (1-4)"
        switch ($choice) {
            "1" { return "yt-dlp" }
            "2" { return "gallery-dl" }
            "3" { return "both" }
            "4" { 
                Write-ColorOutput "Exiting..." "Yellow"
                exit 0 
            }
            default {
                Write-ColorOutput "Invalid choice. Please enter 1, 2, 3, or 4." "Red"
            }
        }
    } while ($true)
}

# Function to get current tool version
function Get-CurrentVersion {
    param(
        [string]$Path,
        [string]$ToolName
    )
    
    $toolConfig = $Tools[$ToolName]
    $toolPath = Join-Path $Path $toolConfig.Executable
    
    try {
        if (-not (Test-Path $toolPath)) {
            Write-ColorOutput "Error: $($toolConfig.Executable) not found in $Path" "Red"
            return $null
        }
        
        # Both tools use --version flag
        $version = & $toolPath --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            return $version.Trim()
        } else {
            Write-ColorOutput "Error: Failed to get current $ToolName version" "Red"
            return $null
        }
    }
    catch {
        Write-ColorOutput "Error: Exception while getting current $ToolName version - $($_.Exception.Message)" "Red"
        return $null
    }
}

# Function to get latest version from GitHub
function Get-LatestVersion {
    param([string]$ToolName)
    
    $toolConfig = $Tools[$ToolName]
    
    try {
        $apiUrl = "https://api.github.com/repos/$($toolConfig.GitHubRepo)/releases/latest"
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -ErrorAction Stop
        
        return $response.tag_name
    }
    catch {
        Write-ColorOutput "Error: Failed to fetch latest $ToolName version from GitHub - $($_.Exception.Message)" "Red"
        return $null
    }
}

# Function to download and replace tool
function Update-Tool {
    param(
        [string]$EnvironmentPath,
        [string]$LatestVersion,
        [string]$ToolName
    )
    
    $toolConfig = $Tools[$ToolName]
    $toolPath = Join-Path $EnvironmentPath $toolConfig.Executable
    $downloadUrl = $toolConfig.DownloadUrl -replace "\{version\}", $LatestVersion
    $tempPath = Join-Path $env:TEMP "$($ToolName)_new.exe"
    
    try {
        Write-ColorOutput "Downloading $ToolName version $LatestVersion..." "Yellow"
        
        # Download the new version
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -ErrorAction Stop
        
        # Verify the download
        if (-not (Test-Path $tempPath)) {
            Write-ColorOutput "Error: Download failed" "Red"
            return $false
        }
        
        # Test the new executable
        Write-ColorOutput "Testing new version..." "Yellow"
        $testResult = & $tempPath --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "Error: Downloaded file is not a valid $ToolName executable" "Red"
            Remove-Item $tempPath -Force
            return $false
        }
        
        # Backup current version with version number
        $currentVersionForBackup = Get-CurrentVersion -Path $EnvironmentPath -ToolName $ToolName
        if ($currentVersionForBackup) {
            # Clean version number for filename (comprehensive cleaning)
            $cleanVersion = $currentVersionForBackup
            # Use character array approach to remove all non-alphanumeric except dots
            $charArray = $cleanVersion.ToCharArray()
            $result = ""
            foreach ($char in $charArray) {
                if ($char -match '[a-zA-Z0-9\.]') {
                    $result += $char
                }
            }
            $cleanVersion = $result -replace '\.', '_'                             # Replace dots with underscores
            $cleanVersion = $cleanVersion -replace '^v', ''                        # Remove 'v' prefix
            
            $backupSuffix = "_backup.$cleanVersion.exe"
            $backupPath = Join-Path $EnvironmentPath ($toolConfig.Executable -replace "\.exe$", $backupSuffix)
            
            
            if (Test-Path $toolPath) {
                Copy-Item $toolPath $backupPath -Force
                Write-ColorOutput "Backup created: $backupPath" "Green"
            }
        }
        
        # Replace the old version
        Move-Item $tempPath $toolPath -Force
        
        Write-ColorOutput "$ToolName successfully updated to version $LatestVersion" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "Error: Failed to update $ToolName - $($_.Exception.Message)" "Red"
        if (Test-Path $tempPath) {
            Remove-Item $tempPath -Force
        }
        return $false
    }
}

# Function to update a single tool
function Update-SingleTool {
    param(
        [string]$ToolName,
        [string]$EnvironmentPath
    )
    
    $toolConfig = $Tools[$ToolName]
    Write-ColorOutput ""
    Write-ColorOutput "=== Checking $ToolName ===" "Cyan"
    
    # Get current version
    Write-ColorOutput "Checking current $ToolName version..." "Yellow"
    $currentVersion = Get-CurrentVersion -Path $EnvironmentPath -ToolName $ToolName
    if (-not $currentVersion) {
        Write-ColorOutput "Skipping $ToolName (not found or error)" "Red"
        return $false
    }
    
    Write-ColorOutput "Current version: $currentVersion" "White"
    
    # Get latest version
    Write-ColorOutput "Fetching latest version from GitHub..." "Yellow"
    $latestVersion = Get-LatestVersion -ToolName $ToolName
    if (-not $latestVersion) {
        Write-ColorOutput "Failed to get latest $ToolName version" "Red"
        return $false
    }
    
    Write-ColorOutput "Latest version: $latestVersion" "White"
    Write-ColorOutput ""
    
    # Compare versions
    if ($currentVersion -eq $latestVersion) {
        Write-ColorOutput "[OK] $ToolName is already up to date!" "Green"
        return $true
    } else {
        Write-ColorOutput "[UPDATE] A newer version of $ToolName is available!" "Yellow"
        Write-ColorOutput "Current: $currentVersion" "Gray"
        Write-ColorOutput "Latest:  $latestVersion" "Gray"
        Write-ColorOutput ""
        
        if ($Force) {
            Write-ColorOutput "Force update enabled. Proceeding with update..." "Yellow"
            $success = Update-Tool -EnvironmentPath $EnvironmentPath -LatestVersion $latestVersion -ToolName $ToolName
            return $success
        } else {
            Write-ColorOutput "Would you like to update $ToolName to the latest version? (Y/N)" "Yellow"
            $response = Read-Host
            
            if ($response -match '^[Yy]') {
                $success = Update-Tool -EnvironmentPath $EnvironmentPath -LatestVersion $latestVersion -ToolName $ToolName
                return $success
            } else {
                Write-ColorOutput "Update cancelled by user." "Yellow"
                return $false
            }
        }
    }
}

# Main script execution
function Main {
    # Determine which tool(s) to update
    if (-not $Tool) {
        $Tool = Show-ToolMenu
    }
    
    Write-ColorOutput ""
    Write-ColorOutput "Environment Path: $EnvironmentPath" "Gray"
    Write-ColorOutput ""
    
    # Check if Environment folder exists
    if (-not (Test-Path $EnvironmentPath)) {
        Write-ColorOutput "Error: SCrawler installation not found!" "Red"
        Write-ColorOutput ""
        Write-ColorOutput "The script searched for SCrawler in these locations:" "Yellow"
        Write-ColorOutput "  • Script directory: $(Split-Path -Parent $MyInvocation.MyCommand.Path)" "Gray"
        Write-ColorOutput "  • User profile and subfolders (Downloads, Desktop, Documents)" "Gray"
        Write-ColorOutput "  • Program Files directories" "Gray"
        Write-ColorOutput "  • Root drives (C:\, D:\, E:\, F:\)" "Gray"
        Write-ColorOutput ""
        Write-ColorOutput "SCrawler is identified by the presence of:" "Yellow"
        Write-ColorOutput "  • SCrawler.exe in the main directory" "Gray"
        Write-ColorOutput "  • Environment folder with downloader tools" "Gray"
        Write-ColorOutput ""
        Write-ColorOutput "To fix this, either:" "Yellow"
        Write-ColorOutput "  1. Move this script to your SCrawler directory, or" "White"
        Write-ColorOutput "  2. Run with: .\Update-SCrawler-Tools.ps1 -EnvironmentPath `"C:\Path\To\SCrawler\Environment`"" "White"
        exit 1
    }
    
    # Update the selected tool(s)
    $success = $true
    if ($Tool -eq "both") {
        $success = Update-SingleTool -ToolName "yt-dlp" -EnvironmentPath $EnvironmentPath
        $success = (Update-SingleTool -ToolName "gallery-dl" -EnvironmentPath $EnvironmentPath) -and $success
    } else {
        $success = Update-SingleTool -ToolName $Tool -EnvironmentPath $EnvironmentPath
    }
    
    if ($success) {
        Write-ColorOutput ""
        Write-ColorOutput "All requested updates completed!" "Green"
        exit 0
    } else {
        Write-ColorOutput ""
        Write-ColorOutput "Some updates failed or were cancelled." "Yellow"
        exit 1
    }
}

# Run the main function
Main

# Pause at the end if script was run directly (not piped or redirected)
if ($Host.Name -eq "ConsoleHost" -and -not $Quiet) {
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}