function Get-SonarrUpcomingEpisodes
{
	<#
		.SYNOPSIS
			Retrieves upcoming episodes from the Sonarr calendar.

		.DESCRIPTION
			Queries the Sonarr calendar endpoint (GET /api/v3/calendar) and returns the episodes
			airing between StartDate and EndDate.

			Dates are converted to UTC and sent in ISO 8601 format with milliseconds
			(yyyy-MM-ddTHH:mm:ss.fffZ), which is what the Sonarr calendar endpoint expects.

		.PARAMETER StartDate
			The start of the period to query. Defaults to the current date and time.

		.PARAMETER EndDate
			The end of the period to query. Defaults to the current date and time plus 7 days.

		.PARAMETER IncludeUnmonitored
			Include episodes of series/seasons that are not monitored. By default only monitored
			episodes are returned (unmonitored=false).

		.EXAMPLE
			Get-SonarrUpcomingEpisodes

			Returns monitored episodes airing in the next 7 days.

		.EXAMPLE
			Get-SonarrUpcomingEpisodes -StartDate (Get-Date).Date -EndDate (Get-Date).Date.AddMonths(1)

			Returns monitored episodes airing between midnight today and the same time next month.

		.EXAMPLE
			Get-SonarrUpcomingEpisodes -EndDate (Get-Date).AddDays(30) -IncludeUnmonitored

			Returns all episodes airing in the next 30 days, including unmonitored ones.

		.EXAMPLE
			Get-SonarrUpcomingEpisodes |
				Select-Object airDate, seriesTitle, seasonNumber, episodeNumber, title |
				Sort-Object airDate

			Returns the next 7 days as a readable schedule including the name of each series.

		.NOTES
			By default the calendar endpoint returns episode objects only; they identify the series
			by seriesId, not by name.
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $false)]
		[DateTime]$StartDate = (Get-Date),

		[Parameter(Mandatory = $false)]
		[DateTime]$EndDate = (Get-Date).AddDays(7),

		[Parameter(Mandatory = $false)]
		[Switch]$IncludeUnmonitored
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
	#Region Validate the date range
	if($EndDate -lt $StartDate)
	{
		throw "EndDate ($EndDate) must not be earlier than StartDate ($StartDate)."
	}
	#EndRegion


	####################################################################################################
	#Region Define the parameters
	try
	{
		# Sonarr expects UTC timestamps in the form 2026-06-27T23:00:00.000Z. InvariantCulture is used
		# to guarantee the ':' time separator regardless of the culture of the calling session.
		$Format = 'yyyy-MM-ddTHH:mm:ss.fffZ'
		$Culture = [System.Globalization.CultureInfo]::InvariantCulture

		$Params = @{
			start       = $StartDate.ToUniversalTime().ToString($Format, $Culture)
			end         = $EndDate.ToUniversalTime().ToString($Format, $Culture)
			includeSeries = 'true'
			unmonitored = 'false'
		}

		if($IncludeUnmonitored)
		{
			$Params['unmonitored'] = 'true'
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
		$Data = Invoke-SonarrRequest -Path '/calendar' -Method GET -Params $Params -ErrorAction Stop
		if($Data)
		{
			# Surface the title as a flat property and drop the embedded series object, which is
			# ~1.5KB per episode and makes the output unwieldy to read.
			$Data = $Data | Select-Object -Property @{ Name = 'seriesTitle'; Expression = { $_.series.title } }, * -ExcludeProperty series
			return $Data
		}
		else
		{
			Write-Verbose -Message 'No upcoming episodes found in the specified period.'
			return
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion
}
