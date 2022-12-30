$indexNumber = "18852"

function getComputerInfo {
    # Pobierz  domene
    $domain = (Get-WmiObject -Class Win32_ComputerSystem).Domain
    
    # Pobierz nazwe obiektu klasy ADDomain
    $domainName = (Get-ADDomain -Identity $domain).Name
    # Pobierz wszystkie komputery z AD
    $computers = Get-ADComputer -Filter * -Properties Name, SID, DistinguishedName, Enabled, PasswordLastSet, Created, OperatingSystem

    $systems = (Get-ADComputer -Filter * -Properties OperatingSystem).OperatingSystem
    $uniqueSystems = $systems | Get-Unique

    # Dla każdego systemu komputera:
    foreach ($system in $uniqueSystems) {
        # Usunięcie wszystkich białych znaków z całego ciągu za pomocą wyrażenia regularnego
        $regex = [regex]"\s"
        $operatingSystemNWS = $regex.Replace($system, "")

        $filePath = "C:\Logi\$($indexNumber)_$($domainName)_$($operatingSystemNWS).csv"
        $null = New-Item -ItemType File -Path $filePath -Force
    }

    # Dla każdego komputera:
    if ($computers) {
        foreach ($computer in $computers) {
            # Pobierz dane komputera
            $Name = $computer.Name
            $SID = $computer.SID
            $DN = $computer.DistinguishedName
            $enabled = $computer.Enabled
            $pwdLastSet = $computer.PasswordLastSet
            $created = $computer.Created
            $operatingSystem = $computer.OperatingSystem

            # Usunięcie wszystkich białych znaków z całego ciągu za pomocą wyrażenia regularnego
            $regex = [regex]"\s"
            $operatingSystemNWS = $regex.Replace($operatingSystem, "")

            $filePath = "C:\Logi\$($indexNumber)_$($domainName)_$($operatingSystemNWS).csv"
    
            $entry = [pscustomobject]@{
                "Nazwa"                                           = $Name
                "SID"                                             = $SID
                "Distinguished Name"                              = $DN
                "Czy aktywny"                                     = $enabled
                "Data ostatniej zmiany hasla na koncie komputera" = $pwdLastSet
                "Data utworzenia"                                 = $created
            }
            $entry | Export-Csv $filePath -Append -NoTypeInformation
        }
    }
    Write-Output "Listy o kontach komputerów zostały pomyślnie utworzone."
}