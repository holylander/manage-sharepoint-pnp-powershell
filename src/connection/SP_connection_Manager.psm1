

function connectToSite() {
    param( 
        [System.Management.Automation.PSCredential] $credential,
        [string]$srcSite,
        [string]$stored_credential
          )
    ## setup connection vars
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
    
    ## setup connection...
    try {
        Write-Host "Credentials ready.Trying to connect...."; #connect to Source Site
        Connect-PnPOnline -Url $srcSite -Credentials $credential; #$connectionSrc = 
        $connectSourceSite = Get-PnPWeb;
        if ($connectSourceSite ) {
            $connectSourceSite = Get-PnPWeb;
            $connectSourceSiteContext = Get-PnPConnection;
    
            if ($connectSourceSite -and $connectSourceSiteContext ) {
                Write-Host $("OK: Connection established with '{0}'" -f $srcSite);
                return @{   "siteContext" = $connectSourceSiteContext;
                    "siteWeb"             = $connectSourceSite;
                    "siteTitle"           = $connectSourceSite.Title;
                    "siteTitleFormated"   = $connectSourceSite.Title.Replace(" ", "_")
                    # TODO: better title formatting
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

Export-ModuleMember connectToSite;
