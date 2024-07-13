SELECT
    S.Sname
FROM
    Student AS S
WHERE
    S.Snum NOT IN (
        SELECT
            DISTINCT E.Snum
        FROM
            Enroll AS E
    );