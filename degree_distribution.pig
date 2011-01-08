-- Load data (boring part)
flight_edges = LOAD '$FLIGHT_EDGES' AS (origin_code:chararray, destin_code:chararray, passengers:int, flights:int, month:int);
--

-- Pull out data for a specific time window
time_window   = FILTER flight_edges BY (month > 200106) AND (month < 200202);

-- For every (airport,month) pair get passengers and flights out
edges_out     = FOREACH time_window GENERATE
                  origin_code AS airport,
                  month       AS month,
                  passengers  AS passengers_out,
                  flights     AS flights_out
                ;

-- For every (airport,month) pair get passengers and flights in
edges_in      = FOREACH time_window GENERATE
                  destin_code AS airport,
                  month       AS month,
                  passengers  AS passengers_in,
                  flights     AS flights_in
                ;

-- group them together and sum
grouped_edges = COGROUP edges_in BY (airport,month), edges_out BY (airport,month);
degree_dist   = FOREACH grouped_edges {
                  passenger_degree = SUM(edges_in.passengers_in) + SUM(edges_out.passengers_out);
                  flights_degree   = SUM(edges_in.flights_in)    + SUM(edges_out.flights_out);
                  GENERATE
                    FLATTEN(group)   AS (airport, month),
                    passenger_degree AS passenger_degree,
                    flights_degree   AS flights_degree
                  ;
                };

DUMP degree_dist;
