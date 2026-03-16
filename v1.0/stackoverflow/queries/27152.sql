
WITH RankedPosts AS (
    SELECT 
        p.Id,
        p.Title,
        p.CreationDate,
        p.ViewCount,
        p.Score,
        p.OwnerUserId,
        u.DisplayName AS OwnerDisplayName,
        COUNT(c.Id) AS CommentCount,
        arrayDistinct(groupArray(assumeNotNull(t.TagName))) AS Tags,
        ROW_NUMBER() OVER (PARTITION BY p.OwnerUserId ORDER BY p.Score DESC) AS PostRank
    FROM 
        Posts p
    LEFT JOIN 
        Users u ON p.OwnerUserId = u.Id
    LEFT JOIN 
        Comments c ON p.Id = c.PostId
    LEFT JOIN 
        (SELECT arrayJoin(splitByString('>', p.Tags)) AS tagName) AS tagName ON true
    LEFT JOIN 
        Tags t ON t.TagName = tagName.tagName
    WHERE 
        p.PostTypeId = 1 
    GROUP BY 
        p.Id, p.Title, p.CreationDate, p.ViewCount, p.Score, p.OwnerUserId, u.DisplayName
),
TopUsers AS (
    SELECT 
        OwnerUserId, 
        COUNT(*) AS PostCount,
        SUM(Score) AS TotalScore,
        SUM(ViewCount) AS TotalViews
    FROM 
        RankedPosts 
    WHERE 
        PostRank <= 5 
    GROUP BY 
        OwnerUserId
    ORDER BY 
        TotalScore DESC
    LIMIT 10
)
SELECT 
    u.Id AS UserId,
    u.DisplayName,
    tu.PostCount,
    tu.TotalScore,
    tu.TotalViews,
    groupArray(assumeNotNull(rp.Title)) AS TopPostTitles,
    groupArray(assumeNotNull(rp.Score)) AS TopPostScores
FROM 
    TopUsers tu
JOIN 
    Users u ON u.Id = tu.OwnerUserId
JOIN 
    RankedPosts rp ON rp.OwnerUserId = u.Id
GROUP BY 
    u.Id, u.DisplayName, tu.PostCount, tu.TotalScore, tu.TotalViews
ORDER BY 
    tu.TotalScore DESC;
