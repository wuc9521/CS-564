SELECT
    F.Fname
FROM
    Faculty F
    LEFT JOIN (
        SELECT
            COUNT(E.Snum) AS num_enroll,
            C.Fid
        FROM
            Enroll AS E,
            Class AS C
        where
            E.Cname = C.Cname
        GROUP BY
            Fid
    ) AS T ON F.Fid = T.Fid
WHERE
    num_enroll < 5;