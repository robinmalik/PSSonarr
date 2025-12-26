---
external help file: PSSonarr-help.xml
Module Name: PSSonarr
online version:
schema: 2.0.0
---

# Get-SonarrHealth

## SYNOPSIS
Gets health status and warnings from Sonarr.

## SYNTAX

```
Get-SonarrHealth [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns health check results from Sonarr, including any warnings or errors
related to system configuration, disk space, updates, etc.

## EXAMPLES

### EXAMPLE 1
```
Get-SonarrHealth
```

Returns all health check results from the default Sonarr server.

### EXAMPLE 2
```
Get-SonarrHealth
```

## PARAMETERS

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

## OUTPUTS

## NOTES
Requires Sonarr v3+ API.

## RELATED LINKS
