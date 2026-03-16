SELECT 
    l_shipmode, 
    COUNT(*) AS number_of_orders, 
    SUM(l_extendedprice) AS total_revenue 
FROM 
    lineitem 
WHERE 
    l_shipdate >= toDate('1997-01-01') AND l_shipdate < toDate('1998-01-01') 
GROUP BY 
    l_shipmode 
ORDER BY 
    total_revenue DESC;