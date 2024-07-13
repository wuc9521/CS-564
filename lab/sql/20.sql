WITH LevelCounts AS (
    SELECT
        Age,
        Level,
        COUNT(*) AS Count
    FROM
        Student
    GROUP BY
        Age,
        Level
),
MaxCounts AS (
    SELECT
        Age,
        MAX(Count) AS MaxCount
    FROM
        LevelCounts
    GROUP BY
        Age
)
SELECT
    L.Age,
    L.Level
FROM
    LevelCounts AS L
    JOIN MaxCounts AS M ON L.Age = M.Age
    AND L.Count = M.MaxCount
ORDER BY
    L.Age ASC;