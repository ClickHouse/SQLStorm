SELECT 
    U.DisplayName AS UserDisplayName,
    P.Title AS PostTitle,
    PH.PostHistoryTypeId,
    COUNT(PH.Id) AS EditCount,
    SUM(CASE WHEN PH.PostHistoryTypeId IN (4, 5, 6) THEN 1 ELSE 0 END) AS TitleBodyTagEdits,
    SUM(CASE WHEN PH.PostHistoryTypeId IN (10, 11, 12) THEN 1 ELSE 0 END) AS ClosureReopenCount,
    AVG(toUnixTimestamp((toDateTime64('2024-10-01 12:34:56', 6) - PH.CreationDate))) AS AverageTimeBetweenEdits
FROM 
    Users U
JOIN 
    Posts P ON U.Id = P.OwnerUserId
JOIN 
    PostHistory PH ON P.Id = PH.PostId
WHERE 
    PH.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR
GROUP BY 
    U.DisplayName, P.Title, PH.PostHistoryTypeId
HAVING 
    COUNT(PH.Id) > 5
ORDER BY 
    EditCount DESC, UserDisplayName ASC;