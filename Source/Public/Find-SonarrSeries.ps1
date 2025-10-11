function Find-SonarrSeries
{
	<#
		.SYNOPSIS
			Search to find a series in order to add to Sonarr.

		.SYNTAX
			Find-SonarrSeries -Name <String> [-ExactMatch] [<CommonParameters>]

			Find-SonarrSeries -IMDBID <String> [<CommonParameters>]

			Find-SonarrSeries -TMDBID <String> [<CommonParameters>]

			Find-SonarrSeries -TVDBID <String> [<CommonParameters>]

		.DESCRIPTION
			This uses the lookup service within Sonarr to search for a series by name, TVDB ID, or IMDB ID.
			It does not search your local Sonarr library, but rather The Movie Database (TMDb).

		.PARAMETER Name
			The name of the series to search for.

		.PARAMETER TMDBID
			The TMDB ID of the series to search for.

		.PARAMETER TVDBID
			The TVDB ID of the series to search for.

		.PARAMETER IMDBID
			The IMDB ID of the series to search for.

		.EXAMPLE
			Find-SonarrSeries -Name "The Matrix"

		.NOTES
			If you have the IMDB ID or TVDB ID of a series, it's better to use this to search.
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = 'Name')]
		[String]$Name,

		[Parameter(Mandatory = $false, ParameterSetName = 'Name')]
		[Switch]$ExactMatch,

		[Parameter(Mandatory = $true, ParameterSetName = 'IMDBID')]
		[ValidatePattern('^(tt)?\d{5,9}$')]
		[String]$IMDBID,

		[Parameter(Mandatory = $true, ParameterSetName = 'TMDBID')]
		[String]$TMDBID,

		[Parameter(Mandatory = $true, ParameterSetName = 'TVDBID')]
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
	if($ParameterSetName -eq 'IMDBID' -and $IMDBID -notmatch '^tt')
	{
		$IMDBID = 'tt' + $IMDBID
	}


	####################################################################################################
	#Region Define the path, parameters, headers and URI
	try
	{
		$Path = "/series/lookup"
		if($Name)
		{
			$Params = @{
				term = $Name
			}
		}
		elseif($IMDBID)
		{
			$Params = @{
				term = "imdb:$($IMDBID)"
			}
		}
		elseif($TMDBID)
		{
			$Params = @{
				term = "tmdb:$($TMDBID)"
			}
		}
		elseif($TVDBID)
		{
			$Params = @{
				term = "tvdb:$($TVDBID)"
			}
		}
		else
		{
			throw 'You must specify a name, TVDBID, or IMDBID.'
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
	#Region make the main request
	Write-Verbose "Querying: $Uri"
	try
	{
		$Data = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method Get -ContentType 'application/json' -ErrorAction Stop
		if($Data)
		{
			# If ExactMatch is specified, filter the results to only include the exact match
			if($ExactMatch)
			{
				$Data = $Data | Where-Object { $_.title -eq $Name }
			}

			return $Data
		}
		else
		{
			Write-Warning -Message "No series found."
			return
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion
}