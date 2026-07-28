function Get-SonarrHealth
{
	<#
		.SYNOPSIS
			Gets health status and warnings from Sonarr.

		.DESCRIPTION
			Returns health check results from Sonarr, including any warnings or errors
			related to system configuration, disk space, updates, etc.

		.EXAMPLE
			Get-SonarrHealth

			Returns all health check results from the active Sonarr context.

		.EXAMPLE
			Get-SonarrHealth | Where-Object { $_.type -eq 'error' }

			Returns only the health checks that Sonarr has raised as errors.

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
		$Data = Invoke-SonarrRequest -Path '/health' -Method GET -ErrorAction Stop
		return $Data
	}
	catch
	{
		throw $_
	}
	#EndRegion
}
