function checkModules () {
    
    if (!$(Get-InstalledModule -Name SharePointPnPPowerShell2013 -ErrorAction SilentlyContinue)) {
        Write-Host "Need to install PnP-powershell for SP2013";
        Install-Module SharePointPnPPowerShell2013 -Scope CurrentUser;
    }
    if (!$(Get-InstalledModule -Name SharePointPnPPowerShell2016 -ErrorAction SilentlyContinue)) {
        Write-Host "Need to install PnP-powershell for SP2016";
        Install-Module SharePointPnPPowerShell2016  -AllowClobber  -Scope CurrentUser;
    }
    if (!$(Get-InstalledModule -Name SharePointPnPPowerShell2019 -ErrorAction SilentlyContinue)) {
        Write-Host "Need to install PnP-powershell for SP2019";
        Install-Module SharePointPnPPowerShell2019  -AllowClobber  -Scope CurrentUser;
    }
    if (!$(Get-InstalledModule -Name SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue)) {
        Write-Host "Need to install PnP-powershell for SPOnline";
        Install-Module SharePointPnPPowerShellOnline  -AllowClobber   -Scope CurrentUser;
    } 

    
}

function getWebParts () {
    param(
        $page_url   ## target url in which you should retrieve items
    )

    $page_webparts = Get-PnPWebPart -ServerRelativePageUrl $page_url
    return $page_webparts
}

function copyWebParts() {
    param (
        $src_url,
        $target_url
    )
    $webparts_id=@()
    $webparts_src=getWebParts -page_url $src_url
    $webparts_on_target_url = getWebParts -page_url $target_url
    ## loop through the webparts that need to be copied, and only copy them if they are not already in the target page
    foreach ($webpart_src in $webparts_src) {
        $webpart_duplicated = $false  

        foreach ($webpart_target in $webparts_on_target_url) {
            if ($webpart_src.WebPart.Title -eq $webpart_targe.WebPart.Title) { 
                $webpart_duplicated = $true
            }
        }
        if (!$webpart_duplicated) {
            $webpart_src_xml=Get-PnPWebPartXml -ServerRelativePageUrl $src_url -Identity $webpart_src.Id.Guid #|  Out-File -filepath $filename;
            Add-PNPWebPartToWebPartPage -ServerRelativePageUrl $target_url -Xml $webpart_src_xml -ZoneId 'wpz' -ZoneIndex $(Get-Random -Maximum 100) ; 
            Write-Host "OK: webpart '$($webpart_src.FieldValues.Title)' has been copied"            
        }
        else {
            Write-Host @("Webpart '", [string]$srcPageWebpartItem.WebPart.Title."' already exists in the target page." );
        }        
    }
}
 
function setWebParts(){
     param (
            $src_url,
            $target_url,
            $item,
            $include_wp_columns
        )
      $webparts_src= getWebParts -page_url $src_url
      $webparts_target=getWebParts -page_url $target_url

}

function generateItemValues () {
    param(
        [array]$fields,
        $item
    )
    $fields | ForEach-Object {
        $field_name = $_ 
        # should not copy ID,it is unique
        if ($field_name -notin 'ID', 'Id', 'FileLeafRef') {
            ## in case there is any value to copy                
            if ($item.FieldValues[$field_name] ) {
                if ( $item.FieldValues[$field_name].getType().BaseType.Name -like "*Lookup*" ) {      
                    if ($field_name -in "Author", "Editor" ) {                            
                        $item_values += @{"$field_name" = [string]$item.FieldValues[$field_name].LookupValue };    
                    }
                    #this is another type of lookup column
                    else {                        
                        $itemValues += @{"$field_name" = [string]$itemIterator.FieldValues[$field_name].LookupId };    
                    }                        
                }
                else {
                    $item_values += @{"$_" = $item.FieldValues[$field_name] }
                }                                   
            }
            ## otherwise, use some empty valye
            else {
                $item_values += @{"$field_name" = $null }; # ""
            }
        }                
    }
    return $item_values
}

    

Export-ModuleMember -Function checkModules, getWebParts, copyWebParts, setWebParts