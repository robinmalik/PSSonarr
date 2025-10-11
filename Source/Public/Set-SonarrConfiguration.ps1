function Set-SonarrConfiguration
{
	<#
		.SYNOPSIS
			Sets the configuration for connecting to a Sonarr server instance.

		.SYNTAX
			Set-SonarrConfiguration -Server <String> -APIKey <String> -RootFolderPath <String> [-Port <Int32>] [-Protocol <String>] [-APIVersion <Int32>] [-Default <Boolean>] [<CommonParameters>]

		.DESCRIPTION
			Saves Sonarr server connection settings including server address, port, API key, and API version to a JSON configuration file.
			The configuration is stored in the user's home directory under .PSSonarr/PSSonarrConfig.json.

		.PARAMETER Server
			The URL or hostname of the Sonarr server (e.g. 'myserver.domain.com')

		.PARAMETER Port
			The port number that Sonarr is listening on. Defaults to 8989.

		.PARAMETER Protocol
			The protocol to use for connecting to the Sonarr server. Defaults to 'http'.

		.PARAMETER APIKey
			The API key from your Sonarr instance. Can be found in Sonarr under Settings > General.

		.PARAMETER APIVersion
			The version of the Sonarr API to use. Defaults to 3.

		.PARAMETER RootFolderPath
			The root folder path where movies are stored.

		.PARAMETER Default
			If set to true, marks this server configuration as the default instance for PSSonarr commands. Defaults to true.

		.EXAMPLE
			Set-SonarrConfiguration -Server 'myserver.domain.com' -APIKey 'myapikey' -RootFolderPath 'D:\Movies'

		.NOTES
			File: Set-SonarrConfiguration.ps1
			The configuration file will be created at $HOME/.PSSonarr/PSSonarrConfig.json
	#>

	param (
		[Parameter(Mandatory = $true)]
		[ValidatePattern('^[a-zA-Z0-9.-]+$')]
		[string]$Server,

		[Parameter(Mandatory = $false)]
		[int]$Port = 8989,

		[Parameter(Mandatory = $false)]
		[ValidateSet("http", "https")]
		[string]$Protocol = "http",

		[Parameter(Mandatory = $true)]
		[string]$APIKey,

		[Parameter(Mandatory = $false)]
		[Int]$APIVersion = "3",

		[Parameter(Mandatory = $true)]
		[string]$RootFolderPath,

		[Parameter(Mandatory = $false)]
		[bool]$Default = $true
	)

	#############################################################################
	#Region Ensure required paths exist and load existing configuration
	$ConfigDir = Join-Path $HOME ".PSSonarr"
	if(-not (Test-Path -Path $ConfigDir -PathType Container))
	{
		try
		{
			New-Item -Path $ConfigDir -ItemType Directory -ErrorAction Stop | Out-Null
		}
		catch
		{
			throw $_
		}
	}

	# Path to the configuration file
	$ConfigPath = Join-Path $ConfigDir "PSSonarrConfig.json"

	# If the file exists, load existing data
	if(Test-Path -Path $ConfigPath -PathType Leaf)
	{
		[Array]$ConfigData = Get-Content -Path $ConfigPath | ConvertFrom-Json
	}
	else
	{
		$ConfigData = @()
	}
	#EndRegion

	#############################################################################
	# If the user has passed default as $False, but there is no existing default server (excluding itself) with
	# default set to $true, then we'll force this server to be the default.
	if($Default -eq $false -and ($ConfigData | Where-Object { $_.Default -eq $true -and $_.Server -ne $Server }).Count -eq 0)
	{
		Write-Warning -Message "No default server found. Forcing this server to be the default."
		$Default = $true
	}

	####################################################################################################
	# Set all servers to Default = $false:
	$ConfigData | ForEach-Object ( { $_.Default = $false } )

	$Found = $false
	foreach($Entry in $ConfigData)
	{
		# If the server and port already exist in the configuration, update the rest of the data
		# that could have changed:
		if($Entry.Server -eq $Server -and $Entry.Port -eq $Port)
		{
			$Entry.Protocol = $Protocol
			$Entry.APIKey = $APIKey
			$Entry.APIVersion = $APIVersion
			$Entry.RootFolderPath = $RootFolderPath
			$Entry.Default = $Default
			$Found = $true
		}
	}

	# If we didn't find the server in the configuration, this would be a new entry:
	if($Found -eq $false)
	{
		#Construct an object with the data we want to save
		$ServerObject = [Ordered]@{
			"Server"         = $Server
			"Port"           = $Port
			"Protocol"       = $Protocol
			"APIKey"         = $APIKey
			"APIVersion"     = $APIVersion
			"RootFolderPath" = $RootFolderPath
			"Default"        = $Default
		}
		$ConfigData += $ServerObject
	}

	####################################################################################################
	#Region Convert to JSON and save to file
	Write-Verbose -Message "Saving configuration to: $ConfigPath"
	try
	{
		# We want to make sure that $ConfigData is always an array before we export it, to ensure we can add
		# additional servers. Don't pipe $ConfigData directly to ConvertTo-Json, otherwise the first time around
		# it'll create an object instead of an array.
		ConvertTo-Json -InputObject $ConfigData -ErrorAction Stop | Set-Content -Path $ConfigPath -Force -ErrorAction Stop
	}
	catch
	{
		throw $_
	}
	Write-Verbose -Message "Configuration saved successfully to: $ConfigPath"
}

