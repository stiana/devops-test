# Parameters
$solutionName = "DevOps-test1"
$platform = "Release|TwinCAT CE7 (ARMV7)" # Release|TwinCAT RT (x64)
$setVariant = "Variant1"
$targetNetId = "5.90.1.214.1.1"
$supressUI = $false
$mainWindowVisible = $true

# Prepare paths
$projectPath = Get-Location
$solutionPath = "$projectPath\$solutionName"
$solutionProjectFilePath = "$projectPath\$solutionName.sln"
$bootPath = "$projectPath\$solutionName\_Boot"

# Call helper scripts
. "$projectPath\scripts\BuildFunctions.ps1"
. "$projectPath\scripts\MessageFilter.ps1"

# register MessageFiler to handle COM object messages
AddMessageFilterClass
[EnvDTEUtils.MessageFilter]::Register() 

# Ensure previously boot folder is removed before new build
if (Test-Path -Path $bootPath) {
	Remove-Item $bootPath -Recurse
}

log "Start TcXaeShell,... "
$dte = new-object -com TcXaeShell.DTE.15.0

$dte.SuppressUI = $supressUI
$dte.MainWindow.Visible = $mainWindowVisible

log "Open solution... "
$sln = $dte.Solution
$sln.Open($solutionProjectFilePath)

# Get TwinCAT project from solution
$project = $sln.Projects.Item(1)
$systemManager = $project.Object

log "Set variant to: $setVariant"
$systemManager.CurrentProjectVariant = $setVariant

$currentVariant = $systemManager.CurrentProjectVariant
log "Variant is set to: $currentVariant"

log "Set target netid... "
$systemManager.SetTargetNetId($targetNetId)

$targetNetId = $systemManager.GetTargetNetId()
log "Target netid set to: $targetNetId"

log "Clean solution... "
$sln.solutionBuild.Clean($true)

Build-Project $sln "$solutionPath\$solutionName.tsproj" $platform

log "Activate configuration... "
$systemManager.ActivateConfiguration()

log "Restart TwinCAT... "
$systemManager.StartRestartTwinCAT() 
 

$dte.Quit()

[EnvDTEUtils.MessageFilter]::Revoke() 

Exit 0