# PS1_Create_Office365_DNS
Creates Microsoft 365 DNS records required for a given domain and outputs to text file formatted for easy copy.

Powershell script that will prompt for a domain, do some basic regex on the input and then create a text file in the directory the script is executed from.
If you enter a domain, it will replace the dots with dashes. 

Example output using example.com:

DNS Records for example.com
Generated on 03-07-2025 17:02:44

##MX Record##
MX
example-com.mail.protection.outlook.com
1 Hour TTL

##Autodiscover##
CNAME
autodiscover
autodiscover.outlook.com
1 Hour TTL
ping autodiscover.example.com

##SPF##
TXT
v=spf1 include:spf.protection.outlook.com -all
1 Hour TTL

##Intune##
CNAME
enterpriseregistration
enterpriseregistration.windows.net

enterpriseenrollment
enterpriseenrollment-s.manage.microsoft.com
1 Hour TTL

##DKIM##
CNAME
selector1._domainkey
selector1-example-com._domainkey.icdb.p-v1.dkim.mail.microsoft

selector2._domainkey
selector2-example-com._domainkey.icdb.p-v1.dkim.mail.microsoft
1 Hour TTL

