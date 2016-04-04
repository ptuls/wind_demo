library(ggplot2)
library(ggbiplot)
library(zoo)

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


theta <- seq(0,2*pi,length.out = 100)
circle <- data.frame(x = cos(theta), y = sin(theta))
p <- ggplot(circle,aes(x,y)) + geom_path()

loadings <- data.frame(wind_pca$rotation, .names = row.names(wind_pca$rotation))
p + geom_text(data=loadings, mapping=aes(x = PC1, y = PC2, label = .names, colour = row.names(wind_pca$rotation))) +
  coord_fixed(ratio=1) +
  labs(x = "PC1", y = "PC2")


theta <- seq(0,2*pi,length.out = 100)
circle <- data.frame(x = cos(theta), y = sin(theta))
p <- ggplot2::ggplot(circle,aes(x,y)) + geom_path()

loadings <- data.frame(wind_pca$rotation)
p + geom_text(data=loadings, mapping=aes(x = PC1, y = PC2), label='')+
  coord_fixed(ratio=1) +
  labs(x = "PC1", y = "PC2")

# take differences between 5 minute intervals; want to see the largest change between consecutive intervals
# convert to matrix first, take differences, then back to dataframe, but lost dates in the process
wind_diff <- data.frame(diff(as.matrix(wind_data_sa_interpolated[, 2:18])))
wind_diff_pca <- prcomp(wind_diff, center=TRUE, scale.=TRUE)

g <- ggbiplot(wind_diff_pca, scale = 1, obs.scale = 1, var.scale = 1, alpha = 0, circle = TRUE)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal', legend.position = 'top')
print(g)

wind_group_pca <- prcomp(wind_data_group[, 18:20], center=TRUE, scale.=TRUE)

g <- ggbiplot(wind_group_pca, scale = 1, obs.scale = 1, var.scale = 1, alpha = 0, circle = TRUE)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal', legend.position = 'top')
print(g)