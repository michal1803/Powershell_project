############################-------------AZ1 PROJEKT ZALICZENIOWY POWERSHELL--------------############################
############################----------------MICHAŁ WĄSIK 18852 IZ07TC1----------------############################

########-----MENU-----########

$header = "##############---------AZ1 PROJEKT ZALICZENIOWY POWERSHELL---------##############"
$author = "##############-------------MICHAL WASIK 18852 IZ07TC1-------------##############"
$indexNumber = "18852"
############ SKRYPT WSZYSTKIE PLIKI TWORZY W SCIEZCE C:\Logi
function createUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Surname,
        [Parameter(Mandatory = $true)]
        [string]$Department
    )

    # Pobieranie nazwy domeny z urządzenia
    $computer = Get-WmiObject -Class Win32_ComputerSystem
    $domain = $computer.Domain

    # Generowanie loginu na podstawie imienia i nazwiska
    $login = $Name + "." + $Surname
    # Sprawdzenie, czy login już istnieje jeśli tak, doda do niego cyfrę
    $i = 1
    $adName = "$($Name) $($Surname)"
    while (Get-ADUser -Filter "SamAccountName -eq '$login'" -ErrorAction SilentlyContinue) {
        $login = $Name + "." + $Surname + $i
        $adName = "$Name $Surname $i"
        $i++
    }

    # Generowanie adresu e-mail na podstawie imienia, nazwiska i domeny
    $email = "$login@$domain"

    # Generowanie hasła
    $password = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | % { [char]$_ })
    # Tworzenie konta użytkownika
    New-ADUser -GivenName $Name -Surname $Surname -Name $($adName) -SamAccountName $login -UserPrincipalName "$login@$domain" -Department $Department -Email $email -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -Enabled $true

    # Zapisywanie informacji o loginie i haśle do pliku CSV
    $data = [pscustomobject]@{
        "Login"    = $login
        "Password" = $password
    }
    $dataFilePath = "C:\Logi\user\$($indexNumber)_$($Name)_$($Surname)_$($i).csv"
    # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
    if (-not (Test-Path $dataFilePath)) {
        $null = New-Item -ItemType File -Path $dataFilePath -Force
    }
    $data | Export-Csv $dataFilePath -NoTypeInformation 

    # Dodawanie wpisu do dziennika
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = [pscustomobject]@{
        "Timestamp" = $timestamp
        "User"      = $env:USERNAME
        "Action"    = "Created user $adName with login $login and password $password"
    }
    $entryFilePath = "C:\Logi\user\$($indexNumber)_create_user.csv"

    # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
    if (-not (Test-Path $entryFilePath)) {
        $null = New-Item -ItemType File -Path $entryFilePath -Force
    }
    $entry | Export-Csv $entryFilePath -Append -NoTypeInformation 
}

function createUsersFromCsv {
    param (
        [Parameter(Mandatory = $true)]
        [string]$CsvPath
    )

    # Pobieranie nazwy domeny z urządzenia
    $computer = Get-WmiObject -Class Win32_ComputerSystem
    $domain = $computer.Domain

    $logFilePath = "C:\Logi\user\$($indexNumber)_create_user.csv"
    # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
    if (-not (Test-Path $logFilePath)) {
        $null = New-Item -ItemType File -Path $logFilePath -Force
        # Jeśli plik nie istnieje, tworzy pusty plik CSV z nagłówkami
        '"Timestamp","User","Action"' | Out-File $logFilePath -Force
    }

  
    # Wczytanie danych z pliku CSV
    $users = Import-Csv $CsvPath
  
    # Dla każdego użytkownika w pliku CSV
    foreach ($user in $users) {
        # Pobranie imienia, nazwiska i działu z obiektu
        $name = $user.Name
        $surname = $user.Surname
        $department = $user.Department
  
        # Generowanie loginu i hasła
        $login = $name + '.' + $surname
        $password = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | % { [char]$_ })
  
        # Generowanie adresu e-mail na podstawie imienia, nazwiska i domeny
        $email = "$login@$domain"

        # Sprawdzenie, czy login już istnieje jeśli tak, doda do niego cyfrę
        $i = 1
        $adName = "$Name $Surname"
        while (Get-ADUser -Filter "SamAccountName -eq '$login'" -ErrorAction SilentlyContinue) {
            $login = $Name + "." + $Surname + $i
            $adName = "$Name $Surname $i"
            $i++
        }
  
        # Tworzenie nowego konta użytkownika w domenie
        New-ADUser -SamAccountName $login -Name $adName -Surname $surname -Email $email -UserPrincipalName "$login@$domain" -Department $department -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -Enabled $true
  
        # Zapisywanie informacji o loginie i haśle do pliku o nazwie użytkownika
        $data = [pscustomobject]@{
            "Login"    = $login
            "Password" = $password
        }
        $dataFilePath = "C:\Logi\user\$($indexNumber)_$($Name)_$($Surname)_$($i).csv"
        # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
        if (-not (Test-Path $dataFilePath)) {
            $null = New-Item -ItemType File -Path $dataFilePath -Force
        }
        $data | Export-Csv $dataFilePath -NoTypeInformation
          
        # Dodawanie wpisu do dziennika
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $entry = [pscustomobject]@{
            "Timestamp" = $timestamp
            "User"      = $env:USERNAME
            "Action"    = "Created user $adName with login $login and password $password"
        }
        $entryFilePath = "C:\Logi\user\$($indexNumber)_create_user.csv"

        # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
        if (-not (Test-Path $entryFilePath)) {
            $null = New-Item -ItemType File -Path $entryFilePath -Force
        }
        $entry | Export-Csv $entryFilePath -Append -NoTypeInformation 
    }
}
function disableAccount {
    param (
        [Parameter(Mandatory = $true)]
        [string]$login
    )

    # Pobierz aktualną datę i godzinę
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH.mm.ss"

    # Wyłącz konto użytkownika
    Disable-ADAccount -Identity $login



    $plik = "C:\Logi\user\$($indexNumber)_wylaczone_konta_$($timestamp).txt"
    # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
    if (-not (Test-Path $plik)) {
        $null = New-Item -ItemType File -Path $plik -Force
    }

    # Zapisz informacje o wyłączeniu konta do pliku log
    Add-Content -Path $plik -Value "Użytkownik $env:USERNAME wyłączył konto $login o godzinie $timestamp"
}

