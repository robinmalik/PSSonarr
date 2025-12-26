function Start-SonarrSeasonSearch
{
	<#
		.SYNOPSIS
			Initiate a search for missing episodes within a specific season of a series in Sonarr.

		.SYNTAX
			Start-SonarrSeasonSearch -SeriesId <Int32> -SeasonNumber <Int32> [<CommonParameters>]

		.DESCRIPTION
			Initiates a search command in Sonarr to download missing episodes for a specific season of a series.
			This function triggers the same action as clicking "Search Season" in the Sonarr web interface.

		.PARAMETER SeriesId
			The Sonarr series ID to search episodes for.

		.PARAMETER SeasonNumber
			The season number to search episodes for (e.g., 1 for Season 1, 0 for Specials).

		.EXAMPLE
			Start-SonarrSeasonSearch -SeriesId 123 -SeasonNumber 1

		.EXAMPLE
			Start-SonarrSeasonSearch -SeriesId 456 -SeasonNumber 0

		.NOTES
			This function initiates a search command in Sonarr to download missing episodes.
			The series must already exist in Sonarr for this function to work.
			This is equivalent to clicking "Search Season" in the Sonarr web interface.
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[Int32]$SeriesId,

		[Parameter(Mandatory = $true)]
		[Int32]$SeasonNumber
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
	#Region Validate series exists
	try
	{
		$Series = Get-SonarrSeries -Id $SeriesId -ErrorAction Stop
		if(!$Series)
		{
			throw "Series with ID $SeriesId not found in Sonarr."
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion

	####################################################################################################
	#Region Define command body
	try
	{
		# Create the command body for SeasonSearch
		$CommandBody = @{
			name         = "SeasonSearch"
			seriesId     = $SeriesId
			seasonNumber = $SeasonNumber
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
		$Result = Invoke-SonarrRequest -Path '/command' -Method POST -Body $CommandBody -ErrorAction Stop
		{
			Write-Verbose "Season search initiated successfully. Command ID: $($Result.id)"
			return $Result
		}
		else
		{
			Write-Warning -Message "Failed to initiate season search for season $SeasonNumber in series ID $SeriesId."
			return
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion
}
