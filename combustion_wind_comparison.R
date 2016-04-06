library(ggplot2)
library(dplyr)
library(reshape2)
library(zoo)
library(lubridate)

# read data
wind.data.sa <- read.csv("~/Documents/Power/wind_data_sa.csv", sep=",")
combustion.data.sa <- read.csv("~/Documents/Power/combustion_data_sa.csv", sep=",")

# AEMO files are based on Eastern Standard Time, so ensure all times are the same
wind.data.sa$DATE <- as.POSIXct(wind.data.sa$DATE, format="%Y/%m/%d %H:%M:%S", tz="EST")
combustion.data.sa$DATE <- as.POSIXct(combustion.data.sa$DATE, format="%Y/%m/%d %H:%M:%S", tz="EST")

# testing with setting to 0
wind.data.sa[is.na(wind.data.sa)] <- 0
combustion.data.sa[is.na(combustion.data.sa)] <- 0

# there exists negative power values and these are small potentially due to measurement
# errors; we set them to 0
wind.data.sa[wind.data.sa < 0] <- 0
combustion.data.sa[combustion.data.sa < 0] <- 0

# work on total energy measured in MWh
# files are given in power generated every 5 minutes, we need to convert this to energy, thus divide by 12, and aggregate
# them into half hourly intervals
energy_conversion <- 12
wind.data.sa$TOTAL <- rowSums(wind.data.sa[, 2:ncol(wind.data.sa)])/energy_conversion
combustion.data.sa$TOTAL <- rowSums(combustion.data.sa[, 2:ncol(combustion.data.sa)])/energy_conversion

wind.generation <- data.frame(wind.data.sa$DATE, wind.data.sa$TOTAL)
names(wind.generation) <- c("DATE", "TOTAL")

combustion.generation <- data.frame(combustion.data.sa$DATE, combustion.data.sa$TOTAL)
names(combustion.generation) <- c("DATE", "TOTAL")

# aggregate in half hourly intervals for wind data
# choose from row 5 onwards to match on the hour with price and demand data
agg <- "1 hour"
wind.generation <- wind.generation[5:nrow(wind.generation), ] %>% group_by(DATE = cut(DATE, 
                           breaks=agg)) %>% summarize(TOTAL = sum(TOTAL))
wind.generation$DATE <- as.POSIXct(wind.generation$DATE, format="%Y-%m-%d %H:%M:%S", tz="EST")

# do the same for combustion
combustion.generation <- combustion.generation[5:nrow(combustion.generation), ] %>% group_by(DATE = cut(DATE, 
                          breaks=agg)) %>% summarize(TOTAL = sum(TOTAL))
combustion.generation$DATE <- as.POSIXct(combustion.generation$DATE, format="%Y-%m-%d %H:%M:%S", tz="EST")

# get percentage generation
percentage.generation <- data.frame(DATE=wind.generation$DATE, 
                        PC=100*wind.generation$TOTAL/(combustion.generation$TOTAL + wind.generation$TOTAL))

start_date1 <- as.POSIXct("2015-12-01 00:00:00", tz = "EST") + minutes(30)
end_date1 <- as.POSIXct("2016-03-01 00:00:00", tz="EST") + minutes(30)
plot.series.summer <- percentage.generation[percentage.generation$DATE >= start_date1 & percentage.generation$DATE <= end_date1, ]
plot.series.summer$LABEL <- rep("s")

p <- ggplot(plot.series.summer, aes(x=DATE, y=PC)) + geom_line(colour = "blue") + xlab("Hourly Interval (Eastern Standard Time)")
p <- p + ylab("%") + ggtitle("South Australian Windfarm Output Percentage of Total Output (Summer 2015)")
p <- p + stat_smooth(formula = mean, color="red", n = 7*24, se = T)
print(p)

start_date2 <- as.POSIXct("2015-06-01 00:00:00", tz = "EST") + minutes(30)
end_date2 <- as.POSIXct("2015-09-01 00:00:00", tz="EST") + minutes(30)
plot.series.winter <- percentage.generation[percentage.generation$DATE >= start_date2 & percentage.generation$DATE <= end_date2, ]
plot.series.winter$LABEL <- rep("w")


plot.series <- percentage.generation[percentage.generation$DATE >= start_date1 & percentage.generation$DATE <= end_date1 |
                                       percentage.generation$DATE >= start_date2 & percentage.generation$DATE <= end_date2, ]
plot.series$LAB <- rep("s")
plot.series[plot.series$DATE >= start_date2 & plot.series$DATE <= end_date2, ]$LAB <- rep("w")

dp <- ggplot(plot.series, aes(x=PC, fill=LAB)) + geom_density(alpha=0.5) + xlab("% of Total Production Power") + ylab("Density")
dp <- dp + ggtitle("Comparison of Summer vs. Winter 2015") + scale_fill_discrete(name="Legend", breaks=c("s", "w"), 
                                                                                  labels=c("Summer", "Winter"))
print(dp)

