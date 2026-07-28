function Invoke-SonarrSeriesSearch
{
	<#
		.SYNOPSIS
			Initiate a search for missing episodes in a series, or in one season of a series, in Sonarr.

		.DESCRIPTION
			Initiates a search command in Sonarr to download missing episodes.

			By default the whole series is searched, which is the same action as clicking "Search Monitored"
			against a series in the Sonarr web interface. Supplying -SeasonNumber narrows the search to a
			single season instead, equivalent to clicking "Search Season".

			These are two different Sonarr commands under the covers: SeriesSearch for the whole series and
			SeasonSearch for one season.

		.PARAMETER SeriesId
			The Sonarr series ID to search for. Aliased to 'Id' so a series object can be piped in directly.

		.PARAMETER SeasonNumber
			The season number to restrict the search to (e.g. 1 for Season 1, 0 for Specials). If omitted,
			the entire series is searched.

		.EXAMPLE
			Invoke-SonarrSeriesSearch -SeriesId 123

			Searches for all missing episodes across the whole series.

		.EXAMPLE
			Invoke-SonarrSeriesSearch -SeriesId 123 -SeasonNumber 1

			Searches for missing episodes in season 1 only.

		.EXAMPLE
			Invoke-SonarrSeriesSearch -SeriesId 456 -SeasonNumber 0

			Searches the specials season only.

		.EXAMPLE
			Get-SonarrSeries -Name 'The Expanse' | Invoke-SonarrSeriesSearch

		.NOTES
			The series must already exist in Sonarr. Returns the command object Sonarr queued; the search
			itself runs asynchronously, so a successful return means the command was accepted, not that
			anything has been grabbed.
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('Id')]
		[Int32]$SeriesId,

		[Parameter(Mandatory = $false)]
		[Int32]$SeasonNumber
	)

	begin
	{
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

		# Tested via PSBoundParameters rather than the value itself, because season 0 (Specials) is a valid
		# season number and would otherwise be indistinguishable from the parameter being omitted:
		$SearchSeason = $PSBoundParameters.ContainsKey('SeasonNumber')
	}
	process
	{
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
			if($SearchSeason)
			{
				$CommandBody = @{
					name         = 'SeasonSearch'
					seriesId     = $SeriesId
					seasonNumber = $SeasonNumber
				}
				$ActionDescription = "Series with ID: $SeriesId (season $SeasonNumber)"
			}
			else
			{
				$CommandBody = @{
					name     = 'SeriesSearch'
					seriesId = $SeriesId
				}
				$ActionDescription = "Series with ID: $SeriesId (all seasons)"
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
			if($PSCmdlet.ShouldProcess($ActionDescription, "Search"))
			{
				Write-Verbose -Message "Sending $($CommandBody.name) for series ID $SeriesId"
				$Result = Invoke-SonarrRequest -Path '/command' -Method POST -Body $CommandBody -ErrorAction Stop
				return $Result
			}
		}
		catch
		{
			throw $_
		}
		#EndRegion
	}
}
