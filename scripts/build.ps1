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

$targetNetId = $systemManager.GetTargetNetId()
log "Target netid: $targetNetId"

log "Clean solution,... "
$sln.solutionBuild.Clean($true)

Build-Project $sln "$workingdirectory\DevOps-test1\DevOps-test1.tsproj" "Release|TwinCAT RT (x64)"
#Build-Project $sln "$workingdirectory\sDevOps-test1\PLC\PLC.plcproj" "Release|TwinCAT RT (x64)"



$dte.Quit()

[EnvDTEUtils.MessageFilter]::Revoke() 

Exit 0