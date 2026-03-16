SELECT
    l_shipmode,
    SUM(l_extendedprice * (1 - l_discount)) AS revenue,
    COUNT(l_orderkey) AS order_count
FROM
    lineitem
WHERE
    l_shipdate >= toDate('1997-01-01') AND l_shipdate < toDate('1997-02-01')
GROUP BY
    l_shipmode
ORDER BY
    revenue DESC;