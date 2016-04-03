require(dplyr)
require(ggplot2)

midnorth <- data.frame(DELAY=wind_data_group$MIDNORTH[-1], ORIG=wind_data_group$MIDNORTH[1:116006]) 
midnorth <- midnorth %>% mutate(PCDIFF=abs(DELAY-ORIG)/ifelse(ORIG == 0, NA, abs(ORIG))*100)
coastal <- data.frame(DELAY=wind_data_group$COASTAL[-1], ORIG=wind_data_group$COASTAL[1:116006]) 
coastal <- coastal %>% mutate(PCDIFF=abs(DELAY-ORIG)/ifelse(ORIG == 0, NA, abs(ORIG))*100)
southeast <- data.frame(DELAY=wind_data_group$SOUTHEAST[-1], ORIG=wind_data_group$SOUTHEAST[1:116006]) 
southeast <- southeast %>% mutate(PCDIFF=abs(DELAY-ORIG)/ifelse(ORIG == 0, NA, abs(ORIG))*100)

#qplot(midnorth$PCDIFF, geom="density", xlab="% change in 5-minute output (MW)", ylab = 
#        "Proportion") + xlim(-200,200) + ggtitle("Power generation variation for the MIDNORTH group")

# South-east group
plt1 <- ggplot(midnorth, aes(x=PCDIFF)) + geom_density(alpha = 0.3, fill="#000099", na.rm = TRUE) + xlim(0,100) +
  xlab("% absolute change in 5-minute output (MW)")
plt2 <- ggplot(coastal, aes(x=PCDIFF)) + geom_density(alpha = 0.3, fill="#FF9900", na.rm = TRUE) + xlim(0,100) +
  xlab("% absolute change in 5-minute output (MW)")
plt3 <- ggplot(southeast, aes(x=PCDIFF)) + geom_density(alpha = 0.3, fill="green", na.rm = TRUE) + xlim(0,100) +
  xlab("% absolute change in 5-minute output (MW)")

# Plot multiple plots on same page (see multiplot.R)
multiplot(plt1, plt2, plt3, cols=2)

# South-east group differences
cnunda_diff <- data.frame(DELAY=wind_data_sa_interpolated$CNUNDAWF[-1], ORIG=wind_data_sa_interpolated$CNUNDAWF[1:116639])
cnunda_diff <- cnunda_diff %>% mutate(PCDIFF=abs(DELAY-ORIG)/ifelse(ORIG == 0, NA, abs(ORIG))*100)
lkbonny1_diff <- data.frame(DELAY=wind_data_sa_interpolated$LKBONNY1[-1], ORIG=wind_data_sa_interpolated$LKBONNY1[1:116639])
lkbonny1_diff <- lkbonny1_diff %>% mutate(PCDIFF=abs(DELAY-ORIG)/ifelse(ORIG == 0, NA, abs(ORIG))*100)
lkbonny2_diff <- data.frame(DELAY=wind_data_sa_interpolated$LKBONNY2[-1], ORIG=wind_data_sa_interpolated$LKBONNY2[1:116639])
lkbonny2_diff <- lkbonny2_diff %>% mutate(PCDIFF=abs(DELAY-ORIG)/ifelse(ORIG == 0, NA, abs(ORIG))*100)
lkbonny3_diff <- data.frame(DELAY=wind_data_sa_interpolated$LKBONNY3[-1], ORIG=wind_data_sa_interpolated$LKBONNY3[1:116639])
lkbonny3_diff <- lkbonny3_diff %>% mutate(PCDIFF=abs(DELAY-ORIG)/ifelse(ORIG == 0, NA, abs(ORIG))*100)

# South-east group
p1 <- ggplot(cnunda_diff, aes(x=PCDIFF)) + geom_density(alpha = 0.3, fill="#000099", na.rm = TRUE) + xlim(0,100) +
  xlab("% absolute change in power")
p2 <- ggplot(lkbonny1_diff, aes(x=PCDIFF)) + geom_density(alpha = 0.3, fill="red", na.rm = TRUE) + xlim(0,100) +
  xlab("% absolute change in power")
p3 <- ggplot(lkbonny2_diff, aes(x=PCDIFF)) + geom_density(alpha = 0.3, fill="green", na.rm = TRUE) + xlim(0,100) +
  xlab("% absolute change in power")
p4 <- ggplot(lkbonny3_diff, aes(x=PCDIFF)) + geom_density(alpha = 0.3, fill="#FF9900", na.rm = TRUE) + xlim(0,100) +
  xlab("% absolute change in power")

# Plot multiple plots on same page (see multiplot.R)
multiplot(p1, p2, p3, p4, cols=2)