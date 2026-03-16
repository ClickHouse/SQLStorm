SELECT 
    p.p_brand,
    COUNT(DISTINCT ps.ps_partkey) AS unique_parts,
    AVG(p.p_retailprice) AS avg_price,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(s.s_name))), ', ') AS suppliers,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(n.n_name))), ', ') AS nations
FROM 
    part p
JOIN 
    partsupp ps ON p.p_partkey = ps.ps_partkey
JOIN 
    supplier s ON ps.ps_suppkey = s.s_suppkey
JOIN 
    nation n ON s.s_nationkey = n.n_nationkey
JOIN 
    region r ON n.n_regionkey = r.r_regionkey
WHERE 
    p.p_size > 50 AND 
    p.p_type LIKE 'rubber%'
GROUP BY 
    p.p_brand
HAVING 
    COUNT(DISTINCT s.s_suppkey) > 5
ORDER BY 
    avg_price DESC;
