# connectToSite

## DESCRIPTION

This script connects to a target sharepoint 2013 on premises and returns a PS object containing different infrmation from the site.

## PARAMETER

- srcSite: Target SP 2013 on premises site URL
- credential: Manually provide a credential type object
- stored_credential: Manually provide a stored credentail object saved in the windows credential manager.

## RESULT

Function returns ( if connection is succesful ) a object with the following properties:

- siteContext = connection site context object;
- siteWeb = site URL
- siteTitle = site Title
- siteTitleFormated = Site title withtout spaces.

## EXAMPLES
$myConnectedSiteContext=connectToSite -srcSite 'http://[mySPonPremisesTenant].arrisi.com/'
