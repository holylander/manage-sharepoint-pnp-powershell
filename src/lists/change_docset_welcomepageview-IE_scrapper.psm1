function docsetDefaultViewScrapper {
    #this function is a workdaround to define docset defaultview / welcomepageview within a list. It will crete a site prop bag with the assiged view name
    param (
        [Parameter(Mandatory = $True)] #con object contains "url" & "context" ( refers to connection context object)
        [PsObject]$con,
        [Parameter(Mandatory = $True)]
        [Object]$browser, #must be a "New-Object -com internetexplorer.application" IE object
        [Parameter(Mandatory = $True)]
        [string]$user, #email
        [Parameter(Mandatory = $True)]
        [string]$pass, #pass
        [Parameter(Mandatory = $True)]
        [string]$list, #list name
        [Parameter(Mandatory = $True)]
        [string]$proptag, #the key value you would like to use as the site property bag
        [Parameter(Mandatory = $True)]
        [string]$target_view, #the target view within the list you would like to use
        [Parameter(Mandatory = $True)]
        [string]$ct_name  #the target content type
    )
    try {
        #get list id & content type ID inside the list
        $ef_list = Get-PnPList -Identity $list -Connection $con.context -errorAction Stop -includes ContentTypes
        foreach ( $ct in $ef_list.ContentTypes) {
            if ($ct.Name -eq $ct_name) {
                $ct_id = $ct.StringId
            }
        }
        if (!$ct_id) {
            throw 'Could not grab Content Type Id from list - {0}' -f $_.Exception.Message
        }
        #generate docset settings page URL
        [system.uri]$docset_config = '{0}/_layouts/15/docsetsettings.aspx?ctype={1}&List={2}' -f $con.url, $ct_id, $ef_list.Id
    
        #browse to target page URL
        $browser.Navigate($docset_config.AbsoluteUri)
        while ($browser.busy) { Start-Sleep 1 }
        Start-Sleep 2
        #Write-Host "DocsetSetting page loaded"
    
        # CHECK if IE is in a login window, if so, perform login
        if ($browser.Document.IHTMLDocument3_getElementById("loginHeader")) {
            $otheraccount = $browser.Document.IHTMLDocument3_getElementById("otherTile")
            if ($otheraccount) {
                #Write-Host("Selecting another account")
                $otheraccount.click()
                while ($browser.busy) { Start-Sleep 1 }
                Start-Sleep 2
            }
            else {
                throw "Could not select another account on the login form"
            }
            $userinput = $browser.Document.IHTMLDocument3_getElementsByName("loginfmt")
            if ($userinput[0]) {
                #Write-Host("Inputing user")
                while ($browser.busy) { Start-Sleep 1 }
                $userinput[0].focus()
                $userinput[0].value = ""
                #while ($browser.busy) { Start-Sleep 1 }
                $userinput[0].value = $user
                $userinput[0].focus()
                #while ($browser.busy) { Start-Sleep 1 }
                $browser.Document.IHTMLDocument3_getElementById("loginHeader").click()
                #while ($browser.busy) { Start-Sleep 1 }
                Start-Sleep 2
                $userinput[0].click()
                while ($browser.busy) { Start-Sleep 1 }
                Start-Sleep 2
                #$browser.Document.IHTMLDocument3_getElementsByName("submit").click() #send user
                $browser.Document.IHTMLDocument3_getElementById("idSIButton9").click() #send user
                while ($browser.busy) { Start-Sleep 1 }
                Start-Sleep 3
            }
            else {
                throw "could not enter user account on the login form"
            }
            $passinput = $browser.Document.IHTMLDocument3_getElementsByName("passwd")
            if ($passinput[0]) {
                #Write-Host("Inputing password")
                $userinput[0].value = ""
                $passinput[0].value = $pass
                $userinput[0].click()
    
                Start-Sleep 3
                #$browser.Document.IHTMLDocument3_getElementsByName("submit").click() #send user
                $browser.Document.IHTMLDocument3_getElementById("idSIButton9").click() #send user
                Start-Sleep 3
                while ($browser.busy) { Start-Sleep 1 }
            }
            else {
                throw "could not enter user password on the login form"
            }
            #Write-Host "Accepting 'keep session' prompt "
            $browser.Document.IHTMLDocument3_getElementById("idSIButton9").click() #send user
            while ($browser.busy) { Start-Sleep 1 }
        }
        #CHECK if IE is already in the docset settings page, and change the default view / welcomepageview
        else {
            $select = $browser.Document.IHTMLDocument3_getElementById("ctl00_PlaceHolderMain_idWelcomePageView_ctl01_DropDownListViews")
            foreach ($option in $select) {
                if ($option.text -eq $target_view) {
                    $view_found = $true
                    $select.Options.SelectedIndex = $option.index
                    $browser.Document.IHTMLDocument3_getElementById("ctl00_PlaceHolderMain_ctl03_RptControls_btnOK").click()
                    Start-Sleep 2
                    while ($browser.busy) { Start-Sleep 1 }
                    $report = 'Docset default view was changed on "{0}" to "{1}"' -f $con.url, $target_view
    
                    #leverage site property bags to keep track
                    try {
                        Set-PnPPropertyBagValue -Key $proptag -Value $target_view -Connection $con.context -ErrorAction Stop -Indexed
                    }
                    catch {
                        throw "SiteScripts must be enabled {0]" -f $_.Exception.Message
                    }
    
                    return $report
                }
            }
            if (!$view_found) {
                throw "Could not find the desired view among the available ones"
            }
        }
    }
    catch {
        #$report = 'Docset default view was NOT changed {0} on {1}: ' -f $con.url, $_.Exception.Message
        return 'Docset default view was NOT changed {0} on {1}: ' -f $con.url, $_.Exception.Message
    }
}

Export-ModuleMember -Function *
