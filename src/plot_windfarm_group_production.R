# plot the windfarm energy production output for the three AEMO windfarm 
# groups: the Coastal, Midnorth and Southern groups

library(ggplot2)
library(dplyr)
library(reshape2)
library(lubridate)
library(magrittr)

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
wind.generation <- data.frame(wind.data.sa$DATE, rowSums(wind.data.sa[, 2:ncol(wind.data.sa)], na.rm=T)/energy_conversion)
names(wind.generation) <- c("DATE", "TOTAL")

# aggregate to form groups according to AEMO official classification
wind.data.sa$COASTAL <- wind.data.sa$CATHROCK + wind.data.sa$STARHLWF + wind.data.sa$WPWF
wind.data.sa$SOUTHERN <- wind.data.sa$LKBONNY1 + wind.data.sa$LKBONNY2 + wind.data.sa$LKBONNY3 + wind.data.sa$CNUNDAWF
wind.data.sa$MIDNORTH <- rowSums(wind.data.sa[, c(2,4,6,7,11,12,13,14,15,17)])
wind.data.sa$TOTAL <- rowSums(wind.data.sa[,2:17])

# plot group output
wind.group.data <- data.frame(wind.data.sa$DATE, wind.data.sa$COASTAL, wind.data.sa$MIDNORTH, wind.data.sa$SOUTHERN, 
                              wind.data.sa$TOTAL)
names(wind.group.data) <- c("DATE", "COASTAL", "MIDNORTH", "SOUTHERN", "TOTAL")

# choose from row 5 onwards to match on the hour with price and demand data
agg <- "30 min"
wind.group.generation <- wind.group.data[5:nrow(wind.group.data), ] %>% group_by(DATE = cut(DATE, 
                         breaks=agg)) %>% summarize(COASTAL = sum(COASTAL)/energy_conversion,
                         MIDNORTH = sum(MIDNORTH)/energy_conversion, 
                         SOUTHERN = sum(SOUTHERN)/energy_conversion,
                         TOTAL = sum(TOTAL)/energy_conversion)
wind.group.generation$DATE <- as.POSIXct(wind.group.generation$DATE, format="%Y-%m-%d %H:%M:%S", tz="EST")


# remember: SA time is half an hour behind EST
# change start_date and end_date to obtain the different seasons; here, we
# set the dates for summer of 2015
summer_start <- "2015-12-01 00:00:00"
summer_end <- "2016-03-01 00:00:00"

start.date <- as.POSIXct(summer_start, tz = "EST") + minutes(30)
end.date <- as.POSIXct(summer_end, tz = "EST") + minutes(30)

wind.group.data.melt <- melt(wind.group.generation[wind.group.generation$DATE >= start.date & wind.group.generation$DATE 
                                                   <= end.date, ], id.vars="DATE")

# plot figure for the three windfarm groups according to the official AEMO classification
p <- ggplot(wind.group.data.melt, aes(DATE, value, col=variable)) + geom_line() + xlab("Date")
p <- p + ylab("Energy (MWh)") + ggtitle("South Australian Windfarm Group Output (Summer 2015)")
p <- p + scale_color_discrete(name="Legend", breaks=c("COASTAL", "MIDNORTH", "SOUTHERN"), 
                              labels=c("Coastal", "Midnorth", "Southern")) + theme_minimal()
print(p)

# plot output densities
p1 <- ggplot(wind.group.data.melt, aes(value, fill=variable)) + geom_density(alpha = 0.3) + xlab("Energy (MWh)")
p1 <- p1 + ylab("Density") + ggtitle("South Australian Windfarm Group Output (Summer 2015)")
p1 <- p1 + scale_fill_discrete(name="Legend", breaks=c("COASTAL", "MIDNORTH", "SOUTHERN", "TOTAL"), 
                              labels=c("Coastal", "Midnorth", "Southern", "Total")) + theme_minimal()
print(p1)


# redo the functions; sometimes melt gets wonky 
start.date <- as.POSIXct(summer_start, tz = "EST") + minutes(30)
end.date <- as.POSIXct(summer_end, tz = "EST") + minutes(30)

wind.coastal <- data.frame(wind.data.sa$DATE, wind.data.sa$CATHROCK, wind.data.sa$STARHLWF, wind.data.sa$WPWF, wind.data.sa$COASTAL)
names(wind.coastal) <- c("DATE", "CATHROCK", "STARHLWF", "WPWF", "COASTAL")
# choose from row 5 onwards to match on the hour with price and demand data
agg <- "30 min"
wind.coastal.generation <- wind.coastal %>% group_by(DATE = cut(DATE, 
                         breaks=agg)) %>% summarize(CATHROCK = sum(CATHROCK)/energy_conversion,
                         STARHLWF = sum(STARHLWF)/energy_conversion, 
                         WPWF = sum(WPWF)/energy_conversion,
                         COASTAL = sum(COASTAL)/energy_conversion)
wind.coastal.generation$DATE <- as.POSIXct(wind.coastal.generation$DATE, format="%Y-%m-%d %H:%M:%S", tz="EST")

wind.coastal.melt <- melt(wind.coastal.generation[wind.coastal.generation$DATE >= start.date & wind.coastal.generation$DATE 
                                                   <= end.date, ], id.vars="DATE")

# plot the wind energy production for the coastal group
p2 <- ggplot(wind.coastal.melt, aes(DATE, value, col=variable)) + geom_line() + xlab("Date")
p2 <- p2 + ylab("Energy (MWh)") + ggtitle("Coastal Group Output")
p2 <- p2 + scale_color_discrete(name="Legend", breaks=c("CATHROCK", "STARHLWF", "WPWF", "COASTAL"), 
                               labels=c("Cathedral Rock", "Starfish Hill", "Wattle Point", "Coastal Total")) + theme_minimal()
print(p2)