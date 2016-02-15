#' Sources an R file with optional caching for subsequent attempts, exporting specified values.
#'
#' \code{lrequire} looks in the current path, and then through a list of predefined paths
#' to search for the given file to source into the current environment, but only making visible
#' specific variables that are "exported" as a list, in a fashion similar
#' to \href{https://nodejs.org/}{node.js}. The caching behaviour can be either suspended or it can
#' re-source files that have changed since the last time the file was cached.
#'
#' @param file A string (or expression) that specifies a file to load, with or without an optional .R extension. If
#'        the file does not exist in the current directory, it searches for the file in the following
#'        directories, first seaching all directories for the named file, then the file with a .R extension.
#'
#'        \itemize{
#'          \item{lib/}
#'          \item{../lib/}
#'          \item{../R/}
#'        }
#'
#'        All variables exposed in the file will be hidden in the calling environment, except for
#'        what is exposed through module.exports or the exports list variable.
#'
#' @param do.caching A boolean, defaulted to TRUE, that can be set to false to disable caching behavior for
#' the file. If the file has already been loaded and cached, setting \code{do.cache} to FALSE will re-source the
#' file. Setting it again to TRUE will re-source the file if the previous state was FALSE.
#'
#' @details
#' \code{lrequire} operates in a similar principle to modules in \href{https://nodejs.org/}{node.js} - keeping
#' any variables created in the source file isolated from the calling environment, while exposing a select set
#' of values/parameters. The specific values are exposed by setting a named list element in the \code{exports} variable
#' to the desired value or by assigning \code{module.exports} a value.
#'
#' Note this list exposed in \code{nodule.exports} should have named items so they can easily be accessed in
#' the calling environment, however that is not necessary if only a single value is being returned.
#'
#' If values are assigned to both \code{module.exports} and \code{exports}, only the values in \code{module.exports}
#' will be exposed to the caller.
#'
#' Caching a long-running operation, such as static data retrieval from a database is a good use of the
#' caching capability of \code{lrequire} during development when the same file is sourced multiple times.
#'
#' During development, files can be reloaded, even if being cached if they have been modified after the time they
#' were cached. To enable this behaviour, set the variable \code{module.change_code} to 1.
#'
#' @return Any values that exist in \code{module.exports} or, if that does not exist, then the
#'         \emph{list} \code{exports}.
#'
#'         If no file is found, \code{NA} is returned.
#'
#' @author Rick Wargo, \email{lrequire@rickwargo.com}
#'
#' @examples
#' \dontrun{
#' ## Given: myfile.R -- example
#' this = list(
#'   ten=      10,
#'   me=       "Rick",
#'   square=   function(x) { return (x*x) }
#' )
#'
#' this$power <- function(x, y) { return (x^y) }
#'
#' # Note that setting module.change_code to 1 will enable any changes to this file to be reloaded the
#' # next time the file is lrequire'd (instead of the cached value being returned).
#'
#' module.change_code <- 1
#' module.exports <- this
#' ## End of myfile.R
#'
#' ## Any one of the file methods can be used to load myfile.R:
#' vals <- lrequire(myfile)
#' # vals <- lrequire(myfile.R, do.caching=FALSE)
#' # vals <- lrequire('myfile')
#' # vals <- lrequire('myfile.R')
#'
#' ## To use vals, access the individual element that is returned through module.exports.
#' print(paste("The square of 8 is ", vals$square(8)))
#' }
#'
#' @export
lrequire <- function(file, do.caching=TRUE) {
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
    #   ../lib
    #   ../R

    paths <- c('lib', '../lib', '../R')
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
  # TODO: Keep an internal list of dependencies and if a file changes that is dynamically reloaded, reload all dependencies
  # TODO: Check if module.change_code is set and if so, have a dynamic watcher to reload the file if it changes

  (function(file, do.caching) {
    filename <- find.first.R(file)
    if (!is.na(filename)) {
      mtime = file.info(filename)$mtime
      filename.mtime <- paste0(filename, '.mtime')

      # If filename.mtime does not exist in environment, then change_code is not set and we will not re-source
      # If filename.mtime does exist, only return cached value if current mod time is <= stored mode time
      if (do.caching && exists(filename, envir=file.cache) &&
          (!exists(filename.mtime, envir=file.cache) || (mtime <= get(filename.mtime, envir=file.cache)))) {
        return(get(filename, envir=file.cache))
      } else {
        # Otherwise, we are not caching or we are caching and have not seen the file yet
        # Or, we are caching and the file has been updated since it has been cached
        source(filename, local = TRUE)

        change.code <- do.caching && exists('module.change_code') && (module.change_code == 1)
        if (change.code) {
          # If we are caching and checking mod times, we want to save the mod time for later checks
          assign(filename.mtime, mtime, envir=file.cache)
        } else if (exists(filename.mtime, envir=file.cache)) {
          # Otherwise we are not caching or we won't refresh newly saved files
          remove(list=c(filename, filename.mtime), envir=file.cache)
        }

        return.val <- NULL
        if (exists('module.exports') && !is.null(module.exports)) {
          return.val <- module.exports
        } else if (exists('exports') && !is.null(exports)) {
          return.val <- exports
        }
        if (do.caching) {
          # We are caching so save the result of this source
          assign(filename, return.val, envir=file.cache)
        }
        return(return.val)
      }
    }
    return(NA)
  })(file, do.caching)
}
