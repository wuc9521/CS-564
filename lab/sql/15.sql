SELECT
    S.Level,
    AVG(S.Age)
FROM
    Student AS S
GROUP BY
    S.Level;