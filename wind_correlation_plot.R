# Perform a simple correlation plot

library(ggplot2)
library(ggbiplot)
library(zoo)
library(corrplot)

# load the data file
wind.data.sa <- read.csv("~/Documents/Power/wind_data_sa.csv", sep=",")

# interpolate if need be
# linear interpolation
wind.data.sa.linear <- na.approx(wind.data.sa)

# spline interpolation
# wind.data.sa.spline <- na.approx(wind.data.sa)

# zero method
# wind.data.sa.zeroed <- 0
# wind.data.sa.zeroed[is.na(wind.data.sa)] <- 0

# first check out the correlations; plot them for visualisation
# rather than interpolate the missing values, we drop the missing ones
# turns out there is little difference, since we are looking at the
# spatial structure (correlation matrix), not the temporal structure
temp <- na.omit(wind.data.sa)
corr.data <- cor(temp[,2:18])

# use hierarchical clustering to check difference with PCA
corrplot(corr.data, order="hclust", hclust.method="complete")