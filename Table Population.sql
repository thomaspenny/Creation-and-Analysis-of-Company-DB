-- ------------------------------------------------------------------------------
--   Database Population Script by Thomas Penny
--   SQLite Compatible Version
-- ------------------------------------------------------------------------------

-- Delete all data from tables to ensure the data is fresh
DELETE FROM Inventory;
DELETE FROM OrderDetails;
DELETE FROM Orders;
DELETE FROM Customer;
DELETE FROM ProjectMember;
DELETE FROM Projects;
DELETE FROM DepartmentManager;
DELETE FROM Dependants;
DELETE FROM Employee;
DELETE FROM Locations;
DELETE FROM Product;
DELETE FROM Warehouse;
DELETE FROM Department;

------------------------------
-- 1. Department
------------------------------
INSERT INTO Department (Department_Name) VALUES ('HR');
INSERT INTO Department (Department_Name) VALUES ('Finance');
INSERT INTO Department (Department_Name) VALUES ('Engineering');
INSERT INTO Department (Department_Name) VALUES ('Sales');
INSERT INTO Department (Department_Name) VALUES ('Customer Service');


------------------------------
-- 2. Product
------------------------------
INSERT INTO Product (Product_Name, Price) VALUES ('Laptop', 1200.00);
INSERT INTO Product (Product_Name, Price) VALUES ('Mouse', 20.00);
INSERT INTO Product (Product_Name, Price) VALUES ('Keyboard', 40.00);
INSERT INTO Product (Product_Name, Price) VALUES ('Monitor', 110.00);
INSERT INTO Product (Product_Name, Price) VALUES ('Headset', 80.00);
INSERT INTO Product (Product_Name, Price) VALUES ('Tablet', 650.00);
INSERT INTO Product (Product_Name, Price) VALUES ('Webcam', 75.00);
INSERT INTO Product (Product_Name, Price) VALUES ('Printer', 180.00);
INSERT INTO Product (Product_Name, Price) VALUES ('Speaker', 95.00);
INSERT INTO Product (Product_Name, Price) VALUES ('Docking Station', 220.00);

------------------------------
-- 3. Warehouse
------------------------------
INSERT INTO Warehouse (Address) VALUES ('123 Warehouse St., London');
INSERT INTO Warehouse (Address) VALUES ('456 Warehouse St., Edinburgh');
INSERT INTO Warehouse (Address) VALUES ('789 Warehouse St., Leeds');
INSERT INTO Warehouse (Address) VALUES ('321 Warehouse St., Belfast');
INSERT INTO Warehouse (Address) VALUES ('654 Warehouse St., Cardiff');
INSERT INTO Warehouse (Address) VALUES ('987 Warehouse St., Manchester');
INSERT INTO Warehouse (Address) VALUES ('147 Warehouse St., Birmingham');
INSERT INTO Warehouse (Address) VALUES ('258 Warehouse St., Glasgow');
INSERT INTO Warehouse (Address) VALUES ('369 Warehouse St., Liverpool');
INSERT INTO Warehouse (Address) VALUES ('741 Warehouse St., Bristol');

