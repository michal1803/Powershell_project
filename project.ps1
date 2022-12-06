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
    Write-Host "Q: Wyjście"
}

do
 {
    showMainMenu
    $selection = Read-Host "Twój wybór"
    switch ($selection)
    {
    '1' {'Wybrałeś opcję: Obsługa kont użytkowników'} 
    '2' {'Wybrałeś opcję: Obsługa kont grup'}
    '3' {'Wybrałeś opcję: Raporty'}
    }
    pause
 }
 until ($selection -eq 'q')