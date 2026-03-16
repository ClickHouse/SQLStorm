
WITH RankedPosts AS (
    SELECT 
        p.Id,
        p.Title,
        p.CreationDate,
        p.Score,
        p.ViewCount,
        ROW_NUMBER() OVER (PARTITION BY p.OwnerUserId ORDER BY p.Score DESC) AS RankByScore,
        COUNT(c.Id) OVER (PARTITION BY p.Id) AS CommentCount,
        COUNT(v.Id) OVER (PARTITION BY p.Id, v.VoteTypeId) AS VoteCount
    FROM 
        Posts p
    LEFT JOIN 
        Comments c ON p.Id = c.PostId
    LEFT JOIN 
        Votes v ON p.Id = v.PostId AND v.VoteTypeId = 2 
    WHERE 
        p.CreationDate >= CURRENT_DATE - INTERVAL 1 YEAR
),
CloseReasons AS (
    SELECT 
        ph.PostId,
        arrayStringConcat(groupArray(assumeNotNull(cr.Name)), ', ') AS CloseReasonNames
    FROM 
        PostHistory ph
    JOIN 
        CloseReasonTypes cr ON CAST(ph.Comment AS INTEGER) = cr.Id
    WHERE 
        ph.PostHistoryTypeId = 10 
    GROUP BY 
        ph.PostId
)
SELECT 
    rp.Id,
    rp.Title,
    rp.CreationDate,
    rp.Score,
    rp.ViewCount,
    rp.CommentCount,
    rp.RankByScore,
    COALESCE(cr.CloseReasonNames, 'No close reasons') AS CloseReasonNames
FROM 
    RankedPosts rp
LEFT JOIN 
    CloseReasons cr ON rp.Id = cr.PostId
WHERE 
    rp.RankByScore <= 5
ORDER BY 
    rp.Score DESC,
    rp.ViewCount DESC
LIMIT 10 OFFSET 10;
