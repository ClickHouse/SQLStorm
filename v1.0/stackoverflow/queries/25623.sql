
WITH TagDetails AS (
    SELECT 
        t.TagName,
        COUNT(p.Id) AS PostCount,
        SUM(CASE WHEN p.PostTypeId = 2 THEN 1 ELSE 0 END) AS AnswerCount,
        SUM(CASE WHEN p.PostTypeId = 1 THEN 1 ELSE 0 END) AS QuestionCount,
        arrayDistinct(groupArray(assumeNotNull(u.DisplayName))) AS TopUsers,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(p.Title))), '; ') AS TopPostTitles,
        MIN(p.CreationDate) AS FirstPostDate,
        MAX(p.CreationDate) AS LastPostDate
    FROM 
        Tags t
    JOIN 
        Posts p ON p.Tags LIKE '%' || t.TagName || '%'
    LEFT JOIN 
        Users u ON p.OwnerUserId = u.Id
    GROUP BY 
        t.TagName
),
TagStatistics AS (
    SELECT 
        TagName,
        PostCount,
        AnswerCount,
        QuestionCount,
        FirstPostDate,
        LastPostDate,
        toUnixTimestamp((LastPostDate - FirstPostDate)) / 86400 AS ActiveDays,
        (PostCount * 1.0 / NULLIF(toUnixTimestamp((LastPostDate - FirstPostDate)) / 86400, 0)) AS PostsPerDay
    FROM 
        TagDetails
),
RankedTags AS (
    SELECT 
        TagName,
        PostCount,
        AnswerCount,
        QuestionCount,
        ActiveDays,
        PostsPerDay,
        RANK() OVER (ORDER BY PostsPerDay DESC) AS TagRank
    FROM 
        TagStatistics
)
SELECT 
    rt.TagName,
    rt.PostCount,
    rt.AnswerCount,
    rt.QuestionCount,
    rt.ActiveDays,
    rt.PostsPerDay,
    rt.TagRank,
    td.TopUsers,
    td.TopPostTitles
FROM 
    RankedTags rt
JOIN 
    TagDetails td ON rt.TagName = td.TagName
WHERE 
    rt.PostsPerDay > 0.5
ORDER BY 
    rt.TagRank;