------------------------------
-- 4. Location
------------------------------
INSERT INTO Locations (Address, Department_ID) VALUES ('1st Floor, Building A', (SELECT Department_ID FROM Department WHERE Department_Name = 'HR'));
INSERT INTO Locations (Address, Department_ID) VALUES ('2nd Floor, Building B', (SELECT Department_ID FROM Department WHERE Department_Name = 'Finance'));
INSERT INTO Locations (Address, Department_ID) VALUES ('3rd Floor, Building C', (SELECT Department_ID FROM Department WHERE Department_Name = 'Engineering'));
INSERT INTO Locations (Address, Department_ID) VALUES ('4th Floor, Building D', (SELECT Department_ID FROM Department WHERE Department_Name = 'Sales'));
INSERT INTO Locations (Address, Department_ID) VALUES ('5th Floor, Building E', (SELECT Department_ID FROM Department WHERE Department_Name = 'Customer Service'));
INSERT INTO Locations (Address, Department_ID) VALUES ('6th Floor, Building F', (SELECT Department_ID FROM Department WHERE Department_Name = 'Engineering'));
INSERT INTO Locations (Address, Department_ID) VALUES ('7th Floor, Building G', (SELECT Department_ID FROM Department WHERE Department_Name = 'HR'));
INSERT INTO Locations (Address, Department_ID) VALUES ('8th Floor, Building H', (SELECT Department_ID FROM Department WHERE Department_Name = 'HR'));
INSERT INTO Locations (Address, Department_ID) VALUES ('9th Floor, Building I', (SELECT Department_ID FROM Department WHERE Department_Name = 'Finance'));
INSERT INTO Locations (Address, Department_ID) VALUES ('10th Floor, Building J', (SELECT Department_ID FROM Department WHERE Department_Name = 'Sales'));
INSERT INTO Locations (Address, Department_ID) VALUES ('11th Floor, Building K', (SELECT Department_ID FROM Department WHERE Department_Name = 'Engineering'));
INSERT INTO Locations (Address, Department_ID) VALUES ('12th Floor, Building L', (SELECT Department_ID FROM Department WHERE Department_Name = 'Customer Service'));
INSERT INTO Locations (Address, Department_ID) VALUES ('13th Floor, Building M', (SELECT Department_ID FROM Department WHERE Department_Name = 'Sales'));
INSERT INTO Locations (Address, Department_ID) VALUES ('14th Floor, Building N', (SELECT Department_ID FROM Department WHERE Department_Name = 'Finance'));
INSERT INTO Locations (Address, Department_ID) VALUES ('15th Floor, Building O', (SELECT Department_ID FROM Department WHERE Department_Name = 'Engineering'));
INSERT INTO Locations (Address, Department_ID) VALUES ('16th Floor, Building P', (SELECT Department_ID FROM Department WHERE Department_Name = 'Customer Service'));

------------------------------
-- 5. Employee
------------------------------
-- CONFIGURATION VARIABLES (modify these values to change behavior):
-- ================================================================
-- MAX_EMPLOYEES = 500          : Maximum number of employees to create
-- MIN_SALARY = 25000           : Minimum employee salary (£)
-- SALARY_RANGE = 75001         : Salary range above minimum (max = £100,001)
-- NIN_FORMAT = 'XXYYYYYYZ'     : X=initials, Y=6 digits, Z=last char of first name
-- DOB_START = '1960-01-01'     : Earliest birth date
-- DOB_RANGE_DAYS = 14610       : Birth date range (~40 years)
-- EMAIL_DOMAIN = '@company.com': Company email domain
-- PHONE_PREFIX = '07'          : UK mobile phone prefix
-- HIRE_START = '2020-01-01'    : Earliest hire date
-- HIRE_RANGE_DAYS = 1826       : Hire date range (~5 years)
-- ================================================================

