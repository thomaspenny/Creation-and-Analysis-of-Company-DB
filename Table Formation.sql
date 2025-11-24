-- ------------------------------------------------------------------------------
--   Database Formation Script by Thomas Penny
--   SQLite Compatible Version
-- ------------------------------------------------------------------------------

-- Drop tables first to ensure they don't already exist

DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS ProjectMember;
DROP TABLE IF EXISTS Projects;
DROP TABLE IF EXISTS DepartmentManager;
DROP TABLE IF EXISTS Dependants;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Locations;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Warehouse;
DROP TABLE IF EXISTS Department;

-- Note, that a * will indicate that the table has dependencies on other tables that require those tables to be created before it can be.

--------------------------------------------------------------------------------

-- Part A: Internal Company tables

-- 1. Department table

CREATE TABLE Department (
    Department_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Department_Name TEXT NOT NULL UNIQUE
);


-- 2. Locations table *

CREATE TABLE Locations (
    Location_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Address TEXT NOT NULL,
    Department_ID INTEGER NOT NULL,
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);


-- 3. Employee table *

CREATE TABLE Employee (
    Employee_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserName TEXT NOT NULL,
    NIN TEXT NOT NULL UNIQUE,
    Address TEXT NOT NULL,
    Salary REAL NOT NULL,
    DOB DATE,
    Email TEXT UNIQUE,
    Phonenumber TEXT UNIQUE,
    Start_Date DATE NOT NULL,
    Leaving_Date DATE,
    Department_ID INTEGER NOT NULL,
    Location_ID INTEGER,
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID),
    FOREIGN KEY (Location_ID) REFERENCES Locations(Location_ID)
);


-- 4. Dependants table *

CREATE TABLE Dependants (
    Dependant_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Employee_ID INTEGER NOT NULL,
    First_Name TEXT NOT NULL,
    DOB DATE NOT NULL,
    Relationship TEXT NOT NULL,
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
);


-- 5. DepartmentManager table

CREATE TABLE DepartmentManager (
    Department_ID INTEGER NOT NULL,
    Employee_ID INTEGER NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE,
    PRIMARY KEY (Department_ID, Employee_ID),
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID),
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
);


-- 6. Projects table *

CREATE TABLE Projects (
    Project_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Project_Name TEXT NOT NULL,
    Location_ID INTEGER NOT NULL,
    FOREIGN KEY (Location_ID) REFERENCES Locations(Location_ID)
);


-- 7. ProjectMember table *

CREATE TABLE ProjectMember (
    Employee_ID INTEGER NOT NULL,
    Project_ID INTEGER NOT NULL,
    Hours_Worked INTEGER,
    PRIMARY KEY (Employee_ID, Project_ID),
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID),
    FOREIGN KEY (Project_ID) REFERENCES Projects(Project_ID)
);

---------------------------------------------------------------
-- Part B: Customer-related tables

-- 8. Customer table *

CREATE TABLE Customer (
    Customer_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserName TEXT NOT NULL,
    SalesRep_ID INTEGER NOT NULL,
    FOREIGN KEY (SalesRep_ID) REFERENCES Employee(Employee_ID)
);


-- 9. Order table *

CREATE TABLE Orders (
    Order_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Customer_ID INTEGER NOT NULL,
    Order_Date DATE NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);


-- 10. Product table

CREATE TABLE Product (
    Product_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Product_Name TEXT NOT NULL,
    Price REAL NOT NULL
);


-- 11. OrderDetails table *

CREATE TABLE OrderDetails (
    Order_ID INTEGER NOT NULL,
    Product_ID INTEGER NOT NULL,
    Quantity INTEGER NOT NULL,
    PRIMARY KEY (Order_ID, Product_ID),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);


-- 12. Warehouse table

CREATE TABLE Warehouse (
    Warehouse_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Address TEXT NOT NULL
);


-- 13. Create Inventory table *

CREATE TABLE Inventory (
    Warehouse_ID INTEGER NOT NULL,
    Product_ID INTEGER NOT NULL,
    Quantity INTEGER NOT NULL,
    PRIMARY KEY (Warehouse_ID, Product_ID),
    FOREIGN KEY (Warehouse_ID) REFERENCES Warehouse(Warehouse_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);
