## [1.0.0] - 2026-07-28

- 💥 [Breaking] `Set-SonarrConfiguration`, `Set-SonarrDefaultServer` and `Get-SonarrDefaultServer` have been removed in favour of the context functions. Existing `PSSonarrConfig.json` files are migrated to named contexts automatically on first use; the old file is left in place for you to delete.
- ✨ [New] `Save-SonarrContext`, `Get-SonarrContext`, `Select-SonarrContext`, `Remove-SonarrContext` - Named contexts replace the single configuration file. A context is identified by a name of your choosing rather than by its server name, so multiple Sonarr instances on the same host (differing only by port) can now be saved and switched between.
- ✨ [New] `Get-SonarrQualityDefinition` - Get the quality definitions configured in Sonarr.
- ✨ [New] `New-SonarrQualityProfile` / `Remove-SonarrQualityProfile` - Create and remove quality profiles.
- 🐛 [Fix] `Convert-SmartPunctuation` - Re-saved with a UTF-8 BOM. The file's own help noted that a BOM was required, but it was saved without one, so Windows PowerShell 5.1 read it as ANSI and corrupted the literal smart characters in its `-replace` patterns - meaning it silently normalised nothing on the minimum supported edition.
- 💥 [Breaking] `Start-SonarrSeasonSearch` renamed to `Invoke-SonarrSeriesSearch`, and `-SeasonNumber` is now optional. Omitting it searches the entire series (Sonarr's `SeriesSearch` command) rather than a single season; supplying it searches that season only, as before (`SeasonSearch`). `-SeriesId` gained an `Id` alias and pipeline input by property name, so `Get-SonarrSeries | Invoke-SonarrSeriesSearch` works. The command also now supports `-WhatIf`/`-Confirm`. The old command name is gone; update any scripts that used it. Calls are otherwise unchanged: passing both `-SeriesId` and `-SeasonNumber` behaves as before.
- 🐛 [Fix] `Get-SonarrSeries` - Now passes `-SuppressWhatIf` on its GET. Without it, running any `ShouldProcess`-capable caller under `-WhatIf` suppressed the lookup, so the caller reported the series as missing instead of previewing the action.

## [0.0.10] - 2026-07-26

- ✨ [New] `Get-SonarrUpcomingEpisodes` - Get episodes airing within a date range via the calendar endpoint. Defaults to the next 7 days.
`Set-SonarrDefaultServer` - Set the default Sonarr server to use.
- ✨ [New] `Invoke-SonarrSeriesRefresh` - Refresh a series in Sonarr.

## [0.0.9] - 2026-07-26

- 🔨 [Changed] `Add-SonarrSeries` - Removed multiple if/else clauses using splatting.
- 🔨 [Changed] `Invoke-SonarrRequest` - Removed overly complex error handling/debugging and replaced with a standard throw $_.
- ✨ [New] `Get-SonarrSeriesEpisode` - Get all episodes for a specific series.

## [0.0.8] - 2026-01-02

- 🐛 [Fix] `Find-SonarrSeries` - Fixed issue whereby TMDB was returning multiple results when searching by ID (e.g. when passing a valid TMDB ID, a series with the same ID value for TVDB id was also returned).

## [0.0.7] - 2025-12-27

- 🐛 [Fix] `Start-SonarrSeasonSearch` was missing an `if` clause. Removed if/else to just return the search result object.

## [0.0.6] - 2025-12-26

- 🔨 [Changed] All cmdlets now use `Invoke-SonarrRequest` instead of manual `Invoke-RestMethod`
- ✨ [New] `Set-SonarrSeriesQualityProfile` - Set the quality profile for a series.
- ✨ [New] Added simple functions for `Get-SonarrHealth`, `Get-SonarrIndexer`, `Get-SonarrQueue`, `Get-SonarrRootFolder` and `Get-SonarrSystem`.
- 🐛 [Fix] `Add-SonarrSeries` - Warn when series exists with corrective suggestive function calls.

## [0.0.5] - 2025-10-11

- 🔨 [Changed] BREAKING CHANGE: Renamed `Search-SonarrSeries` to `Find-SonarrSeries` to aid clarity between finding a series to add to Sonarr vs searching for existing series episodes.
- ✨ [New] `Start-SonarrSeasonSearch` - Search for episodes within a specific season of a series.
- ✨ [New] `Remove-SonarrSeries` - Supports deleting files and adding import list exclusions.
- 🐛 [Fix] `Set-SonarrSeriesStatus` - Remove unrequired parameter.

## [0.0.4] - 2025-10-11

- ✨ [New] `Set-SonarrSeriesStatus` - Set a series to monitored or unmonitored.

## [0.0.3] - 2025-10-11

- ✨ [New] `Set-SonarrSeasonStatus` - Set a season to monitored or unmonitored.
- 📚 [Added] Added Syntax blocks to all functions (via Claude Sonnet 4).

## [0.0.2] - 2024-12-25

- 🐛 [Fix] Expose `Set-SonarrConfiguration` function.

## [0.0.1] - 2024-12-24

- 🎉 A very quick, initial release!
