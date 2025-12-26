function Remove-SonarrSeries
{
	<#
		.SYNOPSIS
			Removes a series from Sonarr.

		.SYNTAX
			Remove-SonarrSeries -Id <String> [-DeleteFiles] [-AddImportListExclusion] [-WhatIf] [-Confirm] [<CommonParameters>]

		.DESCRIPTION
			Removes a series from Sonarr using the series ID. This function supports WhatIf and Confirm parameters
			for safe execution. Optionally can delete associated files and add the series to import list exclusions.

		.PARAMETER Id
			The Sonarr series ID to remove. Accepts pipeline input by property name.

		.PARAMETER DeleteFiles
			If specified, deletes the actual video files associated with the series from disk.

		.PARAMETER AddImportListExclusion
			If specified, adds the series to import list exclusions to prevent it from being re-added automatically.

		.EXAMPLE
			Remove-SonarrSeries -Id '123'

		.EXAMPLE
			Remove-SonarrSeries -Id '123' -DeleteFiles

		.EXAMPLE
			Remove-SonarrSeries -Id '123' -DeleteFiles -AddImportListExclusion

		.EXAMPLE
			Get-SonarrSeries -Name 'Old Show' | Remove-SonarrSeries -DeleteFiles

		.EXAMPLE
			Remove-SonarrSeries -Id '123' -WhatIf

		.NOTES
			This function supports pipeline input and confirmation prompts for safe series removal.
			Use -DeleteFiles with caution as it will permanently delete video files from disk.
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory, ValueFromPipelineByPropertyName)]
		[String]$Id,

		[Parameter(Mandatory = $false)]
		[Switch]$DeleteFiles,

		[Parameter(Mandatory = $false)]
		[Switch]$AddImportListExclusion
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
		#Region Define the path and parameters
		try
		{
			$Path = '/series/' + $Id

			# Build query parameters based on switches
			$Params = @{
				deleteFiles            = $DeleteFiles.ToString().ToLower()
				addImportListExclusion = $AddImportListExclusion.ToString().ToLower()
			}
		}
		catch
		{
			throw $_
		}
		#EndRegion

		####################################################################################################
		#Region make the main request
		$ActionDescription = "Series with ID: $Id"
		if($DeleteFiles)
		{
			$ActionDescription += " (including files)"
		}
		if($AddImportListExclusion)
		{
			$ActionDescription += " (adding to import exclusions)"
		}

		if($PSCmdlet.ShouldProcess($ActionDescription, "Remove"))
		{
			Write-Verbose -Message "Removing series with ID $Id $(if($DeleteFiles){'and deleting files '})$(if($AddImportListExclusion){'and adding to import exclusions'})"
			try
			{
				Invoke-SonarrRequest -Path $Path -Method DELETE -Params $Params -ErrorAction Stop | Out-Null
			}
			catch
			{
				throw $_
			}
		}
		#EndRegion
	}
}