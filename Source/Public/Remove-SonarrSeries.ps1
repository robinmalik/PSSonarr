function Remove-SonarrSeries
{
	<#
		.SYNOPSIS
			Removes a series from Sonarr.

		.SYNTAX
			Remove-SonarrSeries -Id <String> [-WhatIf] [-Confirm] [<CommonParameters>]

		.DESCRIPTION
			Removes a series from Sonarr using the series ID. This function supports WhatIf and Confirm parameters
			for safe execution.

		.PARAMETER Id
			The Sonarr series ID to remove. Accepts pipeline input by property name.

		.EXAMPLE
			Remove-SonarrSeries -Id '123'

		.EXAMPLE
			Get-SonarrSeries -Name 'Old Show' | Remove-SonarrSeries

		.EXAMPLE
			Remove-SonarrSeries -Id '123' -WhatIf

		.NOTES
			This function supports pipeline input and confirmation prompts for safe series removal.
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory, ValueFromPipelineByPropertyName)]
		[String]$Id
	)

	begin
	{
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
	}
	process
	{
		####################################################################################################
		#Region Define the path, parameters, headers and URI
		try
		{
			$Path = '/series/' + $Id
			$Uri = Get-APIUri -RestEndpoint $Path
			$Headers = Get-Headers
		}
		catch
		{
			throw $_
		}
		#EndRegion

		####################################################################################################
		#Region make the main request
		if($PSCmdlet.ShouldProcess("Series with ID: $Id", "Remove"))
		{
			Write-Verbose -Message "Removing series with ID $Id"
			try
			{
				Invoke-RestMethod -Uri $Uri -Headers $Headers -Method Delete -ContentType 'application/json' -ErrorAction Stop
			}
			catch
			{
				Write-Error "Failed to remove series with ID $Id. Error: $($_.Exception.Message)"
			}
		}
		#EndRegion
	}
}