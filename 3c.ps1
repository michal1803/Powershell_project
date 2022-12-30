$indexNumber = "18852"

function generateUsersAccountReport {
    # Pobierz wszystkich użytkowników z AD
    $users = Get-ADUser -Filter * -Properties GivenName, Surname, UserPrincipalName, SamAccountName, DistinguishedName, whenCreated, modifyTimeStamp, LastLogonDate, PasswordLastSet

    # Stwórz plik o nazwie "numer indeksu użytkownicy.csv"
    $filePath = "C:\Logi\$($indexNumber)_uzytkownicy.csv"
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