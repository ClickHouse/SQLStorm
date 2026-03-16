WITH PostStats AS (
    SELECT
        DATE_TRUNC('month', CreationDate) AS PostMonth,
        COUNT(*) AS TotalPosts,
        SUM(ViewCount) AS TotalViews,
        SUM(AnswerCount) AS TotalAnswers,
        SUM(CommentCount) AS TotalComments
    FROM
        Posts
    WHERE
        CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR
    GROUP BY
        PostMonth
),
UserStats AS (
    SELECT
        DATE_TRUNC('month', CreationDate) AS UserMonth,
        COUNT(*) AS TotalUsers,
        SUM(Reputation) AS TotalReputation,
        SUM(UpVotes) AS TotalUpVotes,
        SUM(DownVotes) AS TotalDownVotes
    FROM
        Users
    WHERE
        CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR
    GROUP BY
        UserMonth
)
SELECT
    ps.PostMonth,
    ps.TotalPosts,
    ps.TotalViews,
    ps.TotalAnswers,
    ps.TotalComments,
    us.TotalUsers,
    us.TotalReputation,
    us.TotalUpVotes,
    us.TotalDownVotes
FROM
    PostStats ps
FULL OUTER JOIN
    UserStats us ON ps.PostMonth = us.UserMonth
ORDER BY
    COALESCE(ps.PostMonth, us.UserMonth);