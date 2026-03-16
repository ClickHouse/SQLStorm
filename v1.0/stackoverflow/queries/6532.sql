WITH RankedPosts AS (
    SELECT 
        p.Id,
        p.Title,
        p.CreationDate,
        p.Score,
        p.ViewCount,
        COALESCE(CAST(p.OwnerDisplayName AS VARCHAR), 'Community') AS OwnerDisplayName,
        arrayDistinct(groupArray(assumeNotNull(t.TagName))) AS Tags,
        COUNT(DISTINCT c.Id) AS CommentCount,
        COUNT(DISTINCT ph.Id) AS EditHistoryCount
    FROM 
        Posts p
    LEFT JOIN 
        Comments c ON p.Id = c.PostId
    LEFT JOIN 
        PostHistory ph ON p.Id = ph.PostId
    LEFT JOIN 
        arrayJoin(splitByString('><', p.Tags)) AS t(TagName) ON TRUE
    WHERE 
        p.PostTypeId = 1 AND p.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR
    GROUP BY 
        p.Id, p.Title, p.CreationDate, p.Score, p.ViewCount, p.OwnerDisplayName
),
PostRankings AS (
    SELECT 
        rp.Id,
        rp.Title,
        rp.OwnerDisplayName,
        rp.CreationDate,
        rp.Score,
        rp.ViewCount,
        rp.Tags,
        rp.CommentCount,
        rp.EditHistoryCount,
        RANK() OVER (ORDER BY rp.Score DESC, rp.ViewCount DESC, rp.CreationDate ASC) AS PostRank
    FROM 
        RankedPosts rp
)
SELECT 
    pr.Id,
    pr.Title,
    pr.OwnerDisplayName,
    pr.CreationDate,
    pr.Score,
    pr.ViewCount,
    pr.Tags,
    pr.CommentCount,
    pr.EditHistoryCount,
    pr.PostRank
FROM 
    PostRankings pr
WHERE 
    pr.PostRank <= 10
ORDER BY 
    pr.PostRank;