INSERT INTO Employee (
    UserName,
    NIN,
    Address,
    Salary,
    DOB,
    Email,
    Phonenumber,
    Start_Date,
    Department_ID,
    Location_ID
)
WITH DeptList AS (
    SELECT Department_ID, ROW_NUMBER() OVER (ORDER BY Department_ID) - 1 as dept_index
    FROM Department
),
LocationList AS (
    SELECT Location_ID, Department_ID, ROW_NUMBER() OVER (ORDER BY Location_ID) - 1 as global_loc_index,
           ROW_NUMBER() OVER (PARTITION BY Department_ID ORDER BY Location_ID) - 1 as loc_index
    FROM Locations
),
LocationCounts AS (
    SELECT Department_ID, COUNT(*) as location_count
    FROM Locations
    GROUP BY Department_ID
),
TotalLocations AS (
    SELECT COUNT(*) as total_locations FROM Locations
)
SELECT
    TRIM(People.first_name) || ' ' || TRIM(People.last_name) AS UserName,
    
    -- NIN: FirstInitial + LastInitial + 6-digit number + LastCharOfFirstName
    UPPER(SUBSTR(People.first_name, 1, 1)) || UPPER(SUBSTR(People.last_name, 1, 1)) || 
    printf('%06d', ABS((People.id * 73856093) % 1000000)) || 
    UPPER(SUBSTR(People.first_name, -1, 1)) AS NIN,
    
    COALESCE(People.university, 'Unknown Address') AS Address,
    
    -- Salary: MIN_SALARY (25000) + random amount up to SALARY_RANGE (75001)
    25000 + ABS((People.id * 1234567 + COALESCE(LENGTH(People.first_name), 5) * 987654) % 75001) AS Salary,
    
    -- DOB: Random date from DOB_START ('1960-01-01') + random days up to DOB_RANGE_DAYS (14610 = ~40 years)
    DATE('1960-01-01', '+' || ABS((People.id * 456789 + COALESCE(LENGTH(People.last_name), 5) * 123456) % 14610) || ' days') AS DOB,
    
    -- Email: firstname.lastname + EMAIL_DOMAIN (@company.com)
    LOWER(TRIM(People.first_name)) || '.' || LOWER(TRIM(People.last_name)) || '@company.com' AS Email,
    
    -- Phone: PHONE_PREFIX (07) + 9 random digits (UK mobile format)
    '07' || printf('%09d', ABS((People.id * 987654321 + COALESCE(LENGTH(People.university), 10) * 111111) % 1000000000)) AS Phonenumber,
    
    -- Start_Date: Random date from HIRE_START ('2020-01-01') + random days up to HIRE_RANGE_DAYS (1826 = ~5 years)
    DATE('2020-01-01', '+' || ABS((People.id * 789123 + COALESCE(LENGTH(People.job_title), 8) * 456789) % 1826) || ' days') AS Start_Date,
    
    -- Randomly assign employees to departments using better distribution
    -- Uses combination of multiple hash factors to ensure all departments get employees
    (SELECT Department_ID FROM DeptList 
     WHERE dept_index = (ABS((People.id * 17 + COALESCE(LENGTH(People.first_name), 5) * 23 + 
                             COALESCE(LENGTH(People.last_name), 5) * 29 + People.id * People.id * 31) % 
                        (SELECT COUNT(*) FROM Department)))) AS Department_ID,
    
    -- Location assignment: Assign randomly to locations within each department
    -- Uses multi-factor randomization with weighted distribution to ensure good coverage
    -- MUST use same department formula as above to ensure consistency
    (SELECT ll.Location_ID 
     FROM LocationList ll
     JOIN DeptList dl ON ll.Department_ID = dl.Department_ID
     WHERE dl.dept_index = (ABS((People.id * 17 + COALESCE(LENGTH(People.first_name), 5) * 23 + 
                                COALESCE(LENGTH(People.last_name), 5) * 29 + People.id * People.id * 31) % 
                           (SELECT COUNT(*) FROM Department)))
       AND ll.loc_index = (ABS((People.id * 211 + COALESCE(LENGTH(People.first_name), 5) * 307 + 
                               COALESCE(LENGTH(People.last_name), 5) * 983 + People.id * People.id * 1493) % 
                          (SELECT location_count FROM LocationCounts lc 
                           WHERE lc.Department_ID = ll.Department_ID)))
     LIMIT 1) AS Location_ID
FROM People
WHERE People.first_name IS NOT NULL 
  AND People.last_name IS NOT NULL
  AND TRIM(People.first_name) != ''
  AND TRIM(People.last_name) != ''
  AND People.id <= 500; -- MAX_EMPLOYEES

-- Ensure all locations have at least one employee assigned
-- For any empty locations, reassign some employees from over-populated locations
UPDATE Employee
SET Location_ID = (
    SELECT l.Location_ID 
    FROM Locations l
    LEFT JOIN Employee e ON l.Location_ID = e.Location_ID
    WHERE l.Department_ID = Employee.Department_ID
    GROUP BY l.Location_ID
    HAVING COUNT(e.Employee_ID) = 0
    LIMIT 1
)
WHERE Employee_ID IN (
    SELECT e2.Employee_ID
    FROM Employee e2
    JOIN Locations l2 ON e2.Location_ID = l2.Location_ID
    WHERE l2.Department_ID IN (
        SELECT l3.Department_ID
        FROM Locations l3
        LEFT JOIN Employee e3 ON l3.Location_ID = e3.Location_ID
        GROUP BY l3.Location_ID
        HAVING COUNT(e3.Employee_ID) = 0
    )
    AND e2.Location_ID IN (
        SELECT Location_ID
        FROM Employee
        WHERE Department_ID = e2.Department_ID
        GROUP BY Location_ID
        ORDER BY COUNT(*) DESC
        LIMIT 1
    )
    LIMIT 1
);

-- Set leaving dates for some employees to simulate turnover
-- CONFIGURATION VARIABLES:
-- TURNOVER_PERCENTAGE = 15     : Percentage of employees who leave
-- MIN_TENURE_DAYS = 100        : Minimum days employed before leaving
-- MAX_ADDITIONAL_TENURE = 1200 : Additional random days (max tenure = 1300 days)
-- SENIOR_THRESHOLD = 100       : Employee IDs <= this are senior staff who don't leave

