#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'configliere' ; Configliere.use(:commandline, :env_var, :define)
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer
  def process *args
    airport_code, lat, lng, passenger_degree, seats_degree, flights_degree, year = args
    ppf = passenger_degree.to_f / flights_degree.to_f
    pps = ((passenger_degree.to_f / seats_degree.to_f)*100.0).to_i/100.0 rescue 0.0
    spf = seats_degree.to_f / flights_degree.to_f
    yield [year, airport_code, lat, lng, passenger_degree, flights_degree, ppf, pps, spf]
  end
end

class Reducer < Wukong::Streamer::AccumulatingReducer

  def initialize *args
    super(*args)
    @var = {}
  end

  def start! year, *_
    @var[year.to_i] = []
  end

  # year, lat, lon, passenger_degree, flights_degree, airport_code
  def accumulate *args
    year, airport_code, lat, lng, passenger_degree, flights_degree, ppf, pps, spf = args
    @var[year.to_i] << {:lat => lat.to_f, :lng => lng.to_f, :passenger_degree => passenger_degree.to_i, :flights_degree => flights_degree.to_i, :airport_code => airport_code, :ppf => ppf.to_f.round, :pps => pps.to_f, :spf => spf.to_f}
  end

  def finalize &blk
  end

  def after_stream
    # So big stuff lands on the bottom in the vis
    @var.each{|year, history| @var[year] = history.sort_by{|airport| - airport[:flights_degree]} }
    File.open('data/degree_dist_geo.js', 'wb'){|f| f.puts "var degree_dist = #{JSON.pretty_generate(JSON.parse(@var.to_json))};"}
  end
end

Wukong::Script.new(Mapper, Reducer).run
