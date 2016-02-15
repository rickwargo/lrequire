# lrequire for R

In the fashion of 'node.js' <https://nodejs.org/>, requires a file,
sourcing into the current environment only the variables explicitly specified
in the module.exports or exports list variable.

## Installation

From CRAN:
```r
install.packages("lrequire")
```

From GitHub:
```r
devtools::install_github("rickwargo/lrequire")
```

# Introduction

`lrequire` enables division of labor in R routines, only exposing variables that are necessary.
lrequire-ing scripts keeps the enviornment clean and free of unused and unwanted variables.

## Example
Given the following unit file, named sample.R:
```r
this = list(
  ten=      10,
  me=       "Rick",
  square=   function(x) { return (x*x) }
)

will.not.expose <- TRUE
this$power <- function(x, y) { return (x^y) }

module.exports = this
```
`lrequire` it and make use of it's outputs.
```r
vals <- lrequire(sample)

print(paste("The square of 8 is ", vals$square(8)))
```

Upon `lrequire`-ing `sample.R`, only the `this` list will be exposed and assigned to the variable 
`vals`. It will have the following assignments:

 - vals$ten
 - vals$me
 - vals$square
 - vals$power
 
Note that `vals$ten` and `vals$me` are simple variables while both `vals$square` and `vals$power`
are functions.