function changePassword {
    param (
        [Parameter(Mandatory = $true)]
        [string]$login
    )

    # Pobierz aktualną datę i godzinę
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH.mm.ss"

    # Generowanie hasła
    $password = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | % { [char]$_ })

    # Zmień hasło użytkownika
    Set-ADAccountPassword -Identity $login -NewPassword (ConvertTo-SecureString $password -AsPlainText -Force)

    # Sprawdź, czy zmiana hasła przebiegła pomyślnie
    $uzytkownik = Get-ADUser -Identity $login -Properties PasswordLastSet
    if ($uzytkownik.PasswordLastSet -gt (Get-Date).AddMinutes(-1)) {
        Write-Host "Nowe hasło dla użytkownika $login to $password"
    }
    else {
        Write-Host "Wystąpił błąd podczas zmiany hasła dla użytkownika $login"
    }

    $plik = "C:\Logi\user\$($indexNumber)_zmiana_hasla_$($timestamp).txt"
    # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
    if (-not (Test-Path $plik)) {
        $null = New-Item -ItemType File -Path $plik -Force
    }

    # Zapisz informacje o wyłączeniu konta do pliku log
    Add-Content -Path $plik -Value "Użytkownik $env:USERNAME zmienil haslo dla konta $login na $password o godzinie $timestamp"

}

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
    $entryFilePath = "C:\Logi\group\$($indexNumber)_create_group.csv"

    # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
    if (-not (Test-Path $entryFilePath)) {
        $null = New-Item -ItemType File -Path $entryFilePath -Force
    }
    $entry | Export-Csv $entryFilePath -Append -NoTypeInformation 
}

function addUserToGroup {
    param (
        [Parameter(Mandatory = $true)]
        [string]$groupName,
        [Parameter(Mandatory = $true)]
        [string]$userName
    )
    try {
        # Pobierz obiekt użytkownika z AD
        $user = Get-ADUser -Identity $userName -ErrorAction SilentlyContinue

        # Pobierz obiekt grupy z AD
        $group = Get-ADGroup -Identity $groupName -ErrorAction SilentlyContinue
    }
    catch {
        Write-Output "User lub grupa są nieprawidłowe. Wprowadź dane raz jeszcze."
        return addUserToGroup
    }
    

    # Sprawdź, czy użytkownik jest członkiem grupy
    if ($user.MemberOf -contains $group.DistinguishedName) {
        Write-Output "Użytkownik już jest członkiem grupy"
    }
    else {
        Add-ADGroupMember -Identity $groupName -Members $userName
        Write-Output "Użytkownik został dodany prawidłowo do grupy $groupName"
    }

    # Pobieranie aktualnej daty i godziny
    $currentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $plik = "C:\Logi\group\$($indexNumber)_zmiana_członkostwa_grup.txt"
    # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
    if (-not (Test-Path $plik)) {
        $null = New-Item -ItemType File -Path $plik -Force
    }

    # Zapisywanie informacji o zmianie członkostwa grupy do pliku
    Add-Content -Path $plik -Value "$env:USERNAME dodał użytkownika $userName do grupy $groupName o godzinie $currentDate"
}

