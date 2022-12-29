$indexNumber = "18852"
function disableAccount {
    param (
        [Parameter(Mandatory = $true)]
        [string]$login
    )

    # Pobierz aktualną datę i godzinę
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH.mm.ss"

    # Wyłącz konto użytkownika
    Disable-ADAccount -Identity $login



    $plik = "C:\Logi\$($indexNumber)_wyłączone_konta_$($timestamp).txt"
    # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
    if (-not (Test-Path $plik)) {
        $null = New-Item -ItemType File -Path $plik -Force
    }

    # Zapisz informacje o wyłączeniu konta do pliku log
    Add-Content -Path $plik -Value "Użytkownik $env:USERNAME wyłączył konto $login o godzinie $timestamp"
}