library(dplyr)
library(ggplot2)
library(reshape2)
source(multiplot)

# load data
wind_data_sa <- read.csv("~/Documents/Power/wind_data_sa.csv", sep=',')

# convert date and time to standard
wind_data_sa$DATE <- as.POSIXct(wind_data_sa$DATE, format = "%Y/%m/%d %H:%M:%S", tz="EST")

# aggregate the windfarm power production according to AEMO's classification
# first perform linear interpolation
wind_data_sa.linear <- na.approx(wind_data_sa)

# assume that the small negative values are due to measurement error
wind_data_sa[wind_data_sa < 0] <- 0

# combine to form total sum
wind_data_sa$TOTAL <- rowSums(wind_data_sa[, 2:18])

# note that there is a change in the date format starting from row 89503
# set the format to the following, omitting seconds (%S)
price_demand_sa <- read.csv("~/Documents/Power/price_demand_sa.csv", sep=",")
price_demand_sa$Date <- as.POSIXct(price_demand_sa$Date, format="%Y/%m/%d %H:%M", tz="EST")

# get demand less wind generation
wind_generation <- data.frame(wind_data_sa$DATE, wind_data_sa$TOTAL)
names(wind_generation) <- c("DATE", "TOTAL")

# divide by 12 to get MWh
wind_generation <- wind_generation[5:nrow(wind_generation), ] %>% group_by(DATE = cut(DATE, 
                           breaks="30 min")) %>% summarize(TOTAL = sum(TOTAL, na.rm=na.omit)/12)
# date format has changed; change it back to POSIX standard
wind_generation$DATE <- as.POSIXct(wind_generation$DATE, format="%Y-%m-%d %H:%M:%S", tz="EST")

# August 2015
start_time <- as.POSIXct("2015-08-01 00:00:00", tz="EST") + minutes(30)
end_time <- as.POSIXct("2015-09-01 00:00:00", tz="EST") + minutes(30)

wind_generation <- wind_generation[wind_generation$DATE >= start_time & wind_generation$DATE <= end_time, ]
wind_generation$DEMAND <- price_demand_sa[as.POSIXct(price_demand_sa$Date, tz="EST") >= start_time & 
                                            as.POSIXct(price_demand_sa$Date, tz = "EST") <= end_time, ]$Demand
wind_generation$NET_DEMAND <- wind_generation$DEMAND - wind_generation$TOTAL

# want to plot them on the same plot
wind_generation_melt <- melt(wind_generation, id.vars="DATE")

p1 <- ggplot(wind_generation_melt, aes(DATE, value, col=variable)) + geom_line() + xlab("Date (Eastern Standard Time)") 
p1 <- p1 + ylab("Energy (MWh)") + ggtitle("Aug 2015")
p1 <- p1 + scale_color_discrete(name="Legend", breaks=c("TOTAL", "DEMAND", "NET_DEMAND"), 
                                labels=c("Total", "Demand", "Net Demand"))

# get demand less wind generation
wind_generation <- data.frame(wind_data_sa$DATE, wind_data_sa$TOTAL)
names(wind_generation) <- c("DATE", "TOTAL")

# divide by 12 to get MWh
wind_generation <- wind_generation[5:nrow(wind_generation), ] %>% group_by(DATE = cut(DATE, 
                                  breaks="30 min")) %>% summarize(TOTAL = sum(TOTAL, na.rm=na.omit)/12)
# date format has changed; change it back to POSIX standard
wind_generation$DATE <- as.POSIXct(wind_generation$DATE, format="%Y-%m-%d %H:%M:%S", tz="EST")

# October 2015
start_time <- as.POSIXct("2015-10-01 00:00:00", tz="EST") + minutes(30)
end_time <- as.POSIXct("2015-11-01 00:00:00", tz="EST") + minutes(30)

wind_generation <- wind_generation[wind_generation$DATE >= start_time & wind_generation$DATE <= end_time, ]
wind_generation$DEMAND <- price_demand_sa[as.POSIXct(price_demand_sa$Date, tz="EST") >= start_time & 
                                            as.POSIXct(price_demand_sa$Date, tz = "EST") <= end_time, ]$Demand
wind_generation$NET_DEMAND <- wind_generation$DEMAND - wind_generation$TOTAL

