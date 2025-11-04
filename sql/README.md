# SQL Practice Project - pgExercises Solutions

This repository documents my SQL practice using the [pgExercises](https://pgexercises.com/) dataset  a PostgreSQL-based training database designed to teach SQL through real-world queries.

The exercises cover essential SQL concepts, including:
- Data Definition (DDL) - creating schemas and tables
- Data Manipulation (DML) - inserting, updating, and deleting data
- Filtering and Joins - querying and combining tables efficiently
- Aggregation and Window Functions -summarizing and analyzing data
- String Operations - formatting and cleaning textual data

All SQL scripts were tested locally on PostgreSQL running in Docker, using the schema `cd` (club database).

---

## Project Structure

| File | Description |
|------|--------------|
| `sql/queries.sql` | Contains all query solutions from pgExercises |
| `sql/README.md` | This documentation file explaining problems, solutions, and reasoning |

---

## Local Setup (Optional for Developers)

If you'd like to run these queries yourself using Docker:

```bash
# Start PostgreSQL container
docker run -d \
  --name pg-club \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=exercises \
  -p 5432:5432 postgres:16

```
Then, connect using DBeaver with:
```yaml
Host: localhost  
Port: 5432  
Database: exercises  
User: postgres  
Password: postgres
```
## Question 1: Add a new facility (Spa)
[pgExercises Link](https://pgexercises.com/questions/updates/insert.html)

### Problem
The club is adding a new facility  a Spa.  
We need to insert it into the `cd.facilities` table with the following values:

- facid: 9
- name: 'Spa'
- membercost: 20
- guestcost: 30
- initialoutlay: 100000
- monthlymaintenance: 800

### Solution
```sql
INSERT INTO cd.facilities (
    facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
)
VALUES (
    9, 'Spa', 20, 30, 100000, 800
);
```
### Explanation
This `INSERT` statement adds a new record into the `cd.facilities` table, providing explicit values for all required columns including a manually assigned `facid`.

### Verification
```sql
SELECT * FROM cd.facilities WHERE name = 'Spa';
```


## Question 2: Add Spa again but auto-generate facid
[pgExercises Link](https://pgexercises.com/questions/updates/insert3.html)

### Problem
We want to add the Spa facility again, but this time let PostgreSQL automatically generate the next `facid` rather than specifying it manually.

### Solution
```sql
INSERT INTO cd.facilities (
    facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
)
SELECT
    MAX(facid) + 1,
    'Spa', 20, 30, 100000, 800
FROM cd.facilities;
```
### Explanation
This query uses a subquery to find the current maximum `facid` and adds 1 to it to generate the next available ID automatically.

### Verification
```sql
SELECT * FROM cd.facilities WHERE name = 'Spa';
```


## Question 3: Fix Tennis Court 2 initial outlay
[pgExercises Link](https://pgexercises.com/questions/updates/update.html)

### Problem
We made a mistake entering data for the second tennis court.  
The initial outlay should be `10000` instead of `8000`.

### Solution
```sql
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE name = 'Tennis Court 2';
```
### Explanation
The `UPDATE` statement modifies the value of `initialoutlay` for the row where the facility name is `'Tennis Court 2'`.

### Verification
```sql
SELECT name, initialoutlay FROM cd.facilities WHERE name = 'Tennis Court 2';
```


## Question 4: Increase Tennis Court 2 prices by 10% over Court 1
[pgExercises Link](https://pgexercises.com/questions/updates/updatecalculated.html)

### Problem
We want to increase the price of Tennis Court 2 so that it costs 10% more than Tennis Court 1.  
We must do this dynamically without using constant numeric values.

### Solution
```sql
UPDATE cd.facilities
SET
    membercost = (SELECT membercost * 1.1 FROM cd.facilities WHERE name = 'Tennis Court 1'),
    guestcost  = (SELECT guestcost * 1.1 FROM cd.facilities WHERE name = 'Tennis Court 1')
WHERE name = 'Tennis Court 2';
```
### Explanation
The query uses subqueries to reference Tennis Court 1s current prices and multiplies them by 1.1 to increase by 10%.  
This keeps the query reusable for future adjustments.

### Verification
```sql
SELECT name, membercost, guestcost FROM cd.facilities WHERE name LIKE 'Tennis Court%';
```


## Question 5: Delete all bookings
[pgExercises Link](https://pgexercises.com/questions/updates/delete.html)

### Problem
As part of a data cleanup, we want to delete all records from the `cd.bookings` table.

### Solution
```sql
DELETE FROM cd.bookings;
```
### Explanation
The `DELETE` statement removes all records from the `cd.bookings` table while keeping the table structure intact.

### Verification
```sql
SELECT COUNT(*) FROM cd.bookings;
```
If the result is `0`, all bookings have been successfully deleted.


## Question 6: Delete member 37 who has never booked
[pgExercises Link](https://pgexercises.com/questions/updates/deletewh.html)

### Problem
Remove member 37 who has never made a booking.

### Solution
```sql
DELETE FROM cd.members
WHERE memid = 37
  AND memid NOT IN (SELECT memid FROM cd.bookings);
```
### Explanation
Deletes only members with no bookings using a `NOT IN` subquery.

### Verification
```sql
SELECT * FROM cd.members WHERE memid = 37;
```


## Question 7: Facilities where member cost < 1/50th of maintenance
[pgExercises Link](https://pgexercises.com/questions/basic/where2.html)

### Problem
List facilities that charge a fee to members less than 1/50th of the monthly maintenance cost.

### Solution
```sql
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost > 0
  AND membercost < (monthlymaintenance / 50);
```
### Explanation
Filters facilities where the member cost is proportionally very low compared to maintenance.

### Verification
```sql
SELECT COUNT(*) FROM cd.facilities
WHERE membercost > 0
  AND membercost < (monthlymaintenance / 50);
```


## Question 8: Facilities with Tennis in name
[pgExercises Link](https://pgexercises.com/questions/basic/where3.html)

### Problem
List all facilities with the word Tennis in their name.

### Solution
```sql
SELECT * FROM cd.facilities
WHERE name LIKE '%Tennis%';
```
### Explanation
Uses `LIKE` to find partial string matches.

### Verification
```sql
SELECT COUNT(*) FROM cd.facilities WHERE name LIKE '%Tennis%';
```


## Question 9: Retrieve facilities with IDs 1 and 5
[pgExercises Link](https://pgexercises.com/questions/basic/where4.html)

### Problem
Retrieve details of facilities with ID 1 and 5 without using `OR`.

### Solution
```sql
SELECT * FROM cd.facilities
WHERE facid IN (1, 5);
```
### Explanation
`IN` provides a cleaner way to query multiple discrete values.

### Verification
```sql
SELECT facid FROM cd.facilities WHERE facid IN (1,5);
```


## Question 10: Members who joined after September 1, 2012
[pgExercises Link](https://pgexercises.com/questions/basic/date.html)

### Problem
List all members who joined after September 1, 2012.

### Solution
```sql
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate > '2012-09-01';
```
### Explanation
Filters the members table based on date conditions.

### Verification
```sql
SELECT COUNT(*) FROM cd.members WHERE joindate > '2012-09-01';
```


## Question 11: Combined list of surnames and facility names
[pgExercises Link](https://pgexercises.com/questions/basic/union.html)

### Problem
Produce a combined list of all surnames and facility names.

### Solution
```sql
SELECT surname AS name FROM cd.members
UNION
SELECT name FROM cd.facilities;
```
### Explanation
`UNION` merges two queries with the same column structure and removes duplicates.

### Verification
```sql
SELECT COUNT(*) FROM (SELECT surname FROM cd.members UNION SELECT name FROM cd.facilities) sub;
```


## Question 12: Start times for bookings by David Farrell
[pgExercises Link](https://pgexercises.com/questions/joins/simplejoin.html)

### Problem
Produce a list of start times for bookings made by David Farrell.

### Solution
```sql
SELECT b.starttime
FROM cd.bookings b
JOIN cd.members m ON b.memid = m.memid
WHERE m.firstname = 'David' AND m.surname = 'Farrell';
```
### Explanation
Joins the members and bookings tables and filters on the member name.

### Verification
```sql
SELECT COUNT(*) FROM cd.bookings b
JOIN cd.members m ON b.memid = m.memid
WHERE m.firstname='David' AND m.surname='Farrell';
```


## Question 13: Bookings for tennis courts on 2012-09-21
[pgExercises Link](https://pgexercises.com/questions/joins/simplejoin2.html)

### Problem
List start times and facility names for all bookings for tennis courts on 2012-09-21.

### Solution
```sql
SELECT f.name, b.starttime
FROM cd.bookings b
JOIN cd.facilities f ON b.facid = f.facid
WHERE f.name LIKE '%Tennis Court%'
  AND b.starttime::date = '2012-09-21'
ORDER BY b.starttime;
```
### Explanation
Filters tennis court bookings on a specific date, joining bookings and facilities.

### Verification
```sql
SELECT COUNT(*) FROM cd.bookings b
JOIN cd.facilities f ON b.facid = f.facid
WHERE f.name LIKE '%Tennis Court%' AND b.starttime::date='2012-09-21';


## Question 14: List all members and who recommended them
[pgExercises Link](https://pgexercises.com/questions/joins/self.html)

### Problem
Output a list of all members including the individual who recommended them (if any). Ensure that results are ordered by surname and firstname.

### Solution
```sql
SELECT
    m.firstname AS member_firstname,
    m.surname AS member_surname,
    r.firstname AS recommender_firstname,
    r.surname AS recommender_surname
FROM cd.members m
LEFT JOIN cd.members r ON m.recommendedby = r.memid
ORDER BY m.surname, m.firstname;
```

### Explanation
Self-join on the members table to link each member with the recommender.

### Verification
```sql
SELECT COUNT(*) FROM cd.members;
```



## Question 15: List all members who have recommended another member
[pgExercises Link](https://pgexercises.com/questions/joins/self2.html)

### Problem
Output a list of members who have recommended someone else. Ensure no duplicates.

### Solution
```sql
SELECT DISTINCT
    r.firstname,
    r.surname
FROM cd.members r
JOIN cd.members m ON r.memid = m.recommendedby
ORDER BY r.surname, r.firstname;
```

### Explanation
Inner join the members table on itself and use DISTINCT to avoid duplicates.

### Verification
```sql
SELECT COUNT(DISTINCT recommendedby) FROM cd.members;
```



## Question 16: List all members and their recommender without joins
[pgExercises Link](https://pgexercises.com/questions/joins/sub.html)

### Problem
List all members including their recommender (if any) without using JOINs.

### Solution
```sql
SELECT
    firstname || ' ' || surname AS member,
    (SELECT r.firstname || ' ' || r.surname
     FROM cd.members r
     WHERE r.memid = m.recommendedby) AS recommender
FROM cd.members m
ORDER BY member;
```

### Explanation
Uses a correlated subquery instead of JOIN to retrieve recommender names.

### Verification
```sql
SELECT COUNT(*) FROM cd.members;
```


## Question 17: Count recommendations per member
[pgExercises Link](https://pgexercises.com/questions/aggregates/count3.html)

### Problem
Produce a count of the number of recommendations each member has made. Order by member ID.

### Solution
```sql
SELECT
    recommendedby AS memid,
    COUNT(*) AS recommendations
FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby;
```

### Explanation
Groups by the recommender ID and counts recommendations.

### Verification
```sql
SELECT COUNT(DISTINCT recommendedby) FROM cd.members;
```



## Question 18: Total number of slots booked per facility
[pgExercises Link](https://pgexercises.com/questions/aggregates/fachours.html)

### Problem
Produce a list of total slots booked per facility.

### Solution
```sql
SELECT facid, SUM(slots) AS total_slots
FROM cd.bookings
GROUP BY facid
ORDER BY facid;
```

### Explanation
Aggregates slot counts grouped by facility ID.

### Verification
```sql
SELECT SUM(slots) FROM cd.bookings;
```



## Question 19: Total slots per facility in September 2012
[pgExercises Link](https://pgexercises.com/questions/aggregates/fachoursbymonth.html)

### Problem
Find the total slots booked per facility in September 2012.

### Solution
```sql
SELECT facid, SUM(slots) AS total_slots
FROM cd.bookings
WHERE starttime >= '2012-09-01' AND starttime < '2012-10-01'
GROUP BY facid
ORDER BY total_slots;
```

### Explanation
Filters bookings by date range and aggregates slots by facility.

### Verification
```sql
SELECT COUNT(*) FROM cd.bookings WHERE starttime BETWEEN '2012-09-01' AND '2012-09-30';
```



## Question 20: Total slots per facility per month in 2012
[pgExercises Link](https://pgexercises.com/questions/aggregates/fachoursbymonth2.html)

### Problem
Produce a list of the total slots booked per facility per month in 2012.

### Solution
```sql
SELECT
    facid,
    EXTRACT(MONTH FROM starttime) AS month,
    SUM(slots) AS total_slots
FROM cd.bookings
WHERE EXTRACT(YEAR FROM starttime) = 2012
GROUP BY facid, month
ORDER BY facid, month;
```

### Explanation
Groups results by both facility ID and month number.

### Verification
```sql
SELECT COUNT(DISTINCT EXTRACT(MONTH FROM starttime)) FROM cd.bookings WHERE EXTRACT(YEAR FROM starttime)=2012;
```



## Question 21: Count members who made at least one booking
[pgExercises Link](https://pgexercises.com/questions/aggregates/members1.html)

### Problem
Find total members (including guests) who made at least one booking.

### Solution
```sql
SELECT COUNT(DISTINCT memid) AS member_count
FROM cd.bookings;
```

### Explanation
Uses `DISTINCT` to ensure each member counted once.

### Verification
```sql
SELECT COUNT(*) FROM (SELECT DISTINCT memid FROM cd.bookings) sub;
```



## Question 22: First booking after September 1st 2012 per member
[pgExercises Link](https://pgexercises.com/questions/aggregates/nbooking.html)

### Problem
List each members first booking after September 1st, 2012.

### Solution
```sql
SELECT memid, MIN(starttime) AS first_booking
FROM cd.bookings
WHERE starttime > '2012-09-01'
GROUP BY memid
ORDER BY memid;
```

### Explanation
Uses aggregation with `MIN()` to find earliest booking per member.

### Verification
```sql
SELECT COUNT(DISTINCT memid) FROM cd.bookings WHERE starttime>'2012-09-01';
```



## Question 23: Total member count per join date
[pgExercises Link](https://pgexercises.com/questions/aggregates/countmembers.html)

### Problem
Produce a list of member names and total member count, ordered by join date.

### Solution
```sql
SELECT firstname, surname, COUNT(*) OVER () AS total_members
FROM cd.members
ORDER BY joindate;
```

### Explanation
Uses a window function to count total members across all rows.

### Verification
```sql
SELECT COUNT(*) FROM cd.members;
```



## Question 24: Monotonically increasing list of members
[pgExercises Link](https://pgexercises.com/questions/aggregates/nummembers.html)

### Problem
Produce a monotonically increasing numbered list of members ordered by join date.

### Solution
```sql
SELECT ROW_NUMBER() OVER (ORDER BY joindate) AS row_number, memid, firstname, surname, joindate
FROM cd.members
ORDER BY joindate;
```

### Explanation
`ROW_NUMBER()` provides sequential numbering based on order.

### Verification
```sql
SELECT COUNT(*) FROM cd.members;
```



## Question 25: Facility with highest total slots booked
[pgExercises Link](https://pgexercises.com/questions/aggregates/fachours4.html)

### Problem
Output the facility ID with the highest number of slots booked. Include ties.

### Solution
```sql
SELECT facid, SUM(slots) AS total_slots
FROM cd.bookings
GROUP BY facid
HAVING SUM(slots) = (
    SELECT MAX(SUM(slots)) FROM cd.bookings GROUP BY facid
);
```

### Explanation
Uses `HAVING` with a subquery to match maximum totals.

### Verification
```sql
SELECT COUNT(DISTINCT facid) FROM cd.bookings;
```



## Question 26: Output names formatted as 'Surname, Firstname'
[pgExercises Link](https://pgexercises.com/questions/string/concat.html)

### Problem
Output member names formatted as Surname, Firstname.

### Solution
```sql
SELECT surname || ', ' || firstname AS full_name
FROM cd.members;
```

### Explanation
Concatenates strings using `||` in PostgreSQL.

### Verification
```sql
SELECT COUNT(*) FROM cd.members;
```



## Question 27: Members with parentheses in telephone numbers
[pgExercises Link](https://pgexercises.com/questions/string/reg.html)

### Problem
Find all members whose telephone numbers contain parentheses.

### Solution
```sql
SELECT memid, telephone
FROM cd.members
WHERE telephone LIKE '%(%';
```

### Explanation
Uses `LIKE` to find telephone numbers with '('.

### Verification
```sql
SELECT COUNT(*) FROM cd.members WHERE telephone LIKE '%(%';
```



## Question 28: Count members by first letter of surname
[pgExercises Link](https://pgexercises.com/questions/string/substr.html)

### Problem
Produce a count of members whose surname starts with each letter of the alphabet.

### Solution
```sql
SELECT SUBSTRING(surname, 1, 1) AS initial, COUNT(*) AS member_count
FROM cd.members
GROUP BY initial
ORDER BY initial;
```

### Explanation
Groups members by the first letter of their surname and counts occurrences.

### Verification
```sql
SELECT COUNT(DISTINCT SUBSTRING(surname, 1, 1)) FROM cd.members;
```

