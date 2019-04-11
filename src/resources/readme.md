# SP pnp-powershell general tools

A collection of small functions that provide some extended functionaly, checking if required modules are there, etc

## FUNCTIONS

- **checkModules**: check if required ps modules are there, and if not, install them.
- **getWebParts:** returns an array of webparts elements within a page.
- **copyWebParts:** copy webparts configuration and html declaration to a target page
- **generateItemValues:**  generate a data object structure that is need when updating or creating SP list items.
  - *note*: it will ignore certain fields that can not be modified like ID, etc.
- **getListFields**: returns the array that describes the fields being setup on target list.


### TODOs:
- add export / import SP library/list template config