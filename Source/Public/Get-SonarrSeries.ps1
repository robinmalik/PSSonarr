function Get-SonarrSeries
{
	<#
		.SYNOPSIS
			Retrieves series from Sonarr.

		.SYNTAX
			Get-SonarrSeries [<CommonParameters>]

			Get-SonarrSeries -Id <String> [<CommonParameters>]

			Get-SonarrSeries -Name <String> [<CommonParameters>]

			Get-SonarrSeries -IMDBID <String> [<CommonParameters>]

			Get-SonarrSeries -TMDBID <String> [<CommonParameters>]

			Get-SonarrSeries -TVDBID <String> [<CommonParameters>]

		.DESCRIPTION
			Retrieves series information from Sonarr. Can return all series or filter by specific criteria
			such as ID, name, or external database IDs.

		.PARAMETER Id
			The Sonarr series ID to retrieve.

		.PARAMETER Name
			The name or title of the series to retrieve. Searches both title and originalTitle fields.

		.PARAMETER IMDBID
			The IMDB ID of the series to retrieve. Can include or exclude the 'tt' prefix.

		.PARAMETER TMDBID
			The TMDB (The Movie Database) ID of the series to retrieve.

		.PARAMETER TVDBID
			The TVDB (TheTVDB) ID of the series to retrieve.

		.EXAMPLE
			Get-SonarrSeries

		.EXAMPLE
			Get-SonarrSeries -Id '1'

		.EXAMPLE
			Get-SonarrSeries -Name 'Game of Thrones'

		.EXAMPLE
			Get-SonarrSeries -IMDBID 'tt0944947'

		.NOTES
			When no parameters are specified, all series in Sonarr are returned.
	#>

	[CmdletBinding(DefaultParameterSetName = 'All')]
	param(
		[Parameter(Mandatory = $false, ParameterSetName = 'Id')]
		[String]$Id,

		[Parameter(Mandatory = $false, ParameterSetName = 'Name')]
		[Alias('Title')]
		[String]$Name,

		[Parameter(Mandatory = $false, ParameterSetName = 'IMDBID')]
		[ValidatePattern('^(tt)?\d{5,9}$')]
		[String]$IMDBID,

		[Parameter(Mandatory = $true, ParameterSetName = 'TMDBID')]
		[String]$TMDBID,

		[Parameter(Mandatory = $false, ParameterSetName = 'TVDBID')]
		[ValidatePattern('^\d{1,9}$')]
		[String]$TVDBID
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
	#Region Define the path
	try
	{
		$Path = '/series'
		if($PSCmdlet.ParameterSetName -eq 'Id' -and $Id)
		{
			$Path += "/$Id"
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
		$Data = Invoke-SonarrRequest -Path $Path -Method GET -ErrorAction Stop
		if($Data)
		{
			# Filter results based on parameters if specified
			switch($PSCmdlet.ParameterSetName)
			{
				'Name'
				{
					$Data = $Data | Where-Object { $_.title -eq $Name -or $_.originalTitle -eq $Name }
				}
				'IMDBID'
				{
					if($IMDBID -notmatch '^tt')
					{
						$IMDBID = 'tt' + $IMDBID
					}
					$Data = $Data | Where-Object { $_.imdbId -eq "$IMDBID" }
				}
				'TMDBID'
				{
					$Data = $Data | Where-Object { $_.tmdbId -eq $TMDBID }
				}
				'TVDBID'
				{
					$Data = $Data | Where-Object { $_.tvdbId -eq $TVDBID }
				}
			}

			return $Data
		}
		else
		{
			Write-Verbose -Message 'No result found.'
			return
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion
}