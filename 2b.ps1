$indexNumber = "18852"
function addUserToGroup {
    param (
        [Parameter(Mandatory = $true)]
        [string]$groupName,
        [Parameter(Mandatory = $true)]
        [string]$userName
    )
try{
    # Pobierz obiekt użytkownika z AD
    $user = Get-ADUser -Identity $userName -ErrorAction SilentlyContinue

    # Pobierz obiekt grupy z AD
    $group = Get-ADGroup -Identity $groupName -ErrorAction SilentlyContinue
}catch{
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

    $plik = "C:\Logi\$($indexNumber)_zmiana_członkostwa_grup.txt"
    # Sprawdzanie czy dana ścieżka istnieje, jeśli nie, utworzy ją
    if (-not (Test-Path $plik)) {
        $null = New-Item -ItemType File -Path $plik -Force
    }

    # Zapisywanie informacji o zmianie członkostwa grupy do pliku
    Add-Content -Path $plik -Value "$env:USERNAME dodał użytkownika $userName do grupy $groupName o godzinie $currentDate"
}