# want to plot them on the same plot
wind_generation_melt <- melt(wind_generation, id.vars="DATE")

p2 <- ggplot(wind_generation_melt, aes(DATE, value, col=variable)) + geom_line() + xlab("Date (Eastern Standard Time)") 
p2 <- p2 + ylab("Energy (MWh)") + ggtitle("Oct 2015")
p2 <- p2 + scale_color_discrete(name="Legend", breaks=c("TOTAL", "DEMAND", "NET_DEMAND"), 
                                labels=c("Total", "Demand", "Net Demand"))

# get demand less wind generation
wind_generation <- data.frame(wind_data_sa$DATE, wind_data_sa$TOTAL)
names(wind_generation) <- c("DATE", "TOTAL")

# divide by 12 to get MWh
wind_generation <- wind_generation[5:nrow(wind_generation), ] %>% group_by(DATE = cut(DATE, 
                                  breaks="30 min")) %>% summarize(TOTAL = sum(TOTAL, na.rm=na.omit)/12)
# date format has changed; change it back to POSIX standard
wind_generation$DATE <- as.POSIXct(wind_generation$DATE, format="%Y-%m-%d %H:%M:%S", tz="EST")

# December 2015
start_time <- as.POSIXct("2015-12-01 00:00:00", tz="EST") + minutes(30)
end_time <- as.POSIXct("2016-01-01 00:00:00", tz="EST") + minutes(30)

wind_generation <- wind_generation[wind_generation$DATE >= start_time & wind_generation$DATE <= end_time, ]
wind_generation$DEMAND <- price_demand_sa[as.POSIXct(price_demand_sa$Date, tz="EST") >= start_time & 
                                            as.POSIXct(price_demand_sa$Date, tz = "EST") <= end_time, ]$Demand
wind_generation$NET_DEMAND <- wind_generation$DEMAND - wind_generation$TOTAL

# want to plot them on the same plot
wind_generation_melt <- melt(wind_generation, id.vars="DATE")

p3 <- ggplot(wind_generation_melt, aes(DATE, value, col=variable)) + geom_line() + xlab("Date (Eastern Standard Time)") 
p3 <- p3 + ylab("Energy (MWh)") + ggtitle("Dec 2015")
p3 <- p3 + scale_color_discrete(name="Legend", breaks=c("TOTAL", "DEMAND", "NET_DEMAND"), 
                                labels=c("Total", "Demand", "Net Demand"))

# get demand less wind generation
wind_generation <- data.frame(wind_data_sa$DATE, wind_data_sa$TOTAL)
names(wind_generation) <- c("DATE", "TOTAL")

# divide by 12 to get MWh
wind_generation <- wind_generation[5:nrow(wind_generation), ] %>% group_by(DATE = cut(DATE, 
                                        breaks="30 min")) %>% summarize(TOTAL = sum(TOTAL, na.rm=na.omit)/12)
# date format has changed; change it back to POSIX standard
wind_generation$DATE <- as.POSIXct(wind_generation$DATE, format="%Y-%m-%d %H:%M:%S", tz="EST")

# January 2016
start_time <- as.POSIXct("2016-01-01 00:00:00", tz="EST") + minutes(30)
end_time <- as.POSIXct("2016-02-01 00:00:00", tz="EST") + minutes(30)

wind_generation <- wind_generation[wind_generation$DATE >= start_time & wind_generation$DATE <= end_time, ]
wind_generation$DEMAND <- price_demand_sa[as.POSIXct(price_demand_sa$Date, tz="EST") >= start_time & 
                                            as.POSIXct(price_demand_sa$Date, tz = "EST") <= end_time, ]$Demand
wind_generation$NET_DEMAND <- wind_generation$DEMAND - wind_generation$TOTAL

# want to plot them on the same plot
wind_generation_melt <- melt(wind_generation, id.vars="DATE")

p4 <- ggplot(wind_generation_melt, aes(DATE, value, col=variable)) + geom_line() + xlab("Date (Eastern Standard Time)") 
p4 <- p4 + ylab("Energy (MWh)") + ggtitle("Jan 2016")
p4 <- p4 + scale_color_discrete(name="Legend", breaks=c("TOTAL", "DEMAND", "NET_DEMAND"), 
                                labels=c("Total", "Demand", "Net Demand"))

multiplot(p1, p2, p3, p4, cols=2)