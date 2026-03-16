
WITH RankedPosts AS (
    SELECT 
        p.Id AS PostId,
        p.Title,
        p.Body,
        p.CreationDate,
        p.ViewCount,
        p.Score,
        p.Tags,
        ROW_NUMBER() OVER (PARTITION BY p.PostTypeId ORDER BY p.CreationDate DESC) AS Rank
    FROM 
        Posts p
    WHERE 
        p.CreationDate >= '2024-10-01 12:34:56'::timestamp - INTERVAL '1 year'
),
TopRankedPosts AS (
    SELECT 
        rp.PostId,
        rp.Title,
        rp.Body,
        rp.CreationDate,
        rp.ViewCount,
        rp.Score,
        rp.Tags
    FROM 
        RankedPosts rp
    WHERE 
        rp.Rank <= 5
),
PopularTags AS (
    SELECT 
        LOWER(TRIM(arrayJoin(splitByString('><', SUBSTRING(p.Tags FROM 2 FOR LENGTH(p.Tags) - 2))))) AS Tag,
        COUNT(*) AS TagCount
    FROM 
        Posts p
    WHERE 
        p.CreationDate >= '2024-10-01 12:34:56'::timestamp - INTERVAL '1 year'
    GROUP BY 
        Tag
    ORDER BY 
        TagCount DESC
    LIMIT 10
)
SELECT 
    trp.Title,
    trp.ViewCount,
    trp.Score,
    arrayDistinct(groupArray(assumeNotNull(pt.Name))) AS PostTypes,
    arrayDistinct(groupArray(assumeNotNull(pgt.Tag))) AS PopularTags
FROM 
    TopRankedPosts trp
LEFT JOIN 
    PostTypes pt ON trp.PostId IN (SELECT p.Id FROM Posts p WHERE p.PostTypeId = pt.Id)
LEFT JOIN 
    PopularTags pgt ON pgt.Tag = ANY(splitByString('><', SUBSTRING(trp.Tags FROM 2 FOR LENGTH(trp.Tags) - 2)))
GROUP BY 
    trp.PostId, trp.Title, trp.ViewCount, trp.Score
ORDER BY 
    trp.Score DESC, trp.ViewCount DESC;
