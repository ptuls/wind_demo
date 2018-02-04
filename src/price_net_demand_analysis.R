library(dplyr)
library(ggplot2)
library(reshape2)
library(lubridate)

# load data
wind.data.sa <- read.csv("~/Documents/Power/wind_data_sa.csv", sep=',')

# set timezone to official AEMO standard, the Eastern Standard Time (EST)
wind.data.sa$DATE <- as.POSIXct(wind.data.sa$DATE, format = "%Y/%m/%d %H:%M:%S", tz="EST")

# aggregate the windfarm power production according to AEMO's classification
# perform linear interpolation if needed
# wind.data.sa.linear <- na.approx(wind.data.sa)

# assume that the small negative values are due to measurement error
wind.data.sa[wind.data.sa < 0] <- 0

# aggregate to form groups according to AEMO official classification
wind.data.sa$COASTAL <- wind.data.sa$CATHROCK + wind.data.sa$STARHLWF + wind.data.sa$WPWF
wind.data.sa$SOUTHERN <- wind.data.sa$LKBONNY1 + wind.data.sa$LKBONNY2 + wind.data.sa$LKBONNY3 + wind.data.sa$CNUNDAWF
wind.data.sa$MIDNORTH <- rowSums(wind.data.sa[, c(2,4,6,7,11,12,13,14,15,17)])

# combine to form total sum
wind.data.sa$TOTAL <- rowSums(wind.data.sa[, 2:18])

# set the format to the following, omitting seconds (%S)
price.demand.sa <- read.csv("~/Documents/Power/price_demand_sa.csv", sep=",")
price.demand.sa$Date <- as.POSIXct(price.demand.sa$Date, format="%Y/%m/%d %H:%M", tz="EST")

# get demand less wind generation
wind.generation <- data.frame(wind.data.sa$DATE, wind.data.sa$TOTAL)
names(wind.generation) <- c("DATE", "TOTAL")

# divide by 12 to get MWh
# price data in half hourly aggregates
agg <- "30 min"
energy.conversion <- 12
wind.generation <- wind.generation[5:nrow(wind.generation), ] %>% group_by(DATE = cut(DATE, 
                   breaks=agg)) %>% summarize(TOTAL = sum(TOTAL, na.rm=na.omit)/energy.conversion)
# date format has changed; change it back to POSIX standard
wind.generation$DATE <- as.POSIXct(wind.generation$DATE, format="%Y-%m-%d %H:%M:%S", tz="EST")

# start_time <- max(as.POSIXct(wind.generation[1,]$DATE, tz="EST"), as.POSIXct(price.demand.sa[1,]$Date, tz="EST"))
start_time <- as.POSIXct("2015-06-01 00:00:00", tz="EST") + minutes(30)
end_time <- as.POSIXct("2015-08-31 00:00:00", tz="EST") + minutes(30)
# end_time <- min(as.POSIXct(wind.generation[nrow(wind.generation),]$DATE, tz="EST"), as.POSIXct(price.demand.sa[nrow(price.demand.sa),]$Date, tz="EST"))

wind.generation <- wind.generation[wind.generation$DATE >= start_time & wind.generation$DATE <= end_time, ]
wind.generation$DEMAND <- price.demand.sa[as.POSIXct(price.demand.sa$Date, tz="EST") >= start_time & 
                                            as.POSIXct(price.demand.sa$Date, tz = "EST") <= end_time, ]$Demand
wind.generation$NET_DEMAND <- wind.generation$DEMAND - wind.generation$TOTAL

# plot demand for year 2015; makes sure to index it via Eastern Standard Time for consistency
wind.generation$RRP <- price.demand.sa[price.demand.sa$Date >= start_time & price.demand.sa$Date <= end_time, ]$RRP

p <- ggplot(wind.generation, aes(x=NET_DEMAND, y=RRP)) + geom_point()
print(p)