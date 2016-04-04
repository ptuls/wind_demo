library(dplyr)
library(ggplot2)
library(reshape2)

# load data
wind_data_sa <- read.csv("~/Documents/Power/wind_data_sa.csv", sep=',')

# convert date and time to standard
wind_data_sa$DATE <- as.POSIXct(wind_data_sa$DATE, format = "%Y/%m/%d %H:%M:%S", tz="EST")

# aggregate the windfarm power production according to AEMO's classification
# perform linear interpolation if needed
# wind_data_sa.linear <- na.approx(wind_data_sa)

# assume that the small negative values are due to measurement error
wind_data_sa[wind_data_sa < 0] <- 0

# aggregate
wind_data_sa$COASTAL <- wind_data_sa$CATHROCK + wind_data_sa$STARHLWF + wind_data_sa$WPWF
wind_data_sa$SOUTHERN <- wind_data_sa$LKBONNY1 + wind_data_sa$LKBONNY2 + wind_data_sa$LKBONNY3 + wind_data_sa$CNUNDAWF
wind_data_sa$MIDNORTH <- rowSums(wind_data_sa[, c(2,4,6,7,11,12,13,14,15,17)])

# combine to form total sum
wind_data_sa$TOTAL <- rowSums(wind_data_sa[, 2:18])

# note that there is a change in the date format starting from row 89503
# set the format to the following, omitting seconds (%S)
price_demand_sa <- read.csv("~/Documents/Power/price_demand_sa.csv", sep=",")
price_demand_sa$Date <- as.POSIXct(price_demand_sa$Date, format="%Y/%m/%d %H:%M", tz="EST")

# plot demand for year 2015; makes sure to index it via Eastern Standard Time for consistency
# start_date = as.POSIXct("2015-01-01", tz="EST") + minutes(30)
# end_date = as.POSIXct("2015-12-31", tz="EST") + minutes(30)
# price2015 <- price_demand_sa[price_demand_sa$Date >= start_date & price_demand_sa$Date <= end_date, ]
# p1 <- ggplot(price2015, aes(x=Date, y=Demand)) + geom_line() + xlab("Date (Eastern Standard Time)") 
# p1 <- p1 + ylab("Demand (MWh)") + ggtitle("South Australian Electricity Demand in Year 2015")
# print(p1)

# get demand less wind generation
wind_generation <- data.frame(wind_data_sa$DATE, wind_data_sa$TOTAL)
names(wind_generation) <- c("DATE", "TOTAL")

# divide by 12 to get MWh
wind_generation <- wind_generation[5:nrow(wind_generation), ] %>% group_by(DATE = cut(DATE, 
                                      breaks="30 min")) %>% summarize(TOTAL = sum(TOTAL, na.rm=na.omit)/12)
# date format has changed; change it back to POSIX standard
wind_generation$DATE <- as.POSIXct(wind_generation$DATE, format="%Y-%m-%d %H:%M:%S", tz="EST")

start_time <- max(as.POSIXct(wind_generation[1,]$DATE, tz="EST"), as.POSIXct(price_demand_sa[1,]$Date, tz="EST"))
# start_time <- as.POSIXct("2015-12-25 00:00:00", tz="EST") + minutes(30)
# end_time <- as.POSIXct("2015-12-26 00:00:00", tz="EST") + minutes(30)
end_time <- min(as.POSIXct(wind_generation[nrow(wind_generation),]$DATE, tz="EST"), as.POSIXct(price_demand_sa[nrow(price_demand_sa),]$Date, tz="EST"))

wind_generation <- wind_generation[wind_generation$DATE >= start_time & wind_generation$DATE <= end_time, ]
wind_generation$DEMAND <- price_demand_sa[as.POSIXct(price_demand_sa$Date, tz="EST") >= start_time & 
                                            as.POSIXct(price_demand_sa$Date, tz = "EST") <= end_time, ]$Demand
wind_generation$NET_DEMAND <- wind_generation$DEMAND - wind_generation$TOTAL

# want to plot them on the same plot
wind_generation_melt <- melt(wind_generation, id.vars="DATE")

p2 <- ggplot(wind_generation_melt, aes(DATE, value, col=variable)) + geom_line() + xlab("Date (Eastern Standard Time)") 
p2 <- p2 + ylab("Energy (MWh)") + ggtitle("South Australian Electricity Wind Output and Demand (25 Dec 2015)")
p2 <- p2 + scale_color_discrete(name="Legend", breaks=c("TOTAL", "DEMAND", "NET_DEMAND"), 
                                labels=c("Total", "Demand", "Net Demand"))
print(p2)

# p2 <- ggplot(wind_generation, aes(x=DATE, y=DEMAND)) + geom_line() + xlab("Date (Eastern Standard Time)") 
# p2 <- p2 + ylab("Net Demand (MWh)") + ggtitle("South Australian Electricity Demand Net of Wind Generation (Dec 2015)")
# print(p2)

# add price
wind_generation$PRICE <- price_demand_sa[as.POSIXct(price_demand_sa$Date, tz="EST") >= start_time & 
                                           as.POSIXct(price_demand_sa$Date, tz = "EST") <= end_time, ]$RRP
p3 <- ggplot(wind_generation, aes(x=NET_DEMAND, y=PRICE)) + geom_point() + xlab("Net Demand (MWh)") + ylab("Price ($)")
p3 <- p3 + ggtitle("Price vs. Net Demand (Jan 2016)")

