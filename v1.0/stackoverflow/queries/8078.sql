
WITH RankedPosts AS (
    SELECT p.Id, p.Title, p.CreationDate, p.Score, p.ViewCount, 
           DENSE_RANK() OVER (PARTITION BY pt.Name ORDER BY p.Score DESC) AS RankByScore,
           DENSE_RANK() OVER (PARTITION BY pt.Name ORDER BY p.ViewCount DESC) AS RankByViews
    FROM Posts p
    JOIN PostTypes pt ON p.PostTypeId = pt.Id
    WHERE p.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR
),
TopPosts AS (
    SELECT Id, Title, CreationDate, Score, ViewCount, 
           (RankByScore + RankByViews) AS CombinedRank
    FROM RankedPosts
    WHERE RankByScore <= 5 OR RankByViews <= 5
)
SELECT tp.Title, tp.CreationDate, tp.Score, tp.ViewCount, 
       COUNT(c.Id) AS CommentCount, 
       MAX(v.CreationDate) AS LastVoteDate, 
       arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(b.Name))), ', ') AS Badges
FROM TopPosts tp
LEFT JOIN Comments c ON tp.Id = c.PostId
LEFT JOIN Votes v ON tp.Id = v.PostId
LEFT JOIN Badges b ON tp.Id = b.UserId
GROUP BY tp.Id, tp.Title, tp.CreationDate, tp.Score, tp.ViewCount, tp.CombinedRank
ORDER BY tp.CombinedRank
LIMIT 10;
