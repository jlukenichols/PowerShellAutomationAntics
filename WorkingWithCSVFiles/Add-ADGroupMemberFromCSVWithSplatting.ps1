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

# Build an empty hash table to use for parameter splatting later


# Set this to $true if you want the -WhatIf parameter to be used (i.e. the script won't actually change any group memberships)
$HashArguments = @{
    WhatIf = $true # WARNING: If you set this to $false the script will actually try to add users to groups
}

### End variables ###

### Begin main script body ###

Clear-Host

# Import the CSV as a variable
$csvFileObject = Import-Csv -Path $fullPathToImportFile

# Loop through each line of the CSV file
:loopThroughCsvFile foreach ($line in $csvFileObject) {
    # Add the user to the group
    Add-ADGroupMember -Identity $($line.Group) -Members $($line.User) @HashArguments    
    ## TIP: You can pass in a hash table of splatted parameters in addition to specific named parameters in the same command
    ### This is more efficient than the simpler method from "Add-ADGroupMemberFromCSV.ps1" because we're not...
    ### ...calling the same command in 2 different places, we can just call it once with no if/else/then statements necessary

    ## TIP: You could improve this script even further! Here are some ideas:    
    ### 1) Add logic to confirm that $fullPathToImportFile actually exists, if it doesn't throw an error and stop the script
    ### 2) Replace the Identity and Members parameters with a get-adgroup and get-aduser clause
    #### E.g. Add-ADGroupMember -Identity (get-adgroup $line.Group) -Members (get-aduser $line.User) @HashArguments
    #### This will make the script smart enough to take in DistinguishedName or SamAccountName for each group and user...
    ####... and will verify they actually exist and throw a specific error if they don't
    ### 3) Move Add-ADGroupMember into a try/catch block so you can catch any unexpected errors and report on them

    Write-Host "Adding user $($line.User) to group $($line.Group)"
}

### End main script body ###

break
exit