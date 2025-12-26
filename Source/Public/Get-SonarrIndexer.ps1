function Get-SonarrIndexer
{
	<#
    .SYNOPSIS
        Gets indexer configuration from Sonarr.

    .DESCRIPTION
        Returns configured indexers in Sonarr. Can filter by indexer ID or name.

    .PARAMETER Id
        The ID of a specific indexer to retrieve.

    .PARAMETER Name
        The name of a specific indexer to retrieve. Supports wildcards.

    .EXAMPLE
        Get-SonarrIndexer

        Returns all configured indexers from the default Sonarr server.

    .EXAMPLE
        Get-SonarrIndexer -Id 1

        Returns the indexer with ID 1.

    .EXAMPLE
        Get-SonarrIndexer -Name "NZBgeek"

        Returns the indexer named "NZBgeek".

    .EXAMPLE
        Get-SonarrIndexer -Name "*Usenet*"

        Returns all indexers with "Usenet" in their name.

    .NOTES
        Requires Sonarr v3+ API.
    #>
	[CmdletBinding(DefaultParameterSetName = 'All')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Id', ValueFromPipelineByPropertyName = $true)]
		[int]$Id,

		[Parameter(Mandatory = $true, ParameterSetName = 'Name')]
		[string]$Name
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
	#Region make the main request
	try
	{
		$Path = '/indexer'

		if($PSCmdlet.ParameterSetName -eq 'Id')
		{
			$Path += "/$Id"
		}

		$Data = Invoke-SonarrRequest -Path $Path -Method GET -ErrorAction Stop

		if($PSCmdlet.ParameterSetName -eq 'Name')
		{
			$Data = $Data | Where-Object { $_.name -like $Name }
		}

		return $Data
	}
	catch
	{
		throw $_
	}
	#EndRegion
}
