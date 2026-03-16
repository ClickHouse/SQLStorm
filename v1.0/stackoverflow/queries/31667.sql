WITH RECURSIVE RecentPosts AS (
    SELECT Id, Title, CreationDate, OwnerUserId, Score, ViewCount
    FROM Posts
    WHERE CreationDate > toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 30 DAY
    UNION ALL
    SELECT p.Id, p.Title, p.CreationDate, p.OwnerUserId, p.Score, p.ViewCount
    FROM Posts p
    INNER JOIN RecentPosts rp ON p.Id = rp.Id
),
VoteSummary AS (
    SELECT
        PostId,
        SUM(CASE WHEN VoteTypeId = 2 THEN 1 ELSE 0 END) AS UpVotes,
        SUM(CASE WHEN VoteTypeId = 3 THEN 1 ELSE 0 END) AS DownVotes
    FROM Votes
    GROUP BY PostId
),
UserActivity AS (
    SELECT
        u.Id AS UserId,
        u.DisplayName,
        u.Reputation,
        COUNT(DISTINCT p.Id) AS PostsCreated,
        COALESCE(SUM(vs.UpVotes - vs.DownVotes), 0) AS NetVotes
    FROM Users u
    LEFT JOIN Posts p ON u.Id = p.OwnerUserId
    LEFT JOIN VoteSummary vs ON vs.PostId = p.Id
    GROUP BY u.Id, u.DisplayName, u.Reputation
    HAVING COUNT(DISTINCT p.Id) > 5
)
SELECT
    ra.UserId,
    ra.DisplayName,
    ra.Reputation,
    ra.PostsCreated,
    ra.NetVotes,
    p.Title,
    p.Score,
    p.ViewCount,
    COALESCE(vs.UpVotes, 0) AS TotalUpVotes,
    COALESCE(vs.DownVotes, 0) AS TotalDownVotes,
    arrayDistinct(groupArray(assumeNotNull(t.TagName))) AS Tags
FROM UserActivity ra
JOIN Posts p ON ra.UserId = p.OwnerUserId
LEFT JOIN VoteSummary vs ON vs.PostId = p.Id
LEFT JOIN (
    SELECT
        t.TagName
    FROM Tags t
    JOIN (
        SELECT arrayJoin(splitByString('>', p.Tags)) AS Tag
    ) AS tag_array ON t.TagName = tag_array.Tag
) AS t ON TRUE
WHERE p.CreationDate > toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 60 DAY
GROUP BY ra.UserId, ra.DisplayName, ra.Reputation, ra.PostsCreated, ra.NetVotes, p.Title, p.Score, p.ViewCount, vs.UpVotes, vs.DownVotes
ORDER BY ra.Reputation DESC, ra.NetVotes DESC
LIMIT 10;