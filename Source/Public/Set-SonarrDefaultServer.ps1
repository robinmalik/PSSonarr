function Set-SonarrDefaultServer
{
	<#
		.SYNOPSIS
			Sets the default Sonarr server to use for subsequent commands.

		.DESCRIPTION
			This function modifies the configuration file to set the specified Sonarr server as the default. The server must already exist in the configuration.

		.PARAMETER Server
			The name of the server to set as default.
	#>

	param (
		[Parameter(Mandatory = $true)]
		[ValidatePattern('^[a-zA-Z0-9.-]+$')]
		[ArgumentCompleter({
				param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
				# Read in the existing configuration file
				$ConfigDir = Join-Path $HOME ".PSSonarr"
				$ConfigPath = Join-Path $ConfigDir "PSSonarrConfig.json"
				if (Test-Path -Path $ConfigPath -PathType Leaf)
				{
					$ConfigData = Get-Content -Path $ConfigPath | ConvertFrom-Json
					# Return the Server names for tab completion
					return $ConfigData | ForEach-Object { $_.Server }
				}
			})]
		[string]$Server
	)

	# Path to the configuration file
	$ConfigDir = Join-Path $HOME ".PSSonarr"
	if(-not (Test-Path -Path $ConfigDir -PathType Container))
	{
		throw "Configuration directory does not exist. Please run Set-SonarrConfiguration first."
	}

	$ConfigPath = Join-Path $ConfigDir "PSSonarrConfig.json"

	# If the file exists, load existing data
	if(Test-Path -Path $ConfigPath -PathType Leaf)
	{
		[Array]$ConfigData = Get-Content -Path $ConfigPath | ConvertFrom-Json
	}
	else
	{
		throw "Configuration file does not exist. Please run Set-SonarrConfiguration first."
	}

	# Find the server in the configuration data
	$ServerConfig = $ConfigData | Where-Object { $_.Server -eq $Server }
	if (-not $ServerConfig)
	{
		throw "Server '$Server' not found in configuration. Please run Set-SonarrConfiguration to add it first."
	}

	# Set the Default property for all servers to false
	$ConfigData | ForEach-Object { $_.Default = $false }

	# Set the Default property for the specified server to true
	$ServerConfig.Default = $true

	# Save the updated configuration back to the file
	ConvertTo-Json -InputObject $ConfigData -ErrorAction Stop | Set-Content -Path $ConfigPath -Force -ErrorAction Stop

}