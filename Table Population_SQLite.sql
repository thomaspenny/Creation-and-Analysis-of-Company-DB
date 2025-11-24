-- ------------------------------------------------------------------------------
--   Database Population Script by Thomas Penny
--   SQLite Compatible Version
--   
--   This script populates database tables using an existing People table
--   
--   REQUIREMENTS:
--   =============
--   - People table must exist in the current database with columns:
--     id, first_name, last_name, email, job_title, university
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
INSERT INTO Employee (
    UserName,
    NIN,
    Address,
    Salary,
    DOB,
    Email,
    Phonenumber,
    Start_Date,
    Department_ID
)
WITH DeptList AS (
    SELECT Department_ID, ROW_NUMBER() OVER (ORDER BY Department_ID) - 1 as dept_index
    FROM Department
)
SELECT
    TRIM(People.first_name) || ' ' || TRIM(People.last_name) AS UserName,
    
    UPPER(SUBSTR(People.first_name, 1, 1)) || UPPER(SUBSTR(People.last_name, 1, 1)) || 
    printf('%06d', ABS((People.id * 73856093) % 1000000)) || 
    UPPER(SUBSTR(People.first_name, -1, 1)) AS NIN,
    
    COALESCE(People.university, 'Unknown Address') AS Address,
    
    25000 + ABS((People.id * 1234567 + COALESCE(LENGTH(People.first_name), 5) * 987654) % 75001) AS Salary,
    
    DATE('1960-01-01', '+' || ABS((People.id * 456789 + COALESCE(LENGTH(People.last_name), 5) * 123456) % 14610) || ' days') AS DOB,
    
    LOWER(TRIM(People.first_name)) || '.' || LOWER(TRIM(People.last_name)) || '@company.com' AS Email,
    
    '07' || printf('%09d', ABS((People.id * 987654321 + COALESCE(LENGTH(People.university), 10) * 111111) % 1000000000)) AS Phonenumber,
    
    DATE('2020-01-01', '+' || ABS((People.id * 789123 + COALESCE(LENGTH(People.job_title), 8) * 456789) % 1826) || ' days') AS Start_Date,
    
    (SELECT Department_ID FROM DeptList WHERE dept_index = (People.id % (SELECT COUNT(*) FROM Department))) AS Department_ID
FROM People
WHERE People.first_name IS NOT NULL 
  AND People.last_name IS NOT NULL
  AND TRIM(People.first_name) != ''
  AND TRIM(People.last_name) != ''
  AND People.id <= 500;

-- Set leaving dates for some employees to simulate turnover
UPDATE Employee 
SET Leaving_Date = DATE(Start_Date, '+' || ABS((Employee_ID * 147258 + LENGTH(UserName) * 963) % 1200 + 100) || ' days')
-- Approximately 15% get leaving dates
WHERE ABS((Employee_ID * 17 + LENGTH(UserName) * 23) % 100) < 15
-- Don't set leaving dates for early/senior employees
AND Employee_ID > 100;

