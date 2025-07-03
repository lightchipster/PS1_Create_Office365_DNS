Function GetDomainName{
    $domain = Read-Host "Please enter a domain name"
    $urlpattern ="^((?!-))(xn--)?[a-z0-9][a-z0-9-_]{0,61}[a-z0-9]{0,1}\.(xn--)?([a-z0-9\-]{1,61}|[a-z0-9-]{1,30}\.[a-z]{2,})$"
    while ($domain -notmatch $urlpattern) {
        Write-Host ""
        Write-Host "The domain does not meet the expected format, please try again. Please only enter the domain not an email address."
        $domain = Read-Host "Please enter a domain name"
    }
    if ($containswwww = $domain.Contains("www")){
        $domain=$domain.substring(4)
    }
    return $domain
}

Function MXRecord{
    param($domain)
    $domaindashed = $domain.Replace(".","-")
    $mailprotection = ".mail.protection.outlook.com"
    $mxdomain = $domaindashed + $mailprotection
    
    $output = @"
##MX Record##
MX
$mxdomain
1 Hour TTL

"@
    return $output
}

Function Autodiscover{
    param($domain)
    $autodiscovername = "autodiscover"
    $autodiscoverms = "autodiscover.outlook.com"
    $autodiscover = $autodiscovername + "." + $domain
    
    $output = @"
##Autodiscover##
CNAME
$autodiscovername
$autodiscoverms
1 Hour TTL
ping $autodiscover

"@
    return $output
}

Function SPF{
    param($domain)
    $spfrecord = "v=spf1 include:spf.protection.outlook.com -all"
    
    $output = @"
##SPF##
TXT
$spfrecord
1 Hour TTL

"@
    return $output
}

Function Intune{
    param($domain)
    $enterpriseregms = "enterpriseregistration.windows.net"
    $enterpriseenrollms = "enterpriseenrollment-s.manage.microsoft.com"
    $enterpriseregname = "enterpriseregistration"
    $enterpriseenrollname = "enterpriseenrollment"
    
    $output = @"
##Intune##
CNAME
$enterpriseregname
$enterpriseregms

$enterpriseenrollname
$enterpriseenrollms
1 Hour TTL

"@
    return $output
}

Function DKIM{
    param($domain)
    $dkimrecordms = "._domainkey.icdb.p-v1.dkim.mail.microsoft"
    $selector1name = "selector1-"
    $selector2name = "selector2-"
    $domaindashed = $domain.Replace(".","-")
    $dkimselector1 = $selector1name + $domaindashed + $dkimrecordms
    $dkimselector2 = $selector2name + $domaindashed + $dkimrecordms
    $dkimcname1ms = "selector1._domainkey"
    $dkimcname2ms = "selector2._domainkey"
    
    $output = @"
##DKIM##
CNAME
$dkimcname1ms
$dkimselector1

$dkimcname2ms
$dkimselector2
1 Hour TTL

"@
    return $output
}

Function CreateDNSFile{
    param($domain, $filepath)
    
    # Create the file content
    $fileContent = @"
DNS Records for $domain
Generated on $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")

$(MXRecord -domain $domain)
$(Autodiscover -domain $domain)
$(SPF -domain $domain)
$(Intune -domain $domain)
$(DKIM -domain $domain)
"@
    
    # Create the file
    $fileName = "$domain.txt"
    $fullPath = Join-Path $filepath $fileName
    
    try {
        $fileContent | Out-File -FilePath $fullPath -Encoding UTF8
        Write-Host "DNS records file created successfully: $fullPath" -ForegroundColor Green
        Write-Host "File contents:"
        Write-Host $fileContent
    }
    catch {
        Write-Host "Error creating file: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Main execution
$filepath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$domain = GetDomainName
CreateDNSFile -domain $domain -filepath $filepath