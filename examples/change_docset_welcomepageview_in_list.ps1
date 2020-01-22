
Import-Module -Force $PSScriptRoot\..\src\resources\SP_tools.psm1;
Import-Module -Force $PSScriptRoot\..\src\connection\SP_connection_Manager.psm1;


$con = [psobject]@{
    url     = "[mysiteurl]";
    context = $null;
}

$con.context = Connect-PnPOnline -Url $con.url -ReturnConnection

$config = [psobject] @{
    ct_name = "[desired content type]" #the content type itself
    list    = "[desired listname]" #the list itslef
    view    = "[desired view]" # must exist in the list
    prop    = "[desired prop bag key string]" # must exist in the list
    user    = "[useremail]"
    pass    = "[userpassword]"
}

$IE = New-Object -com internetexplorer.application
$IE.visible = $true

docsetDefaultViewScrapper -con $con -browser $IE -user $config.user -pass $config.pass -list $config.list -proptag $config.prop -target_view $config.view -ct $config.ct_name

$IE.Quit()

