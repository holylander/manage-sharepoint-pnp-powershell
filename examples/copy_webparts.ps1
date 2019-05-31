
Import-Module -Force $PSScriptRoot\..\src\resources\SP_tools.psm1;
Import-Module -Force $PSScriptRoot\..\src\connection\SP_connection_Manager.psm1;

Write-Host $("`nMSG: script Started----`n");

checkModules;
$source_site="";  ## feel free to to prefill this var with the target URL if needed.
$site1_connection = connectToSite -srcSite $source_site -stored_credential spPremises;

##For copying publishing pages, you need to provide at least ID and FileLeafRef
$fields="ID","Title","FileRef","FileLeafRef","PublishingPageContent"
$list_name="Pages"  # feel free to to prefill this var with the target list name if needed.

# get a source and target page items:
$filter= {$_.FieldValues.ID -eq 7}#"" ##   # Filter example: {$_.FieldValues.ID -eq 5}
$src_page= getListItems -site $site1_connection -fields $fields -list_name $list_name -filter $filter
$filter= {$_.FieldValues.ID -eq 8}#"" ##   # Filter example: {$_.FieldValues.ID -eq 5}
$target_page= getListItems -site $site1_connection -fields $fields -list_name $list_name -filter $filter

# copy webparts and get the HTML needed that will render this webparts.
$new_webparts=copyWebParts -src_item $($src_page.items) -target_url $($target_page.items.FieldValues.FileRef)
$target_html_with_new_webparts=$($target_page.items.FieldValues.PublishingPageContent)+$new_webparts

# update target page(s) with webparts code
$changes=@{"PublishingPageContent" = $target_html_with_new_webparts}
$update_result=updateListsItem -site $site1_connection -item $($target_page.items) -list_name $list_name -changes $changes



Write-Host $("`n----MSG: script Ended: `n");

