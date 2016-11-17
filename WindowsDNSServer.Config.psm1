﻿configuration WindowsDNSServer
{
    <#
        .DESCRIPTION
        Basic configuration for Windows DNS Server

        .EXAMPLE
        WindowsDNSServer -outpath c:\dsc\

        .NOTES
        This is the most basic configuration and does not take parameters or configdata
    #>

    Import-DscResource -module 'xDnsServer','xNetworking', 'PSDesiredStateConfiguration'
    
    Node $AllNodes.Where{$_.Role -eq 'DNSServer'}.NodeName
    {
        # WindowsOptionalFeature is compatible with the Nano Server installation option
        WindowsOptionalFeature DNS
        {
            Ensure  = 'Present'
            Name    = 'DNS-Server-Full-Role'
        }

        xDnsServerPrimaryZone Contoso
        {
            Ensure    = 'Present'                
            Name      = 'Contoso.com'
            DependsOn = '[WindowsFeature]DNS'
        }
            
        xDnsRecord ServerOne
        {
            Ensure    = 'Present'
            Name      = 'ServerOne'
            Zone      = 'Contoso.com'
            Type      = 'ARecord'
            Target    = '10.0.0.5'
            DependsOn = '[WindowsFeature]DNS'
        }

        xDnsRecord WWW
        {
            Ensure    = 'Present'
            Name      = 'WWW'
            Zone      = 'Contoso.com'
            Type      = 'CName'
            Target    = 'ServerOne'
            DependsOn = '[WindowsFeature]DNS'
        }
    }
}
