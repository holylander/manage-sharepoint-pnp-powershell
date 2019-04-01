
#import certain modules
. ($PSScriptRoot + "\..\src\pnp-powershell\SP_connection_Manager.ps1");


#Write-Host $("`nMSG: script Started: `n----");

$sourceSite=$false;  ## feel free to to prefill this var with the target URL if needed.
$site1Connection = connectToSite -srcSite $sourceSite -stored_credential spPremises;

#Write-Host $("----`nMSG: script Ended: `n");
