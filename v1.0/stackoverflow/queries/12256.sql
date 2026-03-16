
SELECT 
    p.Id AS PostId,
    p.Title,
    p.CreationDate,
    p.Score,
    p.ViewCount,
    p.AnswerCount,
    p.CommentCount,
    p.FavoriteCount,
    u.Id AS UserId,
    u.DisplayName,
    u.Reputation,
    u.CreationDate AS UserCreationDate,
    COUNT(c.Id) AS CommentCount,
    arrayDistinct(groupArray(assumeNotNull(t.TagName))) AS Tags,
    arrayDistinct(groupArray(assumeNotNull(bh.UserDisplayName))) AS Editors
FROM 
    Posts p
JOIN 
    Users u ON p.OwnerUserId = u.Id
LEFT JOIN 
    Comments c ON p.Id = c.PostId
LEFT JOIN 
    PostHistory bh ON p.Id = bh.PostId
LEFT JOIN 
    arrayJoin(splitByString(',', p.Tags)) AS tag ON TRUE
LEFT JOIN 
    Tags t ON t.TagName = TRIM(tag)
WHERE 
    p.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR 
GROUP BY 
    p.Id, p.Title, p.CreationDate, p.Score, p.ViewCount, p.AnswerCount, 
    p.CommentCount, p.FavoriteCount, u.Id, u.DisplayName, 
    u.Reputation, u.CreationDate
ORDER BY 
    p.CreationDate DESC
LIMIT 
    100;
