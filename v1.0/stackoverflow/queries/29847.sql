WITH TagStats AS (
    SELECT 
        t.TagName,
        COUNT(DISTINCT p.Id) AS TotalPosts,
        COUNT(DISTINCT CASE WHEN p.PostTypeId = 1 THEN p.Id END) AS TotalQuestions,
        COUNT(DISTINCT CASE WHEN p.PostTypeId = 2 THEN p.Id END) AS TotalAnswers,
        SUM(COALESCE(p.ViewCount, 0)) AS TotalViews,
        AVG(p.Score) AS AverageScore,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(u.DisplayName))), ', ') AS TopContributors
    FROM 
        Tags t
    JOIN 
        Posts p ON p.Tags LIKE CONCAT('%<', t.TagName, '>%')
    LEFT JOIN 
        Users u ON u.Id = p.OwnerUserId
    GROUP BY 
        t.TagName
),
RecentActivity AS (
    SELECT 
        p.Title,
        p.CreationDate,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(c.Text))), ' | ') AS RecentComments,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(CONCAT(u.DisplayName, ' (', c.CreationDate, ')')))), ', ') AS UsersCommented
    FROM 
        Posts p
    LEFT JOIN 
        Comments c ON c.PostId = p.Id
    LEFT JOIN 
        Users u ON u.Id = c.UserId
    WHERE 
        p.LastActivityDate > cast('2024-10-01 12:34:56' as timestamp) - INTERVAL '30 days'
    GROUP BY 
        p.Id, p.Title, p.CreationDate
)
SELECT 
    ts.TagName,
    ts.TotalPosts,
    ts.TotalQuestions,
    ts.TotalAnswers,
    ts.TotalViews,
    ts.AverageScore,
    ts.TopContributors,
    ra.Title AS RecentPostTitle,
    ra.CreationDate AS RecentPostDate,
    ra.RecentComments,
    ra.UsersCommented
FROM 
    TagStats ts
LEFT JOIN 
    RecentActivity ra ON ts.TagName = ANY(splitByString(',', (SELECT arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(t.TagName))), ',') FROM Tags t)))
ORDER BY 
    ts.TotalQuestions DESC, ts.TotalPosts DESC
LIMIT 10;