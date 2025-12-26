---
external help file: PSSonarr-help.xml
Module Name: PSSonarr
online version:
schema: 2.0.0
---

# Get-SonarrQueue

## SYNOPSIS
Gets the download queue from Sonarr.

## SYNTAX

```
Get-SonarrQueue [[-Page] <Int32>] [[-PageSize] <Int32>] [-IncludeUnknownSeriesItems] [[-Server] <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns items currently in the download queue, including active downloads
and queued items.
Supports pagination and filtering.

## EXAMPLES

### EXAMPLE 1
```
Get-SonarrQueue
```

Returns the first 20 items in the download queue.

### EXAMPLE 2
```
Get-SonarrQueue -PageSize 50
```

Returns the first 50 items in the download queue.

### EXAMPLE 3
```
Get-SonarrQueue -Page 2 -PageSize 10
```

Returns items 11-20 from the download queue.

### EXAMPLE 4
```
Get-SonarrQueue -IncludeUnknownSeriesItems
```

Returns queue items including downloads that don't match any known series.

## PARAMETERS

### -Page
The page number to retrieve (for pagination).
Defaults to 1.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageSize
The number of items per page.
Defaults to 20.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 20
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeUnknownSeriesItems
Include downloads that don't match any known series.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Server
The Sonarr server to query.
If not specified, uses the default configured server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
