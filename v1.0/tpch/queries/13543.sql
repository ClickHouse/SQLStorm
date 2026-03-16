SELECT 
    l_shipmode, 
    SUM(l_quantity) AS total_quantity, 
    SUM(l_extendedprice) AS total_revenue 
FROM 
    lineitem 
WHERE 
    l_shipdate >= toDate('1995-01-01') 
    AND l_shipdate < toDate('1996-01-01') 
GROUP BY 
    l_shipmode 
ORDER BY 
    total_revenue DESC;
