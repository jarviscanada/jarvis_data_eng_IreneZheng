# SQL Club Database Project
## Introduction
This project demonstrates fundamental SQL development skills including **data modeling, database setup, and query optimization** using **PostgreSQL**.  
The system models a **Club Management Database**, where members can book facilities (e.g., tennis courts, gyms) and have their usage and payments tracked.  
The goal is to understand the structure of relational data and practice writing **Data Definition Language (DDL)** and **Data Manipulation Language (DML)** queries.

This project simulates a real-world database engineering environment by using **Docker** to deploy a PostgreSQL instance and **Git/GitHub** for version control. Developers can also use **pgAdmin** or **DBeaver** as SQL IDEs to execute and test queries.

**Key Technologies:**
- **PostgreSQL** - Database management system
- **Docker** - Containerization for isolated environment
- **Bash** - Command-line scripting for automation
- **Git & GitHub** - Version control and collaboration

---

## Setup Instructions

### Developer Setup

1. **Start PostgreSQL using Docker**
   ```bash
   docker pull postgres:latest
   docker run --name jrvs-psql -e POSTGRES_PASSWORD=password -d -p 5432:5432 postgres
    ```
2. **Access PostgreSQL**
    ```bash
   docker exec -it jrvs-psql psql -U postgres
   ```
3. **Load DDL and sample data**
    ```bash
    # Create schema and tables
    sql -U postgres -d postgres -f sql/ddl.sql

    # Load sample data (members, facilities, bookings)
    psql -U postgres -d postgres -f sql/clubdata.sql
    ```

4. **Verify setup**
    ```bash
    SELECT COUNT(*) FROM cd.members;
    SELECT COUNT(*) FROM cd.facilities;
    SELECT COUNT(*) FROM cd.bookings;
    ```
## Project Structure
| File/Folder | Description |
|--------------|-------------|
| `sql/README.md` | Project documentation explaining setup, design, and queries |
| `sql/clubdata.sql` | Sample data for testing and practice queries |
| `sql/queries.sql` | Query solutions (e.g., pgExercises practice set) |

---

## Table Setup (DDL)

```sql
CREATE SCHEMA IF NOT EXISTS cd;
CREATE TABLE cd.members (
  memid SERIAL PRIMARY KEY, 
  surname VARCHAR(200) NOT NULL, 
  firstname VARCHAR(200) NOT NULL, 
  address VARCHAR(300), 
  zipcode INTEGER, 
  telephone VARCHAR(30), 
  recommendedby INTEGER REFERENCES cd.members(memid), 
  joindate TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE TABLE cd.facilities (
  facid SERIAL PRIMARY KEY, 
  name VARCHAR(100) NOT NULL, 
  membercost NUMERIC(10, 2) NOT NULL DEFAULT 0, 
  guestcost NUMERIC(10, 2) NOT NULL DEFAULT 0, 
  initialoutlay NUMERIC(12, 2) NOT NULL DEFAULT 0, 
  monthlymaintenance NUMERIC(10, 2) NOT NULL DEFAULT 0
);
CREATE TABLE cd.bookings (
  bookid SERIAL PRIMARY KEY, 
  facid INTEGER NOT NULL REFERENCES cd.facilities(facid), 
  memid INTEGER NOT NULL REFERENCES cd.members(memid), 
  starttime TIMESTAMP NOT NULL, 
  slots INTEGER NOT NULL CHECK (slots > 0)
);

```
## Relationships

- Each member can make multiple bookings
- Each facility can be booked many times by different members

## Sample Queries

1. **Show all members**
```sql
SELECT *
FROM cd.members;
```
2. **List all facilities and costs**
```sql
SELECT name, membercost, guestcost
FROM cd.facilities;
```

3. **Find all members who recommended others**
```sql
SELECT DISTINCT m.firstname, m.surname
FROM cd.members AS m
WHERE m.memid IN (
    SELECT DISTINCT recommendedby
    FROM cd.members
    WHERE recommendedby IS NOT NULL
);
```

## Practice SQL Queries

### Question 1: Add a new facility (Spa)

#### Problem
The club is adding a new facility - a Spa.  
We need to insert it into the `cd.facilities` table with the following values:

- facid: 9
- name: 'Spa'
- membercost: 20
- guestcost: 30
- initialoutlay: 100000
- monthlymaintenance: 800

#### Solution
```sql
INSERT INTO cd.facilities (
    facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
)
VALUES (
    9, 'Spa', 20, 30, 100000, 800
);
```
#### Explanation
This `INSERT` statement adds a new record into the `cd.facilities` table, providing explicit values for all required columns including a manually assigned `facid`.

