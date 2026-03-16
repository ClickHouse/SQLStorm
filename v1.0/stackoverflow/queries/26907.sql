WITH RankedPosts AS (
    SELECT 
        p.Id AS PostId,
        p.Title,
        p.ViewCount,
        p.CreationDate,
        p.Tags,
        p.Score,
        u.DisplayName AS OwnerDisplayName,
        ROW_NUMBER() OVER (PARTITION BY p.Tags ORDER BY p.Score DESC) AS Rank
    FROM 
        Posts p
    JOIN 
        Users u ON p.OwnerUserId = u.Id
    WHERE 
        p.PostTypeId = 1 
        AND p.CreationDate >= cast('2024-10-01' as date) - INTERVAL 1 YEAR 
),
TopTags AS (
    SELECT 
        arrayJoin(splitByString('><', Tags)) AS Tag
    FROM 
        RankedPosts
    WHERE 
        Rank = 1
)
SELECT 
    rt.Tag,
    COUNT(*) AS TotalTopPosts,
    AVG(rp.ViewCount) AS AvgViews,
    AVG(rp.Score) AS AvgScore,
    arrayDistinct(groupArray(assumeNotNull(rp.OwnerDisplayName))) AS UniqueAuthors
FROM 
    RankedPosts rp
JOIN 
    TopTags rt ON rt.Tag = ANY(splitByString('><', rp.Tags))
GROUP BY 
    rt.Tag
ORDER BY 
    TotalTopPosts DESC,
    AvgScore DESC;