UPDATE Employee 
SET Leaving_Date = DATE(Start_Date, '+' || 
    ABS((Employee_ID * 147258 + LENGTH(UserName) * 963) % 1200 + 100) -- MIN_TENURE (100) + random up to MAX_ADDITIONAL (1200)
    || ' days')
WHERE ABS((Employee_ID * 17 + LENGTH(UserName) * 23) % 100) < 15 -- TURNOVER_PERCENTAGE (15%)
  AND Employee_ID > 100; -- SENIOR_THRESHOLD

------------------------------
-- 6. Customer
------------------------------
-- CONFIGURATION VARIABLES:
-- TOTAL_CUSTOMERS = 200    : Number of customer records to generate
-- NAME_POOL_SIZE = 200     : Number of unique names from People table
-- Distribution: Customers evenly distributed among sales representatives

INSERT INTO Customer (UserName, SalesRep_ID)
WITH RECURSIVE 
CustomerGenerator(customer_num) AS (
    SELECT 1 AS customer_num
    UNION ALL
    SELECT customer_num + 1 FROM CustomerGenerator WHERE customer_num < 200 -- TOTAL_CUSTOMERS
),
RandomFirstNames AS (
    SELECT DISTINCT first_name, 
           ROW_NUMBER() OVER (ORDER BY RANDOM()) as first_name_order
    FROM People 
    WHERE first_name IS NOT NULL AND LENGTH(TRIM(first_name)) > 0
    LIMIT 200 -- NAME_POOL_SIZE
),
RandomLastNames AS (
    SELECT DISTINCT last_name,
           ROW_NUMBER() OVER (ORDER BY RANDOM()) as last_name_order
    FROM People 
    WHERE last_name IS NOT NULL AND LENGTH(TRIM(last_name)) > 0
    LIMIT 200 -- NAME_POOL_SIZE
),
SalesReps AS (
    SELECT Employee_ID, ROW_NUMBER() OVER (ORDER BY Employee_ID) as rn
    FROM Employee 
    WHERE Department_ID = (SELECT Department_ID FROM Department WHERE Department_Name = 'Sales')
    AND Leaving_Date IS NULL
),
-- Create unique customer names by combining first and last names with different patterns
CustomerNames AS (
    SELECT 
        cg.customer_num,
        TRIM(rfn.first_name) || ' ' || TRIM(rln.last_name) as full_name,
        -- Randomly assign customers to sales reps (instead of even distribution)
        CASE 
            WHEN (SELECT COUNT(*) FROM SalesReps) > 0 THEN
                (ABS((cg.customer_num * 17 + cg.customer_num * cg.customer_num * 31) % (SELECT COUNT(*) FROM SalesReps))) + 1
            ELSE 1
        END as sales_rep_rn
    FROM CustomerGenerator cg
    JOIN RandomFirstNames rfn ON rfn.first_name_order = 
        ((cg.customer_num - 1) % (SELECT COUNT(*) FROM RandomFirstNames)) + 1
    JOIN RandomLastNames rln ON rln.last_name_order = 
        ((cg.customer_num * 7) % (SELECT COUNT(*) FROM RandomLastNames)) + 1
)
SELECT 
    cn.full_name as UserName,
    COALESCE(
        sr.Employee_ID, 
        (SELECT MIN(Employee_ID) FROM SalesReps),
        (SELECT MIN(Employee_ID) FROM Employee WHERE Leaving_Date IS NULL)
    ) as SalesRep_ID
FROM CustomerNames cn
LEFT JOIN SalesReps sr ON sr.rn = cn.sales_rep_rn
ORDER BY cn.customer_num;

------------------------------
-- 7. Projects
------------------------------
-- CONFIGURATION VARIABLES:
-- TOTAL_PROJECTS = 100         : Number of project records to generate
-- PROJECT_PREFIX = 'Project_'  : Prefix for project names (e.g., 'Project_1')
-- Distribution: Projects distributed across all locations using modulo

