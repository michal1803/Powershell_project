$indexNumber = "18852"
function createGroup {
    param (
        [Parameter(Mandatory = $true)]
        [string]$groupName
    )
    # Sprawdź, czy grupa o podanej nazwie już istnieje
    $group = Get-ADGroup -Filter "Name -eq '$groupName'"
    if ($group) {
        Write-Host "Grupa o nazwie $groupName już istnieje podaj nową nazwę grupy"
        return createGroup
    }

    # Pobierz  domeny
    $domain = (Get-WmiObject -Class Win32_ComputerSystem).Domain
    
    # Pobierz obiekt klasy ADDomain
    $domain = Get-ADDomain -Identity $domain

    # Pobierz DN domeny
    $domainDN = $domain.DistinguishedName

    # Pobierz ścieżkę do domeny
    $path = "CN=Users,$domainDN"

    # Pobierz aktualną datę i godzinę
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH.mm.ss"

    # Utwórz grupę
    New-ADGroup -Name $groupName -GroupCategory Security -GroupScope Global -Path $path

    # Sprawdź, czy grupa o podanej nazwie już istnieje
    $newGroup = Get-ADGroup -Filter "Name -eq '$groupName'"
    if ($newGroup) {
        Write-Host "Grupa o nazwie $groupName została pomyślnie dodana"
    }

    # Dodawanie wpisu do dziennika
    $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = [pscustomobject]@{
        "Timestamp" = $timeStamp
        "User"      = $env:USERNAME
        "Action"    = "Created group $groupName"
    }
    $entryFilePath = "C:\Logi\$($indexNumber)_create_group.csv"

    # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
    if (-not (Test-Path $entryFilePath)) {
        $null = New-Item -ItemType File -Path $entryFilePath -Force
    }
    $entry | Export-Csv $entryFilePath -Append -NoTypeInformation 
}