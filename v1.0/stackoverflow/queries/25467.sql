
WITH RankedPosts AS (
    SELECT 
        P.Id AS PostId,
        P.Title,
        P.Body,
        U.DisplayName AS Author,
        P.CreationDate,
        P.Score,
        P.ViewCount,
        P.AnswerCount,
        P.CommentCount,
        P.Tags,
        ROW_NUMBER() OVER (PARTITION BY P.Tags ORDER BY P.CreationDate DESC) AS RankByTag
    FROM 
        Posts P
    JOIN 
        Users U ON P.OwnerUserId = U.Id
    WHERE 
        P.PostTypeId = 1 
        AND P.CreationDate > toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR 
        AND P.ViewCount > 100
),
TagDetails AS (
    SELECT 
        T.TagName,
        COUNT(DISTINCT RP.PostId) AS QuestionCount,
        SUM(RP.AnswerCount) AS TotalAnswers,
        AVG(RP.Score) AS AverageScore,
        SUM(RP.ViewCount) AS TotalViews
    FROM 
        RankedPosts RP
    JOIN 
        arrayJoin(splitByString('><', RP.Tags)) AS T(TagName) ON true
    GROUP BY 
        T.TagName
)
SELECT 
    TD.TagName,
    TD.QuestionCount,
    TD.TotalAnswers,
    TD.AverageScore,
    TD.TotalViews
FROM 
    TagDetails TD
WHERE 
    TD.QuestionCount >= 5 
ORDER BY 
    TD.TotalAnswers DESC,
    TD.AverageScore DESC;
