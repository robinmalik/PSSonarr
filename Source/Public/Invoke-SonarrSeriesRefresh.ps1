function Invoke-SonarrSeriesRefresh
{
	<#
		.SYNOPSIS
			Refreshes a series in Sonarr.

		.DESCRIPTION
			Sends a RefreshSeries command to Sonarr for a specific series. The series can be identified by
			its Sonarr ID or by name. When using -Name, the function resolves the series through
			Get-SonarrSeries and uses the matching Sonarr ID.

		.PARAMETER Id
			The Sonarr series ID to refresh.

		.PARAMETER Name
			The name of the series to refresh. The function resolves the series using Get-SonarrSeries.

		.EXAMPLE
			Invoke-SonarrSeriesRefresh -Id 58

		.EXAMPLE
			Invoke-SonarrSeriesRefresh -Name 'The Expanse'
	#>

	[CmdletBinding(DefaultParameterSetName = 'Id')]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = 'Id')]
		[Int32]$Id,

		[Parameter(Mandatory = $true, ParameterSetName = 'Name')]
		[Alias('Title')]
		[String]$Name
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
	#Region Resolve series ID from name if required
	if($PSCmdlet.ParameterSetName -eq 'Name')
	{
		try
		{
			$Series = Get-SonarrSeries -Name $Name -ErrorAction Stop
			if(!$Series)
			{
				throw "Series with name '$Name' not found in Sonarr."
			}

			if($Series -is [System.Array])
			{
				$Series = @($Series | Where-Object { $_.title -eq $Name -or $_.originalTitle -eq $Name }) | Select-Object -First 1
				if(!$Series)
				{
					throw "Series with name '$Name' not found in Sonarr."
				}
			}
			elseif($Series.title -ne $Name -and $Series.originalTitle -ne $Name)
			{
				throw "Series with name '$Name' not found in Sonarr."
			}

			$Id = [Int32]$Series.id
		}
		catch
		{
			throw $_
		}
	}
	#EndRegion

	####################################################################################################
	#Region Build command body and send refresh request
	try
	{
		$CommandBody = @{
			name     = 'RefreshSeries'
			seriesId = $Id
		}

		$Result = Invoke-SonarrRequest -Path '/command' -Method POST -Body $CommandBody -ErrorAction Stop
		return $Result
	}
	catch
	{
		throw $_
	}
	#EndRegion
}
