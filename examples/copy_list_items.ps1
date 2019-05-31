
Import-Module -Force $PSScriptRoot\..\src\resources\SP_tools.psm1;
Import-Module -Force $PSScriptRoot\..\src\connection\SP_connection_Manager.psm1;
Import-Module -Force $PSScriptRoot\..\src\lists\SP_listItems.psm1;

Write-Host $("`nMSG: script Started----`n");

checkModules;
$source_site="";  ## feel free to to prefill this var with the target URL if needed.
$site1_connection = connectToSite -srcSite $source_site -stored_credential [stored_credential]

$fields="ID","Title","owner","usedBy"
$list_name=""  # feel free to to prefill this var with the target list name if needed.
$filter=$null  # Filter example: {$_.FieldValues.ID -eq 5} 
$list_items= getListItems -site $site1_connection -fields $fields -list_name $list_name -filter $filter

$target_site=$source_site
$site2_connection = connectToSite -srcSite $target_site -stored_credential [stored_credential]
$list_name="" 
$copy_result=copyListsItems -site $site2_connection -item_Collection $list_items -list_name $list_name

Write-Host $("`n----MSG: script Ended: `n");