SELECT
    S.Sname
FROM
    Student AS S,
    Enroll AS E
where
    S.Snum = E.Snum
    AND S.Level = 'JR'
    AND e.Cname = 'Database Systems';