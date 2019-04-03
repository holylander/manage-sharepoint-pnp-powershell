function getListItems() {
    param( 
        [System.Collections.Hashtable] $site, ## need to provide the $site object returned by the SP_connection_manager
        [System.Array]$fields,
        [string]$list_name,
        [System.Management.Automation.ScriptBlock]$filter      ## Filter example: {$_.FieldValues.Category -eq 'home'} 
    )
    
    if (!$list_name) {
        $list_name = [String]$(Read-Host -Prompt 'Please type the sharepoint TARGET list name')
    }

    try {
        Write-Host @("Trying to retrieve items from list: '{0}', site: '{1}' " -f $list_name, $site.siteTitleFormated)  
        if ($filter) {
            Write-Host @("- Filtering items where: '{0}' " -f $filter)  
            $returned_items = Get-PnPListItem -ErrorAction Stop -Connection $site.siteContext -List $list_name -Fields $fields | Where-Object $filter;
        }
        else {
            $returned_items = Get-PnPListItem -ErrorAction Stop -Connection $site.siteContext -List $list_name -Fields $fields ;
        }
        
        Write-Host @('OK: {0} item(s) were returned' -f $returned_items.Length)  
        return @{
            "items"     = $returned_items;
            "fields"    = if ($fields) { $fields } else { "All in item content type" };
            "total"     = $returned_items.count
            "list_name" = $list_name;
        };
    }
    catch {
        Write-Host ("There has been an error trying to retrive the items from list '{1}'.`nError details: {0} " -f ($_.Exception.Message, $list_name))
        #Throw ("Could not retrieve any item from site: [{0}] | list: [$srcListName]." -f $site.siteTitleFormated);
    }
   
}

function copyListsItems( ) {
    param( 
        [System.Collections.Hashtable] $item_Collection, ## need to provide a collection object returned by getListItems
        [System.Collections.Hashtable] $site, ## need to provide the $site object returned by the SP_connection_manager
        [System.Array]$fields, # if empty, use the fields provided in the item_Collection
        [string]$list_name        
    )
    try {
        if ($itemCollection.total -le 0 ) {
            throw 'FAIL: There are no items no be copied.';
        }
    
        if ($fields -and ($($fields.count) -ne $($item_Collection.fields.count) )) {
            throw 'FAIL: number of target and source fields differ.';
        }
        else {
            $fields = $item_Collection.fields 
        }
        $copy_confirm = Read-Host "Would you like to copy these ($($item_Collection.total)) items to '$list_name', on site '$($site.siteTitleFormated)' ? (y/n)?";
        
        # loop until answer is given.
        while ($copy_confirm -ne "y") {
            if ($copy_confirm -eq 'n') { exit }
            $copy_confirm = Read-Host "Ready? [y/n]"
        }
        
        #Create the arrays that will hold the info of the items than returned error, and the successful actions as well    
        $items_copied_ok = @{"items" = @(); "total" = 0 };
        $items_copy_fail = @{"items" = @(); "total" = 0 };
        
        # create the data structure that will be copied into the item        
        $item_Collection.items | ForEach-Object {    
            $item = $_
            $item_Collection.fields | ForEach-Object {
                $field_name = $_ 
                ## in case there is any value to copy                
                if ($item.FieldValues[$field_name] ) {
                    # do not copy ID fields neither lookup fields (these last one need a specialproccess, must be converted to STRING)
                    if ( ($field_name -notin 'ID', 'Id') -and ($item.FieldValues[$field_name].getType().BaseType.Name -notlike "*Lookup*" ) ) {      
                        $item_values += @{"$_" = $item.FieldValues[$field_name] };
                    }
                    else {
                        #special Author / editor case, must be converted to STRING
                        if ($field_name -in "Author", "Editor" ) {                            
                            $item_values += @{"$field_name" = [string]$item.FieldValues[$field_name].LookupValue };    
                        }
                        #this is another type of lookup column
                        else {                        
                            $itemValues += @{"$field_name" = [string]$itemIterator.FieldValues[$field_name].LookupId };    
                        }                        
                    }                
                }
                ## otherwise, use some empty valye
                else {
                    $item_values += @{"$field_name" = $null }; # ""
                }
            }
    
            #try to save the item on target list
            $new_list_item = Add-PnPListItem -ErrorAction Inquire -Connection $site.siteContext -List $list_name -Values $item_values;           
            if ($new_list_item) {
                Write-Host "New item ($($new_list_item.Id)) was saved in to list: '$list_name', on site: '$($site.siteTitleFormated)'. Source item '$($item.FieldValues.GetEnumerator()  | Select-Object -first 1 key)': '$($itemIterator.FieldValues.GetEnumerator()  | Select-Object -first 1 value)'.";        
                $items_copied_ok.items += @{"copy_ok-$($newListItem.Id)" = $itemIterator.FieldValues };
                $items_copied_ok.total += 1;
            }
            else {
                Write-Host "Item '$($itemIterator.FieldValues.GetEnumerator()  | Select-Object -first 1 key)': '$($itemIterator.FieldValues.GetEnumerator()  | Select-Object -first 1 value)' was not copied. "; 
                $items_copy_fail.items += @{'copy_error' = $itemIterator.FieldValues };
                $items_copy_fail.total += 1;
            }
            ##TODO: non blocking / async execution
            ##TODO: take attachments
            ##TODO: take security

            Remove-Variable $item_values;
        }; 
        return @($items_copied_ok, $items_copy_fail)
    }
    catch {
        Write-Host @("There has been an error trying to copy items to '{1}'.`nError details: {0}" -f ($_.Exception.Message), $site.siteTitleFormated);
    } 


    Export-ModuleMember -Function getListItems, copyListsItems;