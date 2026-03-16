SELECT 
    SUM(l_extendedprice * (1 - l_discount)) AS revenue, 
    o_orderdate
FROM 
    lineitem 
JOIN 
    orders ON l_orderkey = o_orderkey 
WHERE 
    l_shipdate BETWEEN toDate('1994-01-01') AND toDate('1994-12-31') 
GROUP BY 
    o_orderdate 
ORDER BY 
    o_orderdate;
