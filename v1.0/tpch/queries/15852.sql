
SELECT 
    SUM(l_extendedprice * (1 - l_discount)) AS revenue
FROM 
    lineitem
WHERE 
    l_shipdate >= toDate('1996-01-01') AND l_shipdate < toDate('1996-01-01') + INTERVAL '1' YEAR;
