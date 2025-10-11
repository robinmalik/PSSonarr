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
		[Parameter(Mandatory = $true, ParameterSetName = 'IMDB')]
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
	if($ParameterSetName -eq 'IMDBID' -and $IMDBID -notmatch '^tt')
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
			Write-Warning "Series already exists in Sonarr!"
			return
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
		$Path = '/series/lookup'

		if($TVDBID)
		{
			$Params = @{
				term = "tvdb%3A$($TVDBID)"
			}
		}
		elseif($IMDBID)
		{
			$Params = @{
				term = "imdb%3A$($IMDBID)"
			}
		}

		# Generate the headers and URI
		$Headers = Get-Headers
		$Uri = Get-APIUri -RestEndpoint $Path -Params $Params
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
			$Series = Search-SonarrSeries -IMDBID $IMDBID -ErrorAction Stop
		}
		elseif($TMDBID)
		{
			$Series = Search-SonarrSeries -TMDBID $TMDBID -ErrorAction Stop
		}
		elseif($TVDBID)
		{
			$Series = Search-SonarrSeries -TVDBID $TVDBID -ErrorAction Stop
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
		$DataEncoded = ([System.Text.Encoding]::UTF8.GetBytes($Data))

		$Headers = Get-Headers
		$Path = '/series'
		$Uri = Get-APIUri -RestEndpoint $Path
	}
	catch
	{
		throw $_
	}
	#EndRegion


	####################################################################################################
	#Region make the main request
	Write-Verbose "Adding: $Uri"
	try
	{
		Invoke-RestMethod -Uri $Uri -Headers $Headers -Method Post -ContentType "application/json" -Body $DataEncoded -ErrorAction Stop
	}
	catch
	{
		throw $_
	}
	#EndRegion
}