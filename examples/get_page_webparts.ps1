
Import-Module -Force $PSScriptRoot\..\src\resources\SP_tools.psm1;
Import-Module -Force $PSScriptRoot\..\src\connection\SP_connection_Manager.psm1;

Write-Host $("`nMSG: script Started----`n");

#checkModules;
$source_site="";  ## feel free to to prefill this var with the target URL if needed.
$site1_connection = connectToSite -srcSite $source_site -stored_credential spPremises;
$page_webparts= getWebParts -page_url # [add ur relative URL]
$page_webparts
Write-Host $("`n----MSG: script Ended: `n");

