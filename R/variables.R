# Define 'global' variables local to the package.

# file.cache is an environment that holds a list of already loaded files, and their mod times for file reloading
file.cache <- new.env()

# exports is an empty list that can be used to deliver values back to the calling environment
exports <- list()

# module.exports is an empty variable that is delivered verbatim back to the calling environment
module.exports <- NULL
