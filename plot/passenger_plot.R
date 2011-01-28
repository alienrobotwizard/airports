# include the ggplot2 library for nice plots
library(ggplot2);

# Read data in and take a subset
degrees        <- read.table('data/yearly_degrees.tsv', header=FALSE, sep='\t', colClasses=c('character', 'character', 'numeric', 'numeric', 'numeric'));
names(degrees) <- c('airport_code', 'year', 'passenger_degree', 'seats_degree', 'flights_degree');
select_degrees <- subset(degrees, year=='2000' | year=='2001' | year=='2002' | year=='2009' | year=='1990');

# Plotting with ggplot2
pdf('passenger_degrees.pdf', 12, 6, pointsize=10);
ggplot(select_degrees, aes(x=passenger_degree, fill=year)) + geom_density(colour='black', alpha=0.3) + scale_x_log10() + ylab('Probability') + xlab(expression(log[10] ('Passengers in + Passengers out'))) + opts(title='Passenger Degree Distribution')
