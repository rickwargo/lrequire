vals <- lrequire(sample)
vals2 <- lrequire(sample2, do.caching=T)
print(vals2$trip)

print(nrow(vals$trip))

#setwd('~/Code/R/Packages/lrequire/playground')
