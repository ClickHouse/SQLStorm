SELECT 
    SUM(l_extendedprice * (1 - l_discount)) AS revenue, 
    o_orderdate 
FROM 
    lineitem 
JOIN 
    orders ON l_orderkey = o_orderkey 
WHERE 
    o_orderdate between toDate('1995-01-01') AND toDate('1996-12-31') 
GROUP BY 
    o_orderdate 
ORDER BY 
    o_orderdate;
