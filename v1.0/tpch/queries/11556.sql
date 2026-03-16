SELECT
    o.o_orderkey,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue,
    o.o_orderdate
FROM
    orders o
JOIN
    lineitem l ON o.o_orderkey = l.l_orderkey
WHERE
    o.o_orderdate BETWEEN toDate('1996-01-01') AND toDate('1996-12-31')
GROUP BY
    o.o_orderkey, o.o_orderdate
ORDER BY
    revenue DESC
LIMIT 10;
