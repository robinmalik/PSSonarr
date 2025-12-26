---
external help file: PSSonarr-help.xml
Module Name: PSSonarr
online version:
schema: 2.0.0
---

# Get-SonarrSystem

## SYNOPSIS
Gets Sonarr system status information.

## SYNTAX

```
Get-SonarrSystem [[-Server] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns detailed system status information including version, branch,
authentication method, database information, operating system, and more.

## EXAMPLES

### EXAMPLE 1
```
Get-SonarrSystem
```

### EXAMPLE 2
```
(Get-SonarrSystem).version
```

Returns just the version number of Sonarr.

## PARAMETERS

### -Server
{{ Fill Server Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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

## OUTPUTS

## NOTES
Requires Sonarr v3+ API.

## RELATED LINKS
