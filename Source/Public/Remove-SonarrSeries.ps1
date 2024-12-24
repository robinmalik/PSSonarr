function Remove-SonarrSeries
{
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