------------------------------
-- 6. Customer
------------------------------
-- Generate 200 customers using random first and last names from People.db
-- Customers are evenly distributed among available sales representatives
INSERT INTO Customer (UserName, SalesRep_ID)
WITH RECURSIVE 
CustomerGenerator(customer_num) AS (
    SELECT 1 AS customer_num
    UNION ALL
    SELECT customer_num + 1 FROM CustomerGenerator WHERE customer_num < 200
),
RandomFirstNames AS (
    SELECT DISTINCT first_name, 
           ROW_NUMBER() OVER (ORDER BY RANDOM()) as first_name_order
    FROM People 
    WHERE first_name IS NOT NULL AND LENGTH(TRIM(first_name)) > 0
    LIMIT 200
),
RandomLastNames AS (
    SELECT DISTINCT last_name,
           ROW_NUMBER() OVER (ORDER BY RANDOM()) as last_name_order
    FROM People 
    WHERE last_name IS NOT NULL AND LENGTH(TRIM(last_name)) > 0
    LIMIT 200
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
        -- Distribute customers evenly among sales reps using modulo arithmetic
        CASE 
            WHEN (SELECT COUNT(*) FROM SalesReps) > 0 THEN
                ((cg.customer_num - 1) % (SELECT COUNT(*) FROM SalesReps)) + 1
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
WITH RECURSIVE project_generator(x) AS (
    SELECT 1 AS x
    UNION ALL
    SELECT x + 1 FROM project_generator WHERE x < 100
),
LocationList AS (
    SELECT Location_ID, ROW_NUMBER() OVER (ORDER BY Location_ID) - 1 as loc_index
    FROM Locations
)
INSERT INTO Projects (Project_Name, Location_ID)
SELECT 
    'Project_' || x,
    (SELECT Location_ID FROM LocationList WHERE loc_index = ((x * 13) % (SELECT COUNT(*) FROM Locations))) AS Location_ID
FROM project_generator;

------------------------------
-- 8. Orders
------------------------------
-- Generate 1000 orders with random customer assignments and dates spread over 5 years
WITH RECURSIVE order_generator(x) AS (
    SELECT 1 AS x
    UNION ALL
    SELECT x + 1 FROM order_generator WHERE x < 1000
),
RandomCustomers AS (
    SELECT Customer_ID, ROW_NUMBER() OVER (ORDER BY Customer_ID) as rn
    FROM Customer
)
INSERT INTO Orders (Customer_ID, Order_Date)
SELECT 
    c.Customer_ID,
    -- Create order dates spread across approximately 5 years (1826 days)
    DATE('2020-01-01', '+' || ABS((o.x * 123456 + c.Customer_ID * 789) % 1826) || ' days') as Order_Date
FROM order_generator o
JOIN RandomCustomers c ON ((o.x - 1) % (SELECT COUNT(*) FROM RandomCustomers)) + 1 = c.rn;

------------------------------
-- 9. DepartmentManager (replicating original Oracle department loop logic)
------------------------------
-- Current managers (one per department)
INSERT INTO DepartmentManager (Department_ID, Employee_ID, Start_Date, End_Date)
SELECT 
    d.Department_ID,
    e.Employee_ID,
    DATE('2023-01-01', '+' || ABS((d.Department_ID * 365 + e.Employee_ID * 30) % 365) || ' days') AS Start_Date,
    NULL AS End_Date
FROM Department d
JOIN (
    SELECT Department_ID, Employee_ID, 
           ROW_NUMBER() OVER (PARTITION BY Department_ID ORDER BY Employee_ID) as rn
    FROM Employee 
    WHERE Leaving_Date IS NULL
) e ON d.Department_ID = e.Department_ID AND e.rn = 1;

-- Past managers (one per department)
INSERT INTO DepartmentManager (Department_ID, Employee_ID, Start_Date, End_Date)
SELECT 
    d.Department_ID,
    e.Employee_ID,
    DATE('2020-01-01', '+' || ABS((d.Department_ID * 200 + e.Employee_ID * 50) % 730) || ' days') AS Start_Date,
    DATE('2022-12-31', '-' || ABS((d.Department_ID * 100 + e.Employee_ID * 25) % 365) || ' days') AS End_Date
FROM Department d
JOIN (
    SELECT Department_ID, Employee_ID, 
           ROW_NUMBER() OVER (PARTITION BY Department_ID ORDER BY Employee_ID DESC) as rn
    FROM Employee 
    WHERE Employee_ID NOT IN (SELECT Employee_ID FROM DepartmentManager)
) e ON d.Department_ID = e.Department_ID AND e.rn = 1;

------------------------------
-- 10. Dependants
------------------------------
-- Generate 0-5 dependents per employee with realistic family relationships:
-- Maximum 1 spouse, maximum 2 parents, remaining slots filled with children
-- Uses random first names from People.db and creates age-appropriate birth dates

INSERT INTO Dependants (First_Name, DOB, Relationship, Employee_ID)
WITH RECURSIVE
RandomNames AS (
    SELECT DISTINCT first_name, 
           ROW_NUMBER() OVER (ORDER BY RANDOM()) as name_order
    FROM People 
    WHERE first_name IS NOT NULL AND LENGTH(first_name) > 0
    LIMIT 200
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
-- Determine random number of dependents (0-5) for each employee
EmployeeDependentCount AS (
    SELECT Employee_ID, emp_dob, emp_age,
           ABS((Employee_ID * 17 + 23) % 6) as dependent_count
    FROM EmployeeAges
),
-- Generate spouse records (0-1 per employee, only for adults, ~66% probability)
SpouseDependents AS (
    SELECT edc.Employee_ID,
           rn.first_name,
           -- Spouse birth date: employee age +/- 5 years
           COALESCE(
               DATE(edc.emp_dob, 
                   '+' || (((edc.Employee_ID * 7) % 11) - 5) || ' years'),
               DATE('1970-01-01', '+' || ((edc.Employee_ID * 7) % 11000) || ' days')
           ) as dob,
           'Spouse' as relationship,
           1 as dependent_seq
    FROM EmployeeDependentCount edc
    JOIN RandomNames rn ON rn.name_order = (edc.Employee_ID % 200) + 1
    WHERE edc.dependent_count >= 1 
      AND edc.emp_age >= 18
      AND (edc.Employee_ID % 3) != 0
),
-- Generate parent records (0-2 per employee, ~20% have parents as dependents)
ParentDependents AS (
    SELECT edc.Employee_ID,
           rn1.first_name,
           -- Parents born 20-30 years before employee
           COALESCE(
               DATE(edc.emp_dob, '-' || (20 + ((edc.Employee_ID * 11) % 11)) || ' years'),
               DATE('1950-01-01', '+' || ((edc.Employee_ID * 11) % 7300) || ' days')
           ) as dob,
           'Parent' as relationship,
           CASE 
               WHEN edc.dependent_count >= 2 AND (edc.Employee_ID % 4) = 0 THEN 2
               WHEN edc.dependent_count >= 3 AND (edc.Employee_ID % 4) = 0 THEN 3
               ELSE 2
           END as dependent_seq
    FROM EmployeeDependentCount edc
    JOIN RandomNames rn1 ON rn1.name_order = ((edc.Employee_ID * 3) % 200) + 1
    WHERE edc.dependent_count >= 2
      AND edc.emp_age >= 25
      AND (edc.Employee_ID % 5) = 0
    
    UNION ALL
    
    -- Second parent for some employees
    SELECT edc.Employee_ID,
           rn2.first_name,
           COALESCE(
               DATE(edc.emp_dob, '-' || (22 + ((edc.Employee_ID * 13) % 9)) || ' years'),
               DATE('1948-01-01', '+' || ((edc.Employee_ID * 13) % 7300) || ' days')
           ) as dob,
           'Parent' as relationship,
           3 as dependent_seq
    FROM EmployeeDependentCount edc
    JOIN RandomNames rn2 ON rn2.name_order = ((edc.Employee_ID * 5) % 200) + 1
    WHERE edc.dependent_count >= 3
      AND edc.emp_age >= 25
      AND (edc.Employee_ID % 5) = 0
      AND (edc.Employee_ID % 7) = 0
),
-- Generate child records to fill remaining dependent slots
ChildDependents AS (
    SELECT edc.Employee_ID,
           rn.first_name,
           -- Children born when employee was 18-45 years old
           COALESCE(
               DATE(edc.emp_dob, '+' || (18 + ((edc.Employee_ID * child_num * 7) % 28)) || ' years'),
               DATE('1990-01-01', '+' || ((edc.Employee_ID * child_num * 7) % 10950) || ' days')
           ) as dob,
           'Child' as relationship,
           child_num as dependent_seq
    FROM EmployeeDependentCount edc
    JOIN (
        WITH RECURSIVE child_seq(child_num) AS (
            VALUES(1)
            UNION ALL
            SELECT child_num + 1 FROM child_seq WHERE child_num < 5
        )
        SELECT child_num FROM child_seq
    ) cs ON cs.child_num <= edc.dependent_count
    JOIN RandomNames rn ON rn.name_order = ((edc.Employee_ID * cs.child_num * 19) % 200) + 1
    WHERE edc.emp_age >= 18
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
-- Assign employees to projects with random hours worked
-- Creates approximately 200 project assignments with varied workload distribution
WITH RECURSIVE member_generator(x) AS (
    SELECT 1 AS x
    UNION ALL
    SELECT x + 1 FROM member_generator WHERE x < 200
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
    -- Generate hours worked between 1-1000 using deterministic randomization
    1 + ABS((m.x * 123 + e.Employee_ID * 456 + p.Project_ID * 789) % 1000) AS Hours_Worked
FROM member_generator m
JOIN RandomEmployees e ON ((m.x - 1) % (SELECT COUNT(*) FROM RandomEmployees)) + 1 = e.emp_rn
JOIN RandomProjects p ON ((m.x * 7) % (SELECT COUNT(*) FROM RandomProjects)) + 1 = p.proj_rn;

------------------------------
-- 12. OrderDetails
------------------------------
-- Create order line items linking orders to products with quantities
-- Generates approximately 500 order details across all orders and products
WITH RECURSIVE detail_generator(x) AS (
    SELECT 1 AS x
    UNION ALL
    SELECT x + 1 FROM detail_generator WHERE x < 500
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
    -- Generate order quantities between 1-500 using mixed seeds for variety
    1 + ABS((d.x * 234 + o.Order_ID * 567 + p.Product_ID * 890) % 500) AS Quantity
FROM detail_generator d
JOIN RandomOrders o ON ((d.x - 1) % (SELECT COUNT(*) FROM RandomOrders)) + 1 = o.ord_rn
JOIN RandomProducts p ON ((d.x * 3) % (SELECT COUNT(*) FROM RandomProducts)) + 1 = p.prod_rn;

------------------------------
-- 13. Inventory
------------------------------
-- Create inventory records for every product in every warehouse
-- Uses cross join to ensure complete product availability across all locations
INSERT INTO Inventory (Warehouse_ID, Product_ID, Quantity)
SELECT 
    w.Warehouse_ID,
    p.Product_ID,
    -- Generate stock levels between 10-500 units per product per warehouse
    10 + ABS((w.Warehouse_ID * 333 + p.Product_ID * 777) % 491) AS Quantity
FROM Warehouse w
CROSS JOIN Product p;