WITH RECURSIVE project_generator(x) AS (
    SELECT 1 AS x
    UNION ALL
    SELECT x + 1 FROM project_generator WHERE x < 100 -- TOTAL_PROJECTS
),
LocationList AS (
    SELECT Location_ID, ROW_NUMBER() OVER (ORDER BY Location_ID) - 1 as loc_index
    FROM Locations
)
INSERT INTO Projects (Project_Name, Location_ID)
SELECT 
    'Project_' || x, -- PROJECT_PREFIX
    (SELECT Location_ID FROM LocationList WHERE loc_index = ((x * 13) % (SELECT COUNT(*) FROM Locations))) AS Location_ID
FROM project_generator;

------------------------------
-- 8. Orders
------------------------------
-- CONFIGURATION VARIABLES:
-- TOTAL_ORDERS = 1000          : Number of orders to generate
-- ORDER_START_DATE = '2020-01-01' : Earliest order date
-- ORDER_RANGE_DAYS = 1826      : Date range (~5 years)
-- Distribution: Orders distributed across all customers using modulo

WITH RECURSIVE order_generator(x) AS (
    SELECT 1 AS x
    UNION ALL
    SELECT x + 1 FROM order_generator WHERE x < 1000 -- TOTAL_ORDERS
),
RandomCustomers AS (
    SELECT Customer_ID, ROW_NUMBER() OVER (ORDER BY Customer_ID) as rn
    FROM Customer
)
INSERT INTO Orders (Customer_ID, Order_Date)
SELECT 
    -- Randomly assign orders to customers (creates varied order counts per customer)
    (SELECT Customer_ID FROM RandomCustomers 
     WHERE rn = (ABS((o.x * 47 + o.x * o.x * 89) % (SELECT COUNT(*) FROM RandomCustomers)) + 1)) as Customer_ID,
    -- Order dates from ORDER_START_DATE + random days up to ORDER_RANGE_DAYS
    DATE('2020-01-01', '+' || ABS((o.x * 123456 + o.x * 789) % 1826) || ' days') as Order_Date -- ORDER_START_DATE, ORDER_RANGE_DAYS
FROM order_generator o;

------------------------------
-- 9. DepartmentManager
------------------------------
-- CONFIGURATION VARIABLES:
-- MANAGER_PERIODS = 2-4        : Number of different managers per department over time
-- EARLIEST_START = '2020-01-01': Earliest possible manager start date (aligned with employee hiring)
-- LATEST_START = '2024-06-01'  : Latest start date for current managers
-- MIN_TENURE_DAYS = 180        : Minimum days a manager serves (6 months)
-- MAX_TENURE_DAYS = 730        : Maximum days a manager serves (2 years)
-- GAP_BETWEEN_MGR = 7-30       : Days gap between manager periods (handover)

-- Generate multiple manager periods per department with no overlaps
WITH RECURSIVE
-- Get list of employees per department
DeptEmployees AS (
    SELECT Department_ID, Employee_ID,
           ROW_NUMBER() OVER (PARTITION BY Department_ID ORDER BY Employee_ID) as emp_rank
    FROM Employee
),
-- Determine number of manager periods per department (2-4 periods)
DeptManagerCount AS (
    SELECT Department_ID,
           2 + ABS((Department_ID * 17) % 3) as manager_count  -- 2-4 managers per dept
    FROM Department
),
-- Generate manager periods recursively
ManagerPeriods AS (
    -- First manager period (oldest)
    SELECT 
        d.Department_ID,
        de.Employee_ID,
        1 as period_num,
        -- Start date: EARLIEST_START (2020-01-01) + random offset (0-180 days)
        DATE('2020-01-01', '+' || ABS((d.Department_ID * 123 + de.Employee_ID * 456) % 180) || ' days') as Start_Date,
        -- End date: Start + MIN_TENURE to MAX_TENURE days (180-730 days = 6 months to 2 years)
        DATE('2020-01-01', 
             '+' || (ABS((d.Department_ID * 123 + de.Employee_ID * 456) % 180) + 
                    180 + ABS((d.Department_ID * 789 + de.Employee_ID * 321) % 550)) || ' days') as End_Date,
        dmc.manager_count
    FROM Department d
    JOIN DeptManagerCount dmc ON d.Department_ID = dmc.Department_ID
    JOIN DeptEmployees de ON d.Department_ID = de.Department_ID AND de.emp_rank = 1
    
    UNION ALL
    
    -- Subsequent manager periods
    SELECT 
        mp.Department_ID,
        de.Employee_ID,
        mp.period_num + 1 as period_num,
        -- Start: Previous End_Date + GAP (7-30 days)
        DATE(mp.End_Date, '+' || (7 + ABS((mp.Department_ID * mp.period_num * 13 + de.Employee_ID * 17) % 24)) || ' days') as Start_Date,
        -- End: New Start + tenure (180-730 days), unless it's the current manager
        CASE 
            WHEN mp.period_num + 1 = mp.manager_count THEN NULL  -- Current manager has no end date
            ELSE DATE(mp.End_Date, 
                     '+' || (7 + ABS((mp.Department_ID * mp.period_num * 13 + de.Employee_ID * 17) % 24) +
                            180 + ABS((mp.Department_ID * de.Employee_ID * mp.period_num * 19) % 550)) || ' days')
        END as End_Date,
        mp.manager_count
    FROM ManagerPeriods mp
    JOIN DeptEmployees de ON mp.Department_ID = de.Department_ID 
        AND de.emp_rank = mp.period_num + 1
    WHERE mp.period_num < mp.manager_count
)
INSERT INTO DepartmentManager (Department_ID, Employee_ID, Start_Date, End_Date)
SELECT Department_ID, Employee_ID, Start_Date, End_Date
FROM ManagerPeriods
ORDER BY Department_ID, period_num;

