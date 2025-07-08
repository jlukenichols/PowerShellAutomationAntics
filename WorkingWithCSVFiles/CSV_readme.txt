This lesson is all about working with CSV files. By the end of this lesson, you should be able to answer the following:

What the hell is a CSV?
    XLSX vs CSV-- just because CSV's open in Excel by default does not make them spreadsheets! You can open them in Notepad++, VSCode, etc.
    How to handle other delimiters than comma? E.g. tab, pipe
    The .CSV filetype extension doesn't matter-- a CSV can have any arbitrary extension as long as it's a plaintext file with some kind of delimiter
    How to work with data that contains your delimiter character?
How to export data from various systems into a CSV report
    Export data like:
        User accounts in an Active Directory domain
        (3)Computer accounts in an Active Directory domain
        Files and folders in a directory
        (2)Printers on a system
        (1)Group memberships of users in an Active Directory domain
How to import data from a CSV file and do something with it
    Import data like:
        (1)CSV containing mappings of users to groups
            Add or remove users to/from these groups
        (2)List of printers from a print server with a specific prefix
            Map each of these printers on a user's computer
        (3)Report of Windows 10 computers joined to an Active Directory domain
            Use PSRemoting to check if each one meets minimum systemm requirements to upgrade to Windows 11