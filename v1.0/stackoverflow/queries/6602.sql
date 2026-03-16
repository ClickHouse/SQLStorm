WITH PostStatistics AS (
    SELECT 
        p.Id AS PostId,
        p.Title,
        p.CreationDate,
        COUNT(c.Id) AS CommentCount,
        COUNT(DISTINCT v.UserId) AS VoteCount,
        SUM(CASE WHEN v.VoteTypeId = 2 THEN 1 ELSE 0 END) AS UpVotes,
        SUM(CASE WHEN v.VoteTypeId = 3 THEN 1 ELSE 0 END) AS DownVotes,
        t.TagName
    FROM 
        Posts p
    LEFT JOIN 
        Comments c ON p.Id = c.PostId
    LEFT JOIN 
        Votes v ON p.Id = v.PostId
    LEFT JOIN 
        arrayJoin(splitByString('<>', p.Tags)) AS t(TagName) ON true
    WHERE 
        p.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR
    GROUP BY 
        p.Id, p.Title, p.CreationDate, t.TagName
),
RankedPosts AS (
    SELECT 
        *,
        RANK() OVER (PARTITION BY TagName ORDER BY VoteCount DESC, UpVotes DESC) AS Rank
    FROM 
        PostStatistics
)
SELECT 
    PostId,
    Title,
    CreationDate,
    CommentCount,
    VoteCount,
    UpVotes,
    DownVotes,
    TagName
FROM 
    RankedPosts
WHERE 
    Rank <= 10
ORDER BY 
    TagName, Rank;