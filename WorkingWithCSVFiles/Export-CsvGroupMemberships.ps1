<#
.SYNOPSIS
    This script is meant to serve as an example of how to export data from AD about group memberships to a CSV file.
.DESCRIPTION
    This script is meant to serve as an example of how to export data from AD about group memberships to a CSV file.
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

# Replace this with a comma-delimited list of group names that you want to retrieve members of
$arrayOfGroupNames = "Black Cats","Orange Cats","Tabby Cats"

# Replace this with the full path where you want to export the report of group members
$fullPathToExportFile = "$PSScriptRoot\CSV_output\ExportCsvGroupMemberships_$currentDateFileFriendly.csv"

### End variables ###

### Begin main script body ###

Clear-Host

# Loop through each group
## It's best practice to always label your loops so if you nest them you can easily break any loop in the hierarchy by name
## e.g. "break loopThroughGroupNames" will break the outer loop even if you run it from the inner loop
## If you just ran "break" from the inner loop it would only break the inner loop
# Write the results of the loop into a variable for use later
$allGroupMembers = :loopThroughGroupNames foreach ($group in $arrayOfGroupNames) {
    # Get the members of this group and write them to a variable
    $thisGroupMembers = Get-ADGroupMember $group

    :loopThroughGroupMembers foreach ($member in $thisGroupMembers) {

        Write-Host "Found user $($member.SamAccountName) in group $group"

        # Output the results of this loop into a PSCustomObject
        # This will be added to the variable $allGroupMembers for easier use later
        [PSCustomObject]@{
            User = $member.SamAccountName
            Group = $group
        }
    }
    Write-Host "------------------------------------"
}

# Take the results of our loop and output to a CSV
$allGroupMembers | Export-Csv -Path $fullPathToExportFile

### End main script body ###

break
exit