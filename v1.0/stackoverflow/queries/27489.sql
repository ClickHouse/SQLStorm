WITH RankedPosts AS (
    SELECT 
        p.Id AS PostId,
        p.Title,
        p.Body,
        p.CreationDate,
        p.ViewCount,
        p.Score,
        p.Tags,
        length(splitByString('>', substring(p.Tags, 2, length(p.Tags)-2)), 1) AS TagCount,
        ROW_NUMBER() OVER (PARTITION BY p.OwnerUserId ORDER BY p.CreationDate DESC) AS PostRank,
        u.Reputation AS UserReputation,
        u.DisplayName AS UserDisplayName
    FROM 
        Posts p
    JOIN 
        Users u ON p.OwnerUserId = u.Id
    WHERE 
        p.PostTypeId = 1 AND 
        p.CreationDate >= cast('2024-10-01 12:34:56' as timestamp) - INTERVAL '30 days' 
),
TopTags AS (
    SELECT 
        arrayJoin(splitByString('>', substring(p.Tags, 2, length(p.Tags)-2))) AS TagName,
        COUNT(*) AS TagUsage
    FROM 
        Posts p
    WHERE 
        p.PostTypeId = 1 AND 
        p.CreationDate >= cast('2024-10-01 12:34:56' as timestamp) - INTERVAL '30 days'
    GROUP BY 
        TagName
    ORDER BY 
        TagUsage DESC
    LIMIT 10
),
PostComments AS (
    SELECT 
        c.PostId,
        COUNT(c.Id) AS CommentCount,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(c.UserDisplayName))), ', ') AS CommentAuthors
    FROM 
        Comments c
    GROUP BY 
        c.PostId
)
SELECT 
    r.PostId,
    r.Title,
    r.Body,
    r.CreationDate,
    r.ViewCount,
    r.Score,
    r.TagCount,
    r.UserReputation,
    r.UserDisplayName,
    pc.CommentCount,
    pc.CommentAuthors,
    tt.TagName AS PopularTag,
    tt.TagUsage AS TagUsageCount
FROM 
    RankedPosts r
LEFT JOIN 
    PostComments pc ON r.PostId = pc.PostId
LEFT JOIN 
    TopTags tt ON tt.TagName = ANY(splitByString('>', substring(r.Tags, 2, length(r.Tags)-2)))
WHERE 
    r.PostRank = 1 
ORDER BY 
    r.Score DESC, r.ViewCount DESC;