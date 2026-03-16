
SELECT 
    u.DisplayName AS UserDisplayName,
    COUNT(DISTINCT p.Id) AS PostCount,
    COALESCE(SUM(CASE WHEN vote.VoteTypeId = 2 THEN 1 ELSE 0 END), 0) AS TotalUpVotes,
    COALESCE(SUM(CASE WHEN vote.VoteTypeId = 3 THEN 1 ELSE 0 END), 0) AS TotalDownVotes,
    AVG(p.Score) AS AveragePostScore,
    MIN(p.CreationDate) AS FirstPostDate,
    MAX(p.CreationDate) AS LatestPostDate,
    COUNT(DISTINCT b.Id) AS BadgeCount,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(pt.Name))), ', ') AS PostTypes,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(tag.TagName))), ', ') AS UsedTags
FROM 
    Users u
JOIN 
    Posts p ON u.Id = p.OwnerUserId
LEFT JOIN 
    Votes vote ON p.Id = vote.PostId
LEFT JOIN 
    Badges b ON u.Id = b.UserId
LEFT JOIN 
    PostTypes pt ON p.PostTypeId = pt.Id
LEFT JOIN 
    arrayJoin(splitByString(',', p.Tags)) AS tag(TagName) ON TRUE
WHERE 
    u.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR
GROUP BY 
    u.DisplayName
HAVING 
    COUNT(DISTINCT p.Id) > 10
ORDER BY 
    TotalUpVotes DESC, AveragePostScore DESC;
