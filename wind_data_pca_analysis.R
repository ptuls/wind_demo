# Perform a simple correlation, PCA and factor analysis on the data of wind power production
# per 5 minutes

library(ggplot2)
library(ggbiplot)
library(zoo)
library(corrplot)

# get multiplot function
source("~/Documents/Power/multiplot.R")

# load the data file
wind.data.sa <- read.csv("~/Documents/Power/wind_data_sa.csv", sep=",")

# interpolate if need be
# wind.data.sa.linear <- na.approx(wind.data.sa)
# wind.data.sa.spline <- na.approx(wind.data.sa)
# wind.data.sa.zeroed[is.na(wind.data.sa)] <- 0

# perform PCA
# note: na.action will not work if formula is not included
wind.pca <- prcomp(~., data=wind.data.sa[, 2:ncol(wind.data.sa)], center=TRUE, scale.=TRUE, na.action = na.omit)

p <- ggbiplot(wind.pca, choices=1:2, scale = 1,  obs.scale = 0, var.scale = 1, circle = TRUE, alpha = 0.0)
p <- p + scale_color_discrete(name = '')
p <- p + theme(legend.direction = 'horizontal', legend.position = 'top') + ggtitle('PCA of the Wind Farms in SA')

# aggregate the windfarm power production according to AEMO's classification
wind.data.sa$COASTAL <- wind.data.sa$CATHROCK + wind.data.sa$STARHLWF + wind.data.sa$WPWF
wind.data.sa$SOUTHERN <- wind.data.sa$LKBONNY1 + wind.data.sa$LKBONNY2 + wind.data.sa$LKBONNY3 + wind.data.sa$CNUNDAWF
wind.data.sa$MIDNORTH <- rowSums(wind.data.sa[, c(2,4,6,7,11,12,13,14,15,17)])

# decompose via PCA
wind.pca.group <- prcomp(~., data=wind.data.sa[, 19:21], center=TRUE, scale.=TRUE, na.action=na.omit)

# plot pca
pg <- ggbiplot(wind.pca.group, choices=1:2, scale = 1,  obs.scale = 0, var.scale = 1, circle = TRUE, alpha = 0.0)
pg <- pg + scale_color_discrete(name = '')
pg <- pg + theme(legend.direction = 'horizontal', legend.position = 'top') + ggtitle('PCA of the Wind Farm Groups')

# plot multiple plots on same plot
multiplot(p, pg, cols=2)