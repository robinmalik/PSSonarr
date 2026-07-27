# In-session override for the selected context.
$script:ActiveContext = $null

#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

#Dot source the files
foreach($import in @($Public + $Private))
{
	try
	{
		. $import.fullname -ErrorAction Stop
	}
	catch
	{
		Write-Error -Message "Failed to import function $($import.fullname): $_"
	}
}