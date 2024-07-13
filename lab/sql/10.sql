SELECT
    CONCAT(C1.Cname, ', ', C2.Cname) AS class_pair
FROM
    Class AS C1,
    Class AS C2
WHERE
    C1.meets_at = C2.meets_at
    AND C1.Cname < C2.Cname
ORDER BY
    class_pair;