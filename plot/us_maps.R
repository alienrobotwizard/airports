library(maps);
library(ggplot2);

# Read in data and name columns
geo_dist        <- read.table('degree_dist_geo.tsv', colClasses=c('character', 'numeric', 'numeric', 'numeric', 'numeric', 'character'), header=FALSE,sep='\t');
names(geo_dist) <- c('airport_code', 'lat', 'lon', 'passenger_degree', 'flights_degree', 'year');

# Get rid of points with NA, focus on flights that both start and end in US
geo_dist        <- subset(geo_dist, !is.na(passenger_degree) & !is.na(flights_degree));
geo_dist        <- subset(geo_dist, lat > 20 & lat < 55 & lon > -140 & lon < -50);

pdf("us_map_aiport_degrees.pdf", height=8, width=12);
us_map          <- data.frame(map('usa', plot=FALSE)[c("x", "y")]);
us_map_plot     <- ggplot(geo_dist, aes(x=lon, y=lat)) + geom_point(aes(size=flights_degree, colour=cut(passenger_degree,7))) + scale_color_brewer(type='seq', palette='YlOrRd') + geom_path(aes(x=us_map$x, y=us_map$y));
us_map_plot;
dev.off();
