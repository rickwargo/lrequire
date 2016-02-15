#' Requires an R file, exporting specific variables as a list.
#'
#' \code{lrequire} looks in the current path, and then through a list of predefined paths
#' to search for the given file to source into the current environment, but only making visible
#' specific variables that are "exported" as a list, in a fashion similar
#' to \href{https://node.js/}{node.js}.
#'
#' @param file a string (or expression) that specifies a file to load, with or without an optional .R extension. If
#'        the file does not exist in the current directory, it searches for the file in the following
#'        directories, first seaching all directories for the named file, then the file with a .R extension.
#'
#'        \itemize{
#'          \item{lib/}
#'          \item{R/}
#'          \item{../lib/}
#'          \item{../R/}
#'        }
#'
#'        All variables exposed in the file will be hidden in the calling environment, except for
#'        what is exposed through the module.exports or exports list variable.
#'
#' @details
#' \code{lrequire} operates in a similar principle to modules in node.js - keeping any variables created in
#' the source file isolated from the calling environment, while exposing a select set of values/parameters.
#' The specific values are exposed by setting named list elements to the desired value. Note this list exposed
#' in \code{nodule.exports} should have named items so they can easily be accessed in the calling environment.
#'
#' @return Any values that exist in the \emph{list} \code{module.exports} or \code{exports}.
#'
#'         If no file is found, \code{NA} is returned.
#'
#' @author Rick Wargo, \email{lrequire@rickwargo.com}
#'
#' @examples
#' ## Given: myfile.R -- example
#' this = list(
#'   ten=      10,
#'   me=       "Rick",
#'   square=   function(x) { return (x*x) }
#' )
#'
#' this$power <- function(x, y) { return (x^y) }
#'
#' module.exports = this
#' ## End of myfile.R
#'
#' ## Any one of the file methods can be used to load myfile.R:
#' # vals <- lrequire(myfile)
#' # vals <- lrequire(myfile.R)
#' # vals <- lrequire('myfile')
#' # vals <- lrequire('myfile.R')
#'
#' ## To use vals, access the individual element that is returned through module.exports.
#' \dontrun{
#' print(paste("The square of 8 is ", vals$square(8)))
#' }
#'
#' @export

lrequire <- function(file) {
  # allow file to be specified without quotes
  file <- as.character(substitute(file))

  file.readable <- function(file) {
    # returns if the file is readable and is not a directory

    return (file.access(file, mode=4) == 0 && !file.info(file)$isdir)
  }

  find.first.R <- function(file) {
    # Check if file exists in the following directories (in the specified order). First check for file in current
    # directory, then file.R in current directory. If neither exist, check file file in the remaining paths, followed
    # by file.R in those paths.
    #   lib
    #   R
    #   ../lib
    #   ../R

    paths <- c('lib', 'R', '../lib', '../R')
    files <- file.path('.', c(file, paste(file, 'R', sep='.')))
    files <- append(files, file.path(paths, file))
    files <- append(files, file.path(paths, paste(file, 'R', sep='.')))

    for (filepath in files) {
      if (file.readable(filepath)) {
        return (filepath)
      }
    }
    warning('No file named ', file, ' or ', file, '.R in: ', paste(c('.', paths), collapse='/, '), '/.')
    return(NA)
  }

  # Look for file or file.R in paths and source locally, exposing list associated with module.exports or exports
  # Return NA otherwise
  #
  # TODO: Cache loaded files and return if already loaded
  # TODO: Check if module.change_code is set and if so, have a dynamic watcher to reload the file if it changes

  (function(file) {
    filename <- find.first.R(file)
    if (!is.na(filename)) {
      source(filename, local = T)
      if (exists('module.exports')) {
        return(module.exports)
      } else if (exists('exports')) {
        return(exports)
      }
    }
    return(NA)
  })(file)
}
