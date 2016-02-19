orig.path <- get.module.paths()

# test getting of modules.path
path <- get.module.paths()
len5 <- length(path)
if (len5 != 5) {
  print('test6.1: failed -- length(path) != 5')
} else {
  print('test6.1: succeeded')
}

# test append to end
append.module.paths("/")
path <- get.module.paths()
len6 <- length(path)
if (len6 != 6) {
  print('test6.2.1: failed -- length(path) != 6')
} else {
  print('test6.2.1: succeeded')
}
if (path[6] != "/") {
  print('test6.2.2: failed -- path[6] != "/"')
} else {
  print('test6.2.2: succeeded')
}

# test remove (of recently appended path)
remove.module.paths(6)
path <- get.module.paths()
len5 <- length(path)
if (len5 != 5) {
  print('test6.3.1: failed -- length(path) != 5')
} else {
  print('test6.3.1: succeeded')
}
if (!all.equal(orig.path, path)) {
  print('test6.3.2: failed -- !all.equal(orig.path, path)')
} else {
  print('test6.3.2: succeeded')
}

# test append to front
append.module.paths("/", 0)
path <- get.module.paths()
len6 <- length(path)
if (len6 != 6) {
  print('test6.4.1: failed -- length(path) != 6')
} else {
  print('test6.4.1: succeeded')
}
if (path[1] != "/") {
  print('test6.4.2: failed -- path[6] != "/"')
} else {
  print('test6.4.2: succeeded')
}

# test append to middle
append.module.paths("/", 3)
path <- get.module.paths()
len7 <- length(path)
if (len7 != 7) {
  print('test6.5.1: failed -- length(path) != 7')
} else {
  print('test6.5.1: succeeded')
}
if (path[4] != "/") {
  print('test6.5.2: failed -- path[4] != "/"')
} else {
  print('test6.5.2: succeeded')
}

# test remove (of multiple paths)
remove.module.paths(1, 4)
path <- get.module.paths()
len5 <- length(path)
if (len5 != 5) {
  print('test6.6.1: failed -- length(path) != 5')
} else {
  print('test6.6.1: succeeded')
}
if (!all.equal(orig.path, path)) {
  print('test6.6.2: failed -- !all.equal(orig.path, path)')
} else {
  print('test6.6.2: succeeded')
}
