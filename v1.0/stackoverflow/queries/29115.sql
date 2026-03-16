WITH PostTagCounts AS (
    SELECT 
        post.Id AS PostId, 
        arrayJoin(splitByString('><', substring(post.Tags, 2, length(post.Tags) - 2))) AS Tag
    FROM 
        Posts post
    WHERE 
        post.PostTypeId = 1
),
TagAggregates AS (
    SELECT 
        Tag, 
        COUNT(*) AS PostCount
    FROM 
        PostTagCounts
    GROUP BY 
        Tag
    HAVING 
        COUNT(*) > 5
),
UserPostCounts AS (
    SELECT 
        p.OwnerUserId, 
        COUNT(p.Id) AS UserPostCount
    FROM 
        Posts p
    WHERE 
        p.PostTypeId IN (1, 2) 
    GROUP BY 
        p.OwnerUserId
),
ActiveUsers AS (
    SELECT 
        u.Id AS UserId,
        u.DisplayName,
        u.Reputation,
        up.UserPostCount
    FROM 
        Users u
    JOIN 
        UserPostCounts up ON u.Id = up.OwnerUserId
    WHERE 
        u.LastAccessDate > toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR
),
TopPostTags AS (
    SELECT 
        t.Tag, 
        SUM(up.UserPostCount) AS TotalPosts
    FROM 
        TagAggregates t
    JOIN 
        PostTagCounts pt ON t.Tag = pt.Tag
    JOIN 
        UserPostCounts up ON pt.PostId = up.OwnerUserId
    GROUP BY 
        t.Tag
    ORDER BY 
        TotalPosts DESC
    LIMIT 10
)
SELECT 
    u.DisplayName, 
    u.Reputation, 
    t.Tag,
    t.TotalPosts
FROM 
    ActiveUsers u
JOIN 
    TopPostTags t ON u.UserPostCount > 10
ORDER BY 
    u.Reputation DESC, t.TotalPosts DESC;