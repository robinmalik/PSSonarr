function Set-SonarrSeriesQualityProfile
{
	<#
		.SYNOPSIS
			Sets the quality profile for a series in Sonarr.

		.SYNTAX
			Set-SonarrSeriesQualityProfile -Id <Int32> -QualityProfileId <Int32> [<CommonParameters>]

		.DESCRIPTION
			Updates the quality profile for a series in Sonarr. This determines the quality standards
			that Sonarr will use when searching for and downloading episodes for this series.

		.PARAMETER Id
			The Sonarr series ID to update.

		.PARAMETER QualityProfileId
			The ID of the quality profile to assign to the series.

		.EXAMPLE
			Set-SonarrSeriesQualityProfile -Id 123 -QualityProfileId 2

		.EXAMPLE
			Get-SonarrSeries -Name "Falling Skies" | Set-SonarrSeriesQualityProfile -QualityProfileId 2

		.NOTES
			This function modifies the quality profile for the entire series.
			Use Get-SonarrQualityProfile to see available quality profiles.
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
		[Int]$Id,

		[Parameter(Mandatory = $true)]
		[ArgumentCompleter({
				param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
				Get-SonarrQualityProfile | Where-Object { $_.id -like "$wordToComplete*" } | ForEach-Object {
					[System.Management.Automation.CompletionResult]::new($_.id, $_.name, 'ParameterValue', "ID: $($_.id)")
				}
			})]
		[Int]$QualityProfileId
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
	#Region Modify quality profile and prepare request
	try
	{
		# Clean up smart punctuation if present
		if($Series.overview)
		{
			$Series.overview = Convert-SmartPunctuation -String $Series.overview
		}

		# Set the quality profile ID
		$Series.qualityProfileId = [int]$QualityProfileId

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
		$Result = Invoke-SonarrRequest -Path $Path -Method PUT -Body $Series -ErrorAction Stop
		return $Result
	}
	catch
	{
		throw $_
	}
	#EndRegion
}
