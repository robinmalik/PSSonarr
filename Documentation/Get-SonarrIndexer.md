---
external help file: PSSonarr-help.xml
Module Name: PSSonarr
online version:
schema: 2.0.0
---

# Get-SonarrIndexer

## SYNOPSIS
Gets indexer configuration from Sonarr.

## SYNTAX

### All (Default)
```
Get-SonarrIndexer [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Id
```
Get-SonarrIndexer -Id <Int32> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Name
```
Get-SonarrIndexer -Name <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns configured indexers in Sonarr.
Can filter by indexer ID or name.

## EXAMPLES

### EXAMPLE 1
```
Get-SonarrIndexer
```

Returns all configured indexers from the default Sonarr server.

### EXAMPLE 2
```
Get-SonarrIndexer -Id 1
```

Returns the indexer with ID 1.

### EXAMPLE 3
```
Get-SonarrIndexer -Name "NZBgeek"
```

Returns the indexer named "NZBgeek".

### EXAMPLE 4
```
Get-SonarrIndexer -Name "*Usenet*"
```

Returns all indexers with "Usenet" in their name.

## PARAMETERS

### -Id
The ID of a specific indexer to retrieve.

```yaml
Type: Int32
Parameter Sets: Id
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
The name of a specific indexer to retrieve.
Supports wildcards.

```yaml
Type: String
Parameter Sets: Name
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

## OUTPUTS

## NOTES
Requires Sonarr v3+ API.

## RELATED LINKS
