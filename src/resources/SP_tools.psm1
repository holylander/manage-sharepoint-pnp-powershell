function checkModules (){
    
    if (!$(Get-InstalledModule -Name SharePointPnPPowerShell2013 -ErrorAction SilentlyContinue)){
        Write-Host "Need to install PnP-powershell for SP2013";
        Install-Module SharePointPnPPowerShell2013 -Scope CurrentUser;
    }
    if(!$(Get-InstalledModule -Name SharePointPnPPowerShell2016 -ErrorAction SilentlyContinue)){
        Write-Host "Need to install PnP-powershell for SP2016";
        Install-Module SharePointPnPPowerShell2016  -AllowClobber  -Scope CurrentUser;
    }
    if(!$(Get-InstalledModule -Name SharePointPnPPowerShell2019 -ErrorAction SilentlyContinue)){
        Write-Host "Need to install PnP-powershell for SP2019";
        Install-Module SharePointPnPPowerShell2019  -AllowClobber  -Scope CurrentUser;
    }
    if(!$(Get-InstalledModule -Name SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue)){
        Write-Host "Need to install PnP-powershell for SPOnline";
        Install-Module SharePointPnPPowerShellOnline  -AllowClobber   -Scope CurrentUser;
    } 

    
}

Export-ModuleMember -Function checkModules;