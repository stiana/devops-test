$workingdirectory = Get-Location
$projectPath = "$workingdirectory"
$solutionName = "DevOps-test1.sln"
$solutionPath = "$projectPath\$solutionName"
$bootPath = "$projectPath\DevOps-test1\_Boot"

. "$workingdirectory\scripts\BuildFunctions.ps1"
. "$workingdirectory\scripts\MessageFilter.ps1"



# register MessageFiler to handle COM object messages
AddMessageFilterClass
[EnvDTEUtils.MessageFilter]::Register() 

# Print working directories
 Log $workingdirectory
 Log $projectPath
 Log $solutionName
 Log $solutionPath
 Log $bootPath

# Ensure previously boot folder is removed before new build
if (Test-Path -Path $bootPath) {
	Remove-Item $bootPath -Recurse
}

log "Start TcXaeShell,... "
$dte = new-object -com TcXaeShell.DTE.15.0
$dte.SuppressUI = $false
$dte.MainWindow.Visible = $true

log "Open solution,... "
$sln = $dte.Solution
$sln.Open($solutionPath)

$project = $sln.Projects.Item(1)
$systemManager = $project.Object

log "testing variant output -> start"
log $systemManager.ProjectVariantConfig 
log "testing variant output -> end"

log "current variant:"
log $systemManager.CurrentProjectVariant

log "current variant:"
$systemManager | log Get-Member -Name CurrentProjectVariant

log "Set variant"
$systemManager.CurrentProjectVariant = "Variant3"



log "Set target netid ... "
$systemManager.SetTargetNetId("5.90.1.214.1.1")

$targetNetId = $systemManager.GetTargetNetId()
log "Target netid: $targetNetId"


log "Clean solution.... "
$sln.solutionBuild.Clean($true)

#Build-Project $sln "$workingdirectory\DevOps-test1\DevOps-test1.tsproj" "Release|TwinCAT RT (x64)"
Build-Project $sln "$workingdirectory\DevOps-test1\DevOps-test1.tsproj" "Release|TwinCAT CE7 (ARMV7)"

log "Activate configuration... "
$systemManager.ActivateConfiguration()

log "Restart TwinCAT.... "
$systemManager.StartRestartTwinCAT() 
 

$dte.Quit()

[EnvDTEUtils.MessageFilter]::Revoke() 

Exit 0