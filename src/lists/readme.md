# LIBRARY DETAILS

A collection of functions for dealing with publishing pages in Sharepoint. To be documented...


## NOTES
- Sometimes you need to access the values thru the FieldValues property, others you should use the ID value ( lookup column case ). 
- Because of this reason, it is recommended that you first peek in the list item structure using the getlistItems function.

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
