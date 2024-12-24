BeforeAll {
	Import-Module -Name "$PSScriptRoot/../Source/PSSonarr.psd1" -Force
	#Get-Content -Path "$PSScriptRoot/.env" -Force | ForEach-Object {
	#	$LineSplit = $_ -split '='
	#	Set-Content -Path "env:\$($LineSplit[0])" -Value $($LineSplit[1]) -Force
	#}
}

Describe "Search-SonarrSeries Tests" {

	It "Tests Search-SonarrSeries by Name" {
		$Series = Search-SonarrSeries -Name "Desperate Housewives" -ExactMatch
		$Series | Should -Not -BeNullOrEmpty
		$Series.title | Should -Be "Desperate Housewives"
	}

	It "Tests Search-SonarrSeries by IMDBID" {
		$Series = Search-SonarrSeries -IMDBID "tt0410975"
		$Series | Should -Not -BeNullOrEmpty
		$Series.title | Should -Be "Desperate Housewives"
	}

	It "Tests Search-SonarrSeries by TMDBID" {
		$Series = Search-SonarrSeries -TMDBID "693"
		$Series | Should -Not -BeNullOrEmpty
		$Series.title | Should -Be "Desperate Housewives"
	}

	It "Tests Search-SonarrSeries by TVDBID" {
		$Series = Search-SonarrSeries -TVDBID "73800"
		$Series | Should -Not -BeNullOrEmpty
		$Series.title | Should -Be "Desperate Housewives"
	}
}


Describe "Add-SonarrSeries and Remove-SonarrSeries Tests" {

	It "Tests Add-SonarrSeries by IMDBID" {
		$Series = Add-SonarrSeries -IMDBID 'tt1462059' -QualityProfileId 14 -Monitor 'none'
		$Series | Should -Not -BeNullOrEmpty
		$Series.title | Should -Be "Falling Skies"
		Remove-SonarrSeries -Id $Series.id
	}

	It "Tests Add-SonarrSeries by TMDBID" {
		$Series = Add-SonarrSeries -TMDBID '2985' -QualityProfileId 14 -Monitor 'none'
		$Series | Should -Not -BeNullOrEmpty
		$Series.title | Should -Be "Andromeda"
		Remove-SonarrSeries -Id $Series.id
	}

	It "Tests Add-SonarrSeries by TVDBID" {
		$Series = Add-SonarrSeries -TVDBID '401003' -QualityProfileId 14 -Monitor 'none'
		$Series | Should -Not -BeNullOrEmpty
		$Series.title | Should -Be "FROM"
		Remove-SonarrSeries -Id $Series.id
	}
}

AfterAll {
	Remove-Module -Name PSSonarr -Force
}