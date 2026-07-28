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
			Queries the active context. Use Select-SonarrContext to target a different instance.
    #>
	[CmdletBinding()]
	param (
	)

	####################################################################################################
	#Region Import configuration
	try
	{
		Import-Configuration -ErrorAction Stop
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
