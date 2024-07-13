SELECT F.Fname, COUNT(C.Cname) AS class_num
FROM Faculty AS F
JOIN Class AS C ON F.Fid = C.Fid
WHERE C.Fid NOT IN (
    SELECT C.Fid
    FROM Class AS C
    WHERE C.Room <> 'R128'
)
AND C.Room = 'R128'
GROUP BY F.Fid, F.Fname;