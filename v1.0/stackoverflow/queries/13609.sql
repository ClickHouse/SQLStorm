
SELECT 
    p.Id AS PostId,
    p.Title,
    p.CreationDate,
    p.Score,
    p.ViewCount,
    COUNT(v.Id) AS VoteCount,
    COUNT(c.Id) AS CommentCount,
    COUNT(b.Id) AS BadgeCount,
    arrayDistinct(groupArray(assumeNotNull(t.TagName))) AS Tags,
    u.Reputation,
    u.DisplayName AS OwnerDisplayName,
    u.Location
FROM 
    Posts p
LEFT JOIN 
    Votes v ON p.Id = v.PostId
LEFT JOIN 
    Comments c ON p.Id = c.PostId
LEFT JOIN 
    Users u ON p.OwnerUserId = u.Id
LEFT JOIN 
    Badges b ON u.Id = b.UserId
LEFT JOIN 
    arrayJoin(splitByString(',', p.Tags)) AS tag_name ON true
LEFT JOIN 
    Tags t ON t.TagName = tag_name
WHERE 
    p.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR
GROUP BY 
    p.Id, p.Title, p.CreationDate, p.Score, p.ViewCount, 
    u.Reputation, u.DisplayName, u.Location
ORDER BY 
    p.Score DESC, p.CreationDate DESC
LIMIT 100;
