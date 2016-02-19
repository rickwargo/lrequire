file.readable <- function(file) {
  # returns if the file is readable and is not a directory

  return (file.access(file, mode=4) == 0 && !file.info(file)$isdir)
}

#' Returns the path of the first found instance of \code{file} in \code{module.path}.
#'
#' A symbol maybe passed instead of a string for readability. If an expression is passed, it must return a string value.
#'
#' @param file a string (or symbol) specifying the \code{file} to search for existance and readability in the current directory,
#'             and if it cannot be found, searches for it in the list of directories specified by \code{module.paths}
#'             and then through the set of paths with the file using a .R extension, if it was not originally
#'             specified.
#'
#' @return A string consisting of the path the file was first found searching through module.paths.
#' @export
#'
#' @examples
#' # Returns the path to the first found file according to module.paths
#' adder.path <- find.first.R('adder')

find.first.R <- function(file) {
  # Check if file exists in the following directories (in the specified order). First check for file in current
  # directory, then file.R in current directory. If neither exist, check file file in the remaining paths, followed
  # by file.R in those paths.

  # TODO: Need to simplify complex paths using .. and other special approachs

  module.paths <- get('.:module.paths', envir = module.cache)
  search.for.r <- (toupper(substr(file, nchar(file)-1, nchar(file))) != '.R')
  files <- c()

  if ((substr(file, 1, 1) == .Platform$file.sep) || (substr(file, 2, 2) == ':')) {
    files <- append(files, ifelse(search.for.r, paste(file, 'R', sep='.'), file))
  } else {
    files <- append(files, file.path('.', ifelse(search.for.r, paste(file, 'R', sep='.'), file)))
    files <- append(files, file.path(module.paths, file))

    # Check file.R only if .R was not specified
    if (search.for.r) {
      files <- append(files, file.path(module.paths, paste(file, 'R', sep='.')))
    }
  }

  # Condense multiple references to same directory ('./' --> '')
  sep = ifelse(.Platform$file.sep == '\\', '\\\\', '/')
  files <- gsub(paste0('(?<!\\.)\\.', sep), '', files, perl=TRUE)

  for (filepath in files) {
    if ((substr(filepath, 1, 1) == .Platform$file.sep) || (substr(filepath, 2, 2) == ':')) {
      # do nothing
    } else {
      filepath <- path.expand(file.path(getwd(), filepath))
      filepath <- gsub('/[^/]+/\\.\\.', '', filepath, perl=TRUE)
    }
    if (file.readable(filepath)) {
      return (filepath)
    }
  }
  warning('No file named ', file,
          ifelse(search.for.r, paste0(' or ', file, '.R'), ''),
          ' in: ', paste(c('.', module.paths), collapse='/, '), '/.')
  return(NA)
}

