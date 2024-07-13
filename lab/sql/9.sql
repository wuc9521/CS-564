SELECT
    Cname
FROM
    Class AS C,
    Faculty AS F
WHERE
    C.Fid = F.Fid
    AND C.Room = 'R128';