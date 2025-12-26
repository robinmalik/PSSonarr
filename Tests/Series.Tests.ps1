BeforeAll {
	Import-Module -Name "$PSScriptRoot/../Source/PSSonarr.psd1" -Force
	$TestConfig = Get-Content -Path "$PSScriptRoot/../Secrets/testconfig.json" | ConvertFrom-Json
	Set-SonarrConfiguration -Server $TestConfig.server -Port $TestConfig.port -APIKey $TestConfig.apikey -RootFolderPath $TestConfig.rootfolderpath -Protocol "http"
}

Describe "Find Series Tests" {

	It "Tests Find-SonarrSeries by Name" {
		$Series = Find-SonarrSeries -Name "Desperate Housewives" -ExactMatch
		$Series | Should -Not -BeNullOrEmpty
		$Series.title | Should -Be "Desperate Housewives"
	}

	It "Tests Find-SonarrSeries by IMDBID" {
		$Series = Find-SonarrSeries -IMDBID "tt0410975"
		$Series | Should -Not -BeNullOrEmpty
		$Series.title | Should -Be "Desperate Housewives"
	}

	It "Tests Find-SonarrSeries by TMDBID" {
		$Series = Find-SonarrSeries -TMDBID "693"
		$Series | Should -Not -BeNullOrEmpty
		$Series.title | Should -Be "Desperate Housewives"
	}

	It "Tests Find-SonarrSeries by TVDBID" {
		$Series = Find-SonarrSeries -TVDBID "73800"
		$Series | Should -Not -BeNullOrEmpty
		$Series.title | Should -Be "Desperate Housewives"
	}
}


Describe "Add/Set/Remove Series and Seasons Tests" {

	It "Tests Add-SonarrSeries by IMDBID (Monitored: None)" {
		$Series = Add-SonarrSeries -IMDBID $TestConfig.series_for_add_remove -QualityProfileId 1 -MonitorOption 'none'
		$Series | Should -Not -BeNullOrEmpty
		$Series.title | Should -Be "Falling Skies"
		Start-Sleep -Seconds 2
	}

	It "Tests Set-SonarrSeriesStatus to Monitored" {
		$Series = Get-SonarrSeries -IMDBID $TestConfig.series_for_add_remove
		$UpdatedSeries = Set-SonarrSeriesStatus -Id $Series.id -Monitored $true -ErrorAction Stop
		$UpdatedSeries.monitored | Should -Be $true
	}

	It "Tests Set-SonarrSeasonStatus to Monitor Season 1" {
		$Series = Get-SonarrSeries -IMDBID $TestConfig.series_for_add_remove
		$UpdatedSeries = Set-SonarrSeasonStatus -Id $Series.id -SeasonNumber 1 -Monitored $true -ErrorAction Stop
		$Season1 = $UpdatedSeries.seasons | Where-Object { $_.seasonNumber -eq 1 }
		$Season1.monitored | Should -Be $true
	}

	It "Tests Set-SonarrSeasonStatus to Unmonitor Season 1" {
		$Series = Get-SonarrSeries -IMDBID $TestConfig.series_for_add_remove
		$UpdatedSeries = Set-SonarrSeasonStatus -Id $Series.id -SeasonNumber 1 -Monitored $false -ErrorAction Stop
		$Season1 = $UpdatedSeries.seasons | Where-Object { $_.seasonNumber -eq 1 }
		$Season1.monitored | Should -Be $false
	}

	It "Tests Set-SonarrSeriesQualityProfile to QualityProfileId 2" {
		$Series = Get-SonarrSeries -IMDBID $TestConfig.series_for_add_remove
		$UpdatedSeries = Set-SonarrSeriesQualityProfile -Id $Series.id -QualityProfileId 2 -ErrorAction Stop
		$UpdatedSeries.qualityProfileId | Should -Be 2
	}

	It "Tests Remove-SonarrSeries with IMDBID" {
		$Series = Get-SonarrSeries -IMDBID $TestConfig.series_for_add_remove
		$Series | Should -Not -BeNullOrEmpty
		Remove-SonarrSeries -Id $Series.id | Should -Be $null
	}
}

AfterAll {
	Remove-Module -Name PSSonarr -Force
}