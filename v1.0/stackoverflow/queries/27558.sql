
WITH TagCounts AS (
    SELECT 
        arrayJoin(splitByString('><', assumeNotNull(SUBSTRING(Tags FROM 2 FOR LENGTH(Tags) - 2)))) AS TagName,
        COUNT(*) AS PostCount
    FROM 
        Posts
    WHERE 
        PostTypeId = 1 
    GROUP BY 
        arrayJoin(splitByString('><', assumeNotNull(SUBSTRING(Tags FROM 2 FOR LENGTH(Tags) - 2))))
),
UserReputation AS (
    SELECT 
        u.Id AS UserId,
        u.DisplayName,
        u.Reputation,
        COUNT(DISTINCT p.Id) AS QuestionsAnswered 
    FROM 
        Users u
    JOIN 
        Posts p ON u.Id = p.OwnerUserId
    WHERE 
        p.PostTypeId = 2 
    GROUP BY 
        u.Id, u.DisplayName, u.Reputation
),
TopTags AS (
    SELECT 
        TagName,
        PostCount
    FROM 
        TagCounts
    ORDER BY 
        PostCount DESC
    LIMIT 10
),
UserActivity AS (
    SELECT 
        ur.UserId, 
        ur.DisplayName, 
        ur.Reputation,
        CONCAT('User has answered ', ur.QuestionsAnswered, ' questions.') AS Activity,
        tt.TagName
    FROM 
        UserReputation ur
    JOIN 
        Posts p ON ur.UserId = p.OwnerUserId
    JOIN 
        TopTags tt ON tt.TagName = ANY(splitByString('><', assumeNotNull(SUBSTRING(p.Tags FROM 2 FOR LENGTH(p.Tags) - 2))))
)
SELECT 
    ua.UserId,
    ua.DisplayName,
    ua.Reputation,
    ua.Activity,
    arrayDistinct(groupArray(assumeNotNull(ua.TagName))) AS RelatedTags
FROM 
    UserActivity ua
GROUP BY 
    ua.UserId, ua.DisplayName, ua.Reputation, ua.Activity
HAVING 
    COUNT(DISTINCT ua.TagName) >= 3 
ORDER BY 
    ua.Reputation DESC;
