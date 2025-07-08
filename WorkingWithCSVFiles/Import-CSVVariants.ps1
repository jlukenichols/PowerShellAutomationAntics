<#
.SYNOPSIS
    This script is meant to serve as an example of how to import variants of CSV files such as tab delimited, pipe delimited, or missing headers
.DESCRIPTION
    This script is meant to serve as an example of how to import variants of CSV files such as tab delimited, pipe delimited, or missing headers
.NOTES
    Author: Luke Nichols
    Last Modified: 2025-07-08T15:49:00Z
#>

### Begin Modules ###

# No modules needed

### End Modules ###

### Begin variables ###

# No variables this time :(

### End variables ###

### Begin main script body ###

Clear-Host

Write-Host "Displaying contents of file from $fullPathToImportFile :"

# Comma delimited with standard header line
#$fullPathToImportFile = "$PSScriptRoot\CSV_output\ExportCsvGroupMemberships_2025-07-08T154502Z.csv.example"
#$csvFileObject = Import-Csv -Path $fullPathToImportFile -Delimiter ","

# Tab delimited with standard header line
#$fullPathToImportFile = "$PSScriptRoot\CSV_output\ExportCsvGroupMemberships_2025-07-08T154502Z.tsv.example"
#$csvFileObject = Import-Csv -Path $fullPathToImportFile -Delimiter "`t"

# Pipe delimited with standard header line
#$csvFileObject = Import-Csv -Path $fullPathToImportFile -Delimiter "|" # pipe delimited
#$fullPathToImportFile = "$PSScriptRoot\CSV_output\ExportCsvGroupMemberships_2025-07-08T154502Z.csvpipe.example" # pipe delimited

# Comma delimited with missing header line
#$fullPathToImportFile = "$PSScriptRoot\CSV_output\ExportCsvGroupMemberships_2025-07-08T154502Z.csvnoheader.example" # comma delimited with no headers
#$csvFileObject = Import-Csv -Path $fullPathToImportFile -Header "User", "Group" # comma delimited, no headers

# Comma delimited with an extra 3 lines above the header line
$fullPathToImportFile = "$PSScriptRoot\CSV_output\ExportCsvGroupMemberships_2025-07-08T154502Z.csvextraheaderlines.example" # comma delimited with extra 3 lines above the header line
$csvFileObject = (Get-Content -Path $fullPathToImportFile | Select-Object -Skip 3 | ConvertFrom-Csv) # comma delimited, extra 3 lines above the header
## TIP: For CSV files with no headers, the order that you specify the headers is very important.
### You must list them in the same order they appear in the file, from left to right.

## Q: When should I specify the headers for Import-Csv?
## A: ONLY when there is no header line at the top of the file. If you specify headers manually with the -Headers parameter...
## ...when there is also a header line it will interpret the header line as data.

## Q: When should I specify the delimiter for Import-Csv?
## A: If it's in a script, it's best practice to always specify the delimiter to match what the import file should use.
## Different cultures and regions use different delimiters, so don't assume that your culture's default of comma is universal.
## A: If you're just running commands in your own PS window on your machine you can exclude the -delimiter parameter if you know it's a comma. That is the default delimiter.

$csvFileObject | Format-Table

### End main script body ###

break
exit