#### Verification
```sql
SELECT * FROM cd.facilities WHERE name = 'Spa';
```


### Question 2: Add Spa again but auto-generate facid

#### Problem
We want to add the Spa facility again, but this time let PostgreSQL automatically generate the next `facid` rather than specifying it manually.

#### Solution
```sql
INSERT INTO cd.facilities (
    facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
)
SELECT
    MAX(facid) + 1,
    'Spa', 20, 30, 100000, 800
FROM cd.facilities;
```
#### Explanation
This query uses a subquery to find the current maximum `facid` and adds 1 to it to generate the next available ID automatically.

#### Verification
```sql
SELECT * FROM cd.facilities WHERE name = 'Spa';
```


### Question 3: Fix Tennis Court 2 initial outlay

#### Problem
We made a mistake entering data for the second tennis court.  
The initial outlay should be `10000` instead of `8000`.

#### Solution
```sql
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE name = 'Tennis Court 2';
```
#### Explanation
The `UPDATE` statement modifies the value of `initialoutlay` for the row where the facility name is `'Tennis Court 2'`.

#### Verification
```sql
SELECT name, initialoutlay FROM cd.facilities WHERE name = 'Tennis Court 2';
```


### Question 4: Increase Tennis Court 2 prices by 10% over Court 1

#### Problem
We want to increase the price of Tennis Court 2 so that it costs 10% more than Tennis Court 1.  
We must do this dynamically without using constant numeric values.

#### Solution
```sql
UPDATE cd.facilities
SET
    membercost = (SELECT membercost * 1.1 FROM cd.facilities WHERE name = 'Tennis Court 1'),
    guestcost  = (SELECT guestcost * 1.1 FROM cd.facilities WHERE name = 'Tennis Court 1')
WHERE name = 'Tennis Court 2';
```
#### Explanation
The query uses subqueries to reference Tennis Court 1's current prices and multiplies them by 1.1 to increase by 10%.  
This keeps the query reusable for future adjustments.

#### Verification
```sql
SELECT name, membercost, guestcost FROM cd.facilities WHERE name LIKE 'Tennis Court%';
```


### Question 5: Delete all bookings

#### Problem
As part of a data cleanup, we want to delete all records from the `cd.bookings` table.

#### Solution
```sql
DELETE FROM cd.bookings;
```
#### Explanation
The `DELETE` statement removes all records from the `cd.bookings` table while keeping the table structure intact.

#### Verification
```sql
SELECT COUNT(*) FROM cd.bookings;
```
If the result is `0`, all bookings have been successfully deleted.


### Question 6: Delete member 37 who has never booked

#### Problem
Remove member 37 who has never made a booking.

#### Solution
```sql
DELETE FROM cd.members
WHERE memid = 37
  AND memid NOT IN (SELECT memid FROM cd.bookings);
```
#### Explanation
Deletes only members with no bookings using a `NOT IN` subquery.

#### Verification
```sql
SELECT * FROM cd.members WHERE memid = 37;
```


### Question 7: Facilities where member cost < 1/50th of maintenance

#### Problem
List facilities that charge a fee to members less than 1/50th of the monthly maintenance cost.

#### Solution
```sql
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost > 0
  AND membercost < (monthlymaintenance / 50);
```
#### Explanation
Filters facilities where the member cost is proportionally very low compared to maintenance.

#### Verification
```sql
SELECT COUNT(*) FROM cd.facilities
WHERE membercost > 0
  AND membercost < (monthlymaintenance / 50);
```


### Question 8: Facilities with Tennis in name

#### Problem
List all facilities with the word Tennis in their name.

#### Solution
```sql
SELECT * FROM cd.facilities
WHERE name LIKE '%Tennis%';
```
#### Explanation
Uses `LIKE` to find partial string matches.

#### Verification
```sql
SELECT COUNT(*) FROM cd.facilities WHERE name LIKE '%Tennis%';
```


### Question 9: Retrieve facilities with IDs 1 and 5

#### Problem
Retrieve details of facilities with ID 1 and 5 without using `OR`.

#### Solution
```sql
SELECT * FROM cd.facilities
WHERE facid IN (1, 5);
```
#### Explanation
`IN` provides a cleaner way to query multiple discrete values.

#### Verification
```sql
SELECT facid FROM cd.facilities WHERE facid IN (1,5);
```


### Question 10: Members who joined after September 1, 2012

