SELECT 
    ph.PostId,
    p.Title,
    ph.PostHistoryTypeId,
    p.CreationDate,
    ph.CreationDate AS RevisionDate,
    u.DisplayName AS EditedByUser,
    ph.Comment,
    ph.Text
FROM 
    PostHistory ph
JOIN 
    Posts p ON ph.PostId = p.Id
JOIN 
    Users u ON ph.UserId = u.Id
WHERE 
    ph.CreationDate >= toDateTime64('2024-10-01 12:34:56', 6) - INTERVAL 30 DAY 
ORDER BY 
    ph.CreationDate DESC;