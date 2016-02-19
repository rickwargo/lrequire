#' Prints the current file cache
#'
#' @param all.names a logical value. If TRUE, all object names are returned. If FALSE,
#'                  names which begin with a . are omitted.
#'
#' @return Nothing is returned, however, the contents of the module cache are printed to the standard output.
#' @export
#'
#' @examples
#' show.module.cache()
show.module.cache <- function(all.names = FALSE) {
    for (v in ls(module.cache, all.names = all.names)) {
    print(paste('Env:', v, '<-', module.cache[[v]]))
  }
}
