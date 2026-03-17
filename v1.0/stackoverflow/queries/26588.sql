
WITH RankedPosts AS (
    SELECT 
        p.Id AS PostId,
        p.Title,
        p.Body,
        p.CreationDate,
        p.ViewCount,
        p.Score,
        u.DisplayName AS OwnerDisplayName,
        ROW_NUMBER() OVER (PARTITION BY p.OwnerUserId ORDER BY p.Score DESC) AS RankByScore,
        COUNT(c.Id) AS CommentsCount,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(t.TagName))), ', ') AS TagList
    FROM 
        Posts p
    JOIN 
        Users u ON p.OwnerUserId = u.Id
    LEFT JOIN 
        Comments c ON p.Id = c.PostId
    LEFT JOIN 
        (
            SELECT 
                arrayJoin(splitByString('> <', assumeNotNull(substr(p.Tags, 2, length(p.Tags) - 2)))) AS TagName
        ) t ON TRUE
    WHERE 
        p.PostTypeId = 1
    GROUP BY 
        p.Id, u.DisplayName, p.Title, p.Body, p.CreationDate, p.ViewCount, p.Score
),
FilteredPosts AS (
    SELECT 
        rp.*,
        CASE 
            WHEN rp.RankByScore <= 5 THEN 'Top 5 Posts'
            WHEN rp.ViewCount > 1000 THEN 'Highly Viewed'
            ELSE 'Other'
        END AS PostCategory
    FROM 
        RankedPosts rp
)
SELECT 
    PostCategory,
    COUNT(PostId) AS TotalPosts,
    AVG(Score) AS AverageScore,
    AVG(ViewCount) AS AverageViewCount,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(OwnerDisplayName))), ', ') AS Contributors,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(TagList))), '; ') AS TagsSummary
FROM 
    FilteredPosts
GROUP BY 
    PostCategory
ORDER BY 
    TotalPosts DESC;
