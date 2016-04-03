# Plot densities for the south east group
library(ggplot2)

# South-east group
p1 <- ggplot(wind_data_sa, aes(x=LKBONNY1)) + geom_density(alpha = 0.3, fill="#000099", na.rm = TRUE) 
p1 <- p1 + xlab("5-min Power Produced (MW)") + ylab("Density") + ggtitle("Lake Bonny 1")
p2 <- ggplot(wind_data_sa, aes(x=LKBONNY2)) + geom_density(alpha = 0.3, fill="red", na.rm = TRUE) 
p2 <- p2 + xlab("5-min Power Produced (MW)") + ylab("Density") + ggtitle("Lake Bonny 2")
p3 <- ggplot(wind_data_sa, aes(x=LKBONNY3)) + geom_density(alpha = 0.3, fill="green", na.rm = TRUE) 
p3 <- p3 + xlab("5-min Power Produced (MW)") + ylab("Density") + ggtitle("Lake Bonny 3")
p4 <- ggplot(wind_data_sa, aes(x=CNUNDAWF)) + geom_density(alpha = 0.3, fill="#FF9900", na.rm = TRUE) +
      xlim(-1, max(wind_data_sa$CNUNDAWF)) 
p4 <- p4 + xlab("5-min Power Produced (MW)") + ylab("Density") + ggtitle("Canunda")

# Plot multiple plots on same page (see multiplot.R)
multiplot(p1, p2, p3, p4, cols=2)

# South-east group
p1 <- ggplot(wind_data_sa, aes(x=CATHROCK)) + geom_density(alpha = 0.3, fill="#000099", na.rm = TRUE) 
p1 <- p1 + xlab("5-min Power Produced (MW)") + ylab("Density") + ggtitle("Cathedral Rock")
p2 <- ggplot(wind_data_sa, aes(x=STARHLWF)) + geom_density(alpha = 0.3, fill="red", na.rm = TRUE) 
p2 <- p2 + xlab("5-min Power Produced (MW)") + ylab("Density") + ggtitle("Starfish Hill")
p3 <- ggplot(wind_data_sa, aes(x=WPWF)) + geom_density(alpha = 0.3, fill="green", na.rm = TRUE) 
p3 <- p3 + xlab("5-min Power Produced (MW)") + ylab("Density") + ggtitle("Wattle Point")

# Plot multiple plots on same page (see multiplot.R)
multiplot(p1, p2, p3, cols=2)