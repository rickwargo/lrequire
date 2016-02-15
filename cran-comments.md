## Develop environment
* local OS X install, R 3.2.3
* OS X El Capitan 10.11.3
* RStudio 0.99.491

## R CMD check results
There were no ERRORs or WARNINGs. 

There was 1 NOTE:

* checking R code for possible problems ... NOTE
lrequire : <anonymous>: no visible binding for global variable
  ‘module.exports’
lrequire : <anonymous>: no visible binding for global variable
  ‘exports’

### Explanation
Both module.exports and exports are defined as global variables, but really local to the
source file being lrequire'd. The function of lrequire is to take the variables specified 
by the module.exports (or exports) list and make them, and only them, visible to the caller.
This behavior operates as intended.

## Downstream dependencies

To the best of my knowledge there are none
