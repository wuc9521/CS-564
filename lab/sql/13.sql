SELECT
    DISTINCT S.Sname
FROM
    Student AS S,
    Enroll AS E
    RIGHT JOIN (
        SELECT
            DISTINCT C1.Cname AS c1name,
            C2.Cname AS c2name
        FROM
            Class AS C1,
            Class AS C2
        WHERE
            C1.meets_at = C2.meets_at
            AND C1.Cname < C2.Cname
    ) AS T ON E.Cname = T.c1name
WHERE
    E.Snum = S.Snum;