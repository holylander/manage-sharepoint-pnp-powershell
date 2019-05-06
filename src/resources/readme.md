# SP pnp-powershell general tools

A collection of small functions that provide some extended functionaly, checking if required modules are there, etc

## FUNCTIONS

- **checkModules**: check if required powershell modules are there, and if not, install them on your system.
- **getWebParts:** returns an array of webparts elements within a page.
- **copyWebParts:** copy webparts configuration to a target page, and returns the html code needed on that page, so webparts will be displayed.
- **generateItemValues:**  returns certain object structure that is needed when updating or creating SP list items.
  - *note*: it will ignore certain fields that can not be modified like ID, etc. It also uses special procedure for lookup columns.
- **getListFields**: returns the array that describes the fields being setup on target list.
- **addUser: given certain user, choose a Site group to which you would like it to be added to.


### TODOs:
- add export / import SP library/list template config