SELECT
    MAX(S.Age)
from
    Student AS S,
    Enroll AS E,
    Class AS C,
    Faculty AS F
WHERE
    Major = 'History'
    OR (
        E.Snum = S.Snum
        AND E.Cname = C.Cname
        AND C.Fid = F.Fid
        AND F.Fname = 'I. Teach'
    );