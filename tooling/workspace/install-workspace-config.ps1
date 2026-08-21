[CmdletBinding()]
param(
    [string]$AppsRoot
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($AppsRoot)) {
    $AppsRoot = Join-Path $PSScriptRoot '..\..\..'
}

$resolvedAppsRoot = (Resolve-Path -LiteralPath $AppsRoot).Path
$repositoryNames = @(
    'sandicts-docs',
    'nodejs-sandicts-api',
    'reactjs-sandicts-web'
)

foreach ($repositoryName in $repositoryNames) {
    $repositoryPath = Join-Path $resolvedAppsRoot $repositoryName
    if (-not (Test-Path -LiteralPath (Join-Path $repositoryPath '.git'))) {
        throw "Expected Git repository not found: $repositoryPath"
    }
}

$sourceVscodeSettings = Join-Path $PSScriptRoot '.vscode\settings.json'
$sourcePrePushHook = Join-Path $PSScriptRoot '.githooks\pre-push'
$targetVscodeDirectory = Join-Path $resolvedAppsRoot '.vscode'
$targetHooksDirectory = Join-Path $resolvedAppsRoot '.githooks'
$targetVscodeSettings = Join-Path $targetVscodeDirectory 'settings.json'
$targetPrePushHook = Join-Path $targetHooksDirectory 'pre-push'

New-Item -ItemType Directory -Force -Path $targetVscodeDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $targetHooksDirectory | Out-Null
Copy-Item -LiteralPath $sourceVscodeSettings -Destination $targetVscodeSettings -Force
Copy-Item -LiteralPath $sourcePrePushHook -Destination $targetPrePushHook -Force

$gitExecutable = (Get-Command git -ErrorAction Stop).Source
$portableHooksPath = (Resolve-Path -LiteralPath $targetHooksDirectory).Path.Replace('\', '/')

foreach ($repositoryName in $repositoryNames) {
    $repositoryPath = Join-Path $resolvedAppsRoot $repositoryName
    & $gitExecutable -C $repositoryPath config core.hooksPath $portableHooksPath
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to configure Git hooks for $repositoryName"
    }
}

Write-Output "Workspace settings installed in $resolvedAppsRoot"
Write-Output "Git pre-push hook configured for $($repositoryNames.Count) repositories"
