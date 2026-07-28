# About

A PowerShell module to help with automation around the Sonarr application. Similar to [PSRadarr](https://github.com/robinmalik/PSRadarr), which does the same for Radarr.

Note: There is a more comprehensive C# based PowerShell module available at: [https://github.com/Yevrag35/PoshSonarr](https://github.com/Yevrag35/PoshSonarr) that you may wish to check out, before using this native PowerShell module.

See the [Changelog](CHANGELOG.md) for a list of changes.

<br>

# Getting Started:

1. Install the module from the PowerShell Gallery:
    ```powershell
    Install-PSResource -Name PSSonarr
    ```
2. Save a context. A context is a named set of connection settings for one Sonarr instance. To use the default protocol of `http` and port of `8989` run:
   ```powershell
   Save-SonarrContext -Name 'sonarr' -Server 'myserver.domain.com' -APIKey 'myapikey' -RootFolderPath '/storage/TV'
   ```
   To use a different protocol or port, run:
   ```powershell
   Save-SonarrContext -Name 'sonarr' -Server 'myserver.domain.com' -APIKey 'myapikey' -RootFolderPath '/storage/TV' -Protocol 'https' -Port 443
   ```
   The first context you save becomes the active one, and all commands use the active context. See [Context System](#context-system) below for switching between multiple instances.
3. Try a command from the 'Examples by Action' below.

> If you used `Set-SonarrConfiguration` in an earlier version, your servers are migrated to named contexts automatically the first time you run a command. Run `Get-SonarrContext` to check them, then delete `$HOME/.PSSonarr/PSSonarrConfig.json`.

<br>

# Context System:

Every command talks to whichever context is currently active. A context is identified by a name of your choosing rather than by its server, so several Sonarr instances on the same host (differing only by port) can be saved alongside each other.

**Save a context per instance:**
```powershell
Save-SonarrContext -Name 'tv'   -Server 'myserver.domain.com' -Port 8989 -APIKey 'abc123' -RootFolderPath '/storage/TV'
Save-SonarrContext -Name 'tv4k' -Server 'myserver.domain.com' -Port 8990 -APIKey 'xyz789' -RootFolderPath '/storage/TV4K'
```

**List contexts** (`*` marks the active one):
```powershell
Get-SonarrContext
```

**Switch context** (tab-completion is supported for `-Name`):
```powershell
Select-SonarrContext -Name tv4k
```

**Switch for the current session only**, leaving the persisted default untouched:
```powershell
Select-SonarrContext -Name tv4k -Persist $false
```

**Save a context in memory only**, writing nothing to disk (useful in CI):
```powershell
Save-SonarrContext -Name 'ci' -Server 'sonarr' -APIKey $env:SONARR_API_KEY -RootFolderPath '/storage/TV' -Persist $false
```

**Remove a context**:
```powershell
Remove-SonarrContext -Name tv4k
```

Contexts are stored as JSON in `$HOME/.PSSonarr/Contexts`. The API key is stored in plain text so that contexts remain portable between machines and containers — anyone able to read that directory can read the key.

<br>

# Examples by Action:

## Series Management

**Get all series:**
```powershell
Get-SonarrSeries
```

**Get a series by IMDB, TMDB or TVDB ID:**
```powershell
Get-SonarrSeries -IMDBID 'tt0944947'
Get-SonarrSeries -TVDBID '121361'
```

**Search TMDb (via Sonarr) for a series that isn't in the library yet:**
```powershell
Find-SonarrSeries -Name 'The Simpsons'
```

**Add a series by IMDB ID, monitor all episodes but do not start a search:**
```powershell
$Search = Find-SonarrSeries -Name 'The Simpsons' -ExactMatch
Add-SonarrSeries -IMDBID $Search.imdbId -QualityProfileId 1 -MonitorOption 'all'
```

**Add a series by TVDB ID, monitor only future episodes, and initiate a search:**
```powershell
Add-SonarrSeries -TVDBID '121361' -QualityProfileId 1 -MonitorOption 'future' -Search
```

**Set the monitor status for an existing series:**
```powershell
$Series = Get-SonarrSeries -Name 'The Expanse'
Set-SonarrSeriesStatus -Id $Series.id -Monitored $true
```

**Set the monitor status for a single season:**
```powershell
$Series = Get-SonarrSeries -Name 'The Expanse'
Set-SonarrSeasonStatus -Id $Series.id -SeasonNumber 1 -Monitored $false
```

**Change the quality profile for an existing series:**
```powershell
Get-SonarrSeries -Name 'Falling Skies' | Set-SonarrSeriesQualityProfile -QualityProfileId 2
```

**Search for missing episodes across a whole series:**
```powershell
Invoke-SonarrSeriesSearch -SeriesId 123
```

**Search for missing episodes in a specific season only:**
```powershell
Invoke-SonarrSeriesSearch -SeriesId 123 -SeasonNumber 1
```

**Search every monitored series:**
```powershell
Get-SonarrSeries | Where-Object { $_.monitored } | Invoke-SonarrSeriesSearch
```

**Refresh a series' metadata and rescan its folder on disk:**
```powershell
Invoke-SonarrSeriesRefresh -Name 'The Expanse'
```

**Remove a series, deleting its files and excluding it from future imports:**
```powershell
Remove-SonarrSeries -Id 123 -DeleteFiles -AddImportListExclusion
```

**Get episodes airing in the next 7 days:**
```powershell
Get-SonarrUpcomingEpisodes
```

**Get episodes airing in a wider window:**
```powershell
Get-SonarrUpcomingEpisodes -EndDate (Get-Date).AddDays(30) |
    Select-Object airDate, seriesTitle, seasonNumber, episodeNumber, title | Sort-Object airDate
```

## Episode Management

**Get all episodes for a series:**
```powershell
Get-SonarrSeriesEpisode -SeriesId 123
```

## Quality Profile Management

**Get all quality profiles, or a specific one by name:**
```powershell
Get-SonarrQualityProfile
Get-SonarrQualityProfile -Name 'HD-1080p'
```

**See the quality names available to build a profile from:**
```powershell
Get-SonarrQualityDefinition | Sort-Object weight | Select-Object quality, weight
```

**Create a new quality profile:**
```powershell
New-SonarrQualityProfile -Name 'WEBDL-HD' -AllowedQualities 'WEBDL-720p', 'WEBDL-1080p' -Cutoff 'WEBDL-1080p' -UpgradeAllowed
```

**Remove a quality profile:**
```powershell
Get-SonarrQualityProfile -Name 'SD Only' | Remove-SonarrQualityProfile
```

## Queue Management

**See what is downloading:**
```powershell
(Get-SonarrQueue).records | Select-Object title, status, timeleft
```

**Include downloads that don't match any known series:**
```powershell
(Get-SonarrQueue -IncludeUnknownSeriesItems).records
```

## Root Folder Management

**List root folders and their free space:**
```powershell
Get-SonarrRootFolder | Select-Object path, @{n='FreeSpaceGB';e={[math]::Round($_.freeSpace/1GB,2)}}
```

## Indexer Management

**List configured indexers:**
```powershell
Get-SonarrIndexer
```

**Find indexers excluded from automatic search:**
```powershell
Get-SonarrIndexer | Where-Object { -not $_.enableAutomaticSearch }
```

## System Management

**Check the instance is reachable, and look for problems:**
```powershell
(Get-SonarrSystem).version
Get-SonarrHealth
```

<br>

# Notes:

* `-MonitorOption` on `Add-SonarrSeries` accepts: `all`, `firstSeason`, `lastSeason`, `future`, `missing`, `existing`, `recent`, `pilot`, `monitorSpecials`, `unmonitorSpecials`, `none`.
