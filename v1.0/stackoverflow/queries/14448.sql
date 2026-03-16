
WITH PostActivity AS (
    SELECT
        toYear(CreationDate) AS Year,
        toMonth(CreationDate) AS Month,
        COUNT(*) AS TotalPosts,
        SUM(CASE WHEN PostTypeId = 1 THEN 1 ELSE 0 END) AS TotalQuestions,
        SUM(CASE WHEN PostTypeId = 2 THEN 1 ELSE 0 END) AS TotalAnswers,
        SUM(ViewCount) AS TotalViews,
        SUM(Score) AS TotalScore
    FROM
        Posts
    WHERE
        CreationDate >= CURRENT_DATE - INTERVAL 1 YEAR
    GROUP BY
        toYear(CreationDate),
        toMonth(CreationDate)
),
UserActivity AS (
    SELECT
        toYear(CreationDate) AS Year,
        toMonth(CreationDate) AS Month,
        COUNT(DISTINCT Id) AS TotalUsers
    FROM
        Users
    WHERE
        CreationDate >= CURRENT_DATE - INTERVAL 1 YEAR
    GROUP BY
        toYear(CreationDate),
        toMonth(CreationDate)
)
SELECT
    p.Year,
    p.Month,
    p.TotalPosts,
    p.TotalQuestions,
    p.TotalAnswers,
    p.TotalViews,
    p.TotalScore,
    u.TotalUsers
FROM
    PostActivity p
JOIN
    UserActivity u ON p.Year = u.Year AND p.Month = u.Month
ORDER BY
    p.Year DESC, p.Month DESC;
