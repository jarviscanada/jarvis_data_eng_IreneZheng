-- -----------------------------------------------------
-- Q1: Add a new facility (Spa)
-- https://pgexercises.com/questions/updates/insert.html
-- -----------------------------------------------------
INSERT INTO cd.facilities (
  facid, name, membercost, guestcost,
  initialoutlay, monthlymaintenance
)
VALUES
  (9, 'Spa', 20, 30, 100000, 800);
-- Verify
SELECT
  *
FROM
  cd.facilities
WHERE
  name = 'Spa';
-- -----------------------------------------------------
-- Q2: Add Spa facility with automatically generated facid
-- https://pgexercises.com/questions/updates/insert3.html
-- -----------------------------------------------------
INSERT INTO cd.facilities (
  facid, name, membercost, guestcost,
  initialoutlay, monthlymaintenance
)
SELECT
  MAX(facid) + 1,
  'Spa',
  20,
  30,
  100000,
  800
FROM
  cd.facilities;
-- Verify
SELECT
  *
FROM
  cd.facilities
WHERE
  name = 'Spa';
-- -----------------------------------------------------
-- Q3: Correct initial outlay for Tennis Court 2
-- https://pgexercises.com/questions/updates/update.html
-- -----------------------------------------------------
UPDATE
  cd.facilities
SET
  initialoutlay = 10000
WHERE
  name = 'Tennis Court 2';
-- Verify
SELECT
  name,
  initialoutlay
FROM
  cd.facilities
WHERE
  name = 'Tennis Court 2';
-- -----------------------------------------------------
-- Q4: Increase Tennis Court 2 prices by 10% more than Tennis Court 1
-- https://pgexercises.com/questions/updates/updatecalculated.html
-- -----------------------------------------------------
UPDATE
  cd.facilities
SET
  membercost = (
    SELECT
      membercost * 1.1
    FROM
      cd.facilities
    WHERE
      name = 'Tennis Court 1'
  ),
  guestcost = (
    SELECT
      guestcost * 1.1
    FROM
      cd.facilities
    WHERE
      name = 'Tennis Court 1'
  )
WHERE
  name = 'Tennis Court 2';
-- Verify
SELECT
  name,
  membercost,
  guestcost
FROM
  cd.facilities
WHERE
  name LIKE 'Tennis Court%';
-- -----------------------------------------------------
-- Q5: Delete all records from bookings table
-- https://pgexercises.com/questions/updates/delete.html
-- -----------------------------------------------------
DELETE FROM
  cd.bookings;
-- Verify
SELECT
  COUNT(*) AS remaining_bookings
FROM
  cd.bookings;
-- -----------------------------------------------------
-- Q6: Delete member 37 who has never made a booking
-- https://pgexercises.com/questions/updates/deletewh.html
-- -----------------------------------------------------
DELETE FROM
  cd.members
WHERE
  memid = 37
  AND memid NOT IN (
    SELECT
      memid
    FROM
      cd.bookings
  );
-- Verify
SELECT
  *
FROM
  cd.members
WHERE
  memid = 37;
-- -----------------------------------------------------
-- Q7: List facilities where member cost < 1/50th of monthly maintenance
-- https://pgexercises.com/questions/basic/where2.html
-- -----------------------------------------------------
SELECT
  facid,
  name,
  membercost,
  monthlymaintenance
FROM
  cd.facilities
WHERE
  membercost > 0
  AND membercost < (monthlymaintenance / 50);
-- -----------------------------------------------------
-- Q8: List all facilities with the word 'Tennis' in their name
-- https://pgexercises.com/questions/basic/where3.html
-- -----------------------------------------------------
SELECT
  facid,
  name,
  membercost,
  guestcost,
  initialoutlay,
  monthlymaintenance
FROM
  cd.facilities
WHERE
  name LIKE '%Tennis%';
-- -----------------------------------------------------
-- Q9: Retrieve details of facilities with ID 1 and 5 (without OR)
-- https://pgexercises.com/questions/basic/where4.html
-- -----------------------------------------------------
SELECT
  *
