
<#PSScriptInfo

.VERSION 0.1.0

.GUID 2d1436b4-b53a-42ea-80d6-8495742fdede

.AUTHOR Michael Greene

.COMPANYNAME Microsoft Corporation

.COPYRIGHT 

.TAGS DSCConfiguration

.LICENSEURI https://github.com/Microsoft/WindowsDNSServerConfig/blob/master/LICENSE

.PROJECTURI https://github.com/Microsoft/WindowsDNSServerConfig

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
https://github.com/Microsoft/WindowsDNSServerConfig/blob/master/README.md##releasenotes

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module xDNSServer

<# 

.DESCRIPTION 
 This module contains PowerShell Desired State Configuration solutions for deploying and configuring DNS Servers 

#> 
Param()

configuration WindowsDNSServerConfig
{
    <#
        .DESCRIPTION
        Basic configuration for Windows DNS Server with zones and records

        .EXAMPLE
        WindowsDNSServer -outpath c:\dsc\

        .NOTES
        This configuration requires the corresponding configdata file
    #>

    Import-DscResource -module 'xDnsServer','PSDesiredStateConfiguration'
    
    Node $AllNodes.NodeName
    {
        # WindowsOptionalFeature is compatible with the Nano Server installation option
        WindowsOptionalFeature DNS
        {
            Ensure  = 'Enable'
            Name    = 'DNS-Server-Full-Role'
        }
        
        foreach ($Zone in $Node.ZoneData)
        {
            xDnsServerPrimaryZone $Zone.PrimaryZone
            {
                Ensure    = 'Present'                
                Name      = $Zone.PrimaryZone
                DependsOn = '[WindowsOptionalFeature]DNS'
            }

            foreach ($ARecord in $Zone.ARecords.Keys)
            {
                xDnsRecord "$($Zone.PrimaryZone)_$ARecord"
                {
                    Ensure    = 'Present'
                    Name      = $ARecord
                    Zone      = $Zone.PrimaryZone
                    Type      = 'ARecord'
                    Target    = $Zone.ARecords[$ARecord]
                    DependsOn = "[WindowsOptionalFeature]DNS","[xDnsServerPrimaryZone]$($Zone.PrimaryZone)"
                }        
            }

            foreach ($CNameRecord in $Zone.CNameRecords.Keys)
            {
                xDnsRecord "$($Zone.PrimaryZone)_$CNameRecord"
                {
                    Ensure    = 'Present'
                    Name      = $CNameRecord
                    Zone      = $Zone.PrimaryZone
                    Type      = 'CName'
                    Target    = $Zone.CNameRecords[$CNameRecord]
                    DependsOn = "[WindowsOptionalFeature]DNS","[xDnsServerPrimaryZone]$($Zone.PrimaryZone)"
                }        
            }
        }
    }
}