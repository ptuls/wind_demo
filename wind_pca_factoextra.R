require("factoextra")

wind_pca <- prcomp(wind_data_sa[, 2:18], center=TRUE, scale.=TRUE)
fviz_pca_var(wind_pca, col.var="contrib") + scale_color_gradient2(low="white", mid="blue", 
        high="red", midpoint=55) + theme_minimal()