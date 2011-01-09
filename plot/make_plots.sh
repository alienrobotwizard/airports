#!/usr/bin/env bash

if [ -e 'yearly_degrees.tsv' ]
then 
R --vanilla < flights_plot.R
R --vanilla < passenger_plot.R
else
  echo -e "Can't find \"yearly_degrees.tsv\"\n\nPlease calculate the yearly degree distribution and place in this directory."
fi
