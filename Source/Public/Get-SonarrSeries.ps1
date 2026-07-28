function Get-SonarrSeries
{
	<#
		.SYNOPSIS
			Retrieves series from Sonarr.

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
			The TVDB (TheTVDB) ID of the series to retrieve. Sonarr filters on this server side, so only the
			matching series is returned over the wire.

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

			-Id and -TVDBID are resolved by Sonarr itself. -Name, -IMDBID and -TMDBID are not supported as
			filters by the Sonarr API, so the full series list is retrieved and filtered locally; prefer
			-TVDBID where you have the choice and the library is large.
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
	#Region Define the path and any server side filtering
	# Sonarr only filters the series list server side by TVDB ID (and by its own ID, via a dedicated route).
	# Everything else has to come back over the wire in full and be filtered below.
	try
	{
		$Path = '/series'
		$Params = @{}

		if($PSCmdlet.ParameterSetName -eq 'Id' -and $Id)
		{
			$Path += "/$Id"
		}
		elseif($PSCmdlet.ParameterSetName -eq 'TVDBID')
		{
			$Params['tvdbId'] = $TVDBID
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
		# -SuppressWhatIf because this is a read: without it, running any ShouldProcess-capable caller under
		# -WhatIf suppresses the lookup and the caller sees "not found" rather than a preview.
		$Data = Invoke-SonarrRequest -Path $Path -Method GET -Params $Params -SuppressWhatIf -ErrorAction Stop
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
					# Already filtered server side. Repeating it here costs nothing against a single result
					# and keeps the output correct if an instance ever ignores the tvdbId parameter:
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