FROM
  cd.facilities
WHERE
  facid IN (1, 5);
-- -----------------------------------------------------
-- Q10: List members who joined after September 1, 2012
-- https://pgexercises.com/questions/basic/date.html
-- -----------------------------------------------------
SELECT
  memid,
  surname,
  firstname,
  joindate
FROM
  cd.members
WHERE
  joindate > '2012-09-01';
-- -----------------------------------------------------
-- Q11: Combined list of all member surnames and facility names
-- https://pgexercises.com/questions/basic/union.html
-- -----------------------------------------------------
SELECT
  surname AS name
FROM
  cd.members
UNION
SELECT
  name
FROM
  cd.facilities;
-- -----------------------------------------------------
-- Q12: List start times for bookings by member 'David Farrell'
-- https://pgexercises.com/questions/joins/simplejoin.html
-- -----------------------------------------------------
SELECT
  b.starttime
FROM
  cd.bookings AS b
  INNER JOIN cd.members AS m ON b.memid = m.memid
WHERE
  m.firstname = 'David'
  AND m.surname = 'Farrell';
-- -----------------------------------------------------
-- Q13: List start times and facility names for tennis court bookings on 2012-09-21
-- https://pgexercises.com/questions/joins/simplejoin2.html
-- -----------------------------------------------------
SELECT
  b.starttime,
  f.name AS facility_name
FROM
  cd.bookings AS b
  INNER JOIN cd.facilities AS f ON b.facid = f.facid
WHERE
  f.name LIKE 'Tennis Court%'
  AND DATE(b.starttime) = '2012-09-21'
ORDER BY
  b.starttime;
-- -----------------------------------------------------
-- Q14: List all members and the members who recommended them
-- https://pgexercises.com/questions/joins/self.html
-- -----------------------------------------------------
SELECT
  m.firstname AS member_firstname,
  m.surname AS member_surname,
  r.firstname AS recommender_firstname,
  r.surname AS recommender_surname
FROM
  cd.members AS m
  LEFT JOIN cd.members AS r ON m.recommendedby = r.memid
ORDER BY
  m.surname,
  m.firstname;
-- -----------------------------------------------------
-- Q15: List all members who have recommended another member (no duplicates)
-- https://pgexercises.com/questions/joins/self2.html
-- -----------------------------------------------------
SELECT
  DISTINCT r.firstname,
  r.surname
FROM
  cd.members AS r
  INNER JOIN cd.members AS m ON m.recommendedby = r.memid
ORDER BY
  r.surname,
  r.firstname;
-- -----------------------------------------------------
-- Q16: List all members and their recommender (no joins, formatted names)
-- https://pgexercises.com/questions/joins/sub.html
-- -----------------------------------------------------
SELECT
  DISTINCT CONCAT(m.firstname, ' ', m.surname) AS member,
  (
    SELECT
      CONCAT(r.firstname, ' ', r.surname)
    FROM
      cd.members AS r
    WHERE
      r.memid = m.recommendedby
  ) AS recommender
FROM
  cd.members AS m
ORDER BY
  member;
-- -----------------------------------------------------
-- Q17: Count how many recommendations each member has made
-- https://pgexercises.com/questions/aggregates/count3.html
-- -----------------------------------------------------
SELECT
  recommendedby AS memid,
  COUNT(*) AS recommendation_count
FROM
  cd.members
WHERE
  recommendedby IS NOT NULL
GROUP BY
  recommendedby
ORDER BY
  recommendedby;
-- -----------------------------------------------------
-- Q18: Total number of slots booked per facility
-- https://pgexercises.com/questions/aggregates/fachours.html
-- -----------------------------------------------------
SELECT
  facid,
  SUM(slots) AS total_slots
FROM
  cd.bookings
GROUP BY
  facid
ORDER BY
  facid;
-- -----------------------------------------------------
-- Q19: Total number of slots booked per facility in September 2012
-- https://pgexercises.com/questions/aggregates/fachoursbymonth.html
-- -----------------------------------------------------
SELECT
  facid,
  SUM(slots) AS total_slots
