create database Blinkit_Grocery;   #Create Database
USE Blinkit_Grocery;             #Use this Database

SET SQL_SAFE_UPDATES = 0;  # Safe Mode ON Command [disables Safe Updates Mode in MySQL, allowing to run potentially risky SQL statements like UPDATE or DELETE without a WHERE clause or LIMIT.]

#Data Preprocessing:
create table GroceryData (
    Item_Fat_Content VARCHAR(50),
    Item_Identifier VARCHAR(50),
    Item_Type VARCHAR(50),
    Outlet_Establishment_Year INT,
    Outlet_Identifier VARCHAR(50),
    Outlet_Location_Type VARCHAR(50),
    Outlet_Size VARCHAR(50),
    Outlet_Type VARCHAR(50),
    Item_Visibility FLOAT,
    Item_Weight FLOAT,
    Total_Sales FLOAT,
    Rating FLOAT
);

ALTER TABLE GroceryData MODIFY Item_Weight FLOAT NULL;  #Allow NULL Values, dataset includes missing or unknown weights, and want to store them as NULL instead of 0 or dummy values.
ALTER TABLE GroceryData MODIFY Item_Weight DOUBLE;      #This command changes the data type to DOUBLE, which provides more precision and a larger range than FLOAT.

SELECT * FROM GroceryData;
SELECT COUNT(*) FROM GroceryData;         # Total Number of Row and Coulmn

DESCRIBE GroceryData;     # is used to display the structure (schema) of the table GroceryData.
ALTER TABLE GroceryData 
CHANGE `ï»¿Item Fat Content` Item_Fat_Content VARCHAR(50);        # That ï»¿ sequence is the Byte Order Mark (BOM) from a UTF-8 encoded CSV file, its sometime gets accidentally when Import 

# Data Cleaning:
UPDATE GroceryData         
SET Item_Fat_Content =
CASE
WHEN Item_Fat_Content IN  ('LF', 'low fat') THEN 'Low Fat'       #This query standardizes inconsistent values in the Item_Fat_Content column of the GroceryData table.
WHEN Item_Fat_Content = 'reg' THEN 'Regular'
ELSE Item_Fat_Content
END;

SELECT Item_Weight, COUNT(*) 
FROM GroceryData 
GROUP BY Item_Weight                #(optional) This helps you see how many 0s or NULLs exist before deciding.
ORDER BY Item_Weight;

SELECT DISTINCT(Item_Identifier)FROM GroceryData; # For see the DISTINCT values 

# SQL Query for KPI's:
	# 1. Total Sales:
select concat('Total_Sales:', CAST(SUM(Total_Sales)/1000000 AS DECIMAL(10,2)), ' Million') AS Total_Sales
FROM GroceryData;    # Total Sales number is very big, so we change the number into Million 
# What This Query Does: 
-- SUM(Total_Sales): Adds up all sales values in the Total_Sales column.
-- / 1000000: Converts the total into millions.
-- CAST(... AS DECIMAL(10,2)): Rounds the number to 2 decimal places.
-- CONCAT(...): Combines the label, the number, and the "Million" text into one string.
-- AS Total_Sales: Gives the result column a readable name. 

     # 2. Average Sales:
SELECT CONCAT('Average Sales', CAST(AVG(Total_Sales) AS DECIMAL(10,1)), ' USD') AS Avg_Sales
FROM GroceryData;    # Average Sales number is in USD, so we change the number into USD
#What This Does:
-- AVG(Total_Sales): Calculates the average of all values in the Total_Sales column.
-- CAST(... AS DECIMAL(10,1)): Rounds the result to 1 decimal place.
-- CONCAT(...): Formats the result as a descriptive string

# 3. Number of Items:
SELECT CONCAT('No of Items: ', COUNT(*)) AS No_Of_Items FROM GroceryData;
# What It Does:
-- COUNT(*): Counts all rows in the GroceryData table.
-- CONCAT('No of Items: ', COUNT(*)): Creates a human-readable string.
-- AS No_Of_Items: Labels the output column.

# 4. Average Rating:
SELECT CONCAT('Average Rating: ', CAST(AVG(Rating) AS DECIMAL(10,2))) AS Avg_Rating
FROM GroceryData;     
# What It Does:
-- AVG(Rating): Computes the average value of the Rating column.
-- CAST(... AS DECIMAL(10,2)): Rounds it to 2 decimal places for clarity.
-- CONCAT(...): Formats the result as a readable string

