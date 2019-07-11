
Import-Module -Force $PSScriptRoot\..\src\resources\SP_tools.psm1;
Import-Module -Force $PSScriptRoot\..\src\connection\SP_connection_Manager.psm1;


Write-Host $("`nMSG: script Started----`n");

checkModules;
$source_site="";  ## feel free to to prefill this var with the target URL if needed.
$site1_connection = connectToSite -srcSite $source_site -stored_credential spOnline;

Get-PnPCustomAction -Connection $site1_connection.siteContext -Scope All

Write-Host $("`n----MSG: script Ended: `n");
