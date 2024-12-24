function Get-SonarrSeries
{
	[CmdletBinding()]
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
	if($ParameterSetName -eq 'IMDBID' -and $IMDBID -notmatch '^tt')
	{
		$IMDBID = 'tt' + $IMDBID
	}


	####################################################################################################
	#Region Define the path, parameters, headers and URI
	try
	{
		$Path = '/series'
		if($PSCmdlet.ParameterSetName -eq 'Id' -and $Id)
		{
			$Path += "/$Id"
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