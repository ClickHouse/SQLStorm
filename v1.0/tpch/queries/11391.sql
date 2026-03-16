SELECT 
    l.l_suppkey, 
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM 
    lineitem l
JOIN 
    orders o ON l.l_orderkey = o.o_orderkey
WHERE 
    o.o_orderdate >= toDate('1995-01-01') 
    AND o.o_orderdate < toDate('1996-01-01')
GROUP BY 
    l.l_suppkey
ORDER BY 
    revenue DESC
LIMIT 10;
