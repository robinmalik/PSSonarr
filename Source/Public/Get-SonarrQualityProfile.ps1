function Get-SonarrQualityProfile
{
	<#
		.SYNOPSIS
			Retrieves quality profiles from Sonarr.

		.SYNTAX
			Get-SonarrQualityProfile [<CommonParameters>]

			Get-SonarrQualityProfile -Id <String> [<CommonParameters>]

			Get-SonarrQualityProfile -Name <String> [<CommonParameters>]

		.DESCRIPTION
			Retrieves quality profile information from Sonarr. Can return all quality profiles or filter by specific criteria
			such as ID or name.

		.PARAMETER Id
			The quality profile ID to retrieve.

		.PARAMETER Name
			The name of the quality profile to retrieve.

		.EXAMPLE
			Get-SonarrQualityProfile

		.EXAMPLE
			Get-SonarrQualityProfile -Id '1'

		.EXAMPLE
			Get-SonarrQualityProfile -Name 'HD-1080p'

		.NOTES
			When no parameters are specified, all quality profiles in Sonarr are returned.
	#>

	[CmdletBinding(DefaultParameterSetName = 'All')]
	param(
		[Parameter(Mandatory = $false, ParameterSetName = 'Id')]
		[String]$Id,

		[Parameter(Mandatory = $false, ParameterSetName = 'Name')]
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
	#Region Define the path, parameters, headers and URI
	try
	{
		$Path = '/qualityprofile'
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
			if($Name)
			{
				$Data = $Data | Where-Object { $_.name -eq $Name }
			}

			return $Data
		}
	}
	catch
	{
		throw $_
	}

}