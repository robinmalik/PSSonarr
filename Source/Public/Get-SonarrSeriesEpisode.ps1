function Get-SonarrSeriesEpisode
{
	<#
	.SYNOPSIS
		Retrieves episode-level data for a series from Sonarr.

	.DESCRIPTION
		PSSonarr does not expose the episode endpoint, so this calls the Sonarr API
		directly (GET /api/v3/episode?seriesId=) using the same server and API key
		that server.ps1 passes to Set-SonarrConfiguration.

	.PARAMETER SeriesId
		The Sonarr series ID.

	.EXAMPLE
		$Episodes = Get-SonarrSeriesEpisode -SeriesId 123
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[int]$SeriesId
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
		Invoke-SonarrRequest -Path "/episode?seriesId=$SeriesId" -Method GET -ErrorAction Stop
	}
	catch
	{
		throw $_
	}
}
