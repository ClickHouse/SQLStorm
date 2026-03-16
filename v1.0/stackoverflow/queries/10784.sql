
SELECT 
    P.Id AS PostId,
    P.Title,
    P.CreationDate AS PostCreationDate,
    U.DisplayName AS OwnerDisplayName,
    U.Reputation AS OwnerReputation,
    T.TagName,
    COUNT(C.Id) AS CommentsCount,
    COUNT(V.Id) AS VotesCount
FROM 
    Posts P
JOIN 
    Users U ON P.OwnerUserId = U.Id
LEFT JOIN 
    Comments C ON P.Id = C.PostId
LEFT JOIN 
    Votes V ON P.Id = V.PostId
LEFT JOIN 
    arrayJoin(splitByString('><', P.Tags)) AS T(TagName) ON TRUE
WHERE 
    P.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 30 DAY
GROUP BY 
    P.Id, P.Title, P.CreationDate, U.DisplayName, U.Reputation, T.TagName
ORDER BY 
    P.CreationDate DESC
LIMIT 100;
