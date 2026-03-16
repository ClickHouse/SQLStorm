SELECT 
    pt.Name AS PostType,
    COUNT(p.Id) AS PostCount,
    AVG(p.Score) AS AvgScore,
    AVG(p.ViewCount) AS AvgViewCount,
    AVG(u.Reputation) AS AvgUserReputation,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(u.DisplayName))), ', ') AS UserNames
FROM 
    Posts p
JOIN 
    PostTypes pt ON p.PostTypeId = pt.Id
LEFT JOIN 
    Users u ON p.OwnerUserId = u.Id
WHERE 
    p.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 30 DAY 
GROUP BY 
    pt.Name
ORDER BY 
    PostCount DESC;