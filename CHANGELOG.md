## [0.0.6] - 2025-12-26

-   🔨 [Changed] All cmdlets now use `Invoke-SonarrRequest` instead of manual `Invoke-RestMethod`
-   ✨ [New] `Set-SonarrSeriesQualityProfile` - Set the quality profile for a series.
-   ✨ [New] Added simple functions for `Get-SonarrHealth`, `Get-SonarrIndexer`, `Get-SonarrQueue`, `Get-SonarrRootFolder` and `Get-SonarrSystem`.
-   🐛 [Fix] `Add-SonarrSeries` - Warn when series exists with corrective suggestive function calls.

## [0.0.5] - 2025-10-11

-   🔨 [Changed] BREAKING CHANGE: Renamed `Search-SonarrSeries` to `Find-SonarrSeries` to aid clarity between finding a series to add to Sonarr vs searching for existing series episodes.
-   ✨ [New] `Start-SonarrSeasonSearch` - Search for episodes within a specific season of a series.
-   ✨ [New] `Remove-SonarrSeries` - Supports deleting files and adding import list exclusions.
-   🐛 [Fix] `Set-SonarrSeriesStatus` - Remove unrequired parameter.

## [0.0.4] - 2025-10-11

-   ✨ [New] `Set-SonarrSeriesStatus` - Set a series to monitored or unmonitored.

## [0.0.3] - 2025-10-11

-   ✨ [New] `Set-SonarrSeasonStatus` - Set a season to monitored or unmonitored.
-   📚 [Added] Added Syntax blocks to all functions (via Claude Sonnet 4).

## [0.0.2] - 2024-12-25

-   🐛 [Fix] Expose `Set-SonarrConfiguration` function.

## [0.0.1] - 2024-12-24

-   🎉 A very quick, initial release!
