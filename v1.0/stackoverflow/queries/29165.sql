
WITH RankedPosts AS (
    SELECT 
        p.Id AS PostId,
        p.Title,
        p.Body,
        p.Tags,
        p.CreationDate,
        ROW_NUMBER() OVER (PARTITION BY p.Tags ORDER BY p.ViewCount DESC) AS TagRank,
        p.OwnerUserId
    FROM 
        Posts p
    WHERE 
        p.PostTypeId = 1 AND 
        p.CreationDate > TIMESTAMP '2024-10-01 12:34:56' - INTERVAL '1 year' AND 
        p.ViewCount > 1000
),
TagStatistics AS (
    SELECT 
        arrayJoin(splitByString('>', assumeNotNull(Tags))) AS Tag,
        COUNT(*) AS PostCount,
        AVG(toUnixTimestamp((TIMESTAMP '2024-10-01 12:34:56' - CreationDate))) AS AvgAgeInSeconds
    FROM 
        RankedPosts
    GROUP BY 
        Tag
),
UserReputation AS (
    SELECT 
        u.Id AS UserId,
        u.DisplayName,
        SUM(v.BountyAmount) AS TotalBounty,
        COUNT(DISTINCT p.Id) AS PostsCount
    FROM 
        Users u
    JOIN 
        Posts p ON u.Id = p.OwnerUserId
    LEFT JOIN 
        Votes v ON p.Id = v.PostId AND v.VoteTypeId = 8  
    GROUP BY 
        u.Id, u.DisplayName
)
SELECT 
    rs.PostId,
    rs.Title,
    rs.Body,
    ts.Tag,
    ts.PostCount,
    ts.AvgAgeInSeconds,
    ur.DisplayName AS UserName,
    ur.TotalBounty,
    ur.PostsCount
FROM 
    RankedPosts rs
JOIN 
    TagStatistics ts ON ts.Tag = ANY(splitByString('>', assumeNotNull(rs.Tags)))
JOIN 
    UserReputation ur ON ur.UserId = rs.OwnerUserId
WHERE 
    rs.TagRank = 1
ORDER BY 
    ts.PostCount DESC, 
    ur.TotalBounty DESC
LIMIT 10;
