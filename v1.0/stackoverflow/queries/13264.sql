
SELECT 
    p.Id AS PostId,
    p.Title,
    p.ViewCount,
    p.Score,
    p.CreationDate,
    u.DisplayName AS OwnerDisplayName,
    COUNT(DISTINCT c.Id) AS CommentCount,
    COUNT(DISTINCT v.Id) AS VoteCount,
    arrayDistinct(groupArray(assumeNotNull(t.TagName))) AS Tags,
    p.AcceptedAnswerId,
    MAX(ph.CreationDate) AS LastEdited
FROM 
    Posts p
JOIN 
    Users u ON p.OwnerUserId = u.Id
LEFT JOIN 
    Comments c ON p.Id = c.PostId
LEFT JOIN 
    Votes v ON p.Id = v.PostId
LEFT JOIN 
    arrayJoin(splitByString('>', assumeNotNull(p.Tags))) AS tag_ids ON true
LEFT JOIN 
    Tags t ON t.TagName = tag_ids
LEFT JOIN 
    PostHistory ph ON p.Id = ph.PostId
GROUP BY 
    p.Id, p.Title, p.ViewCount, p.Score, p.CreationDate, u.DisplayName, p.AcceptedAnswerId
ORDER BY 
    p.Score DESC, p.ViewCount DESC
LIMIT 100;
