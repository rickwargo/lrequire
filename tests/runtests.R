# Test sequence to verify functionality of lrequire and support functions
# No testing harness so as to not require additional packages
# These tests may test more than a single piece of functionality

tst1 <- lrequire(test1)
tst2.sum <- lrequire(test2)
tst3 <- lrequire(test3)

# test1.1 -- test to see if variables exposed in the lrequire-d file exist in the current namespace
if (exists('will.not.be.exposed')) {
  print('test1.1: failed -- "will.not.be.exposed" was exposed')
} else {
  print('test1.1: succeeded')
}

# test1.2 -- test if exposed variable is set and known
if (tst1$hello.world != 'hello world!') {
  print('test1.2: failed -- hello.world is not "hello.world!"')
} else {
  print('test1.2: succeeded')
}

# test1.3 -- test if exposed function is callable and functions correctly
if (tst1$sum(1, 2) != 3) {
  print('test1.3: failed -- sum(1, 2) != 3')
} else {
  print('test1.3: succeeded')
}

# test2.1 -- test if exposed function is callable and functions correctly
if (tst2.sum(1, 2) != 3) {
  print('test2.1: failed -- sum(1, 2) != 3')
} else {
  print('test2.1: succeeded')
}


# test3.1 -- test to see if variables exposed in the lrequire-d file exist in the current namespace
if (exists('will.not.be.exposed')) {
  print('test3.1: failed -- "will.not.be.exposed" was exposed')
} else {
  print('test3.1: succeeded')
}

# test3.2 -- test if exposed variable is set and known
if (tst3$hello.world != 'hello world!') {
  print('test3.2: failed -- hello.world is not "hello.world!"')
} else {
  print('test3.2: succeeded')
}

# test3.3 -- test if exposed function is callable and functions correctly
if (tst3$sum(1, 2) != 3) {
  print('test3.3: failed -- sum(1, 2) != 3')
} else {
  print('test3.3: succeeded')
}

# test4 -- tests module.change_code, caching, and simplifying lrequire arguments to ensure they point to the same file
source('test4.R')

# test5 -- tests module.cache and associated functions
source('test5.R')

# test6 -- tests modules.path and associated functions
source('test6.R')
