# manage-sharepoint-pnp-powershell

Different Powershell cmdLets for managing Sharepoint Online / on Premises.
So far, most of the powershell scripts here provide extended functionality to pnp-powershell library, so admin can work list data, publishing pages, in a faster/easier way.

The scripts are organized in two different folders, source and examples. All you need to start work is to import the provided powershell modules.

You can start checking out the [examples folder](examples), and learn how to use the functions


## Prerequisites

- In order to generate the Cmdlet help you need to have the Windows Management Framework v4.0 installed, which you can download from [http://www.microsoft.com/en-us/download/details.aspx?id=40855]([https://link](http://www.microsoft.com/en-us/download/details.aspx?id=40855)).
- You will need to have installed the Sharepoint PnP-powershell module.
- You will need to have installed the credential manager module
  - Run ```Install-Module -Name CredentialManager```
  - Create your stored credentials in the Windows credentials manager. Please NOTE that it must be a "generic credential", not a "Windows credential"
