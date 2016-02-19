fileConn<-file("dyntest4.R")
writeLines(c("module.exports <- 1", "module.change_code = 0"), fileConn)
close(fileConn)

# Expect: first time seen, should load file and cache
tst4.1 <- lrequire(dyntest4)

if (tst4.1 != 1) {
  print('test4.1: failed -- tst4.1 != 1')
} else {
  print('test4.1: succeeded')
}

fileConn<-file("dyntest4.R")
writeLines(c("module.exports <- 2", "module.change_code = 1"), fileConn)
close(fileConn)

# Expect: seen previously, should load file FROM cache
tst4.2.1 <- lrequire('dyntest4.R')

if (tst4.2.1 != 1) {
  print('test4.2.1: failed -- tst4.2.1 != 1')
} else {
  print('test4.2.1: succeeded')
}

# Expect: forcing a reload, should load from DISK
#reset.module.cache()
#tst4.2.2 <- lrequire(dyntest4)
tst4.2.2 <- lrequire(file.path(getwd(), './././dyntest4'), force.reload = TRUE)

if (tst4.2.2 != 2) {
  print('test4.2.2: failed -- tst4.2.2 != 2')
} else {
  print('test4.2.2: succeeded')
}

Sys.sleep(1)  # Need to delay so the modification time is different than the previous file
fileConn<-file("dyntest4.R")
writeLines(c("module.exports <- 3", "module.change_code = 1"), fileConn)
close(fileConn)

# Expect: since change_code = 1 and mtime has changed, should load from DISK,
tst4.3 <- lrequire('./././dyntest4.R')

if (tst4.3 != 3) {
  print('test4.3: failed -- tst4.3 != 3')
} else {
  print('test4.3: succeeded')
}

# remove temporary file
file.remove('dyntest4.R')
