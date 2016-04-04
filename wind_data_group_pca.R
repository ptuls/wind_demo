library(ggplot2)
library(ggbiplot)
library(zoo)

# load data
wind_data_sa <- read.csv("wind_data_sa.csv", sep=",")

# aggregate the windfarm power production according to AEMO's classification
# first perform linear interpolation
wind_data_sa.linear <- na.approx(wind_data_sa)

# aggregate
wind_data_sa$COASTAL <- wind_data_sa$CATHROCK + wind_data_sa$STARHLWF + wind_data_sa$WPWF
wind_data_sa$SOUTHERN <- wind_data_sa$LKBONNY1 + wind_data_sa$LKBONNY2 + wind_data_sa$LKBONNY3 + wind_data_sa$CNUNDAWF
wind_data_sa$MIDNORTH <- rowSums(wind_data_sa[, c(2,4,6,7,11,12,13,14,15,17)])

# decompose via PCA
wind_pca_group <- prcomp(~., data=wind_data_sa[, 19:21], center=TRUE, scale.=TRUE, na.action=na.omit)

# plot pca
g <- ggbiplot(wind_pca_group, choices=1:2, scale = 1,  obs.scale = 0, var.scale = 1, circle = TRUE, alpha = 0.0)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal', legend.position = 'top') + ggtitle('PCA Windfarm Group')
print(g)