
Import-Module -Force $PSScriptRoot\..\src\resources\SP_tools.psm1;
Import-Module -Force $PSScriptRoot\..\src\connection\SP_connection_Manager.psm1;


Write-Host $("`nMSG: script Started----`n");

checkModules;
$sourceSite="";  ## feel free to to prefill this var with the target URL if needed.
$site1Connection = connectToSite -srcSite $sourceSite -stored_credential spPremises;

Write-Host $("`n----MSG: script Ended: `n");
