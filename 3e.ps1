$indexNumber = "18852"


function getDomainOUs {
        
    # Pobierz  domene
    $domain = (Get-WmiObject -Class Win32_ComputerSystem).Domain

    # Pobierz nazwe obiektu klasy ADDomain
    $domainName = (Get-ADDomain -Identity $domain).DistinguishedName

    $OUs = Get-ADOrganizationalUnit -Filter * -SearchBase $domainName | Sort-Object -Property DistinguishedName
    $filePath = "C:\Logi\$($indexNumber)_OS.csv"
    $null = New-Item -ItemType File -Path $filePath -Force
  
    
    $OUs | Select-Object Name, DistinguishedName | Export-Csv -Path $filePath -NoTypeInformation
    
    Write-Output "Lista jednostek organizacyjnych została pomyślnie utworzona."
}