#' Removes module from cache, applying same logic as \code{\link{find.first.R}} to find and remove it
#'
#' @param file name of a file, same as the one used in the \code{\link{lrequire}} method, that will be removed
#'             from the cache, such that the next time the \code{file} is \code{\link{lrequire}}'d, it will be
#'             read and executed.
#'
#' @return boolean value yielding success of removal from the cache
#' @export
#'
#' @examples
#' remove.from.module.cache(variables)
remove.from.module.cache <- function(file) {
  # allow file to be specified without quotes
  file <- as.character(substitute(file))

  filename <- find.first.R(file)
  if (!is.na(filename)) {
    filename.mtime <- paste0(filename, '.mtime')
    remove(list=c(filename, filename.mtime), envir=module.cache)
  }

  return (!is.na(filename))
}
