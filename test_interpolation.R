# testing the interpolation methods of zoo
library(zoo)
library(ggplot2)

# choose Hallett Windfarm 1 due to complete dataset
lo = 700
hi = 1999
interval = hi-lo+1
orig <- wind_data_sa[lo:hi,]$HALLWF2
test <- orig

# random errors
num_erasures <- 20
locs <- sample(1:interval, num_erasures, replace=FALSE)
test[locs] <- NA

# interpolate
test.linear <- na.approx(test)
test.spline <- na.spline(test)

err.linear <- abs(test.linear - orig)/orig*100
err.spline <- abs(test.spline - orig)/orig*100

# plot
plot(err.linear, type="linear")


# block missing
hour = 12
start = 510
num_hours = 6

# pathological case: start = 300, num_hours = 2, lo = 700, hi = 1999, HALLWF1
test <- orig
test[start:(start + num_hours*hour-1)] <- NA

# interpolate
test.linear <- na.approx(test)
test.spline <- na.spline(test)

err.linear <- abs(test.linear - orig)/abs(orig)*100
err.spline <- abs(test.spline - orig)/abs(orig)*100

# plot
plot(err.linear, type="linear")
max(err.linear[err.linear > 0])
mean(err.linear[err.linear > 0])

max(err.spline[err.spline > 0])
mean(err.spline[err.spline > 0])