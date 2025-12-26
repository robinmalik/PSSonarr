function Set-SonarrSeriesStatus
{
	<#
		.SYNOPSIS
			Sets the monitoring status of a series in Sonarr.

		.SYNTAX
			Set-SonarrSeriesStatus -Id <Int32> -SeasonNumber <Int32> -Monitored <Boolean> [<CommonParameters>]

		.DESCRIPTION
			Updates the monitoring status of a series in Sonarr. When a series is monitored, Sonarr will automatically
			search for and download episodes. When unmonitored, episodes will not be automatically downloaded.

		.PARAMETER Id
			The Sonarr series ID to update.

		.PARAMETER Monitored
			Boolean value indicating whether the series should be monitored (True) or unmonitored (False).

		.EXAMPLE
			Set-SonarrSeriesStatus -Id 123 -Monitored $true

		.EXAMPLE
			Set-SonarrSeriesStatus -Id 456 -Monitored $false

		.NOTES
			This function modifies the overall series monitoring status, not individual seasons.
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $True)]
		[Int]$Id,

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
		$Series.monitored = [bool]$Monitored

		$Path = '/series/' + "$Id"
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
		Invoke-SonarrRequest -Path $Path -Method PUT -Body $Series -ErrorAction Stop
	}
	catch
	{
		throw $_
	}
	#EndRegion
}