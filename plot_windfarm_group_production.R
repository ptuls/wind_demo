library(ggplot2)
library(dplyr)
library(reshape2)
library(lubridate)

# read data
wind.data.sa <- read.csv("~/Documents/Power/wind_data_sa.csv", sep=",")

# AEMO files are based on Eastern Standard Time, so ensure all times are the same
wind.data.sa$DATE <- as.POSIXct(wind.data.sa$DATE, format="%Y/%m/%d %H:%M:%S", tz="EST")

# there exists negative power values and these are small potentially due to measurement
# errors; we set them to 0
wind.data.sa[wind.data.sa < 0] <- 0

# work on total energy
# files are given in power generated every 5 minutes, we need to convert this to energy, thus divide by 12
energy_conversion <- 12
wind.generation <- data.frame(wind.data.sa$DATE, rowSums(wind.data.sa[, 2:ncol(wind.data.sa), na.rm=T])/energy_conversion)
names(wind.generation) <- c("DATE", "TOTAL")

# aggregate to form groups according to AEMO official classification
wind.data.sa$COASTAL <- wind.data.sa$CATHROCK + wind.data.sa$STARHLWF + wind.data.sa$WPWF
wind.data.sa$SOUTHERN <- wind.data.sa$LKBONNY1 + wind.data.sa$LKBONNY2 + wind.data.sa$LKBONNY3 + wind.data.sa$CNUNDAWF
wind.data.sa$MIDNORTH <- rowSums(wind.data.sa[, c(2,4,6,7,11,12,13,14,15,17)])

# plot group output
wind.group.data <- data.frame(wind.data.sa$DATE, wind.data.sa$COASTAL, wind.data.sa$MIDNORTH, wind.data.sa$SOUTHERN)
names(wind.group.data) <- c("DATE", "COASTAL", "MIDNORTH", "SOUTHERN")

# remember: SA time is half an hour behind EST
start_date <- as.POSIXct("2015-06-01 00:00:00", tz = "EST") + minutes(30)
end_date <- as.POSIXct("2015-07-01 00:00:00", tz = "EST") + minutes(30)
# end_date <- tail(wind.group.data$DATE, 1)
# choose from row 5 onwards to match on the hour with price and demand data
wind.group.generation <- wind.group.data[5:nrow(wind.group.data), ] %>% group_by(DATE = cut(DATE, 
                         breaks="30 min")) %>% summarize(COASTAL = sum(COASTAL)/energy_conversion,
                         MIDNORTH = sum(MIDNORTH)/energy_conversion, 
                         SOUTHERN = sum(SOUTHERN)/energy_conversion)
wind.group.generation$DATE <- as.POSIXct(wind.group.generation$DATE, format="%Y-%m-%d %H:%M:%S", tz="EST")

wind.group.data.melt <- melt(wind.group.generation[wind.group.generation$DATE >= start_date & wind.group.generation$DATE 
                                                   <= end_date, ], id.vars="DATE")

# plot figure
p <- ggplot(wind.group.data.melt, aes(DATE, value, col=variable)) + geom_line() + xlab("Date (Eastern Standard Time)")
p <- p + ylab("Energy (MWh)") + ggtitle("South Australian Windfarm Group Output (Jun 2015)")
p <- p + scale_color_discrete(name="Legend", breaks=c("COASTAL", "MIDNORTH", "SOUTHERN"), 
                              labels=c("Coastal", "Midnorth", "Southern"))
print(p)




