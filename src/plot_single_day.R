# Script to plot several days/weeks' worth of wind energy production versus demand
# Here, we chose a week starting Christmas Eve 2015
library(dplyr)
library(ggplot2)
library(reshape2)
library(lubridate)
library(zoo)

# load data
# directory <- "~/Documents/Power/wind_data_sa.csv"
directory <- "~/wind_demo/data/wind_data_sa.csv"
wind.data.sa <- read.csv(directory, sep=',')

# set timezone to official AEMO standard, the Eastern Standard Time (EST)
wind.data.sa$DATE <- as.POSIXct(wind.data.sa$DATE, format = "%Y/%m/%d %H:%M:%S", tz="EST")

# assume that the small negative values are due to measurement error
wind.data.sa[wind.data.sa < 0] <- 0

# linear interpolation
wind.data.sa <- na.approx(wind.data.sa)

# combine to form total sum
wind.data.sa$TOTAL <- rowSums(wind.data.sa[, 2:ncol(wind.data.sa)])

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
                               breaks=agg)) %>% summarize(TOTAL = sum(TOTAL)/energy.conversion)
# date format has changed; change it back to POSIX standard
wind.generation$DATE <- as.POSIXct(wind.generation$DATE, format="%Y-%m-%d %H:%M:%S", tz="EST")

# set the start date and end date
start_time <- as.POSIXct("2015-12-24 00:00:00", tz="EST") + minutes(30)
end_time <- as.POSIXct("2016-01-01 00:00:00", tz="EST") + minutes(30)

wind.generation <- wind.generation[wind.generation$DATE >= start_time & wind.generation$DATE <= end_time, ]
wind.generation$DEMAND <- price.demand.sa[as.POSIXct(price.demand.sa$Date, tz="EST") >= start_time & 
                                            as.POSIXct(price.demand.sa$Date, tz = "EST") <= end_time, ]$Demand
wind.generation$NET_DEMAND <- wind.generation$DEMAND - wind.generation$TOTAL

# want to plot them on the same plot, so we melt
wind.generation.melt <- melt(wind.generation, id.vars="DATE")

# plot the results
p <- ggplot(wind.generation.melt, aes(DATE, value, col=variable)) + geom_line() + xlab("Date") 
p <- p + ylab("Energy (MWh)") + ggtitle("South Australian Electricity Wind Output and Demand (Week Starting 24 Dec 2015)")
p <- p + scale_color_discrete(name="Legend", breaks=c("TOTAL", "DEMAND", "NET_DEMAND"), 
                                labels=c("Total Wind Energy", "Demand", "Net Demand")) + theme_minimal()
print(p)