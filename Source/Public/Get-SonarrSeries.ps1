function Get-SonarrSeries
{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $false, ParameterSetName = 'Id')]
		[String]$Id
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
		$Path = '/series'
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
	Write-Verbose "Querying $Uri"
	try
	{
		$Data = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method Get -ContentType 'application/json' -ErrorAction Stop
		if($Data)
		{
			return $Data
		}
		else
		{
			Write-Verbose -Message 'No result found.'
			return
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion
}