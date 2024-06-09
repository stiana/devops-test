function Log {
	param (
		$message
	)

	$date = Get-Date -Format "o"
	Write-Host "${date}: ${message}"
}

function Build-Project {
	param (
		$sln,
		$ProjectPath,
		$SolutionConfiguration
	)

	log  "Build configuratoin '$SolutionConfiguration' of project: $ProjectPath"
	$sln.solutionBuild.BuildProject("$SolutionConfiguration", $ProjectPath, $true)

	$lastBuildInfo = $sln.solutionBuild.LastBuildInfo

	if($lastBuildInfo -eq 0){
		log "Build succeeded"
	}
	else{
		log "Build failed"
		$dte.Quit()
		Exit 1
	}

}