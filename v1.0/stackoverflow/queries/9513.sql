
WITH RankedPosts AS (
    SELECT 
        p.Id AS PostId,
        p.Title,
        p.CreationDate,
        p.Score,
        p.ViewCount,
        p.AnswerCount,
        p.CommentCount,
        p.FavoriteCount,
        ROW_NUMBER() OVER (PARTITION BY pt.Name ORDER BY p.Score DESC, p.CreationDate DESC) AS Rank,
        u.DisplayName AS OwnerDisplayName,
        arrayDistinct(groupArray(assumeNotNull(t.TagName))) AS TagsList
    FROM 
        Posts p
    JOIN 
        PostTypes pt ON p.PostTypeId = pt.Id
    JOIN 
        Users u ON p.OwnerUserId = u.Id
    LEFT JOIN 
        arrayJoin(splitByString('<>', assumeNotNull(p.Tags))) AS tag ON TRUE
    LEFT JOIN 
        Tags t ON tag = t.TagName
    WHERE 
        p.CreationDate >= TIMESTAMP '2024-10-01 12:34:56' - INTERVAL '1 year' 
    GROUP BY 
        p.Id, pt.Name, u.DisplayName
),
TopRankedPosts AS (
    SELECT 
        *,
        COUNT(*) OVER (PARTITION BY Rank) AS TotalPosts 
    FROM 
        RankedPosts
    WHERE 
        Rank <= 5
)
SELECT 
    PostId,
    Title,
    CreationDate,
    Score,
    ViewCount,
    AnswerCount,
    CommentCount,
    FavoriteCount,
    OwnerDisplayName,
    TagsList,
    TotalPosts
FROM 
    TopRankedPosts
ORDER BY 
    TotalPosts DESC, Score DESC;
