
Import-Module -Force $PSScriptRoot\..\src\resources\SP_tools.psm1;
Import-Module -Force $PSScriptRoot\..\src\connection\SP_connection_Manager.psm1;

Write-Host $("`nMSG: script Started----`n");

#checkModules;
$source_site="";  ## feel free to to prefill this var with the target URL if needed.
$source_site="";  ## feel free to to prefill this var with the target URL if needed.

$site1_connection = connectToSite -srcSite $source_site -stored_credential spPremises;

$fields="ID","Title"
$list_name=""  # feel free to to prefill this var with the target list name if needed.
$filter=$null  # Filter example: {$_.FieldValues.ID -eq 5}

$list_items= getListFields -site $site1_connection -list_name $list_name
$list_items | select Title, InternalName, StaticName | Sort Title


Write-Host $("`n----MSG: script Ended: `n");