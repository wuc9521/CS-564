SELECT
    C.Cname,
    C.Room,
    C.meets_at
FROM
    Student AS S,
    Enroll AS E,
    Class AS C
WHERE
    S.Sname = 'Joseph Thompson'
    AND S.Snum = E.Snum
    AND E.Cname = C.Cname;