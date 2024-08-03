= SQL Queries

== SQL Queries

=== Get Person Profile

```sql
SELECT p.pid, p.name, p.major, p.hindex,
l.loc_name AS location, l.locid as location_id,
(SELECT COUNT(*) FROM Publish pub WHERE pub.pid = p.pid) AS publication_count,
(SELECT COUNT(*) FROM Has o WHERE o.pid = p.pid) AS grant_count
FROM People p
JOIN \"in\" i ON p.pid = i.pid
JOIN Locations l ON i.locid = l.locid
WHERE p.pid = :personId
```

=== Get Person Publications

```sql
SELECT pub.pubid, pub.pmid, pub.doi
FROM Publications pub
JOIN Publish p ON pub.pubid = p.pubid
WHERE p.pid = :personId
```

=== Get Person Grants

```sql
SELECT g.grantid, g.budget_start
FROM Grants g
JOIN Has o ON g.grantid = o.grantid
WHERE o.pid = :personId
```

=== Get People by Publication Count

filtered by major and location

```sql
SELECT p.pid as pid, p.name as name, p.major as major, COUNT(pub.pubid) as pubCount
FROM People p
JOIN \"in\" i ON p.pid = i.pid
JOIN Locations l ON i.locid = l.locid
LEFT JOIN publish pub ON p.pid = pub.pid
WHERE l.loc_name = :locName AND p.major LIKE %:major%
GROUP BY p.pid, p.name, p.major
ORDER BY pubCount DESC
```

=== Get People by H-Index

filtered by major and location

```sql
SELECT p.pid as pid, p.name as name, p.major as major, p.hindex as hindex
FROM People p
JOIN \"in\" i ON p.pid = i.pid
JOIN Locations l ON i.locid = l.locid
WHERE l.loc_name = :locName AND p.major LIKE %:major%
ORDER BY p.hindex DESC
```

=== Get People with Publications but no Grants

filtered by major and location

```sql
SELECT DISTINCT p.pid as pid, p.name as name, p.major as major, p.hindex as hindex
FROM People p
JOIN \"in\" i ON p.pid = i.pid
JOIN Locations l ON i.locid = l.locid
JOIN Publish pub ON p.pid = pub.pid
WHERE l.loc_name = :locName AND p.major LIKE %:major%
AND p.pid NOT IN (SELECT pid FROM Has)
```

=== Get Locations by People in Major

```sql
SELECT l.locid as locid, l.loc_name as locName, COUNT(p.pid) as peopleCount
FROM Locations l
JOIN \"in\" i ON l.locid = i.locid
JOIN People p ON i.pid = p.pid
WHERE p.major LIKE %:major%
GROUP BY l.locid, l.loc_name
ORDER BY peopleCount DESC
```

=== Get Locations by Total Grants (filtered by major)

```sql
SELECT l.locid as locid, l.loc_name as locName, COUNT(DISTINCT g.grantid) as grantCount
FROM Locations l
JOIN \"in\" i ON l.locid = i.locid
JOIN People p ON i.pid = p.pid
LEFT JOIN Has o ON p.pid = o.pid
LEFT JOIN Grants g ON o.grantid = g.grantid
WHERE p.major LIKE %:major%
GROUP BY l.locid, l.loc_name
ORDER BY grantCount DESC
```
=== Get Locations by Maximum H-Index (filtered by major)

```sql
SELECT l.locid as locid, l.loc_name as locName, MAX(p.hindex) as maxHIndex
FROM Locations l
JOIN \"in\" i ON l.locid = i.locid
JOIN People p ON i.pid = p.pid
WHERE p.major LIKE %:major%
GROUP BY l.locid, l.loc_name
ORDER BY maxHIndex DESC
```

=== Get Location Profile

```sql
SELECT l.*,
(SELECT COUNT(DISTINCT p.pid) FROM People p JOIN \"in\" i ON p.pid = i.pid WHERE i.locid = l.locid) as scholar_count,
(SELECT COUNT(DISTINCT pub.pubid) FROM Publications pub JOIN Publish pu ON pub.pubid = pu.pubid JOIN People p ON pu.pid = p.pid JOIN \"in\" i ON p.pid = i.pid WHERE i.locid = l.locid) as publication_count,
(SELECT COUNT(DISTINCT g.grantid) FROM Grants g JOIN Has h ON g.grantid = h.grantid JOIN People p ON h.pid = p.pid JOIN \"in\" i ON p.pid = i.pid WHERE i.locid = l.locid) as grant_count
FROM Locations l WHERE l.locid = :locid
```
=== Get Scholars in Location Sorted by Number of Publications

