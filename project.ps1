############################-------------AZ1 PROJEKT ZALICZENIOWY POWERSHELL--------------############################
############################----------------MICHAŁ WĄSIK 18852 IZ07TC1----------------############################

########-----MENU-----########

$title = "##############-------------AZ1 PROJEKT ZALICZENIOWY POWERSHELL-------------##############"
$author = "##############-------------MICHAL WASIK 18852 IZ07TC1-------------##############"
$indexNumber = "18852"

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
    New-ADUser -Name $($adName) -SamAccountName $login -UserPrincipalName "$login@$domain" -Department $Department -Email $email -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -Enabled $true

    # Zapisywanie informacji o loginie i haśle do pliku CSV
    $data = [pscustomobject]@{
        "Login"    = $login
        "Password" = $password
    }
    $dataFilePath = "C:\Logi\$($indexNumber)_$($Name)_$($Surname)_$($i).csv"
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
    $entryFilePath = "C:\Logi\$($indexNumber)_create_user.csv"

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

    $logFilePath = "C:\Logi\$($indexNumber)_create_user.csv"
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
        $dataFilePath = "C:\Logi\$($indexNumber)_$($Name)_$($Surname)_$($i).csv"
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
        $entryFilePath = "C:\Logi\$($indexNumber)_create_user.csv"

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



    $plik = "C:\Logi\$($indexNumber)_wylaczone_konta_$($timestamp).txt"
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

    $plik = "C:\Logi\$($indexNumber)_zmiana_hasla_$($timestamp).txt"
    # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
    if (-not (Test-Path $plik)) {
        $null = New-Item -ItemType File -Path $plik -Force
    }

    # Zapisz informacje o wyłączeniu konta do pliku log
    Add-Content -Path $plik -Value "Użytkownik $env:USERNAME zmienil haslo dla konta $login na $password o godzinie $timestamp"

}

function createUserTest {
    try {
        createUser
        Write-Host "Pomyślnie utworzono użytkownika"
        break outer
    }
    catch {
        Write-Host "Wystąpił błąd podczas dodawania użytkownika."
    }
}

function createUsersFromCsvTest {
    try {
        createUsersFromCsv
        Write-Host "Pomyślnie utworzono użytkowników"
        break outer
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
    Write-Host "================ $Title ================"
    
    Write-Host "1: Tworzenie nowych grup"
    Write-Host "2: Dodawania użytkowników do grup"
    Write-Host "B: Cofnij" 
    Write-Host "Q: Wyjdź"
}

function showRaportMenu {
    param (
        [string]$Title = 'Raporty'
    )
    Clear-Host
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