------------------------------
-- 10. Dependants
------------------------------
-- CONFIGURATION VARIABLES:
-- MAX_DEPENDENTS = 5           : Maximum dependents per employee (0-5)
-- NAME_POOL_SIZE = 200         : Number of random names from People table
-- MIN_ADULT_AGE = 18           : Minimum age to have spouse
-- SPOUSE_AGE_DIFF = 5          : Spouse age difference range (±5 years)
-- MIN_PARENT_AGE = 25          : Minimum age to have parents as dependents
-- PARENT_MIN_GAP = 20          : Minimum years parents older than employee
-- PARENT_MAX_GAP = 30          : Maximum years parents older than employee
-- MIN_CHILD_AGE = 18           : Minimum employee age to have children
-- CHILD_PARENT_MIN_AGE = 18    : Parent age when child born (minimum)
-- CHILD_PARENT_MAX_AGE = 45    : Parent age when child born (maximum)
-- Relationships: Max 1 spouse, max 2 parents, remaining slots = children

INSERT INTO Dependants (First_Name, DOB, Relationship, Employee_ID)
WITH RECURSIVE
RandomNames AS (
    SELECT DISTINCT first_name, 
           ROW_NUMBER() OVER (ORDER BY RANDOM()) as name_order
    FROM People 
    WHERE first_name IS NOT NULL AND LENGTH(first_name) > 0
    LIMIT 200 -- NAME_POOL_SIZE
),
-- Calculate current age of each active employee
EmployeeAges AS (
    SELECT Employee_ID, DOB as emp_dob,
           CASE 
               WHEN DOB IS NULL THEN 35
               ELSE CAST((julianday('now') - julianday(DOB)) / 365.25 AS INTEGER)
           END as emp_age
    FROM Employee 
    WHERE Leaving_Date IS NULL
),
-- Determine random number of dependents (0-MAX_DEPENDENTS) for each employee
EmployeeDependentCount AS (
    SELECT Employee_ID, emp_dob, emp_age,
           ABS((Employee_ID * 17 + 23) % 6) as dependent_count -- % 6 gives 0-5 (MAX_DEPENDENTS)
    FROM EmployeeAges
),
-- Generate spouse records (0-1 per employee, only for adults, ~66% probability)
SpouseDependents AS (
    SELECT edc.Employee_ID,
           rn.first_name,
           -- Spouse DOB: employee age ± SPOUSE_AGE_DIFF (5) years
           COALESCE(
               DATE(edc.emp_dob, 
                   '+' || (((edc.Employee_ID * 7) % 11) - 5) || ' years'), -- % 11 - 5 gives range -5 to +5
               DATE('1970-01-01', '+' || ((edc.Employee_ID * 7) % 11000) || ' days')
           ) as dob,
           'Spouse' as relationship,
           1 as dependent_seq
    FROM EmployeeDependentCount edc
    JOIN RandomNames rn ON rn.name_order = (edc.Employee_ID % 200) + 1 -- NAME_POOL_SIZE
    WHERE edc.dependent_count >= 1 
      AND edc.emp_age >= 18 -- MIN_ADULT_AGE
      AND (edc.Employee_ID % 3) != 0 -- ~66% have spouse (2 out of 3)
),
-- Generate parent records (0-2 per employee, ~20% have parents as dependents)
ParentDependents AS (
    SELECT edc.Employee_ID,
           rn1.first_name,
           -- Parents DOB: PARENT_MIN_GAP (20) to PARENT_MAX_GAP (30) years before employee
           COALESCE(
               DATE(edc.emp_dob, '-' || (20 + ((edc.Employee_ID * 11) % 11)) || ' years'), -- 20 + (0-10) = 20-30 years
               DATE('1950-01-01', '+' || ((edc.Employee_ID * 11) % 7300) || ' days')
           ) as dob,
           'Parent' as relationship,
           CASE 
               WHEN edc.dependent_count >= 2 AND (edc.Employee_ID % 4) = 0 THEN 2
               WHEN edc.dependent_count >= 3 AND (edc.Employee_ID % 4) = 0 THEN 3
               ELSE 2
           END as dependent_seq
    FROM EmployeeDependentCount edc
    JOIN RandomNames rn1 ON rn1.name_order = ((edc.Employee_ID * 3) % 200) + 1 -- NAME_POOL_SIZE
    WHERE edc.dependent_count >= 2
      AND edc.emp_age >= 25 -- MIN_PARENT_AGE
      AND (edc.Employee_ID % 5) = 0 -- 20% have parents (1 in 5)
    
    UNION ALL
    
    -- Second parent for some employees
    SELECT edc.Employee_ID,
           rn2.first_name,
           -- Second parent: 22-30 years older than employee
           COALESCE(
               DATE(edc.emp_dob, '-' || (22 + ((edc.Employee_ID * 13) % 9)) || ' years'), -- 22 + (0-8) = 22-30 years
               DATE('1948-01-01', '+' || ((edc.Employee_ID * 13) % 7300) || ' days')
           ) as dob,
           'Parent' as relationship,
           3 as dependent_seq
    FROM EmployeeDependentCount edc
    JOIN RandomNames rn2 ON rn2.name_order = ((edc.Employee_ID * 5) % 200) + 1 -- NAME_POOL_SIZE
    WHERE edc.dependent_count >= 3
      AND edc.emp_age >= 25 -- MIN_PARENT_AGE
      AND (edc.Employee_ID % 5) = 0 -- Must already qualify for first parent
      AND (edc.Employee_ID % 7) = 0 -- ~3% have both parents (1 in 7 of those with 1 parent)
),
-- Generate child records to fill remaining dependent slots
ChildDependents AS (
    SELECT edc.Employee_ID,
           rn.first_name,
           -- Child DOB: when employee was CHILD_PARENT_MIN_AGE (18) to CHILD_PARENT_MAX_AGE (45) years old
           COALESCE(
               DATE(edc.emp_dob, '+' || (18 + ((edc.Employee_ID * child_num * 7) % 28)) || ' years'), -- 18 + (0-27) = 18-45 years
               DATE('1990-01-01', '+' || ((edc.Employee_ID * child_num * 7) % 10950) || ' days')
           ) as dob,
           'Child' as relationship,
           child_num as dependent_seq
    FROM EmployeeDependentCount edc
    JOIN (
        WITH RECURSIVE child_seq(child_num) AS (
            VALUES(1)
            UNION ALL
            SELECT child_num + 1 FROM child_seq WHERE child_num < 5 -- MAX_DEPENDENTS
        )
        SELECT child_num FROM child_seq
    ) cs ON cs.child_num <= edc.dependent_count
    JOIN RandomNames rn ON rn.name_order = ((edc.Employee_ID * cs.child_num * 19) % 200) + 1 -- NAME_POOL_SIZE
    WHERE edc.emp_age >= 18 -- MIN_CHILD_AGE
      -- Calculate slots already used by spouse and parents
      AND cs.child_num > (
          CASE WHEN (edc.Employee_ID % 3) != 0 AND edc.emp_age >= 18 THEN 1 ELSE 0 END +
          CASE 
              WHEN edc.emp_age >= 25 AND (edc.Employee_ID % 5) = 0 AND edc.dependent_count >= 2 THEN 1
              ELSE 0 
          END +
          CASE 
              WHEN edc.emp_age >= 25 AND (edc.Employee_ID % 5) = 0 AND (edc.Employee_ID % 7) = 0 AND edc.dependent_count >= 3 THEN 1
              ELSE 0 
          END
      )
)
-- Combine all dependent types
SELECT first_name, dob, relationship, Employee_ID
FROM SpouseDependents
UNION ALL
SELECT first_name, dob, relationship, Employee_ID  
FROM ParentDependents
UNION ALL
SELECT first_name, dob, relationship, Employee_ID
FROM ChildDependents
ORDER BY Employee_ID;

