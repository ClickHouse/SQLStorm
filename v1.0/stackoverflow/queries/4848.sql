WITH RankedPosts AS (
    SELECT 
        p.Id,
        p.Title,
        p.Score,
        p.ViewCount,
        p.AnswerCount,
        p.CommentCount,
        ROW_NUMBER() OVER (PARTITION BY p.PostTypeId ORDER BY p.Score DESC) AS Rank,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(t.TagName))), ', ') AS Tags
    FROM 
        Posts p
    LEFT JOIN 
        Tags t ON t.WikiPostId = p.Id OR t.ExcerptPostId = p.Id
    WHERE 
        p.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR
    GROUP BY 
        p.Id, p.Title, p.Score, p.ViewCount, p.AnswerCount, p.CommentCount, p.PostTypeId
),

UserReputation AS (
    SELECT 
        u.Id AS UserId,
        u.Reputation,
        COALESCE(SUM(v.BountyAmount), 0) AS TotalBountyWon
    FROM 
        Users u
    LEFT JOIN 
        Votes v ON v.UserId = u.Id AND v.VoteTypeId = 8
    GROUP BY 
        u.Id, u.Reputation
),

TopUsers AS (
    SELECT 
        ur.UserId,
        ur.Reputation,
        ur.TotalBountyWon,
        DENSE_RANK() OVER (ORDER BY ur.Reputation DESC, ur.TotalBountyWon DESC) AS UserRank
    FROM 
        UserReputation ur
    WHERE 
        ur.Reputation > 0
)

SELECT 
    rp.Title AS PostTitle,
    rp.Score AS PostScore,
    rp.ViewCount AS PostViewCount,
    rp.AnswerCount AS TotalAnswers,
    rp.CommentCount AS TotalComments,
    rp.Tags AS AssociatedTags,
    tu.UserId AS TopUserId,
    tu.Reputation AS TopUserReputation,
    tu.TotalBountyWon AS TopUserBounty,
    CASE 
        WHEN rp.Rank <= 5 THEN 'Top 5'
        ELSE 'Other'
    END AS PostRankGroup
FROM 
    RankedPosts rp
JOIN 
    Posts p ON p.Id = rp.Id
LEFT JOIN 
    TopUsers tu ON p.OwnerUserId = tu.UserId
WHERE 
    p.AcceptedAnswerId IS NOT NULL
    AND p.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 6 MONTH
ORDER BY 
    rp.Score DESC, tu.Reputation DESC
LIMIT 100;