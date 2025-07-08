<#
.SYNOPSIS
    This script is meant to serve as an example of how to take a CSV file containing a map of usernames and group names and then add each user to each group.
.DESCRIPTION
    This script is meant to serve as an example of how to take a CSV file containing a map of usernames and group names and then add each user to each group.
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

# Replace this with the full path of the input CSV file
$fullPathToImportFile = "$PSScriptRoot\CSV_output\ExportCsvGroupMemberships_2025-07-08T154502Z.csv.example"

# Set this to $true if you want the -WhatIf parameter to be used (i.e. the script won't actually change any group memberships)
$testMode = $true # WARNING: If you set this to $false the script will actually try to remove users from groups

### End variables ###

### Begin main script body ###

Clear-Host

# Import the CSV as a variable
$csvFileObject = Import-Csv -Path $fullPathToImportFile

# Loop through each line of the CSV file
:loopThroughCsvFile foreach ($line in $csvFileObject) {
    # If $testMode is $false, actually do the thing
    if ($testMode -eq $false) {
        Add-ADGroupMember -Identity $($line.Group) -Members $($line.User)
    } else {
        # $testMode is not $false, so default to doing nothing
        ## TIP: Why did we use a simple "else" instead of "elseif ($testMode -eq $true)?"
        ## Doing it this way is a fail-safe. If the user forgets to assign any variable to $testMode or if they set it to an invalid value such as "$testMode = true"...
        ## ...then this will "fail-safe" so that the default action is always to do nothing. The user must explicitly and correctly set this to $false or else it will do nothing
        Add-ADGroupMember -Identity $($line.Group) -Members $($line.User) -WhatIf
    }
    ## TIP: It would be more efficient to rewrite the above portion of the script using splatting
    ### I decided to write it this way to be more easy to read, but see script "Add-ADGroupMembersFromCSVWithSplatting.ps1" for the better way to handle this with less re-used code
    ### https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-7.5

    Write-Host "Adding user $($line.User) to group $($line.Group)"
    ## TIP: When you are retrieving a specific property of an object, e.g. SamAccountName, User, or Group...
    ### ...it's helpful to wrap the whole thing in parentheses with a dollar sign $ at the beginning
    ### e.g. instead of $line.Group use $($line.Group)
    ### This will prevent weird errors where PowerShell isn't smart enough to realize the whole thing is one variable
}

### End main script body ###

break
exit