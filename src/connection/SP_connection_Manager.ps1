function connectToSite($srcSite, $credential, $stored_credential) {

    if (!$srcSite) {
        $srcSite = Read-Host -Prompt 'Please type the sharepoint target site URL';
    }

    if ($stored_credential) {
        $credential = $(Get-StoredCredential -Target $stored_credential);
    }
    if (!$credential) {
        Write-Host "Credentials were not provided. Prompting now..."
        $credential = Get-Credential;      
    }
    try {
        Write-Host "Credentials ready.Trying to connect...."; #connect to Source Site
        $connectionSrc = Connect-PnPOnline -Url $srcSite -Credentials $credential;
        $connectSourceSite = Get-PnPWeb;
        if ($connectSourceSite ) {
            $connectSourceSite = Get-PnPWeb;
            $connectSourceSiteContext = Get-PnPConnection;
    
            if ($connectSourceSite -and $connectSourceSiteContext ) {
                Write-Host $("----`nConnection established with {0}" -f $srcSite);
                return @{   "siteContext" = $connectSourceSiteContext;
                    "siteWeb"             = $connectSourceSite;
                    "siteTitle"           = $connectSourceSite.Title;
                    "siteTitleFormated"   = $connectSourceSite.Title.Replace(" ", "_")
                }
            }                   
        }
        else {
            throw "There has been an error trying to connect Source to '$srcSite'";
        } 
    }
    catch {
        Write-Host @("There has been an error trying to connect to '{1}'.`nError details: {0}" -f ($_.Exception.Message), $srcSite);
    }    
}
