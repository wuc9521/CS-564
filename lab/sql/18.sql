SELECT S.Sname
FROM Student AS S
JOIN Enroll AS E ON S.Snum = E.Snum
GROUP BY S.Sname
HAVING COUNT(E.Cname) = (
    SELECT MAX(ClassCount)
    FROM (
        SELECT COUNT(E.Cname) AS ClassCount
        FROM Enroll AS E
        GROUP BY E.Snum
    ) AS MaxClasses
);