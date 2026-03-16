SELECT 
    DATE_TRUNC('month', p.CreationDate) AS Month,
    COUNT(DISTINCT p.Id) AS TotalPosts,
    COUNT(DISTINCT c.Id) AS TotalComments,
    COUNT(DISTINCT v.Id) AS TotalVotes
FROM 
    Posts p
LEFT JOIN 
    Comments c ON p.Id = c.PostId
LEFT JOIN 
    Votes v ON p.Id = v.PostId
WHERE 
    p.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR
GROUP BY 
    Month
ORDER BY 
    Month ASC;