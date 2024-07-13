SELECT AVG(S.Age) AS avg_age
FROM Student AS S
JOIN Enroll AS E ON S.Snum = E.Snum
JOIN Class AS C ON E.Cname = C.Cname
JOIN Faculty AS F ON C.Fid = F.Fid
WHERE F.Fname = 'I. Teach';
