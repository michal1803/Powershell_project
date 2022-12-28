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
        [string]$global:Name,
        [Parameter(Mandatory = $true)]
        [string]$global:Surname,
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
    try {
        while (Get-ADUser $login) {
            $login = $Name + "." + $Surname + $i
            $adName = "$($Name) $($Surname) $($i)"
            $i++
        }
    }
    catch {}

    # Generowanie adresu e-mail na podstawie imienia, nazwiska i domeny
    $email = "$login@$domain"

    # Generowanie hasła
    $password = '' 

    1..12 | ForEach-Object { 

        $password += [char](Get-Random -Minimum 48 -Maximum 122) 
    }
    # Tworzenie konta użytkownika
    New-ADUser -Name $adName -SamAccountName $login -UserPrincipalName "$login@$domain" -Department $Department -Email $email -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -Enabled $true

    # Zapisywanie informacji o loginie i haśle do pliku CSV
    $data = [pscustomobject]@{
        "Name"     = $Name
        "Surname"  = $Surname
        "Login"    = $login
        "Password" = $password
        "Email"    = $email
    }
    $dataFilePath = "C:\Logi\$($indexNumber)_$($Name)_$($Surname).csv"
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
        "Action"    = "Created user $Name $Surname with login $login and password $password"
    }
    $entryFilePath = "C:\Logi\$($indexNumber)_create_user.csv"

    # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
    if (-not (Test-Path $entryFilePath)) {
        $null = New-Item -ItemType File -Path $entryFilePath -Force
    }
    $entry | Export-Csv $entryFilePath -Append -NoTypeInformation 
}
############----MENU----############
function createUserTest {
    try {
        createUser
        Write-Host "Pomyślnie utworzono użytkownika $($Name) $($Surname)"
        break outer
    }
    catch {
        Write-Host "Wystąpił błąd podczas wykonywania funkcji."
    }
}
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
        showUserMenu
        $selection = Read-Host "Twój wybór"
        switch ($selection) {
            '1' { createUser }
            'b' { showMainMenu } 
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
            'b' { showMainMenu } 
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
            'b' { showMainMenu } 
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