------------------------------
-- 11. ProjectMember
------------------------------
-- CONFIGURATION VARIABLES:
-- TOTAL_ASSIGNMENTS = 200      : Number of employee-project assignments
-- MAX_HOURS = 1000             : Maximum hours worked on a project
-- Distribution: Employees and projects cycled using modulo

WITH RECURSIVE member_generator(x) AS (
    SELECT 1 AS x
    UNION ALL
    SELECT x + 1 FROM member_generator WHERE x < 200 -- TOTAL_ASSIGNMENTS
),
RandomEmployees AS (
    SELECT Employee_ID, ROW_NUMBER() OVER (ORDER BY Employee_ID) as emp_rn
    FROM Employee WHERE Leaving_Date IS NULL
),
RandomProjects AS (
    SELECT Project_ID, ROW_NUMBER() OVER (ORDER BY Project_ID) as proj_rn  
    FROM Projects
)
INSERT OR IGNORE INTO ProjectMember (Employee_ID, Project_ID, Hours_Worked)
SELECT 
    e.Employee_ID,
    p.Project_ID,
    -- Hours: 1 to MAX_HOURS (1000) using deterministic randomization
    1 + ABS((m.x * 123 + e.Employee_ID * 456 + p.Project_ID * 789) % 1000) AS Hours_Worked -- MAX_HOURS
