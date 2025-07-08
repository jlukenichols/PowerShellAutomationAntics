<#
.SYNOPSIS
    This script is meant to serve as an example of how to export data from AD about computers to a CSV file.
.DESCRIPTION
    This script is meant to serve as an example of how to export data from AD about computers to a CSV file.
.NOTES
    Author: Luke Nichols
    Last Modified: 2025-07-08T15:49:00Z
#>

#Requires -modules ActiveDirectory

### Begin Modules ###

# If you don't have the AD PowerShell module installed, run this as administrator to install it
#Add-windowsCapability -Online -Name RSAT.ActiveDirectory.*

# Import the AD powershell module
Import-Module ActiveDirectory

### End Modules ###

### Begin variables ###

# Get the current date in UTC
$currentDateUTC = (Get-Date).ToUniversalTime()

# Convert the current date to a file path-friendly format
# This is basically the "ISO 8601" format but with the colons stripped out since those are invalid characters in Windows file paths
# https://en.wikipedia.org/wiki/ISO_8601
# This format is great for log files because sorting by name is the same thing as sorting by date. I.e. if you sort by name it will automatically sort oldest to newest
$currentDateFileFriendly = Get-Date $currentDateUTC -Format yyyy-MM-ddTHHmmssZ

# Replace this with an array of patterns of "OperatingSystem" you want to retrieve from AD computer objects, e.g. "Windows 10*", "Windows 11*"
$arrayOfTargetOSPatterns = "Windows 10*"

# Replace this with the full path where you want to export the report of group members
$fullPathToExportFile = "$PSScriptRoot\CSV_output\ExportCsvADComputersW10_$currentDateFileFriendly.csv"

### End variables ###

### Begin main script body ###

Clear-Host

# Loop through each OS name pattern, write results to a variable
$allSpecifiedComputerObjects = :loopThroughTargetOSPatterns foreach ($OSPattern in $arrayOfTargetOSPatterns) {
    # Build the filter for Get-ADComputer
    ## This would be hard to build in-line on the same command
    $filter = "OperatingSystem -like `"$OSPattern`""
    # Retrieve all AD computer objects matching this pattern
    $allAdComputerObjects = Get-ADComputer -Filter $filter -Properties OperatingSystem, Name | Select-Object -Property Name, OperatingSystem

    # Loop through each computer object returned and output it as a PSCustomObject
    :loopThroughComputerObjects foreach ($ComputerObject in $allAdComputerObjects) {
        [PSCustomObject]@{
            ComputerName = $($ComputerObject.Name)
            OperatingSystem = $($ComputerObject.OperatingSystem)
        }
    }
}

# Take the results of our query, filter to only the properties we care about, and output to a CSV
$allSpecifiedComputerObjects | Export-Csv -Path $fullPathToExportFile

Write-Host "Results saved to $fullPathToExportFile"

### End main script body ###

break
exit