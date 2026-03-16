
WITH RankedPosts AS (
    SELECT p.Id AS PostId,
           p.Title,
           p.Body,
           p.Tags,
           p.CreationDate,
           p.Score,
           u.Reputation AS OwnerReputation,
           ROW_NUMBER() OVER (PARTITION BY p.Tags ORDER BY p.Score DESC) AS TagRank
    FROM Posts p
    JOIN Users u ON p.OwnerUserId = u.Id
    WHERE p.PostTypeId = 1  
),
RecentPosts AS (
    SELECT PostId,
           Title,
           Body,
           Tags,
           CreationDate,
           Score,
           OwnerReputation
    FROM RankedPosts
    WHERE TagRank <= 5  
    AND CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 30 DAY
),
TagStatistics AS (
    SELECT TagName,
           COUNT(DISTINCT PostId) AS PostCount,
           AVG(OwnerReputation) AS AvgReputation,
           MAX(CreationDate) AS LatestPostDate
    FROM RecentPosts
    CROSS JOIN arrayJoin(splitByString('><', Tags)) AS TagName
    GROUP BY TagName
)
SELECT ts.TagName,
       ts.PostCount,
       ts.AvgReputation,
       ts.LatestPostDate,
       arrayStringConcat(groupArray(assumeNotNull(rp.Title)), '; ') AS TopTitles,
       arrayStringConcat(groupArray(assumeNotNull(rp.Body)), '; ') AS TopBodies
FROM TagStatistics ts
JOIN RecentPosts rp ON ts.TagName = ANY(splitByString('><', rp.Tags))
GROUP BY ts.TagName, ts.PostCount, ts.AvgReputation, ts.LatestPostDate
ORDER BY ts.PostCount DESC, ts.AvgReputation DESC;
