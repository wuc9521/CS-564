SELECT
    Cname
FROM
    Class as C,
    Faculty AS F
WHERE
    C.Fid = F.Fid
    AND F.Fname = 'Elizabeth Taylor'