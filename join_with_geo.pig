--
-- Joins previously calculated yearly degree distributions with airport locations so
-- we can plot on a map.
--
-- USAGE:
--
-- local mode:
-- pig -x local -p DEG_DIST=/path/to/degree_distribution -p AIRPORTS=/path/to/airport_locations.tsv -p DEG_DIST_GEO=/path/to/output join_with_geo.pig
--
-- hadoop mode:
-- pig -p DEG_DIST=/path/to/degree_distribution -p AIRPORTS=/path/to/airport_locations.tsv -p DEG_DIST_GEO=/path/to/output join_with_geo.pig
--

-- Load data (boring part)
deg_dist = LOAD '$DEG_DIST' AS (airport_code:chararray, year:int, passenger_degree:int, seats_degree:int, flights_degree:int);
airports = LOAD '$AIRPORTS' AS (airport_code:chararray, latitude:float, longitude:float); -- other fields will be dropped
--

-- Join tables together with inner join on common field
with_geo      = JOIN airports BY airport_code, deg_dist BY airport_code;
with_geo_flat = FOREACH with_geo GENERATE
                  airports::airport_code     AS airport_code,
                  airports::latitude         AS latitude,
                  airports::longitude        AS longitude,
                  deg_dist::passenger_degree AS passenger_degree,
                  deg_dist::seats_degree     AS seats_degree,
                  deg_dist::flights_degree   AS flights_degree,
                  deg_dist::year             AS year
                ;

-- Store into a flat file
STORE with_geo_flat INTO '$DEG_DIST_GEO';
