library(RMySQL)

con <- dbConnect(MySQL(), user='uber', password='driver', dbname='uber', host='localhost')
suppressWarnings(trip <- dbReadTable(con, 'v_trip_details'))
#print(paste("Loaded", nrow(trip), "records."))

print("loading sample!")

#module.exports <- list(trip=trip)
exports$trip <- trip

#vals2 <- lrequire(sample2)

module.change_code <- 1
