---
external help file: PSSonarr-help.xml
Module Name: PSSonarr
online version:
schema: 2.0.0
---

# Add-SonarrSeries

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### IMDB
```
Add-SonarrSeries -IMDBID <String> -QualityProfileId <Int32> [-MonitorOption <Object>] [-Search]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### TMDB
```
Add-SonarrSeries -TMDBID <String> -QualityProfileId <Int32> [-MonitorOption <Object>] [-Search]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### TVDB
```
Add-SonarrSeries -TVDBID <String> -QualityProfileId <Int32> [-MonitorOption <Object>] [-Search]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -IMDBID
{{ Fill IMDBID Description }}

```yaml
Type: String
Parameter Sets: IMDB
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MonitorOption
{{ Fill MonitorOption Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:
Accepted values: all, firstSeason, lastSeason, future, missing, existing, recent, pilot, monitorSpecials, unmonitorSpecials, none

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -QualityProfileId
{{ Fill QualityProfileId Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Search
{{ Fill Search Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TMDBID
{{ Fill TMDBID Description }}

```yaml
Type: String
Parameter Sets: TMDB
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TVDBID
{{ Fill TVDBID Description }}

```yaml
Type: String
Parameter Sets: TVDB
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
