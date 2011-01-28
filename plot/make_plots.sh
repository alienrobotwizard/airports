#!/usr/bin/env bash

if [ -e 'data/yearly_degrees.tsv' ]
then 
R --vanilla < flights_plot.R
R --vanilla < passenger_plot.R
else
  echo -e "Can't find \"yearly_degrees.tsv\"\n\nPlease calculate the yearly degree distribution and place into data/yearly_degrees.tsv"
fi
