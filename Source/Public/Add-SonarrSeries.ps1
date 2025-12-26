function Add-SonarrSeries
{
	<#
		.SYNOPSIS
			Add a series to Sonarr by IMDB, TMDB, or TVDB ID.

		.SYNTAX
			Add-SonarrSeries -IMDBID <String> -QualityProfileId <Int32> [-MonitorOption <String>] [-Search] [<CommonParameters>]

			Add-SonarrSeries -TMDBID <String> -QualityProfileId <Int32> [-MonitorOption <String>] [-Search] [<CommonParameters>]

			Add-SonarrSeries -TVDBID <String> -QualityProfileId <Int32> [-MonitorOption <String>] [-Search] [<CommonParameters>]

		.DESCRIPTION
			Adds a series to Sonarr using external database IDs. The function will search for the series using the provided ID,
			then add it to Sonarr with the specified quality profile and monitoring options.

			Note: This function only targets settings for the show as a whole (e.g. quality profile and monitoring new seasons) but
			not individual seasons; for this use Set-SonarrSeasonStatus after adding the series.

		.PARAMETER IMDBID
			The IMDB ID of the series to add. Can include or exclude the 'tt' prefix.

		.PARAMETER TMDBID
			The TMDB (The Movie Database) ID of the series to add.

		.PARAMETER TVDBID
			The TVDB (TheTVDB) ID of the series to add.

		.PARAMETER QualityProfileId
			The ID of the quality profile to assign to the series.

		.PARAMETER MonitorOption
			The monitoring option for the series. Valid values are: 'all', 'firstSeason', 'lastSeason', 'future', 'missing', 'existing', 'recent', 'pilot', 'monitorSpecials', 'unmonitorSpecials', 'none'. Defaults to 'all'.

		.PARAMETER Search
			If specified, initiates a search for missing episodes after adding the series.

		.EXAMPLE
			Add-SonarrSeries -IMDBID 'tt0944947' -QualityProfileId 1 -MonitorOption 'all' -Search

		.EXAMPLE
			Add-SonarrSeries -TVDBID '121361' -QualityProfileId 2 -MonitorOption 'future'

		.NOTES
			The series must exist in the external database (IMDB, TMDB, or TVDB) and be findable through Sonarr's lookup service.
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = 'IMDBID')]
		[ValidatePattern('^(tt)?\d{5,9}$')]
		[String]$IMDBID,

		[Parameter(Mandatory = $true, ParameterSetName = 'TMDB')]
		[ValidatePattern('^\d{1,9}$')]
		[String]$TMDBID,

		[Parameter(Mandatory = $true, ParameterSetName = 'TVDB')]
		[String]$TVDBID,

		[Parameter(Mandatory = $true)]
		[int]
		$QualityProfileId,

		[Parameter(Mandatory = $false)]
		[ValidateSet('all', 'firstSeason', 'lastSeason', 'future', 'missing', 'existing', 'recent', 'pilot', 'monitorSpecials', 'unmonitorSpecials', 'none')]
		$MonitorOption = 'all',

		[Parameter(Mandatory = $false)]
		[Switch]$Search
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
	# If using IMDB, ensure the ID is in the correct format
	if($PSCmdlet.ParameterSetName -eq 'IMDBID' -and $IMDBID -notmatch '^tt')
	{
		$IMDBID = 'tt' + $IMDBID
	}


	####################################################################################################
	#Region Check if already in Sonarr before attempting an addition
	Write-Verbose -Message "Checking if the series already exists"
	try
	{
		if($IMDBID)
		{
			$Series = Get-SonarrSeries -IMDBID $IMDBID -ErrorAction Stop
		}
		elseif($TMDBID)
		{
			$Series = Get-SonarrSeries -TMDBID $TMDBID -ErrorAction Stop
		}
		elseif($TVDBID)
		{
			$Series = Get-SonarrSeries -TVDBID $TVDBID -ErrorAction Stop
		}

		if($Series)
		{
			Write-Verbose -Message "Series already exists in Sonarr with ID $($Series.id)."

			if($Series.qualityProfileId -ne $QualityProfileId)
			{
				Write-Warning -Message "Series already exists but has a different quality profile (Current: $($Series.qualityProfileId), Desired: $QualityProfileId). Use 'Set-SonarrSeriesQualityProfile' to update the quality profile."

			}

			if($Series.monitored -eq $false -and $MonitorOption -ne 'none')
			{
				Write-Warning -Message "Series already exists but is unmonitored. Use 'Set-SonarrSeriesStatus' to change series monitoring status, and 'Set-SonarrSeasonStatus' to change season monitoring status."
			}

			if($Series.monitored -eq $true -and $MonitorOption -eq 'none')
			{
				Write-Warning -Message "Series already exists and is monitored. Use 'Set-SonarrSeriesStatus' to change series monitoring status, and 'Set-SonarrSeasonStatus' to change season monitoring status."
			}

			return $Series
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion


	####################################################################################################
	#Region Define the path, parameters, headers and URI
	try
	{
		if($TVDBID)
		{
			$Params = @{
				term = "tvdb:$TVDBID"
			}
		}
		elseif($IMDBID)
		{
			$Params = @{
				term = "imdb:$IMDBID"
			}
		}
		elseif($TMDBID)
		{
			$Params = @{
				term = "tmdb:$TMDBID"
			}
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion


	####################################################################################################
	#Region Search for the series (we need to get the data before adding it)
	Write-Verbose -Message "Using Sonarr lookup service to find the series"
	try
	{
		if($IMDBID)
		{
			$Series = Find-SonarrSeries -IMDBID $IMDBID -ErrorAction Stop
		}
		elseif($TMDBID)
		{
			$Series = Find-SonarrSeries -TMDBID $TMDBID -ErrorAction Stop
		}
		elseif($TVDBID)
		{
			$Series = Find-SonarrSeries -TVDBID $TVDBID -ErrorAction Stop
		}

		if(!$Series)
		{
			throw "Could not find the series to add"
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion


	#############################################################################
	#Region Append data
	try
	{
		$Series | Add-Member -MemberType NoteProperty -Name 'qualityProfileId' -Value $QualityProfileId -Force
		$Series | Add-Member -MemberType NoteProperty -Name 'languageProfileId' -Value 1 -Force
		$Series | Add-Member -MemberType NoteProperty -Name 'seasonFolder' -Value $True -Force
		$Series | Add-Member -MemberType NoteProperty -Name 'monitored' -Value $True -Force
		$Series | Add-Member -MemberType NoteProperty -Name 'rootFolderPath' -Value $Config.RootFolderPath -Force

		if($Search)
		{
			$Series | Add-Member -MemberType NoteProperty -Name 'addOptions' -Value $(
				[PSCustomObject]@{
					monitor                    = $MonitorOption
					searchForMissingEpisodes   = $true
					ignoreEpisodesWithFiles    = $false
					ignoreEpisodesWithoutFiles = $false
				}
			) -Force
		}
		else
		{
			$Series | Add-Member -MemberType NoteProperty -Name 'addOptions' -Value $(
				[PSCustomObject]@{
					monitor                      = $MonitorOption
					searchForMissingEpisodes     = $false
					searchForCutoffUnmetEpisodes = $false
					ignoreEpisodesWithFiles      = $false
					ignoreEpisodesWithoutFiles   = $false
				}
			) -Force
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion


	####################################################################################################
	#Region Define the path, parameters, headers and URI
	try
	{
		$Data = $Series | ConvertTo-Json -Depth 5
		Write-Debug -Message "Series data to be posted: $Data"
	}
	catch
	{
		throw $_
	}
	#EndRegion


	####################################################################################################
	#Region make the main request
	Write-Verbose "Adding series to Sonarr"
	try
	{
		$Result = Invoke-SonarrRequest -Path '/series' -Method POST -Body $Data -ErrorAction Stop
		return $Result
	}
	catch
	{
		throw $_
	}
	#EndRegion
}