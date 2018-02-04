# Script to plot several days/weeks' worth of wind energy production versus demand
# Here, we chose a week starting Christmas Eve 2015
library(dplyr)
library(ggplot2)
library(reshape2)
library(lubridate)

# load data
wind.data.sa <- read.csv("~/Documents/Power/wind_data_sa.csv", sep=',')

# set timezone to official AEMO standard, the Eastern Standard Time (EST)
wind.data.sa$DATE <- as.POSIXct(wind.data.sa$DATE, format = "%Y/%m/%d %H:%M:%S", tz="EST")

# assume that the small negative values are due to measurement error
wind.data.sa[is.na(wind.data.sa)] <- 0
wind.data.sa[wind.data.sa < 0] <- 0

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
                     breaks=agg)) %>% summarize(TOTAL = sum(TOTAL, na.rm=na.omit)/energy.conversion)
# date format has changed; change it back to POSIX standard
wind.generation$DATE <- as.POSIXct(wind.generation$DATE, format="%Y-%m-%d %H:%M:%S", tz="EST")

# set the start date and end date
start_time1 <- as.POSIXct("2015-12-01 00:00:00", tz="EST") + minutes(30)
end_time1 <- as.POSIXct("2016-02-29 00:00:00", tz="EST") + minutes(30)

start_time2 <- as.POSIXct("2015-06-01 00:00:00", tz="EST") + minutes(30)
end_time2 <- as.POSIXct("2015-09-01 00:00:00", tz="EST") + minutes(30)

wind.generation <- wind.generation[wind.generation$DATE >= start_time1 & wind.generation$DATE <= end_time1 |
                                     wind.generation$DATE >= start_time2 & wind.generation$DATE <= end_time2, ]
wind.generation$DEMAND <- price.demand.sa[price.demand.sa$Date >= start_time1 & price.demand.sa$Date <= end_time1 |
                                            price.demand.sa$Date >= start_time2 & price.demand.sa$Date <= end_time2, ]$Demand
wind.generation$REDUCE <- wind.generation$TOTAL/wind.generation$DEMAND*100

# want to plot them on the same plot
plot.series <- wind.generation
plot.series$LAB <- rep("s")
plot.series[plot.series$DATE >= start_time2 & plot.series$DATE <= end_time2, ]$LAB <- rep("w")

# plot the results
p <- ggplot(plot.series, aes(x=REDUCE, fill=LAB)) + geom_density(alpha=0.5) + xlab("% Serviced") 
p <- p + ylab("Density") + ggtitle("Serviced Energy Demand due to Wind (2015)") 
p <- p + scale_fill_discrete(name="Legend", breaks=c("s", "w"), labels=c("Summer", "Winter"))
print(p)