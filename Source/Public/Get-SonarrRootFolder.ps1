function Get-SonarrRootFolder
{
	<#
    .SYNOPSIS
        Gets root folder configuration from Sonarr.

    .DESCRIPTION
        Returns configured root folders in Sonarr, including available disk space and folder paths. Can filter by root folder ID.

    .PARAMETER Id
        The ID of a specific root folder to retrieve.

    .EXAMPLE
        Get-SonarrRootFolder

        Returns all configured root folders from the default Sonarr server.

    .EXAMPLE
        Get-SonarrRootFolder -Id 1

        Returns the root folder with ID 1.

    .EXAMPLE
        Get-SonarrRootFolder | Select-Object path, @{n='FreeSpaceGB';e={[math]::Round($_.freeSpace/1GB,2)}}

        Returns all root folders with their paths and free space in GB.

    .NOTES
        Requires Sonarr v3+ API.
    #>
	[CmdletBinding(DefaultParameterSetName = 'All')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Id', ValueFromPipelineByPropertyName = $true)]
		[int]$Id
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
		$Path = '/rootfolder'

		if($PSCmdlet.ParameterSetName -eq 'Id')
		{
			$Path += "/$Id"
		}

		$Data = Invoke-SonarrRequest -Path $Path -Method GET -ErrorAction Stop
		return $Data
	}
	catch
	{
		throw $_
	}
	#EndRegion
}