#### Problem
List all members who joined after September 1, 2012.

#### Solution
```sql
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate > '2012-09-01';
```
#### Explanation
Filters the members table based on date conditions.

#### Verification
```sql
SELECT COUNT(*) FROM cd.members WHERE joindate > '2012-09-01';
```


### Question 11: Combined list of surnames and facility names

#### Problem
Produce a combined list of all surnames and facility names.

#### Solution
```sql
SELECT surname AS name FROM cd.members
UNION
SELECT name FROM cd.facilities;
```
#### Explanation
`UNION` merges two queries with the same column structure and removes duplicates.

#### Verification
```sql
SELECT COUNT(*) FROM (SELECT surname FROM cd.members UNION SELECT name FROM cd.facilities) sub;
```


### Question 12: Start times for bookings by David Farrell

#### Problem
Produce a list of start times for bookings made by David Farrell.

#### Solution
```sql
SELECT b.starttime
FROM cd.bookings b
JOIN cd.members m ON b.memid = m.memid
WHERE m.firstname = 'David' AND m.surname = 'Farrell';
```
#### Explanation
Joins the members and bookings tables and filters on the member name.

#### Verification
```sql
SELECT COUNT(*) FROM cd.bookings b
JOIN cd.members m ON b.memid = m.memid
WHERE m.firstname='David' AND m.surname='Farrell';
```


### Question 13: Bookings for tennis courts on 2012-09-21

#### Problem
List start times and facility names for all bookings for tennis courts on 2012-09-21.

#### Solution
```sql
SELECT f.name, b.starttime
FROM cd.bookings b
JOIN cd.facilities f ON b.facid = f.facid
WHERE f.name LIKE '%Tennis Court%'
  AND b.starttime::date = '2012-09-21'
ORDER BY b.starttime;
```
#### Explanation
Filters tennis court bookings on a specific date, joining bookings and facilities.

#### Verification
```sql
SELECT COUNT(*) FROM cd.bookings b
JOIN cd.facilities f ON b.facid = f.facid
WHERE f.name LIKE '%Tennis Court%' AND b.starttime::date='2012-09-21';
```

### Question 14: List all members and who recommended them

#### Problem
Output a list of all members including the individual who recommended them (if any). Ensure that results are ordered by surname and firstname.

#### Solution
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

#### Explanation
Self-join on the members table to link each member with the recommender.

#### Verification
```sql
SELECT COUNT(*) FROM cd.members;
```



### Question 15: List all members who have recommended another member

#### Problem
Output a list of members who have recommended someone else. Ensure no duplicates.

#### Solution
```sql
SELECT DISTINCT
    r.firstname,
    r.surname
FROM cd.members r
JOIN cd.members m ON r.memid = m.recommendedby
ORDER BY r.surname, r.firstname;
```

#### Explanation
Inner join the members table on itself and use DISTINCT to avoid duplicates.

#### Verification
```sql
SELECT COUNT(DISTINCT recommendedby) FROM cd.members;
```



### Question 16: List all members and their recommender without joins

#### Problem
List all members including their recommender (if any) without using JOINs.

#### Solution
```sql
SELECT
    firstname || ' ' || surname AS member,
    (SELECT r.firstname || ' ' || r.surname
     FROM cd.members r
     WHERE r.memid = m.recommendedby) AS recommender
FROM cd.members m
ORDER BY member;
```

#### Explanation
Uses a correlated subquery instead of JOIN to retrieve recommender names.

#### Verification
```sql
SELECT COUNT(*) FROM cd.members;
```


### Question 17: Count recommendations per member

#### Problem
Produce a count of the number of recommendations each member has made. Order by member ID.

#### Solution
```sql
SELECT
    recommendedby AS memid,
    COUNT(*) AS recommendations
FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby;
```

#### Explanation
Groups by the recommender ID and counts recommendations.

#### Verification
```sql
SELECT COUNT(DISTINCT recommendedby) FROM cd.members;
```



### Question 18: Total number of slots booked per facility

#### Problem
Produce a list of total slots booked per facility.

#### Solution
```sql
SELECT facid, SUM(slots) AS total_slots
FROM cd.bookings
GROUP BY facid
ORDER BY facid;
```

#### Explanation
Aggregates slot counts grouped by facility ID.

#### Verification
```sql
SELECT SUM(slots) FROM cd.bookings;
```



### Question 19: Total slots per facility in September 2012

#### Problem
Find the total slots booked per facility in September 2012.

