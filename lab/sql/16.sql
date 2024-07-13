SELECT
    S.Level,
    AVG(S.Age)
FROM
    Student AS S
WHERE
    S.Level <> 'JR'
GROUP BY
    S.Level;