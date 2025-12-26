function Get-SonarrQueue {
    <#
    .SYNOPSIS
        Gets the download queue from Sonarr.

    .DESCRIPTION
        Returns items currently in the download queue, including active downloads
        and queued items. Supports pagination and filtering.

    .PARAMETER Page
        The page number to retrieve (for pagination). Defaults to 1.

    .PARAMETER PageSize
        The number of items per page. Defaults to 20.

    .PARAMETER IncludeUnknownSeriesItems
        Include downloads that don't match any known series.

    .PARAMETER Server
        The Sonarr server to query. If not specified, uses the default configured server.

    .EXAMPLE
        Get-SonarrQueue

        Returns the first 20 items in the download queue.

    .EXAMPLE
        Get-SonarrQueue -PageSize 50

        Returns the first 50 items in the download queue.

    .EXAMPLE
        Get-SonarrQueue -Page 2 -PageSize 10

        Returns items 11-20 from the download queue.

    .EXAMPLE
        Get-SonarrQueue -IncludeUnknownSeriesItems

        Returns queue items including downloads that don't match any known series.

    .NOTES
        Requires Sonarr v3+ API.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [int]$Page = 1,

        [Parameter(Mandatory = $false)]
        [int]$PageSize = 20,

        [Parameter(Mandatory = $false)]
        [switch]$IncludeUnknownSeriesItems,

        [Parameter(Mandatory = $false)]
        [string]$Server
    )

	####################################################################################################
	#Region Import configuration
	try
	{
		if($Server)
		{
			Import-Configuration -Server $Server -ErrorAction Stop
		}
		else
		{
			Import-Configuration -ErrorAction Stop
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion


	####################################################################################################
	#Region Define the parameters
	try
	{
		$Params = @{
			page = $Page
			pageSize = $PageSize
		}

		if($IncludeUnknownSeriesItems)
		{
			$Params['includeUnknownSeriesItems'] = 'true'
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
		$Data = Invoke-SonarrRequest -Path '/queue' -Method GET -Params $Params -ErrorAction Stop
		return $Data
	}
	catch
	{
		throw $_
	}
	#EndRegion
}