#### Solution
```sql
SELECT facid, SUM(slots) AS total_slots
FROM cd.bookings
WHERE starttime >= '2012-09-01' AND starttime < '2012-10-01'
GROUP BY facid
ORDER BY total_slots;
```

#### Explanation
Filters bookings by date range and aggregates slots by facility.

#### Verification
```sql
SELECT COUNT(*) FROM cd.bookings WHERE starttime BETWEEN '2012-09-01' AND '2012-09-30';
```



### Question 20: Total slots per facility per month in 2012

### #Problem
Produce a list of the total slots booked per facility per month in 2012.

#### Solution
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

#### Explanation
Groups results by both facility ID and month number.

#### Verification
```sql
SELECT COUNT(DISTINCT EXTRACT(MONTH FROM starttime)) FROM cd.bookings WHERE EXTRACT(YEAR FROM starttime)=2012;
```



### Question 21: Count members who made at least one booking

#### Problem
Find total members (including guests) who made at least one booking.

#### Solution
```sql
SELECT COUNT(DISTINCT memid) AS member_count
FROM cd.bookings;
```

#### Explanation
Uses `DISTINCT` to ensure each member counted once.

#### Verification
```sql
SELECT COUNT(*) FROM (SELECT DISTINCT memid FROM cd.bookings) sub;
```



### Question 22: First booking after September 1st 2012 per member

#### Problem
List each member's first booking after September 1st, 2012.

#### Solution
```sql
SELECT memid, MIN(starttime) AS first_booking
FROM cd.bookings
WHERE starttime > '2012-09-01'
GROUP BY memid
ORDER BY memid;
```

#### Explanation
Uses aggregation with `MIN()` to find earliest booking per member.

#### Verification
```sql
SELECT COUNT(DISTINCT memid) FROM cd.bookings WHERE starttime>'2012-09-01';
```



### Question 23: Total member count per join date

#### Problem
Produce a list of member names and total member count, ordered by join date.

#### Solution
```sql
SELECT firstname, surname, COUNT(*) OVER () AS total_members
FROM cd.members
ORDER BY joindate;
```

#### Explanation
Uses a window function to count total members across all rows.

#### Verification
```sql
SELECT COUNT(*) FROM cd.members;
```



### Question 24: Monotonically increasing list of members

#### Problem
Produce a monotonically increasing numbered list of members ordered by join date.

#### Solution
```sql
SELECT ROW_NUMBER() OVER (ORDER BY joindate) AS row_number, memid, firstname, surname, joindate
FROM cd.members
ORDER BY joindate;
```

#### Explanation
`ROW_NUMBER()` provides sequential numbering based on order.

#### Verification
```sql
SELECT COUNT(*) FROM cd.members;
```



### Question 25: Facility with highest total slots booked

#### Problem
Output the facility ID with the highest number of slots booked. Include ties.

#### Solution
```sql
SELECT facid, SUM(slots) AS total_slots
FROM cd.bookings
GROUP BY facid
HAVING SUM(slots) = (
    SELECT MAX(SUM(slots)) FROM cd.bookings GROUP BY facid
);
```

#### Explanation
Uses `HAVING` with a subquery to match maximum totals.

#### Verification
```sql
SELECT COUNT(DISTINCT facid) FROM cd.bookings;
```



### Question 26: Output names formatted as 'Surname, Firstname'

#### Problem
Output member names formatted as Surname, Firstname.

#### Solution
```sql
SELECT surname || ', ' || firstname AS full_name
FROM cd.members;
```

#### Explanation
Concatenates strings using `||` in PostgreSQL.

#### Verification
```sql
SELECT COUNT(*) FROM cd.members;
```



### Question 27: Members with parentheses in telephone numbers


#### Problem
Find all members whose telephone numbers contain parentheses.

#### Solution
```sql
SELECT memid, telephone
FROM cd.members
WHERE telephone LIKE '%(%';
```

#### Explanation
Uses `LIKE` to find telephone numbers with '('.

#### Verification
```sql
SELECT COUNT(*) FROM cd.members WHERE telephone LIKE '%(%';
```



### Question 28: Count members by first letter of surname


#### Problem
Produce a count of members whose surname starts with each letter of the alphabet.

#### Solution
```sql
SELECT SUBSTRING(surname, 1, 1) AS initial, COUNT(*) AS member_count
FROM cd.members
GROUP BY initial
ORDER BY initial;
```

#### Explanation
Groups members by the first letter of their surname and counts occurrences.

#### Verification
```sql
SELECT COUNT(DISTINCT SUBSTRING(surname, 1, 1)) FROM cd.members;
```