FROM
  cd.bookings
WHERE
  starttime >= '2012-09-01'
  AND starttime < '2012-10-01'
GROUP BY
  facid
ORDER BY
  total_slots;
-- -----------------------------------------------------
-- Q20: Total number of slots booked per facility per month in 2012
-- https://pgexercises.com/questions/aggregates/fachoursbymonth2.html
-- -----------------------------------------------------
SELECT
  facid,
  EXTRACT(
    MONTH
    FROM
      starttime
  ) AS month,
  SUM(slots) AS total_slots
FROM
  cd.bookings
WHERE
  EXTRACT(
    YEAR
    FROM
      starttime
  ) = 2012
GROUP BY
  facid,
  month
ORDER BY
  facid,
  month;
-- -----------------------------------------------------
-- Q21: Total number of members (including guests) who made at least one booking
-- https://pgexercises.com/questions/aggregates/members1.html
-- -----------------------------------------------------
SELECT
  COUNT(DISTINCT memid) AS total_members_with_bookings
FROM
  cd.bookings;
-- -----------------------------------------------------
-- Q22: Each member's first booking after September 1st, 2012
-- https://pgexercises.com/questions/aggregates/nbooking.html
-- -----------------------------------------------------
SELECT
  m.memid,
  m.firstname,
  m.surname,
  MIN(b.starttime) AS first_booking
FROM
  cd.members AS m
  INNER JOIN cd.bookings AS b ON m.memid = b.memid
WHERE
  b.starttime > '2012-09-01'
GROUP BY
  m.memid,
  m.firstname,
  m.surname
ORDER BY
  m.memid;
-- -----------------------------------------------------
-- Q23: List member names with total member count (including guests)
-- https://pgexercises.com/questions/aggregates/countmembers.html
-- -----------------------------------------------------
SELECT
  firstname,
  surname,
  COUNT(*) OVER () AS total_member_count
FROM
  cd.members
ORDER BY
  joindate;
-- -----------------------------------------------------
-- Q24: Monotonically increasing numbered list of members by join date
-- https://pgexercises.com/questions/aggregates/nummembers.html
-- -----------------------------------------------------
SELECT
  ROW_NUMBER() OVER (
    ORDER BY
      joindate
  ) AS row_number,
  memid,
  firstname,
  surname,
  joindate
FROM
  cd.members
ORDER BY
  joindate;
-- -----------------------------------------------------
-- Q25: Facility ID(s) with the highest number of slots booked (include ties)
-- https://pgexercises.com/questions/aggregates/fachours4.html
-- -----------------------------------------------------
SELECT
  facid,
  SUM(slots) AS total_slots
FROM
  cd.bookings
GROUP BY
  facid
HAVING
  SUM(slots) = (
    SELECT
      MAX(total_slots)
    FROM
      (
        SELECT
          SUM(slots) AS total_slots
        FROM
          cd.bookings
        GROUP BY
          facid
      ) AS sub
  );
-- -----------------------------------------------------
-- Q26: Output member names formatted as 'Surname, Firstname'
-- https://pgexercises.com/questions/string/concat.html
-- -----------------------------------------------------
SELECT
  CONCAT(surname, ', ', firstname) AS member_name
FROM
  cd.members;
-- -----------------------------------------------------
-- Q27: Find members with telephone numbers containing parentheses
-- https://pgexercises.com/questions/string/reg.html
-- -----------------------------------------------------
SELECT
  memid,
  telephone
FROM
  cd.members
WHERE
  telephone LIKE '%(%'
  OR telephone LIKE '%)%'
ORDER BY
  memid;
-- -----------------------------------------------------
-- Q28: Count of members by first letter of surname
-- https://pgexercises.com/questions/string/substr.html
-- -----------------------------------------------------
SELECT
  SUBSTRING(
    surname
    FROM
      1 FOR 1
  ) AS first_letter,
  COUNT(*) AS member_count
FROM
  cd.members
GROUP BY
  first_letter
ORDER BY
  first_letter;


