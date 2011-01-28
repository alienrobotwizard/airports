#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

class EdgeMapper < Wukong::Streamer::RecordStreamer
  #
  # Yield both ways so we can sum (passengers in + passengers out) and (flights
  # in + flights out) individually in the reduce phase.
  #
  def process origin_code, destin_code, passengers, flights, month
    yield [origin_code, month, "OUT", passengers, flights]
    yield [destin_code, month, "IN", passengers, flights]
  end
end

class DegreeCalculator < Wukong::Streamer::AccumulatingReducer
  #
  # What are we going to use as a key internally?
  #
  def get_key airport, month, in_or_out, passengers, flights
    [airport, month]
  end

  def start! airport, month, in_or_out, passengers, flights
    @out_degree = {:passengers => 0, :flights => 0}
    @in_degree  = {:passengers => 0, :flights => 0}
  end

  def accumulate airport, month, in_or_out, passengers, flights
    case in_or_out
    when "IN" then
      @in_degree[:passengers] += passengers.to_i
      @in_degree[:flights]    += flights.to_i
    when "OUT" then
      @out_degree[:passengers] += passengers.to_i
      @out_degree[:flights]    += flights.to_i
    end
  end

  #
  # For every airport and month, calculate passenger and flight degrees
  #
  def finalize

    # Passenger degrees (out, in, and total)
    passengers_out   = @out_degree[:passengers]
    passengers_in    = @in_degree[:passengers]
    passengers_total = passengers_in + passengers_out

    # Flight degrees (out, in, and total)
    flights_out      = @out_degree[:flights]
    flights_in       = @in_degree[:flights]
    flights_total    = flights_in + flights_out

    yield [key, passengers_in, passengers_out, passengers_total, flights_in, flights_out, flights_total]
  end
end

#
# Need to use 2 fields for partition so every record with the same airport and
# month land on the same reducer
#
Wukong::Script.new(
  EdgeMapper,
  DegreeCalculator,
  :partition_fields  => 2 # use two fields to partition records
  ).run
