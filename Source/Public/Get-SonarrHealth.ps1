function Get-SonarrHealth
{
	<#
    .SYNOPSIS
        Gets health status and warnings from Sonarr.

    .DESCRIPTION
        Returns health check results from Sonarr, including any warnings or errors
        related to system configuration, disk space, updates, etc.

    .PARAMETER Server
        The Sonarr server to query. If not specified, uses the default configured server.

    .EXAMPLE
        Get-SonarrHealth

        Returns all health check results from the default Sonarr server.

    .EXAMPLE
        Get-SonarrHealth

    .NOTES
        Requires Sonarr v3+ API.
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
