
WITH PostStats AS (
    SELECT 
        p.Id AS PostId,
        p.Title,
        p.CreationDate,
        p.Score,
        p.ViewCount,
        COUNT(c.Id) AS CommentCount,
        COUNT(v.Id) AS VoteCount,
        arrayDistinct(groupArray(assumeNotNull(t.TagName))) AS Tags,
        COALESCE((SELECT COUNT(a.Id) FROM Posts a WHERE a.AcceptedAnswerId = p.Id), 0) AS AcceptedAnswers
    FROM 
        Posts p
    LEFT JOIN 
        Comments c ON p.Id = c.PostId
    LEFT JOIN 
        Votes v ON p.Id = v.PostId
    LEFT JOIN 
        (SELECT arrayJoin(splitByString('<>', p.Tags)) AS TagName, p.Id FROM Posts p) AS t ON p.Id = t.Id
    GROUP BY 
        p.Id, p.Title, p.CreationDate, p.Score, p.ViewCount
)

SELECT 
    PostId,
    Title,
    CreationDate,
    Score,
    ViewCount,
    CommentCount,
    VoteCount,
    Tags,
    AcceptedAnswers
FROM 
    PostStats
ORDER BY 
    Score DESC, ViewCount DESC;
