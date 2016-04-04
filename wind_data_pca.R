library(ggplot2)
library(ggbiplot)
library(zoo)

# load data
wind_data_sa <- read.csv("wind_data_sa.csv", sep=",")

# interpolate if need be
# wind_data_sa.linear <- na.approx(wind_data_sa)
# wind_data_sa.spline <- na.approx(wind_data_sa)

# perform PCA
# note: na.action will not work if formula is not included
wind_pca <- prcomp(~., data=wind_data_sa[, 2:18], center=TRUE, scale.=TRUE, na.action = na.omit)

g <- ggbiplot(wind_pca, choices=1:2, scale = 1,  obs.scale = 0, var.scale = 1, circle = TRUE, alpha = 0.0)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal', legend.position = 'top') + ggtitle('PCA Windfarms')
print(g)

