
WITH RankedPosts AS (
    SELECT 
        p.Id AS PostId,
        p.Title,
        p.CreationDate,
        p.Score,
        p.ViewCount,
        p.AnswerCount,
        COALESCE(u.DisplayName, 'Anonymous') AS Author,
        ROW_NUMBER() OVER (PARTITION BY p.PostTypeId ORDER BY p.Score DESC) AS rn,
        SUM(CASE WHEN v.VoteTypeId = 2 THEN 1 ELSE 0 END) OVER (PARTITION BY p.Id) AS Upvotes,
        SUM(CASE WHEN v.VoteTypeId = 3 THEN 1 ELSE 0 END) OVER (PARTITION BY p.Id) AS Downvotes
    FROM 
        Posts p
    LEFT JOIN 
        Users u ON p.OwnerUserId = u.Id
    LEFT JOIN 
        Votes v ON p.Id = v.PostId
    WHERE 
        p.CreationDate >= (toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR)
),

RecentComments AS (
    SELECT 
        c.PostId,
        COUNT(*) AS CommentCount,
        MAX(c.CreationDate) AS LastCommentDate
    FROM 
        Comments c
    WHERE 
        c.CreationDate >= (toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 MONTH)
    GROUP BY 
        c.PostId
),

PostHistoryFiltered AS (
    SELECT 
        ph.PostId,
        arrayStringConcat(groupArray(assumeNotNull(ph.Comment)), ', ') AS HistoryComments
    FROM 
        PostHistory ph
    WHERE 
        ph.CreationDate >= (toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 6 MONTH)
    GROUP BY 
        ph.PostId
)

SELECT 
    rp.PostId,
    rp.Title,
    rp.CreationDate,
    rp.Score,
    rp.ViewCount,
    rp.AnswerCount,
    rp.Author,
    rp.Upvotes,
    rp.Downvotes,
    COALESCE(rc.CommentCount, 0) AS RecentCommentCount,
    rc.LastCommentDate,
    COALESCE(phf.HistoryComments, 'No history') AS PostHistory
FROM 
    RankedPosts rp
LEFT JOIN 
    RecentComments rc ON rp.PostId = rc.PostId
LEFT JOIN 
    PostHistoryFiltered phf ON rp.PostId = phf.PostId
WHERE 
    rp.rn = 1 
    AND rp.Score > 0
ORDER BY 
    rp.Score DESC, rp.ViewCount DESC
LIMIT 100;
