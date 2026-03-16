WITH UserRankings AS (
    SELECT 
        U.Id AS UserId,
        U.DisplayName,
        U.Reputation,
        ROW_NUMBER() OVER (ORDER BY U.Reputation DESC) AS Rank
    FROM 
        Users U
),
PostDetails AS (
    SELECT 
        P.Id AS PostId,
        P.Title,
        P.CreationDate,
        P.Score,
        P.ViewCount,
        P.AnswerCount,
        P.CommentCount,
        U.DisplayName AS OwnerDisplayName,
        (SELECT COUNT(*) FROM Votes V WHERE V.PostId = P.Id AND V.VoteTypeId = 2) AS UpVotes,
        (SELECT COUNT(*) FROM Votes V WHERE V.PostId = P.Id AND V.VoteTypeId = 3) AS DownVotes
    FROM 
        Posts P
    LEFT JOIN 
        Users U ON P.OwnerUserId = U.Id
    WHERE 
        P.PostTypeId = 1 AND 
        P.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 1 YEAR
),
TopPosts AS (
    SELECT 
        PD.*,
        UR.Reputation AS UserReputation,
        UR.Rank
    FROM 
        PostDetails PD
    JOIN 
        UserRankings UR ON PD.OwnerDisplayName = UR.DisplayName
    ORDER BY 
        PD.Score DESC, 
        PD.ViewCount DESC
    LIMIT 10
)
SELECT 
    TP.PostId,
    TP.Title,
    TP.CreationDate,
    TP.Score,
    TP.ViewCount,
    TP.AnswerCount,
    TP.CommentCount,
    TP.UpVotes,
    TP.DownVotes,
    TP.OwnerDisplayName,
    TP.UserReputation,
    TP.Rank
FROM 
    TopPosts TP
WHERE 
    EXISTS (
        SELECT 1 
        FROM Comments C 
        WHERE C.PostId = TP.PostId
    )
ORDER BY 
    TP.UpVotes DESC, 
    TP.CreationDate DESC;