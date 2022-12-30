$indexNumber = "18852"
function generateGroupReport {
    # Pobierz wszystkie grupy z AD
    $groups = Get-ADGroup -Filter *

    # Dla każdej grupy:
    foreach ($group in $groups) {
        # Pobierz nazwę grupy
        $groupName = $group.Name

        # Pobierz członków grupy
        $members = Get-ADGroupMember -Identity $groupName

        # Jeśli grupa ma członków:
        if ($members) {

            $filePath = "C:\Logi\$($indexNumber)_$($groupName).txt"
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