# Creation and Analysis of Company Database

A comprehensive project demonstrating SQLite database creation, population, and analysis using Python and Jupyter Notebook. This project creates a multi-table company database with departments, employees, customers, orders, and more.

## Project Overview

This project includes:
- SQLite database schema with 13+ interconnected tables
- Data import from CSV files
- SQL scripts for table creation and population
- Python-based data analysis using Jupyter Notebook
- Visualizations and insights from company data

## Prerequisites

- Python 3.x
- SQLite3
- Jupyter Notebook
- Required Python libraries:
  - `sqlite3` (built-in)
  - `pandas`
  - `matplotlib`
  - `seaborn`
  - `numpy`

## Installation

Install the required Python packages:

```bash
pip install pandas matplotlib seaborn numpy jupyter
```

## Project Structure

```
Creation-and-Analysis-of-Company-DB/
│
├── Database/
│   ├── people.csv              # Source data for employee information
│   ├── Table Formation.sql     # SQL script to create database schema
│   └── Table Population.sql    # SQL script to populate tables with data
│
├── Company_Analysis.ipynb      # Jupyter Notebook for data analysis
├── Company_Analysis.html       # HTML export of the analysis notebook
└── README.md                   # This file
```

## Step-by-Step Guide

### Step 1: Create the Database and Import CSV Data

First, create a new SQLite database and import the `people.csv` file:

1. Open a terminal/command prompt in the project directory
2. Start SQLite3 and create the database:

```bash
sqlite3 Company.db
```

3. Inside the SQLite prompt, import the CSV file:

```sql
.mode csv
.import Database/people.csv people
.exit
```

This creates a `people` table from the CSV data that will be used by subsequent scripts.

### Step 2: Run Table Formation Script

Execute the table formation script to create the database schema:

```bash
sqlite3 Company.db < "Database/Table Formation.sql"
```

This script will:
- Drop any existing tables to ensure a clean slate
- Create 13+ interconnected tables including:
  - Department
  - Employee
  - Locations
  - Customer
  - Orders
  - OrderDetails
  - Product
  - Warehouse
  - Inventory
  - Projects
  - ProjectMember
  - Dependants
  - DepartmentManager

### Step 3: Run Table Population Script

Populate the tables with sample data:

```bash
sqlite3 Company.db < "Database/Table Population.sql"
```

This script will:
- Clear any existing data
- Insert comprehensive sample data into all tables
- Establish relationships between tables through foreign keys

### Step 4: Run the Jupyter Notebook Analysis

Launch Jupyter Notebook and open the analysis file:

```bash
jupyter notebook Company_Analysis.ipynb
```

The notebook includes:
- Database connection and exploration
- Schema inspection
- Data queries and analysis
- Visualizations and insights
- Statistical analysis of company data

Run all cells in the notebook to:
- Connect to the database
- Explore the database schema
- Execute SQL queries
- Generate visualizations
- Analyze business metrics

## Database Schema Highlights

The database includes the following key tables:

- **Department**: Company departments and organizational structure
- **Employee**: Employee information, salaries, and department assignments
- **Customer**: Customer contact information
- **Orders**: Customer order records
- **Product**: Product catalog with pricing
- **Warehouse**: Inventory locations
- **Projects**: Company projects and timelines
- **ProjectMember**: Employee-project assignments

## Analysis Features

The Jupyter Notebook provides:
- Comprehensive database schema exploration
- Employee demographics and salary analysis
- Department distribution and staffing levels
- Order and revenue analysis
- Product performance metrics
- Inventory management insights
- Project allocation and resource management

## Troubleshooting

- **Database locked error**: Ensure no other applications have the database open
- **Import errors**: Verify CSV file path and format
- **Missing tables**: Ensure scripts are run in the correct order
- **Python package errors**: Install all required packages using pip

## Author

Thomas Penny

## License

This project is for educational and demonstration purposes.
