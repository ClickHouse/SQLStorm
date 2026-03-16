SELECT 
    l_suppkey, 
    SUM(l_extendedprice * (1 - l_discount)) AS revenue
FROM 
    lineitem
WHERE 
    l_shipdate >= toDate('1997-01-01') AND l_shipdate < toDate('1997-12-31')
GROUP BY 
    l_suppkey
ORDER BY 
    revenue DESC
LIMIT 10;