function generateGroupReport {
    # Pobierz wszystkie grupy z AD
    $groups = Get-ADGroup -Filter *

    # Dla każdej grupy:
    foreach ($group in $groups) {
        # Pobierz nazwę grupy
        $groupName = $group.Name

        # Pobierz członków grupy
        $members = Get-ADGroupMember -Identity $groupName -ErrorAction SilentlyContinue

        # Jeśli grupa ma członków:
        if ($members) {

            $filePath = "C:\Logi\raporty\$($indexNumber)_$($groupName).txt"
            # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
            $null = New-Item -ItemType File -Path $filePath -Force

            # Dla każdego członka grupy:
            foreach ($member in $members) {
                # Pobierz login użytkownika
                $userName = $member.SamAccountName

                # Dodaj login do pliku
                Add-Content -Path $filePath -Value $userName
            }
        }
    }
    Write-Output "Lista grup z członkami została pomyślnie utworzona."
}

function generateDisabledAccountReport {
    # Pobierz wszystkie wyłączone konta z AD
    $disabledAccounts = Get-ADUser -Filter { Enabled -eq $false } -Properties Name, DistinguishedName, SID, modifyTimeStamp

    # Stwórz plik o nazwie "numer indeksu wyłączone konta.csv"
    $filePath = "C:\Logi\raporty\$($indexNumber)_wylaczone_konta.csv"
    $null = New-Item -ItemType File -Path $filePath -Force

    # Dodaj nagłówki do pliku CSV
    Add-Content -Path $filePath -Value "Nazwa konta,DistinguishedName,SID,Data ostatniej modyfikacji"

    # Jeśli są jakieś wyłączone konta:
    if ($disabledAccounts) {
       
        # Dla każdego wyłączonego konta:
        foreach ($account in $disabledAccounts) {
            # Pobierz dane konta
            $userName = $account.Name
            $distinguishedName = $account.DistinguishedName
            $sid = $account.SID
            $lastModified = $account.modifyTimeStamp

            # Dodaj dane do pliku CSV
            Add-Content -Path $filePath -Value "$userName,$distinguishedName,$sid,$lastModified"
        }
    }
    Write-Output "Lista wyłączonych użytkowników została pomyślnie utworzona."
}

function generateUsersAccountReport {
    # Pobierz wszystkich użytkowników z AD
    $users = Get-ADUser -Filter * -Properties GivenName, Surname, UserPrincipalName, SamAccountName, DistinguishedName, whenCreated, modifyTimeStamp, LastLogonDate, PasswordLastSet

    # Stwórz plik o nazwie "numer indeksu użytkownicy.csv"
    $filePath = "C:\Logi\raporty\$($indexNumber)_uzytkownicy.csv"
    $null = New-Item -ItemType File -Path $filePath -Force
    # Jeśli są jacyś użytkownicy:
    if ($users) {

        # Dla każdego użytkownika:
        foreach ($user in $users) {
            # Pobierz dane użytkownika
            $firstName = $user.GivenName
            $lastName = $user.Surname
            $login = $user.UserPrincipalName
            $samAccount = $user.SamAccountName
            $location = $user.DistinguishedName
            $created = $user.whenCreated
            $lastModified = $user.modifyTimeStamp
            $lastLogon = $user.lastLogonDate
            $pwdLastSet = $user.PasswordLastSet
            # Dodaj dane do pliku CSV

            $entry = [pscustomobject]@{
                "Imie"                                  = $firstName
                "Nazwisko"                              = $lastName
                "Login (UPN)"                           = $login
                "Samaccount"                            = $samAccount
                "Lokalizacja"                           = $location
                "Data utworzenia"                       = $created
                "Data ostatniej modyfikacji"            = $lastModified
                "Data ostatniego logowania"             = $lastLogon
                "Data ostatniej zmiany hasla na koncie" = $pwdLastSet
            }
            # Dodanie usera do csv
            $entry | Export-Csv $filePath -Append -NoTypeInformation 
        }
    }
    Write-Output "Lista kont użytkowników została pomyślnie utworzona."
}