```sql
SELECT p.pid, p.name, p.major, p.hindex, COUNT(DISTINCT pub.pubid) as publication_count
FROM People p
JOIN \"in\" i ON p.pid = i.pid
LEFT JOIN Publish pu ON p.pid = pu.pid
LEFT JOIN Publications pub ON pu.pubid = pub.pubid
WHERE i.locid = :locid
GROUP BY p.pid, p.name, p.major, p.hindex
ORDER BY publication_count DESC
```

== Stored Procedures

=== Add New Person
```sql
CREATE OR REPLACE FUNCTION AddNewPerson(
  p_name VARCHAR(100),
  p_major VARCHAR(50),
  p_hindex INT,
  p_location VARCHAR(100)
) RETURNS void AS $$
DECLARE
  new_pid INT;
  loc_id INT;
BEGIN
  SELECT COALESCE(MAX(pid), 0) + 1 INTO new_pid FROM people;
  INSERT INTO people (pid, name, major, hindex)
  VALUES (new_pid, p_name, p_major, p_hindex);

  SELECT locid INTO loc_id FROM locations WHERE loc_name = p_location;
  IF NOT FOUND THEN
    SELECT COALESCE(MAX(locid), 0) + 1 INTO loc_id FROM locations;
    INSERT INTO locations (locid, loc_name)
    VALUES (loc_id, p_location);
  END IF;
  INSERT INTO "in" (pid, locid) VALUES (new_pid, loc_id);
END;
$$ LANGUAGE plpgsql;
```

=== Update H-Index

```sql
CREATE OR REPLACE FUNCTION UpdateHIndex(
  p_name VARCHAR(100),
  p_new_hindex INT
) RETURNS void AS $$
BEGIN
  UPDATE people
  SET hindex = p_new_hindex
  WHERE name = p_name;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Person with name % not found', p_name;
  END IF;
END;
$$ LANGUAGE plpgsql;
```

=== Add Publication and Association

```sql
CREATE OR REPLACE FUNCTION AddPublicationAndAssociate(
  p_pmid VARCHAR(20),
  p_doi VARCHAR(50),
  p_author_name VARCHAR(100)
) RETURNS void AS $$
DECLARE
  new_pubid INT;
  author_pid INT;
BEGIN
  SELECT pid INTO author_pid FROM people WHERE name = p_author_name;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Author with name % not found', p_author_name;
  END IF;

  SELECT MAX(pubid) + 1 INTO new_pubid FROM publications;

  INSERT INTO publications (pubid, pmid, doi)
  VALUES (new_pubid, p_pmid, p_doi);

  INSERT INTO publish (pid, pubid)
  VALUES (author_pid, new_pubid);
END;
$$ LANGUAGE plpgsql;
```

=== Assign Grant to Person

```sql
CREATE OR REPLACE FUNCTION AssignGrantToPerson(
  p_budget_start DATE,
  p_person_name VARCHAR(100)
) RETURNS void AS $$
DECLARE
  new_grantid INT;
  person_pid INT;
BEGIN
  SELECT pid INTO person_pid FROM people WHERE name = p_person_name;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Person with name % not found', p_person_name;
  END IF;

  SELECT MAX(grantid) + 1 INTO new_grantid FROM grants;

  INSERT INTO grants (grantid, budget_start)
  VALUES (new_grantid, p_budget_start);

  INSERT INTO has (pid, grantid)
  VALUES (person_pid, new_grantid);
END;
$$ LANGUAGE plpgsql;
```

=== Change Person Location

```sql
CREATE OR REPLACE FUNCTION ChangePersonLocation(
  p_person_name VARCHAR(100),
  p_loc_name VARCHAR(100)
) RETURNS void AS $$
DECLARE
  person_pid INT;
  loc_id INT;
BEGIN
  SELECT pid INTO person_pid FROM people WHERE name = p_person_name;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Person with name % not found', p_person_name;
  END IF;


  SELECT locid INTO loc_id FROM locations WHERE loc_name = p_loc_name;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Location with name % not found', p_loc_name;
  END IF;

  IF EXISTS (SELECT 1 FROM "in" WHERE pid = person_pid) THEN
    UPDATE "in"
    SET locid = loc_id
    WHERE pid = person_pid;
  ELSE
    INSERT INTO "in" (pid, locid)
    VALUES (person_pid, loc_id);
  END IF;
END;
$$ LANGUAGE plpgsql;
```