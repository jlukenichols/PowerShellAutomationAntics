<#
.SYNOPSIS
    This script is meant to serve as an example of how to export data from AD about users to a CSV file.
.DESCRIPTION
    This script is meant to serve as an example of how to export data from AD about users to a CSV file.
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

# Replace this with the DistinguishedName of an OU where you want to retrieve all users
$organizationalUnitDistinguishedName = "OU=TestUsers,OU=User Accounts,DC=lab,DC=lukenichols,DC=net"

# Replace this with the specific properties you want to retrieve with get-aduser
$arrayOfADUserProperties = "CanonicalName","CN","DisplayName","DistinguishedName","EmailAddress","Name","SamAccountname","sn","Surname","UserPrincipalName"

# Replace this with the full path where you want to export the report of group members
$fullPathToExportFile = "$PSScriptRoot\CSV_output\ExportCsvADUsers_$currentDateFileFriendly.csv"

### End variables ###

### Begin main script body ###

Clear-Host

# Confirm that the OU actually exists and we can reach AD
try {
    # Get the specified OU and write it to a variable
    $organizationalUnitObject = Get-ADOrganizationalUnit -Identity $organizationalUnitDistinguishedName
} catch {
    # Something went wrong. Maybe we typed the OU name wrong, it doesn't actually exist, we don't have connectivity to a domain controller, we have insufficient permissions, etc?
    Write-Host "ERROR: Failed to find OU `"$organizationalUnitDistinguishedName`". Check the value of `$organizationalUnitDistinguishedName and try again." -ForegroundColor "Red"
    Write-Host "Also, ensure that you have connectivity to a domain controller and the necessary permissions to perform this action." -ForegroundColor "Red"
    Write-Host "$_" -ForegroundColor "Red"
    # Terminate the script, we cannot proceed without a valid OU
    break
    exit
}

# Retrieve the users inside the target OU from AD and save the data to a variable
$allUsersInOU = Get-ADUser -Filter * -SearchBase $($organizationalUnitObject.DistinguishedName) -Properties $arrayOfADUserProperties

## TIP: Get-ADUser has a set of default properties which it will return no matter what you provide in the -Properties parameter.
## You should treat -Properties as a list of any ADDITIONAL properties that you want to retrieve.
## It's totally fine to include default properties in the -Properties parameter, it won't hurt anything
## Here are the default properties, which you can see by running "Get-ADUser $env:username"
## "DistinguishedName","Enabled","GivenName","Name","ObjectClass","ObjectGUID","SamAccountName","SID","Surname","UserPrincipalName"
##
## TIP: You could use "-Properties *" to retrieve all properties and then filter them later with Select-Object but that would take longer to retrieve from AD...
## ...and consume more CPU and memory. It's better to only retrieve the properties you need as a best practice. If you're only retrieving 20 users...
## ...then "-Properties *" will not noticably change anything, but what if you're retrieving 2000?
##
## TIP: Some properties of an AD user are arrays, e.g. userCertificate or memberOf. That means each user has a one-to-many relationship with groups.
## Unfortunately, there is no easy way to represent one-to-many relationships in a CSV file, because it is a flatfile database.
## In a real database you would handle this with a separate table for user-group mappings and use foreign keys for the Users and Groups tables...
## ...but that's not a realistic option in a CSV. If you really want an array in your CSV, just be careful about the delimiters. If the array is ...
## ...delimited with the same character as your CSV's fields, you'll have to replace the delimiter with another character or wrap the whole thing in double-quotes to treat it as a string.
## Additionally, whatever system will be reading that CSV must be smart enough to re-assemble the string of groups into an array containing an arbitrary number of values.

# Take the results of our query, filter to only the properties we care about, and output to a CSV
$allUsersInOU | Select-Object -Property $arrayOfADUserProperties | Export-Csv -Path $fullPathToExportFile

## TIP: If any of the properties of $allUsersInOU are blank, the script will output that property as a double comma with nothing in between.
## For an example, check the "EmailAddress" field in "WorkingWithCsvFiles\CSV_output\ExportCsvADUsers_2025-07-08T171749Z.csvBlankValues.example"
## Only 1 user actually has an Email Address, the rest are blank, represented with ",," with nothing in between.
## It is VERY important that the double comma is there, or else all the values after it would shift left by 1 column.
## CSV's rely on the quantity of delimiters being consistent on each line in order to align values with the appropriate headers.
## In practice you probably never need to worry about this in PowerShell, Export-CSV will handle it for you.
## The only time you may need to worry about this if you're manually constructing a CSV line-by-line by appending text to a file.
## If you're doing that, you're probably doing something wrong and could re-factor your code to use Export-Csv instead.

Write-Host "Results saved to $fullPathToExportFile"

### End main script body ###

break
exit