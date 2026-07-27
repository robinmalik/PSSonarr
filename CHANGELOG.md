## [0.0.10] - 2026-07-26

- ✨ [New] `Get-SonarrUpcomingEpisodes` - Get episodes airing within a date range via the calendar endpoint. Defaults to the next 7 days.
- ✨ [New] `Set-SonarrDefaultServer` - Set the default Sonarr server to use.
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
