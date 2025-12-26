function Get-SonarrSystem
{
	<#
    .SYNOPSIS
        Gets Sonarr system status information.

    .DESCRIPTION
        Returns detailed system status information including version, branch,
        authentication method, database information, operating system, and more.

    .EXAMPLE
        Get-SonarrSystem

    .EXAMPLE
        (Get-SonarrSystem).version

        Returns just the version number of Sonarr.

    .NOTES
        Requires Sonarr v3+ API.
    #>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $false)]
		[string]$Server
	)

	####################################################################################################
	#Region Import configuration
	try
	{
		if($Server)
		{
			Import-Configuration -Server $Server -ErrorAction Stop
		}
		else
		{
			Import-Configuration -ErrorAction Stop
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion


	####################################################################################################
	#Region make the main request
	try
	{
		$Data = Invoke-SonarrRequest -Path '/system/status' -Method GET -ErrorAction Stop
		return $Data
	}
	catch
	{
		throw $_
	}
	#EndRegion
}
