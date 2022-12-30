$indexNumber = "18852"

function generateDisabledAccountReport {
    # Pobierz wszystkie wyłączone konta z AD
    $disabledAccounts = Get-ADUser -Filter { Enabled -eq $false } -Properties Name,DistinguishedName, SID, modifyTimeStamp

     # Stwórz plik o nazwie "numer indeksu wyłączone konta.csv"
     $filePath = "C:\Logi\$($indexNumber)_wylaczone_konta.csv"
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

######## NOT DONE
## nie działa last modfied 
