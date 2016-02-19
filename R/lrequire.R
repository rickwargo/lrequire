#' Sources an R file with optional caching for subsequent attempts, exporting specified values
#'
#' \code{lrequire} looks in the current path, and then through a list of predefined paths
#' to search for the given file to source into the current environment, but only making visible
#' specific variables that are "exported" as a list, in a fashion similar
#' to \href{https://nodejs.org/}{node.js}. The caching behaviour can be either suspended or it can
#' re-source files that have changed since the last time the file was cached.
#'
#' @param file a string (or expression) that specifies a file to load, with or without an optional .R extension. If
#'        the file does not exist in the current directory, it searches for the file in directories listed in
#'        \code{module.paths}, first seaching all directories for the named file,
#'        then the file with a .R extension.
#'
#'        \itemize{
#'          \item{./R_modules/}
#'          \item{./lib/}
#'          \item{../R_modules/}
#'          \item{../lib/}
#'          \item{~/.R_modules}
#'        }
#'
#'        All variables exposed in the file will be hidden in the calling environment, except for
#'        what is exposed through module.exports or the exports list variable.
#'
#' @param force.reload a logical value, defaulted to FALSE, that can be set to TRUE to disable caching behavior for
#' the file. If the file has already been loaded and cached, setting \code{force.reload} to TRUE will re-source the
#' file. Setting it again to FALSE will re-source the file if the previous state was TRUE.
#'
#' @details
#' \code{lrequire} operates in a similar principle to modules in \href{https://nodejs.org/}{node.js} - keeping
#' any variables created in the source file isolated from the calling environment, while exposing a select set
#' of values/parameters. The specific values are exposed by setting a named list element in the \code{exports} variable
#' to the desired value or by assigning \code{module.exports} a value.
#'
#' Note this list exposed in \code{module.exports} should have named items so they can easily be accessed in
#' the calling environment, however that is not necessary if only a single value is being returned.
#'
#' If values are assigned to both \code{module.exports} and \code{exports}, only the values in \code{module.exports}
#' will be exposed to the caller.
#'
#' Caching a long-running operation, such as static data retrieval from a database is a good use of the
#' caching capability of \code{lrequire} during development when the same file is sourced multiple times.
#'
#' During development, files can be reloaded, even if being cached, if they have been modified after the time they
#' were cached. To enable this behaviour, set the variable \code{module.change_code} to 1.
#'
#' To quickly clear lrequire's package environment, unload the package. In RStudio, this can be done by unchecking
#' \code{lrequire} on the Packages tab. You can also execute the following at the R prompt:
#' \code{
#'     detach("package:lrequire", unload=TRUE)
#'     }
#' The next call to \code{library(lrequire)} will ensure it starts off with a clean slate.
#'
#' @return Any values that exist in \code{module.exports} or, if that does not exist, then the
#'         \emph{list} \code{exports}.
#'
#'         If no file is found, \code{NA} is returned.
#'
#' @author Rick Wargo, \email{lrequire@rickwargo.com}
#'
#' @examples
#' say.hello.to <- lrequire('../lrequire/tests/example-hello')
#' say.hello.to('Rick')
#'
#' @export
lrequire <- function(file, force.reload = FALSE) {
  # allow file to be specified without quotes
  if (length(substitute(file)) > 1) { # an expression was passed, just evaluate it
    file <- as.character(file)
  } else {
    file <- as.character(substitute(file))
  }

  # Look for file or file.R in paths and source locally, exposing list associated with module.exports or exports
  # Return NA otherwise
  #
  # TODO: Keep an internal list of dependencies and if a file changes that is dynamically reloaded, reload all dependencies
  # TODO: Check if module.change_code is set and if so, have a dynamic watcher to reload the file if it changes
  # TODO: Have a pre-defined list of paths to search for R modules
  # TODO: allow same filename to be cached multiple ways!!! (maybe cache on getpath)

  (function(file, force.reload) {
    filename <- find.first.R(file)
    if (!is.na(filename)) {
      mtime = file.info(filename)$mtime
      filename.mtime <- paste0(filename, '.mtime')

      if (exists('.:module.change_code', envir=module.cache)) {
        module.change_code <- get('.:module.change_code', envir=module.cache)
      } else {
        module.change_code <- 0
      }

      if (exists(filename.mtime, envir=module.cache) && (module.change_code > 0)) {
        # if change_code is set and the modification time has changed, force the reload
        if (get(filename.mtime, envir=module.cache) != mtime) {
          force.reload <- TRUE
        }
      }

      if (force.reload || !exists(filename, envir=module.cache)) {
        # forcing a reload of the file has never been read
        source(filename, local = TRUE)
        if (exists('module.change_code')) {
          assign('.:module.change_code', module.change_code, envir=module.cache)
        } else {
          module.change_code <- 0
        }

        # Get the value of module.exports or exports and save to later return to the caller
        return.val <- NULL
        if (exists('module.exports') && !is.null(module.exports)) {
          return.val <- module.exports
        } else if (exists('exports') && !is.null(exports)) {
          return.val <- exports
        }

        # Anytime we load a file, we want to save the file and mod time for later checks
        assign(filename, return.val, envir=module.cache)
        assign(filename.mtime, mtime, envir=module.cache)

        return(return.val)
      } else {
        return(get(filename, envir=module.cache))
      }
    }
    return(NA)
  })(file, force.reload)
}
