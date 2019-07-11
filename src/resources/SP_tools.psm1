function checkModules () {
    if (!$(Get-InstalledModule -Name CredentialManager -ErrorAction SilentlyContinue)) {
        Write-Host "Need to change the execution policy scope for the current user to unrestricted, in order to import modules."
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
        Write-Host "Need to install powershell module CredentialManager"
        Install-Module CredentialManager -Scope CurrentUser
    }
    if (!$(Get-InstalledModule -Name SharePointPnPPowerShell2013 -ErrorAction SilentlyContinue)) {
        Write-Host "Need to install PnP-powershell for SP2013"
        Install-Module SharePointPnPPowerShell2013 -AllowClobber -Scope CurrentUser
    }
    if (!$(Get-InstalledModule -Name SharePointPnPPowerShell2016 -ErrorAction SilentlyContinue)) {
        Write-Host "Need to install PnP-powershell for SP2016"
        Install-Module SharePointPnPPowerShell2016 -AllowClobber -Scope CurrentUser
    }
    if (!$(Get-InstalledModule -Name SharePointPnPPowerShell2019 -ErrorAction SilentlyContinue)) {
        Write-Host "Need to install PnP-powershell for SP2019"
        Install-Module SharePointPnPPowerShell2019 -AllowClobber -Scope CurrentUser
    }
    if (!$(Get-InstalledModule -Name SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue)) {
        Write-Host "Need to install PnP-powershell for SPOnline"
        Install-Module SharePointPnPPowerShellOnline -AllowClobber -Scope CurrentUser
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
        $target_url,    # target page url
        $src_item       # sp page source item
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
            #get target page new webpart ID, in order to build the required HTML to enable such webpart.
            $webpart_target_id=$webpart_target_xml.Substring($webpart_target_xml.IndexOf("View Name=""{")+12)
            $webpart_target_id = $webpart_target_id.Substring(0,$webpart_target_id.IndexOf("}"))

            $new_webpart_code += '<div class="ms-rtestate-read ms-rte-wpbox" contenteditable="false"> <div class="ms-rtestate-notify  ms-rtestate-read {0}" id="div_{0}" unselectable="on"></div><div id="vid_{0}" unselectable="on" style="display: none"></div></div>' -f $($webpart_target_id.ToLower())

            Write-Host "OK: webpart '$($webpart_src.WebPart.Title)' has been copied"
        }
        else {
            Write-Host @("Webpart '"+[string]$webpart_src.WebPart.Title+"' already exists in the target page." )
        }
    }


    return $new_webpart_code
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
                        $item_values += @{"$field_name" = [string]$item.FieldValues[$field_name].LookupValue }
                    }
                    #this is another type of lookup column
                    else {                        
                        $itemValues += @{"$field_name" = [string]$item.FieldValues[$field_name].LookupId }    
                    }                        
                }
                else {
                    $item_values += @{"$field_name" = $item.FieldValues[$field_name] }
                }
            }
            ## otherwise, use some empty valye
            else {
                $item_values += @{"$field_name" = $null } # ""
            }
        }
    }
    return $item_values
}
function getListFields($site, $list_name) {
    if (!$list_name) {
        $list_name = [String]$(Read-Host -Prompt 'Please type the sharepoint TARGET list name')
    }
    $temp = Get-PnPField -List $list_name -Connection $site.siteContext
    $temp = $temp | sort Title
    return $temp
}

function  addUser {
    param(
        [System.Collections.Hashtable] $site, ## provides the $site object returned by the SP_connection_manager ( site connection context )
        [string]$user  #username to be added
    )
    $site_groups = Get-PnPGroup -Connection $site.siteContext #-web $site1_connection.siteWeb
    Write-Host "Avaiable groups:"
    $site_groups
    while (!$answer) {
        $answer = Read-Host "Please choose a group to which to you would like to add this user ( use group ID)"
        if ($answer -notin $site_groups.Id) {
            Write-Host "Wrong Id, Please retry."
            $answer = $false
        }
    }
    try {
        write-host "Trying to add user..."
        $target_group_name = $($site_groups | Where-Object Id -eq $answer).Title
        Add-PnPUserToGroup -LoginName $user -Identity $target_group_name -Connection $site.siteContext -ErrorAction Stop
        return "User '$user' was added to '$target_group_name' group."
    }
    catch {
        return "ERROR: User '$user' could not be added to '$target_group_name' group."
    }
}
function  removeUser {
    param(
        [System.Collections.Hashtable] $site, ## provides the $site object returned by the SP_connection_manager ( site connection context )
        [string]$user  #username to be added
    )
    $site_groups = Get-PnPGroup -Connection $site.siteContext #-web $site1_connection.siteWeb
    Write-Host "Avaiable groups:"
    $site_groups
    while (!$answer) {
        $answer = Read-Host "Please choose the group from which you would like to remove this user ( use group ID)"
        if ($answer -notin $site_groups.Id) {
            Write-Host "Wrong Id, Please retry."
            $answer = $false
        }
    }
    try {
        write-host "Trying to remove user..."
        $target_group_name = $($site_groups | Where-Object Id -eq $answer).Title

        Remove-PnPUserFromGroup -LoginName $user -Identity $target_group_name -Connection $site.siteContext -ErrorAction Stop
        return "User '$user' was removed to '$target_group_name' group."
    }
    catch {
        return "ERROR: User '$user' could not be remove to '$target_group_name' group."
    }
}

Export-ModuleMember -Function checkModules, getWebParts, copyWebParts, generateItemValues, getListFields,addUser,removeUser