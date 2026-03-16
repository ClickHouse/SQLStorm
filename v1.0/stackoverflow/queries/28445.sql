
WITH RankedPosts AS (
    SELECT 
        p.Id AS PostId,
        p.Title,
        p.CreationDate,
        p.Score,
        p.ViewCount,
        COUNT(NULLIF(TRIM(tag), '')) AS TagCount,
        u.DisplayName AS OwnerDisplayName,
        u.Reputation AS OwnerReputation,
        ROW_NUMBER() OVER (PARTITION BY p.PostTypeId ORDER BY p.Score DESC, p.ViewCount DESC) AS Rank
    FROM 
        Posts p
    JOIN 
        Users u ON p.OwnerUserId = u.Id
    JOIN 
        arrayJoin(splitByString('<>', SUBSTRING(p.Tags, 2, LENGTH(p.Tags) - 2))) AS tag ON TRUE
    WHERE 
        p.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR
    GROUP BY 
        p.Id, p.Title, p.CreationDate, p.Score, p.ViewCount, u.DisplayName, u.Reputation, p.PostTypeId
)

SELECT 
    rp.PostId,
    rp.Title,
    rp.CreationDate,
    rp.Score,
    rp.ViewCount,
    rp.TagCount,
    rp.OwnerDisplayName,
    rp.OwnerReputation,
    COALESCE(ph.Comment, 'No changes made') AS LastModificationComment,
    ph.CreationDate AS LastModificationDate
FROM 
    RankedPosts rp
LEFT JOIN 
    PostHistory ph ON rp.PostId = ph.PostId 
WHERE 
    rp.Rank <= 10
ORDER BY 
    rp.OwnerDisplayName, 
    rp.Score DESC;
