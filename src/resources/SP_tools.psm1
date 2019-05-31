function checkModules () {
    if (!$(Get-InstalledModule -Name CredentialManager -ErrorAction SilentlyContinue)) {
        Write-Host "Need to install powershell module CredentialManager";
        Install-Module CredentialManager -Scope CurrentUser;
    }
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
        $target_url,
        $src_item
    )
    Write-Host "Trying to copy webparts over..."
    $src_url=$($src_item.FieldValues.FileRef)
    $webparts_id=@()
    $webparts_src=getWebParts -page_url  $src_url
    $webparts_on_target_url = getWebParts -page_url $target_url
    ## loop through the webparts that need to be copied
    foreach ($webpart_src in $webparts_src) {
        $webpart_duplicated = $false  
        
        foreach ($webpart_target in $webparts_on_target_url) {
            #check if webpart is duplicated
            if ($webpart_src.WebPart.Title -eq $webpart_targe.WebPart.Title) { 
                $webpart_duplicated = $true
            }
        }
        #and only copy them if they are not already in the target page
        if (!$webpart_duplicated) {
            $webpart_src_xml=Get-PnPWebPartXml -ServerRelativePageUrl $src_url -Identity $webpart_src.Id.Guid 
            Add-PNPWebPartToWebPartPage -ServerRelativePageUrl $target_url -Xml $webpart_src_xml -ZoneId 'wpz' -ZoneIndex $(Get-Random -Maximum 10000)             
            $webpart_target_xml=Get-PnPWebPartXml -ServerRelativePageUrl $target_url -Identity $webpart_src.WebPart.Title    
            $webpart_target_id=$webpart_target_xml.Substring($webpart_target_xml.IndexOf("View Name=""{")+12)
            $webpart_target_id = $webpart_target_id.Substring(0,$webpart_target_id.IndexOf("}"))

            if ($src_item.FieldValues.PublishingPageContent){
                #lets add the webpart code into the html area
                $new_webpart_code = '<div class="ms-rtestate-read ms-rte-wpbox" contenteditable="false"> <div class="ms-rtestate-notify  ms-rtestate-read {0}" id="div_{0}" unselectable="on"></div><div id="vid_{0}" unselectable="on" style="display: none;"></div></div>' -f $($webpart_target_id.ToLower());
                $src_item.FieldValues.PublishingPageContent+=$new_webpart_code
            }
            Write-Host "OK: webpart '$($webpart_src.WebPart.Title)' has been copied"            
        }
        else {
            Write-Host @("Webpart '"+[string]$webpart_src.WebPart.Title+"' already exists in the target page." );
        }        
    }

    
    return $src_item
}
function generateItemValues () {
    param(
        [array]$fields,
        $item
    )
    $fields | ForEach-Object {
        $field_name = $_ 
        # should not copy ID,it is unique
        if ($field_name -notin 'ID', 'Id', 'FileLeafRef','PublishingPageLayout') {
            ## in case there is any value to copy                
            if ($item.FieldValues[$field_name] ) {
                if ( $item.FieldValues[$field_name].getType().BaseType.Name -like "*Lookup*" ) {      
                    if ($field_name -in "Author", "Editor" ) {                            
                        $item_values += @{"$field_name" = [string]$item.FieldValues[$field_name].LookupValue };    
                    }
                    #this is another type of lookup column
                    else {                        
                        $itemValues += @{"$field_name" = [string]$item.FieldValues[$field_name].LookupId };    
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
function getListFields($site, $list_name) {
    $temp = Get-PnPField -List $list_name -Connection $site.siteContext;
    $temp = $temp | sort Title;
    return $temp;
}
    

Export-ModuleMember -Function checkModules, getWebParts, copyWebParts, generateItemValues, getListFields