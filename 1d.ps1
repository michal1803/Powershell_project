$indexNumber = "18852"

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
    } else {
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