SELECT
    C.Cname
FROM
    Class AS C
    LEFT JOIN (
        SELECT
            Cname,
            COUNT(Snum) AS student_count
        FROM
            Enroll
        GROUP BY
            Cname
    ) AS T ON T.Cname = C.Cname
WHERE
    (C.Room = 'R128')
    OR (T.student_count >= 5);