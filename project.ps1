############################-------------AZ1 PROJEKT ZALICZENIOWY POWERSHELL--------------############################
############################----------------MICHAŁ WĄSIK 18852 IZ07TC1----------------############################

########-----MENU-----########

$title = "##############-------------AZ1 PROJEKT ZALICZENIOWY POWERSHELL-------------##############"
$author = "##############-------------MICHAL WASIK 18852 IZ07TC1-------------##############"


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