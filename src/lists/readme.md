# LIBRARY DETAILS

This module exports a collection of functions for dealing with list items,  publishing pages, and publishing pages webparts in Sharepoint. To be documented...
Almost any functions needs to work with a *site connection context* object, which can be queried using the [connection module](../connection/SP_connection_Manager.psm1)

## FUNCTIONS

- **getListItems**: returns an object that contains:
  - items = query returned items
  - fields = array with the fields that were queried
  - total : total sum of returned items
  - list_name:  list name that was requested
- **copyListsItems:** copy list items from a SP list to another, based on a definition of columns to be used.
  - returns an object that reports which items where succesfully copied and which returned errors
- **updateListsItem:** modify one or more SP list items, based on a static change or a result of data handler function.
- **copyPublishingItems:**  copies publishing page items along with its webparts. Tip: use filtering options when selecting which pages you would like to copy.
  - *note*: Webparts declaration will only be copied to the *publishingPageContent* column
  - returns an object that reports which items where succesfully copied and which returned errors


### NOTES

- Sometimes you need to access the values thru the FieldValues property, others you should use the ID value ( lookup column case ).
- Because of this reason, it is recommended that you first peek in the list item structure using the getlistItems, or the getListFields function.

### HANDLER FUNCTION EXAMPLES

```
function transformation($item,$itemCollection ){
        return @{"MDDLinkUrl"="$($item.FieldValues.MDDLinkUrl.Url.replace('original string','new string')),$($item.FieldValues.MDDLinkUrl.Description)"};        
    }
```

```
function transformation($item,$itemCollection ){
        $genericTempVar=[Collections.Generic.List[Object]]$itemCollection;
        $total = $itemCollection.count;
        $divider=[int]$itemCollection.count/2;
        $currentPosition=$genericTempVar.findIndex({$args.Id -eq $item.Id});
        
        switch ($currentPosition){
            {$_ -lt $divider}{
                $position = (($currentPosition ) * 2)+1;
            
            }
            {$_ -ge $divider}{
                $position = (($currentPosition-$divider ) * 2)+2;
            }
            default{
                $position=0;       
            }
        }
        return @{"MDDPosition"=$position};
```

### FUTURE TODOs

- add feature: copy wiki pages
- feature: copy wiki pages webparts
- feature: copy files and folders
- apply regex where needed
