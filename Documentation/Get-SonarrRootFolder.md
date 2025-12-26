---
external help file: PSSonarr-help.xml
Module Name: PSSonarr
online version:
schema: 2.0.0
---

# Get-SonarrRootFolder

## SYNOPSIS
Gets root folder configuration from Sonarr.

## SYNTAX

### All (Default)
```
Get-SonarrRootFolder [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Id
```
Get-SonarrRootFolder -Id <Int32> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns configured root folders in Sonarr, including available disk space and folder paths.
Can filter by root folder ID.

## EXAMPLES

### EXAMPLE 1
```
Get-SonarrRootFolder
```

Returns all configured root folders from the default Sonarr server.

### EXAMPLE 2
```
Get-SonarrRootFolder -Id 1
```

Returns the root folder with ID 1.

### EXAMPLE 3
```
Get-SonarrRootFolder | Select-Object path, @{n='FreeSpaceGB';e={[math]::Round($_.freeSpace/1GB,2)}}
```

Returns all root folders with their paths and free space in GB.

## PARAMETERS

### -Id
The ID of a specific root folder to retrieve.

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
