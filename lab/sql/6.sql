SELECT
    Cname
from
    Class
where
    Room = 'R128'
    OR meets_at LIKE 'MWF%';