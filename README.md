# About

A PowerShell module to help with automation around the Sonarr application. Similar to [PSRadarr](https://github.com/robinmalik/PSRadarr).

Note: There is a more comprehensive C# based PowerShell module available at: [https://github.com/Yevrag35/PoshSonarr](https://github.com/Yevrag35/PoshSonarr) that you may wish to check out, before using this native PowerShell module.

See the [Changelog](CHANGELOG.md) for a list of changes.

---

# Getting Started:

1. Install the module from the PowerShell Gallery: `Install-Module -Name PSSonarr`.
2. Save your Sonarr configuration. To use the default protocol of `http` and port of `8989` run:
   ```powershell
   Set-SonarrConfiguration -Server 'myserver.domain.com' -APIKey 'myapikey' -RootFolderPath 'D:\Movies'
   ```
   To use a different protocol or port, run:
   ```powershell
   Set-SonarrConfiguration -Server 'myserver.domain.com' -APIKey 'myapikey' -Protocol 'https' -Port 443
   ```
3. Try a command from the 'Examples' below.

# Examples:

**Get all series**:
```powershell
Get-SonarrSeries
```

**Search for a series by name, add it to Sonarr by IMDB ID, monitor all episodes but do not start a search**:
```powershell
$Search = Find-SonarrSeries -Name 'The Simpsons' -ExactMatch
Add-SonarrSeries -IMDBID $Search.imdbId -MonitorOption 'all'
```


**Search for a series by name, add it to Sonarr by IMDB ID, monitor the latest season and initiate a search**:
```powershell
$Search = Find-SonarrSeries -Name 'The Simpsons' -ExactMatch
Add-SonarrSeries -IMDBID $Search.imdbId -MonitorOption 'latest' -Search
```

**Switching between Sonarr servers**:
This assumes you have saved multiple servers using `Set-SonarrConfiguration`. The `-Server` parameter supports tab completion.
```powershell
Set-SonarrDefaultServer -Server 'myserver.domain.com'
```