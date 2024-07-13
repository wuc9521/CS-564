SELECT
    S.Sname
FROM
    Student AS S,
    Enroll AS E,
    Class AS C,
    Faculty AS F
WHERE
    S.Level = 'JR'
    AND E.Snum = S.Snum
    AND E.Cname = C.Cname
    AND C.Fid = F.Fid
    AND F.Fname = 'I. Teach';