function getComputersInfo {
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

        $filePath = "C:\Logi\raporty\$($indexNumber)_$($domainName)_$($operatingSystemNWS).csv"
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

            $filePath = "C:\Logi\raporty\$($indexNumber)_$($domainName)_$($operatingSystemNWS).csv"
    
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

function getDomainOUs {
        
    # Pobierz  domene
    $domain = (Get-WmiObject -Class Win32_ComputerSystem).Domain

    # Pobierz nazwe obiektu klasy ADDomain
    $domainName = (Get-ADDomain -Identity $domain).DistinguishedName

    $OUs = Get-ADOrganizationalUnit -Filter * -SearchBase $domainName | Sort-Object -Property DistinguishedName
    $filePath = "C:\Logi\raporty\$($indexNumber)_OS.csv"
    $null = New-Item -ItemType File -Path $filePath -Force
  
    
    $OUs | Select-Object Name, DistinguishedName | Export-Csv -Path $filePath -NoTypeInformation
    
    Write-Output "Lista jednostek organizacyjnych została pomyślnie utworzona."
}

function createUserTest {
    try {
        createUser
        Write-Host "Pomyślnie utworzono użytkownika"
    }
    catch {
        Write-Host "Wystąpił błąd podczas dodawania użytkownika."
    }
}

function createUsersFromCsvTest {
    try {
        createUsersFromCsv
        Write-Host "Pomyślnie utworzono użytkowników"
    }
    catch {
        Write-Host "Wystąpił błąd podczas dodawania użytkowników."
    }
}

function disableAccountTest {
    try {
        disableAccount
        Write-Host "Pomyślnie wyłączono konto"
    }
    catch {
        Write-Host "Wystąpił błąd podczas wyłączania konta."
    }
}


############----MENU----############

function showMainMenu {
    param (
        [string]$Title = 'MENU GŁÓWNE'
    )
    Clear-Host
    Write-Host $author
    Write-Host $header
    Write-Host 
    Write-Host "================ $Title ================"
    
    Write-Host "1: Obsługa kont użytkowników"
    Write-Host "2: Obsługa kont grup"
    Write-Host "3: Raporty"
    Write-Host "Q: Wyjdź"
}

function showUserMenu {
    param (
        [string]$Title = 'Obsługa kont użytkowników'
    )
    Clear-Host
    Write-Host $author
    Write-Host $header
    Write-Host 
    Write-Host "================ $Title ================"
    
    Write-Host "1: Tworzenie konta użytkowanika"
    Write-Host "2: Tworzenie wielu kont na podstawie pliku csv"
    Write-Host "3: Wyłączenie konta użytkownika"
    Write-Host "4: Zmiana hasła konta użytkownika" 
    Write-Host "B: Cofnij"
    Write-Host "Q: Wyjdź"
}

function showGroupMenu {
    param (
        [string]$Title = 'Obsługa kont grup'
    )
    Clear-Host
    Write-Host $author
    Write-Host $header
    Write-Host 
    Write-Host "================ $Title ================"
    
    Write-Host "1: Tworzenie nowych grup"
    Write-Host "2: Dodawanie użytkowników do grup"
    Write-Host "B: Cofnij" 
    Write-Host "Q: Wyjdź"
}

function showRaportMenu {
    param (
        [string]$Title = 'Raporty'
    )
    Clear-Host
    Write-Host $author
    Write-Host $header
    Write-Host 
    Write-Host "================ $Title ================"
    
    Write-Host "1: Lista grup z członkami"
    Write-Host "2: Lista wyłączonych kont w domenie"
    Write-Host "3: Lista szczegółowych informacji o kontach użytkowników" 
    Write-Host "4: Lista szczegółowych informacji o kontach komputerów w domenie" 
    Write-Host "5: Lista jednostek organizacyjnych w domenie" 
    Write-Host "B: Cofnij" 
    Write-Host "Q: Wyjdź"
}

function showUserMenuCases {
    do {
        showUserMenu -NoExit
        $selection = Read-Host "Twój wybór"
        switch ($selection) {
            '1' { createUserTest }
            '2' { createUsersFromCsvTest }
            '3' { disableAccountTest }
            '4' { changePassword }
            'b' { return showMainMenu } 
            'q' { break outer }
        }
        pause
    }
    until ($selection -eq 'q')
    
}

function showGroupMenuCases {
    do {
        showGroupMenu
        $selection = Read-Host "Twój wybór"
        switch ($selection) {
            '1' { createGroup }
            '2' { addUserToGroup }
            'b' { return showMainMenu } 
            'q' { break outer }
        }
        pause
    }
    until ($selection -eq 'q')
    
}
function showRaportMenuCases {
    do {
        showRaportMenu
        $selection = Read-Host "Twój wybór"
        switch ($selection) {
            '1' { generateGroupReport }
            '2' { generateDisabledAccountReport }
            '3' { generateUsersAccountReport }
            '4' { getComputersInfo }
            '5' { getDomainOUs }
            'b' { return showMainMenu } 
            'q' { break outer }
        }
        pause
    }
    until ($selection -eq 'q')
    
}

:outer do {
    showMainMenu
    $selection = Read-Host "Twój wybór"
    switch ($selection) {
        '1' { showUserMenuCases } 
        '2' { showGroupMenuCases }
        '3' { showRaportMenuCases }
        'q' { break outer }
    }
    pause
}
until ($selection -eq 'q')