# SQL Query for Granular Requirements:
	# 1. Total Sales by Fat Content:
SELECT CONCAT('Total Sales by Fat Content', CAST(SUM(Total_Sales)/1000000 AS DECIMAL(10,2)), ' Million') AS Total_Sales
FROM GroceryData
WHERE Item_Fat_Content = 'Low Fat'
GROUP BY Item_Fat_Content
ORDER BY Total_Sales DESC; 

SELECT 
    Item_Fat_Content,
    CONCAT('$', CAST(SUM(Total_Sales)/1000 AS DECIMAL(10,2))) AS Total_Sales,
    CONCAT(CAST(AVG(Total_Sales) AS DECIMAL(10,1)), ' USD') AS Avg_Sales,
    CONCAT(COUNT(*), ' Items') AS No_Of_Items,
    CONCAT(CAST(AVG(Rating) AS DECIMAL(10,2)), ' Stars') AS Avg_Rating
FROM 
    GroceryData
GROUP BY 
    Item_Fat_Content
ORDER BY 
    SUM(Total_Sales) DESC;
    
# 2. Total Sales by Item Type:
		# All Items:
SELECT
    Item_Type,
    CONCAT('$', CAST(SUM(Total_Sales)/1000 AS DECIMAL(10,2))) AS Total_Sales,
    CONCAT(CAST(AVG(Total_Sales) AS DECIMAL(10,1)), ' USD') AS Avg_Sales,
    CONCAT('No of Items: ', COUNT(*)) AS No_Of_Items,
    CONCAT(CAST(AVG(Rating) AS DECIMAL(10,2)), ' Stars') AS Avg_Rating
FROM 
    GroceryData
GROUP BY 
    Item_Type
ORDER BY 
    SUM(Total_Sales) DESC;
    
    # Top & Last 5 Items:
(
    SELECT 
        Item_Type,
        CONCAT('$', CAST(IFNULL(SUM(Total_Sales), 0)/1000 AS DECIMAL(10,2))) AS Total_Sales,
        CONCAT(CAST(IFNULL(AVG(Total_Sales), 0) AS DECIMAL(10,1)), ' USD') AS Avg_Sales,
        CONCAT(COUNT(*), ' Items') AS No_Of_Items,
        CONCAT(CAST(IFNULL(AVG(Rating), 0) AS DECIMAL(10,2)), ' Stars') AS Avg_Rating
    FROM 
        GroceryData
    GROUP BY 
        Item_Type
    ORDER BY 
        IFNULL(SUM(Total_Sales), 0) DESC
    LIMIT 5
)
UNION ALL
(
    SELECT 
        Item_Type,
        CONCAT('$', CAST(IFNULL(SUM(Total_Sales), 0)/1000 AS DECIMAL(10,2))) AS Total_Sales,
        CONCAT(CAST(IFNULL(AVG(Total_Sales), 0) AS DECIMAL(10,1)), ' USD') AS Avg_Sales,
        CONCAT(COUNT(*), ' Items') AS No_Of_Items,
        CONCAT(CAST(IFNULL(AVG(Rating), 0) AS DECIMAL(10,2)), ' Stars') AS Avg_Rating
    FROM 
        GroceryData
    GROUP BY 
        Item_Type
    ORDER BY 
        IFNULL(SUM(Total_Sales), 0) ASC
    LIMIT 5
);

	 # 4. Total Sales by Outlet Establishment:
SELECT Outlet_Establishment_Year,
	CAST(SUM(Total_Sales) AS DECIMAL (10,2)) AS Total_Sales,
    CONCAT('Average Sales', CAST(AVG(Total_Sales) AS DECIMAL(10,1)), ' USD') AS Avg_Sales,
    CONCAT('No of Items: ', COUNT(*)) AS No_Of_Items,
    CONCAT('Average Rating: ', CAST(AVG(Rating) AS DECIMAL(10,2))) AS Avg_Rating
FROM GroceryData
GROUP BY Outlet_Establishment_Year
ORDER BY Total_Sales DESC;

# 5. Percentage of Sales by Outlet Size:
SELECT 
    Outlet_Size, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM GroceryData
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;

	# 6. Sales by Outlet Location:
SELECT Outlet_Location_Type, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM GroceryData
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC;
    
    # 7. All Metrics by Outlet Type:
SELECT Outlet_Type, 
CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
-- CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage,
		CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Avg_Sales,
		COUNT(*) AS No_Of_Items,
		CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,
		CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Item_Visibility
FROM GroceryData
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC;