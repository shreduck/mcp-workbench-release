param(
    [string]$Target = "$env:USERPROFILE\Apps\MCP Workbench",
    [ValidateSet("with-jre", "launcher")]
    [string]$Flavor = "with-jre",
    [string]$Version = "latest",
    [string]$Repository = "shreduck/mcp-workbench-release"
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message"
}

function Get-Release {
    param(
        [string]$Repository,
        [string]$Version
    )

    $headers = @{
        "Accept" = "application/vnd.github+json"
        "User-Agent" = "mcp-workbench-installer"
    }

    if ($Version -eq "latest") {
        $uri = "https://api.github.com/repos/$Repository/releases?per_page=30"
        $releases = Invoke-RestMethod -Uri $uri -Headers $headers
        $release = $releases | Where-Object { -not $_.draft } | Select-Object -First 1
        if ($null -eq $release) {
            throw "No public releases were found for $Repository."
        }
        return $release
    }

    $tag = [Uri]::EscapeDataString($Version)
    $tagUri = "https://api.github.com/repos/$Repository/releases/tags/$tag"
    return Invoke-RestMethod -Uri $tagUri -Headers $headers
}

function Select-Asset {
    param(
        $Release,
        [string]$Flavor
    )

    $pattern = if ($Flavor -eq "with-jre") {
        '^mcp-workbench-windows-with-jre-.+\.zip$'
    } else {
        '^mcp-workbench-windows-launcher-.+\.zip$'
    }

    $asset = $Release.assets | Where-Object { $_.name -match $pattern } | Select-Object -First 1
    if ($null -eq $asset) {
        $available = ($Release.assets | ForEach-Object { $_.name }) -join ", "
        throw "Could not find a Windows $Flavor zip on release $($Release.tag_name). Available assets: $available"
    }
    return $asset
}

function Remove-KnownAppFiles {
    param([string]$Target)

    $paths = @(
        "MCP Workbench.exe",
        "app",
        "runtime",
        "mcp-workbench-launcher.jar",
        "run-mcp-workbench.bat"
    )

    foreach ($path in $paths) {
        $fullPath = Join-Path $Target $path
        if (Test-Path -LiteralPath $fullPath) {
            Remove-Item -LiteralPath $fullPath -Recurse -Force
        }
    }
}

function Copy-ReleaseContents {
    param(
        [string]$Source,
        [string]$Target
    )

    New-Item -ItemType Directory -Force -Path $Target | Out-Null
    Remove-KnownAppFiles -Target $Target
    Get-ChildItem -LiteralPath $Source | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $Target -Recurse -Force
    }
}

$release = Get-Release -Repository $Repository -Version $Version
$asset = Select-Asset -Release $release -Flavor $Flavor
$targetPath = [IO.Path]::GetFullPath($Target)
$workDir = Join-Path ([IO.Path]::GetTempPath()) ("mcp-workbench-install-" + [Guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $workDir $asset.name
$extractDir = Join-Path $workDir "extract"

try {
    Write-Step "Release: $($release.tag_name)"
    Write-Step "Asset: $($asset.name)"
    Write-Step "Target: $targetPath"

    New-Item -ItemType Directory -Force -Path $workDir | Out-Null
    Write-Step "Downloading from public GitHub Releases"
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -UseBasicParsing

    Write-Step "Extracting zip"
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force

    $items = @(Get-ChildItem -LiteralPath $extractDir)
    $sourceDir = if ($items.Count -eq 1 -and $items[0].PSIsContainer) {
        $items[0].FullName
    } else {
        $extractDir
    }

    Write-Step "Installing files"
    Copy-ReleaseContents -Source $sourceDir -Target $targetPath

    Write-Step "Done"
    Write-Host "Installed MCP Workbench $($release.tag_name) to $targetPath"
    if ($Flavor -eq "with-jre") {
        Write-Host "Run: `"$targetPath\MCP Workbench.exe`""
    } else {
        Write-Host "Run: `"$targetPath\run-mcp-workbench.bat`""
    }
} finally {
    if (Test-Path -LiteralPath $workDir) {
        Remove-Item -LiteralPath $workDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
