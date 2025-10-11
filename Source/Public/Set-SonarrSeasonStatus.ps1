function Set-SonarrSeasonStatus
{
	<#
		.SYNOPSIS
			Sets the monitoring status of a specific season in Sonarr.

		.SYNTAX
			Set-SonarrSeasonStatus -Id <Int32> -SeasonNumber <Int32> -Monitored <Boolean> [<CommonParameters>]

		.DESCRIPTION
			Updates the monitoring status of a specific season for a series in Sonarr. When a season is monitored,
			Sonarr will automatically search for and download episodes from that season. When unmonitored,
			episodes from that season will not be automatically downloaded.

		.PARAMETER Id
			The Sonarr series ID containing the season to update.

		.PARAMETER SeasonNumber
			The season number to update (e.g., 1 for Season 1, 0 for Specials).

		.PARAMETER Monitored
			Boolean value indicating whether the season should be monitored (True) or unmonitored (False).

		.EXAMPLE
			Set-SonarrSeasonStatus -Id 123 -SeasonNumber 1 -Monitored $true

		.EXAMPLE
			Set-SonarrSeasonStatus -Id 456 -SeasonNumber 3 -Monitored $false

		.NOTES
			This function specifically modifies individual season monitoring status within a series.
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $True)]
		[Int]$Id,

		[Parameter(Mandatory = $True)]
		[Int]$SeasonNumber,

		[Parameter(Mandatory = $True)]
		[Boolean]$Monitored
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
	#Region Get the series
	try
	{
		$Series = Get-SonarrSeries -Id $Id -ErrorAction Stop
		if(!$Series)
		{
			throw "Series with ID $Id not found."
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
		if($Series.overview)
		{
			$Series.overview = Convert-SmartPunctuation -String $Series.overview
		}

		# Set the monitored status
		($Series.seasons | Where-Object { $_.seasonNumber -eq $SeasonNumber }).monitored = [bool]$Monitored

		# Encode the body
		$BodyJSON = ($Series | ConvertTo-Json -Depth 5)
		$BodyEncoded = ([System.Text.Encoding]::UTF8.GetBytes($BodyJSON))

		$Path = '/series/' + "$Id"

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
	Write-Verbose "Querying $Uri"
	try
	{
		Invoke-RestMethod -Uri $Uri -Headers $Headers -Method Put -ContentType 'application/json' -Body $BodyEncoded -ErrorAction Stop
	}
	catch
	{
		throw $_
	}
	#EndRegion
}