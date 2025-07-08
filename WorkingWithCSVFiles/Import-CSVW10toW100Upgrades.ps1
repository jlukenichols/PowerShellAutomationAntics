<#
.SYNOPSIS
    This script is meant to serve as an example of how to import a CSV containing Windows 10 computers and check if each one is compatible with Windows 11
.DESCRIPTION
    This script is meant to serve as an example of how to import a CSV containing Windows 10 computers and check if each one is compatible with Windows 11
.NOTES
    Author: Luke Nichols
    Last Modified: 2025-07-08T15:49:00Z
#>

### Begin Modules ###

# No modules needed

### End Modules ###

### Begin variables ###

# Get the current date in UTC
$currentDateUTC = (Get-Date).ToUniversalTime()

# Convert the current date to a file path-friendly format
# This is basically the "ISO 8601" format but with the colons stripped out since those are invalid characters in Windows file paths
# https://en.wikipedia.org/wiki/ISO_8601
# This format is great for log files because sorting by name is the same thing as sorting by date. I.e. if you sort by name it will automatically sort oldest to newest
$currentDateFileFriendly = Get-Date $currentDateUTC -Format yyyy-MM-ddTHHmmssZ

# Replace this with the full path of the input CSV file, this is produced by "Export-CsvADComputersWindows10.ps1"
#$fullPathToImportFile = "$PSScriptRoot\CSV_output\ExportCsvADComputersW10_2025-07-08T194118Z.csv.example"
#$fullPathToImportFile = "$PSScriptRoot\CSV_output\ExportCsvADComputersW10_2025-07-08T195223Z.csv"
$fullPathToImportFile = "$PSScriptRoot\CSV_output\ExportCsvADComputersW10_2025-07-08T195246Z.csv"

# Replace this with the full path where you want to export the report of computers incompatible with Windows 11
$fullPathToExportFile = "$PSScriptRoot\CSV_output\ComputersIncompatibleWithWindows11_$currentDateFileFriendly.csv"

### End variables ###

### Begin main script body ###

Clear-Host

# Import input CSV
$W10Computers = Import-Csv -Path $fullPathToImportFile

# Loop through each line in the CSV file, save results to a variable
$TpmCheckResults = :loopThroughW10Computers foreach ($line in $W10Computers) {
    Write-Host "Querying TPM details of computer $($line.ComputerName) ..."
    
    # Check if the computer has a TPM module
    ## NOTE: This relies on PSRemoting and may take a while
    $Tpm = Invoke-Command -ComputerName $($line.ComputerName) -ScriptBlock {
        Get-CimInstance -Namespace "ROOT/CIMV2/Security/MicrosoftTpm" -ClassName Win32_Tpm
    }    

    # Check if $Tpm returned nothing
    if (-not($Tpm)) {
        # Tpm not defined, something went wrong
        Write-Host "ERROR: Unable to determine Tpm compatibility for $($line.ComputerName)" -ForegroundColor Red
        [PSCustomObject]@{
            ComputerName = $($line.ComputerName)
            W11Compatible = "UNKNOWN"
        }
        continue loopThroughW10Computers
    } else {    
        # Check if our Tpm module is compatible with 2.0 which is required for W11 upgrades
        if ($Tpm.SpecVersion -like "*2.0*") {
            Write-Host "Computer $($line.ComputerName) has a TPM 2.0 module, it is eligible to be upgraded to Windows 11!" -ForegroundColor Green
        } elseif ($Tpm.SpecVersion -notlike "*2.0*") {
            Write-Host "Computer $($line.ComputerName) does NOT have a TPM 2.0 module, it is INELIGIBLE to be upgraded to Windows 11!" -ForegroundColor Red        
            [PSCustomObject]@{
                ComputerName = $($line.ComputerName)
                W11Compatible = $false
            }
        } else {
            Write-host "UNHANDLED EXCEPTION: Unexpected value of `$Tpm.SpecVersion for computer $($line.ComputerName)"
        }
        ## TIP: Because of a quirk with how Get-CimInstance is outputting the data, SpecVersion is NOT an array. It is a string containing comma-separted values.
        ## Because of this, we have to use a wildcard match and treat it like a string, instead of being able to use the -in comparator.
    }
}

# Check if TPM Check returned anything
if ($TpmCheckResults) {
    # Export the TPM check results to an output file
    $TpmCheckResults | Export-Csv -Path "$fullPathToExportFile"
    Write-Host "Results saved to $fullPathToExportFile"
} else {
    Write-Host "No incompatible computers found!"
}

### End main script body ###

break
exit