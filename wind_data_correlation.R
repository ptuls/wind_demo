library("GGally")

# group the wind farms
ggpairs(wind_data_group[, 1:3])

# detecting NAs
which(is.na(wind_data_sa))
# count number of NAs
sum(is.na(wind_data_sa))

wind_group_diff <- do.call(rbind, by(wind_data_group, wind_data_group$gvkey,function(data) { data <- ts(data) ; cbind(data,Quarter=diff(data[,2]),Two.Quarter=diff(data[,2],2))}))