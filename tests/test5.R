
fileConn<-file('dyntest5.R')
writeLines(c('value <- 1'), fileConn)
close(fileConn)

cache <- get.module.cache()

# test reset.module.cache
reset.module.cache()
len2 <- length(cache)
len0 <- length(ls(cache))
if (len2 != 2) {
  print('test5.1.1: failed -- length(cache) != 2')
} else {
  print('test5.1.1: succeeded')
}
if (len0 != 0) {
  print('test5.1.2: failed -- length(ls(cache)) != 0')
} else {
  print('test5.1.2: succeeded')
}

# test adding to cache - requiring should add two items
reset.module.cache()
tst6 <- lrequire('dyntest5.R')
len2 <- length(ls(cache))
if (len2 != 2) {
  print('test5.2: failed -- length(ls(cache)) != 2')
} else {
  print('test5.2: succeeded')
}

# test remove.from.module.cache by removing previously added file
remove.from.module.cache('dyntest5.R')
len0 <- length(ls(cache))
if (len0 != 0) {
  print('test5.3: failed -- length(ls(cache)) != 0')
} else {
  print('test5.3: succeeded')
}

# cleanup temporary file
file.remove('dyntest5.R')
