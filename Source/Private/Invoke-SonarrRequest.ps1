function Invoke-SonarrRequest
{
	<#
		.SYNOPSIS
			Centralized function for making HTTP requests to the Sonarr API.

		.DESCRIPTION
			This function consolidates all HTTP request logic for the Sonarr API, providing consistent
			error handling, URL encoding, header generation, and support for common parameters like -WhatIf.

		.PARAMETER Path
			The API endpoint path (e.g., '/series', '/qualityprofile'). Leading slash is optional.

		.PARAMETER Method
			The HTTP method to use (GET, POST, PUT, DELETE). Defaults to GET.

		.PARAMETER Params
			A hashtable of query string parameters to append to the URL. Values will be properly URL-encoded.

		.PARAMETER Body
			The request body for POST/PUT requests. Can be a hashtable, PSCustomObject, or JSON string.
			If not a string, it will be converted to JSON automatically.

		.PARAMETER SuppressWhatIf
			If specified, bypasses WhatIf support for read-only operations (GET requests).

		.EXAMPLE
			Invoke-SonarrRequest -Path '/series' -Method GET

		.EXAMPLE
			Invoke-SonarrRequest -Path '/series/lookup' -Params @{ term = 'imdb:tt0944947' }

		.EXAMPLE
			$Body = @{ qualityProfileId = 1; monitored = $true }
			Invoke-SonarrRequest -Path '/series' -Method POST -Body $Body

		.NOTES
			This function requires the configuration to be loaded via Import-Configuration before use.
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]$Path,

		[Parameter(Mandatory = $false)]
		[ValidateSet('GET', 'POST', 'PUT', 'DELETE')]
		[String]$Method = 'GET',

		[Parameter(Mandatory = $false)]
		[System.Collections.IDictionary]$Params,

		[Parameter(Mandatory = $false)]
		[Object]$Body,

		[Parameter(Mandatory = $false)]
		[Switch]$SuppressWhatIf
	)

	####################################################################################################
	# Strip leading slash from path if present
	if($Path.StartsWith('/'))
	{
		$Path = $Path.Substring(1)
	}

	####################################################################################################
	# Build query string with proper URL encoding
	[String]$QueryString = ''
	if($Params -and $Params.Count -gt 0)
	{
		$EncodedParams = @()
		foreach($Key in $Params.Keys)
		{
			$EncodedKey = [System.Web.HttpUtility]::UrlEncode($Key)
			$EncodedValue = [System.Web.HttpUtility]::UrlEncode($Params[$Key])
			$EncodedParams += "$EncodedKey=$EncodedValue"
		}
		$QueryString = '?' + ($EncodedParams -join '&')
	}

	####################################################################################################
	# Construct the full URI
	$Uri = "$($Config.Protocol)://$($Config.Server):$($Config.Port)/api/v$($Config.APIVersion)/$Path$QueryString"

	####################################################################################################
	# Build headers
	$Headers = @{
		'X-Api-Key' = $Config.APIKey
	}

	####################################################################################################
	# Prepare body if provided
	$RequestParams = @{
		Uri     = $Uri
		Headers = $Headers
		Method  = $Method
	}

	if($Body)
	{
		if($Body -is [String])
		{
			$BodyBytes = [System.Text.Encoding]::UTF8.GetBytes($Body)
		}
		else
		{
			$BodyJson = $Body | ConvertTo-Json -Depth 10 -Compress
			$BodyBytes = [System.Text.Encoding]::UTF8.GetBytes($BodyJson)
		}

		$RequestParams['Body'] = $BodyBytes
		$RequestParams['ContentType'] = 'application/json'
	}

	####################################################################################################
	# Handle WhatIf for state-changing operations
	$IsReadOnly = ($Method -eq 'GET')

	if(-not $IsReadOnly -or -not $SuppressWhatIf)
	{
		$OperationDescription = "$Method $Uri"
		if($Body)
		{
			$OperationDescription += " (with body)"
		}

		if($PSCmdlet.ShouldProcess($OperationDescription, "Invoke Sonarr API"))
		{
			# Proceed with the request
		}
		else
		{
			# WhatIf or Confirm prevented execution
			return
		}
	}

	####################################################################################################
	# Make the request with consistent error handling
	try
	{
		Write-Verbose -Message "[$Method] $Uri"
		if($Body)
		{
			Write-Debug -Message "Request Body: $($Body | ConvertTo-Json -Depth 10 -Compress)"
		}
		$Response = Invoke-RestMethod @RequestParams -ErrorAction Stop
		return $Response
	}
	catch [Microsoft.PowerShell.Commands.HttpResponseException]
	{
		# PowerShell 7+ exception handling
		$ErrorMessage = $_.Exception.Message
		$StatusCode = $_.Exception.StatusCode

		# Try to read the response body
		try
		{
			if($_.ErrorDetails -and $_.ErrorDetails.Message)
			{
				$ErrorBody = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction Stop

				if($ErrorBody.message)
				{
					$ErrorMessage = $ErrorBody.message
				}

				if($ErrorBody.errors)
				{
					$ValidationErrors = @()
					foreach($err in $ErrorBody.errors)
					{
						if($err.errorMessage) { $ValidationErrors += $err.errorMessage }
						elseif($err.message) { $ValidationErrors += $err.message }
						else { $ValidationErrors += ($err | ConvertTo-Json -Compress) }
					}
					if($ValidationErrors)
					{
						$ErrorMessage += " | Validation errors: " + ($ValidationErrors -join '; ')
					}
				}
			}
		}
		catch
		{
			# Couldn't parse error body
			if($_.ErrorDetails.Message)
			{
				$ErrorMessage += " | Response: $($_.ErrorDetails.Message)"
			}
		}

		$PSCmdlet.ThrowTerminatingError(
			[System.Management.Automation.ErrorRecord]::new(
				[Exception]::new("Sonarr API request failed ($StatusCode): $ErrorMessage"),
				'SonarrAPIError',
				[System.Management.Automation.ErrorCategory]::InvalidOperation,
				$Uri
			)
		)
	}
	catch
	{
		# Fallback for other exception types or PowerShell 5.1
		$ErrorMessage = $_.Exception.Message

		# Try to extract detailed error from Sonarr API response
		if($_.ErrorDetails.Message)
		{
			try
			{
				$ErrorDetails = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction Stop

				# Sonarr often returns errors in different formats, try to extract them all
				if($ErrorDetails.message)
				{
					$ErrorMessage = $ErrorDetails.message
				}

				# Check for validation errors array
				if($ErrorDetails.errors)
				{
					$ValidationErrors = $ErrorDetails.errors | ForEach-Object {
						if($_.errorMessage) { $_.errorMessage }
						elseif($_.message) { $_.message }
						else { $_ }
					}
					if($ValidationErrors)
					{
						$ErrorMessage += " | Validation errors: " + ($ValidationErrors -join '; ')
					}
				}

				# Some endpoints return an array of error strings
				if($ErrorDetails -is [Array])
				{
					$ErrorMessage += " | Errors: " + ($ErrorDetails -join '; ')
				}
			}
			catch
			{
				# If we can't parse as JSON, use the raw message
				$ErrorMessage += " | Response: $($_.ErrorDetails.Message)"
			}
		}

		throw "Sonarr API request failed: $ErrorMessage"
	}
}