FROM member_generator m
JOIN RandomEmployees e ON ((m.x - 1) % (SELECT COUNT(*) FROM RandomEmployees)) + 1 = e.emp_rn
JOIN RandomProjects p ON ((m.x * 7) % (SELECT COUNT(*) FROM RandomProjects)) + 1 = p.proj_rn;

------------------------------
-- 12. OrderDetails
------------------------------
-- CONFIGURATION VARIABLES:
-- TOTAL_ORDER_LINES = 500      : Number of order line items
-- MAX_QUANTITY = 500           : Maximum quantity per product per order
-- Distribution: Orders and products cycled using modulo

WITH RECURSIVE detail_generator(x) AS (
    SELECT 1 AS x
    UNION ALL
    SELECT x + 1 FROM detail_generator WHERE x < 500 -- TOTAL_ORDER_LINES
),
RandomOrders AS (
    SELECT Order_ID, ROW_NUMBER() OVER (ORDER BY Order_ID) as ord_rn
    FROM Orders
),
RandomProducts AS (
    SELECT Product_ID, ROW_NUMBER() OVER (ORDER BY Product_ID) as prod_rn
    FROM Product
)
INSERT OR IGNORE INTO OrderDetails (Order_ID, Product_ID, Quantity)
SELECT 
    o.Order_ID,
    p.Product_ID,
    -- Quantity: 1 to MAX_QUANTITY (500) using deterministic randomization
    1 + ABS((d.x * 234 + o.Order_ID * 567 + p.Product_ID * 890) % 500) AS Quantity -- MAX_QUANTITY
FROM detail_generator d
JOIN RandomOrders o ON ((d.x - 1) % (SELECT COUNT(*) FROM RandomOrders)) + 1 = o.ord_rn
JOIN RandomProducts p ON ((d.x * 3) % (SELECT COUNT(*) FROM RandomProducts)) + 1 = p.prod_rn;

------------------------------
-- 13. Inventory
------------------------------
-- CONFIGURATION VARIABLES:
-- MIN_STOCK = 10               : Minimum inventory per product per warehouse
-- STOCK_RANGE = 491            : Additional stock range (max = 10 + 491 = 501)
-- Distribution: Every product stocked in every warehouse (cross join)

INSERT INTO Inventory (Warehouse_ID, Product_ID, Quantity)
SELECT 
    w.Warehouse_ID,
    p.Product_ID,
    -- Stock: MIN_STOCK (10) to MIN_STOCK + STOCK_RANGE (501) units
    10 + ABS((w.Warehouse_ID * 333 + p.Product_ID * 777) % 491) AS Quantity -- MIN_STOCK, STOCK_RANGE
FROM Warehouse w

CROSS JOIN Product p;
