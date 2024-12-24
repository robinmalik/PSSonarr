function Import-Configuration
{
	[CmdletBinding()]
	param(
	)

	$FileName = 'PSSonarrConfig.json'
	$FilePath = "$HOME/.PSSonarr/$FileName"

	if(Test-Path $FilePath)
	{
		try
		{
			$Script:Config = Get-Content $FilePath -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
		}
		catch
		{
			throw $_
		}

		# Refine to our default server:
		$Script:Config = $Script:Config | Where-Object { $_.Default -eq $True }
		if(!$Script:Config)
		{
			throw "No default server found in $FilePath. Please run Set-SonarrConfiguration."
		}
	}
	else
	{
		throw "Config file not found at $FilePath. Please run Set-SonarrConfiguration."
	}
}