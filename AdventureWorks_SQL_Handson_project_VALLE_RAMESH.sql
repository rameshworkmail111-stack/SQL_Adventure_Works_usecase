-- 4. Part A – DDL Operations 

-- TASK 1 ( Database investigation ) 

-- What tables are available? 
USE ADVENTURE_WORKS_TRAINING;
SHOW TABLES;

-- Which tables belong to Sales, Production and Person schemas?

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN
(
    'Sales',
    'Production',
    'Person'
)
ORDER BY
    TABLE_SCHEMA,
    TABLE_NAME;
    
-- Identify primary keys for Sales.SalesOrderHeader, Sales.SalesOrderDetail, Sales.Customer, Production.Product and Sales.SalesPerson. 
DESCRIBE Sales.SalesOrderHeader;
DESCRIBE Sales.SalesOrderDetail;
DESCRIBE Sales.Customer;
DESCRIBE Production.Product;
DESCRIBE Sales.SalesPerson;
-- Identify important foreign-key relationships.

-- (1.) Customer → Person 					(Sales.Customer.PersonID  -> 	Person.Person.BusinessEntityID )
-- (2.) Customer → Territory    			( Sales.Customer.TerritoryID -> Sales.SalesTerritory.TerritoryID )
-- (3.) Sales Order Header → Customer 		( Sales.SalesOrderHeader.CustomerID -> Sales.Customer.CustomerID )
-- (4.) Sales Order Header → Salesperson 	( Sales.SalesOrderHeader.SalesPersonID -> Sales.SalesPerson.BusinessEntityID )
-- (5.) Sales Order Header → Territory  	( Sales.SalesOrderHeader.TerritoryID -> Sales.SalesTerritory.TerritoryID )
-- (6.) Sales Order Detail → Sales Order Header 	( Sales.SalesOrderDetail.SalesOrderID -> Sales.SalesOrderHeader.SalesOrderID )
-- (7.) Sales Order Detail → Product 				( Sales.SalesOrderDetail.ProductID ->  Production.Product.ProductID )
-- (8.) Product → Product Subcategory				( Production.Product.ProductSubcategoryID -> Production.ProductSubcategory.ProductSubcategoryID )
-- (9.) Product Subcategory → Product Category		( Production.ProductSubcategory.ProductCategoryID     ->      Production.ProductCategory.ProductCategoryID )

-- Determine how a customer connects to a sales order, how a sales order connects to a product, and how a product connects to a product category.
-- Customer → Sales Order
SELECT
    C.CustomerID,
    SOH.SalesOrderID,
    SOH.OrderDate,
    SOH.TotalDue
FROM Sales.Customer AS C
JOIN Sales.SalesOrderHeader AS SOH
    ON C.CustomerID = SOH.CustomerID
LIMIT 10;

-- Sales Order → Product

SELECT
    SOH.SalesOrderID,
    SOD.SalesOrderDetailID,
    P.ProductID,
    P.Name AS ProductName,
    SOD.OrderQty,
    SOD.LineTotal
FROM Sales.SalesOrderHeader AS SOH
JOIN Sales.SalesOrderDetail AS SOD
    ON SOH.SalesOrderID = SOD.SalesOrderID
JOIN Production.Product AS P
    ON SOD.ProductID = P.ProductID
LIMIT 10;
-- Find the approximate number of records in each major table.

SELECT 'Person.Person' AS TableName, COUNT(*) AS RecordCount
FROM Person.Person

UNION ALL

SELECT 'Sales.Customer', COUNT(*)
FROM Sales.Customer

UNION ALL

SELECT 'Sales.SalesOrderHeader', COUNT(*)
FROM Sales.SalesOrderHeader

UNION ALL

SELECT 'Sales.SalesOrderDetail', COUNT(*)
FROM Sales.SalesOrderDetail

UNION ALL

SELECT 'Sales.SalesPerson', COUNT(*)
FROM Sales.SalesPerson

UNION ALL

SELECT 'Sales.SalesTerritory', COUNT(*)
FROM Sales.SalesTerritory

UNION ALL

SELECT 'Production.Product', COUNT(*)
FROM Production.Product

UNION ALL

SELECT 'Production.ProductSubcategory', COUNT(*)
FROM Production.ProductSubcategory

UNION ALL

SELECT 'Production.ProductCategory', COUNT(*)
FROM Production.ProductCategory;
-- ---------------------------------------------------------------------------------------------------------------------------------------------

-- Task 2: Create an Analysis Database 

CREATE DATABASE Adventure_Works_Training; 

USE ADVENTURE_WORKS_TRAINING;

CREATE SCHEMA ANALYTICS;

CREATE SCHEMA Person;

CREATE SCHEMA Production;

CREATE SCHEMA Sales;

SELECT * FROM PERSON.PERSON;

-- --------------------------------------------------------------------------------------------
-- Task 3: Create Customer Analysis Table 

CREATE TABLE Analytics.CustomerAnalysis
( CustomerID INT PRIMARY KEY , 
  CustomerName VARCHAR(50) NOT NULL, 
  TerritoryID INT , 
  TotalOrders INT , 
  TotalRevenue DECIMAL(10,2), 
  CustomerSegment VARCHAR(50), 
  CreatedDate DATE );
-- --------------------------------------------------------------------------------------------
-- Task 4: Create Product Performance Table 

CREATE TABLE Analytics.ProductPerformance(
	ProductID INT PRIMARY KEY, ProductName VARCHAR(50) NOT NULL, 
	ProductCategory VARCHAR(50) , ProductSubcategory VARCHAR(30) , 
	TotalQuantitySold INT , TotalRevenue DECIMAL(10,2), 
	AverageSellingPrice DECIMAL(10,2) , ProductRank INT , PerformanceCategory VARCHAR(50)
);
-- --------------------------------------------------------------------------------------------
-- Task 5: ALTER TABLE Practice

-- Add a column

ALTER TABLE ANALYTICS.PRODUCTPERFORMANCE
ADD COLUMN RATING FLOAT CHECK (RATING < 5.0);

-- Change a column's data type.

ALTER TABLE ANALYTICS.PRODUCTPERFORMANCE
MODIFY COLUMN TOTALREVENUE FLOAT;

-- Add a DEFAULT constraint. 

ALTER TABLE ANALYTICS.PRODUCTPERFORMANCE
MODIFY COLUMN RATING INT DEFAULT 1 ;

-- Add a CHECK constraint.

ALTER TABLE ANALYTICS.PRODUCTPERFORMANCE
ADD CONSTRAINT PP_ASP_CHK CHECK (AverageSellingPrice > 1000.00);

-- Add a UNIQUE constraint.

ALTER TABLE ANALYTICS.PRODUCTPERFORMANCE
ADD CONSTRAINT PP_PN_UQ UNIQUE(ProductName);

-- Rename a column where supported.

ALTER TABLE ANALYTICS.PRODUCTPERFORMANCE
RENAME COLUMN TotalRevenue TO REVENUE;

-- Remove a constraint.

ALTER TABLE ANALYTICS.PRODUCTPERFORMANCE
DROP CONSTRAINT PP_PN_UQ;

-- Remove a column.

ALTER TABLE ANALYTICS.PRODUCTPERFORMANCE
DROP COLUMN RATING;

-- Challenge: Explain the difference between ALTER TABLE and UPDATE.
-- ALTER COMMAND USED TO MODIFY THE STRUCTURE OF THE TABLE. UPDATE COMMAND, MODIFIES THE DATA IN THE TABLE. 

-- --------------------------------------------------------------------------------------------
-- 5. Part B – DML Operations

-- Task 6: INSERT 

INSERT INTO Analytics.CustomerAnalysis 
( CustomerID, CustomerName, TerritoryID, TotalOrders, TotalRevenue, CustomerSegment, CreatedDate )
VALUES
( 1001, 'Alice Johnson', 101, 15, 1250.50, 'Enterprise', '2025-01-15' ),
( 1002, 'Bob Smith', 102, 8, 450.75, 'SMB', '2025-02-20' ),
( 1003, 'Charlie Brown', 103, 22, 3100.00, 'Enterprise', '2025-01-05' ),
( 1004, 'Diana Prince', 101, 5, 120.25, 'Startup', '2025-03-10' ),
( 1005, 'Ethan Hunt', 104, 45, 8900.50, 'Enterprise', '2024-11-12' ),
( 1006, 'Fiona Gallagher', 102, 12, 980.00, 'SMB', '2025-04-01' ),
( 1007, 'George Martin', 105, 3, 75.50, 'Startup', '2025-05-22' ),
( 1008, 'Hannah Abbott', 103, 18, 2100.75, 'SMB', '2025-02-14' ),
( 1009, 'Ian Malcolm', 101, 30, 5400.00, 'Enterprise', '2024-12-05' ),
( 1010, 'Julia Roberts', 104, 7, 330.20, 'Startup', '2025-06-18' ),
( 1011, 'Kevin Hart', 102, 25, 4100.90, 'SMB', '2025-01-30' ),
( 1012, 'Laura Croft', 105, 10, 890.45, 'SMB', '2025-03-25' ),
( 1013, 'Michael Scott', 101, 50, 12000.00, 'Enterprise', '2024-10-10' ),
( 1014, 'Nancy Wheeler', 103, 4, 95.00, 'Startup', '2025-07-05' ),
( 1015, 'Oscar Martinez', 104, 14, 1500.60, 'SMB', '2025-02-28' ),
( 1016, 'Pam Beesly', 102, 20, 2800.30, 'SMB', '2025-04-15' ),
( 1017, 'Quentin Tarantino', 105, 2, 50.00, 'Startup', '2025-08-01' ),
( 1018, 'Rachel Green', 101, 35, 6700.80, 'Enterprise', '2024-11-20' ),
( 1019, 'Steve Rogers', 103, 28, 4950.25, 'Enterprise', '2025-01-10' ),
( 1020, 'Tina Fey', 104, 11, 1100.00, 'SMB', '2025-05-05' );   

-- --------------------------------------------------------------------------------------------- 
-- Task 7: UPDATE
-- Objective: Update customer segments based on revenue. 

SELECT CustomerID, CustomerName, TotalRevenue, 
	CASE 
		WHEN TotalRevenue >= 10000 THEN "PREMIUM"
		WHEN TotalRevenue > 5000 and TotalRevenue <= 9999 THEN "GOLD" 
		WHEN TotalRevenue > 1000 and TotalRevenue <= 4999 THEN "SILVER" 
		ELSE "STANDARD" 
    END AS "CUSTOMER_REVENUE_SEGMENT"
FROM Analytics.CustomerAnalysis ;
-- ---------------------------------------------------------------------------------------------
-- Task 8: DELETE, Objective: Remove test records after validating the target rows.

SET SQL_SAFE_UPDATES = 0;
DELETE FROM Analytics.CustomerAnalysis WHERE TOTALREVENUE < 100.0 ;

-- Challenge: How can you verify that you are deleting only the intended records?
SELECT * FROM Analytics.CustomerAnalysis;
-- --------------------------------------------------------------------------------------------- 
-- 6. Part C – Basic Sales Analysis 
-- Task 9: Sales Order Analysis ( use aggregate functions ). 

-- Find total sales orders.

SELECT COUNT(SALESORDERID) AS TOTAL_SALES_ORDERS FROM  Sales.SalesOrderHeader;

-- Find total sales amount.

SELECT SUM(TOTALDUE) AS TOTAL_SALES_AMOUNT FROM  Sales.SalesOrderHeader;

-- Find average, minimum and maximum order value.

SELECT  MAX(TOTALDUE) AS Max_Revenue,
		MIN(TOTALDUE) AS Min_Revenue,
		AVG(TOTALDUE) AS Avg_Revenue FROM Sales.SalesOrderHeader;

-- Find the number of unique customers.

SELECT COUNT(DISTINCT CustomerID) AS UniqueCustomers FROM Sales.SalesOrderHeader;

-- Find the number of unique products sold.

SELECT COUNT(DISTINCT ProductID) AS UniqueProductsSold FROM Sales.SalesOrderDetail;
-- ------------------------------------------------------------------------------------------
-- 7. Part D – GROUP BY and Aggregation 

-- Task 10: Customer Revenue 

-- Objective: Calculate customer-level sales performance.

-- Customer ID ( STEP - 1 )

SELECT CustomerID, TerritoryID FROM Sales.Customer;

-- Customer name ( STEP - 2 )

SELECT BusinessEntityID, FirstName, MiddleName , LastName FROM Person;

-- Combine both ID & Name using JOIN ( STEP - 3) 

SELECT C.CUSTOMERID, 
		P.FirstName + " " + P.LastName AS FULL_NAME         -- SELECTING REQUIRED COLUMNS AND CONCATENATED 
        FROM SALES.CUSTOMER AS C                            -- SALES.CUSTOMER ALIAS C
        JOIN PERSON AS P                                    -- PERSON ALIAS P
        ON C.PERSONID = P.BUSINESSENTITYID;                 -- JOINES THROUGH ID
	
-- Number of orders ( USING Sales.SalesOrderHeader ) (STEP - 4)
 
SELECT 
	C.CUSTOMERID, 
	P.FirstName + " " + P.LastName AS FULL_NAME,
    COUNT(SOH.SALESORDERID) AS NUM_OF_ORDERS              -- COUNT THE NO.OF ORDERS
        FROM SALES.CUSTOMER AS C 
		JOIN PERSON AS P                                     
			ON C.PERSONID = P.BUSINESSENTITYID
		JOIN Sales.SalesOrderHeader AS SOH              -- SALES.SALESORDERHEADER ALIAS SOH
			ON C.CUSTOMERID = SOH.CUSTOMERID           -- JOINED THROUGH VUSTOMERID B/W THEM.
		GROUP BY 
			C.CUSTOMERID, P.FIRSTNAME, P.LASTNAME ;    -- WE NEED TO COUNT THE NO.OF ORDERS FOR EACH CUSTOMER, WE NEED TO GROUP CUSTOMER_ID, FIRST NAME AND LAST NAME.

-- Total revenue      ( STEP - 5 )

SELECT 
	C.CUSTOMERID, 
	P.FirstName + " " + P.LastName AS FULL_NAME,
    COUNT(SOH.SALESORDERID) AS NUM_OF_ORDERS,
    SUM(SOH.TOTALDUE) AS TOTAL_REVENUE                 -- SELECTED TOTAL REVENUE FOR EACH CUSTOMER BASED ON NO.OF ORDERS
        FROM SALES.CUSTOMER AS C 
		JOIN PERSON AS P                                     
			ON C.PERSONID = P.BUSINESSENTITYID
		JOIN Sales.SalesOrderHeader AS SOH              
			ON C.CUSTOMERID = SOH.CUSTOMERID          
		GROUP BY 
			C.CUSTOMERID, P.FIRSTNAME, P.LASTNAME ;

-- Average order value    ( STEP - 6 ) 

SELECT 
	C.CUSTOMERID, 
	P.FirstName + " " + P.LastName AS FULL_NAME,
    COUNT(SOH.SALESORDERID) AS NUM_OF_ORDERS,
    SUM(SOH.TOTALDUE) AS TOTAL_REVENUE,
    AVG(SOH.TOTALDUE) AS AVG_ORDER_VALUE           -- FOR TOTAL VALUE OF A CUSTOMER, WE FIND AVERAGE.
        FROM SALES.CUSTOMER AS C 
		JOIN PERSON AS P                                     
			ON C.PERSONID = P.BUSINESSENTITYID
		JOIN Sales.SalesOrderHeader AS SOH              
			ON C.CUSTOMERID = SOH.CUSTOMERID           
		GROUP BY 
			C.CUSTOMERID, P.FIRSTNAME, P.LASTNAME ;

-- Challenge: Sort customers by revenue from highest to lowest. 

SELECT 
	C.CUSTOMERID, 
	P.FirstName + " " + P.LastName AS FULL_NAME,
    COUNT(SOH.SALESORDERID) AS NUM_OF_ORDERS,
    SUM(SOH.TOTALDUE) AS TOTAL_REVENUE,
    AVG(SOH.TOTALDUE) AS AVG_ORDER_VALUE           -- FOR TOTAL VALUE OF A CUSTOMER, WE FIND AVERAGE.
        FROM SALES.CUSTOMER AS C 
		JOIN PERSON.PERSON AS P                                     
			ON C.PERSONID = P.BUSINESSENTITYID
		JOIN Sales.SalesOrderHeader AS SOH              
			ON C.CUSTOMERID = SOH.CUSTOMERID           
		GROUP BY 
			C.CUSTOMERID, P.FIRSTNAME, P.LASTNAME 
		ORDER BY TOTAL_REVENUE DESC;                      -- ORDERED BASED ON TOTAL_REVENUE FRO TOP TO BOTTOM.
-- ------------------------------------------------------------------------------------------------------------------------------------------
-- Task 11: Product Revenue 
-- Objective: Analyze product performance.

-- Find the top 20 products based on quantity sold.

SELECT PRODUCTID, SUM(ORDERQTY) AS QUNTITY_SOLD FROM  SALES.SALESORDERDETAIL GROUP BY PRODUCTID ORDER BY SUM(ORDERQTY) DESC LIMIT 20;

-- Find the top 20 products based on revenue.

SELECT SOD.PRODUCTID,P.PRODUCTNUMBER, P.NAME ,SOD.LINETOTAL
        FROM SALES.SALESORDERDETAIL AS SOD
        JOIN PRODUCTION.PRODUCT AS P
        ON P.PRODUCTID = SOD.PRODUCTID 
        ORDER BY LINETOTAL DESC
        LIMIT 20;

-- Challenge: Are the products with the highest quantity sold also the products generating the highest revenue?  
-- (A.) No. high quantity sold, doesn't generate highest revenue. It also depends on average selling price. 

-- -------------------------------------------------------------------------------------------------------------------------------
-- Task 12: Territory Performance
-- Objective: Calculate territory-level performance.

-- Number of customers PER TERRITORY  

SELECT SC.TERRITORYID,  COUNT(DISTINCT SC.CUSTOMERID) AS NO_OF_CUSTOMERS
FROM SALES.CUSTOMER AS SC
GROUP BY SC.TERRITORYID;

-- Number of orders PER TERROTORY

SELECT SOH.TERRITORYID, COUNT(DISTINCT SOH.SALESORDERID) AS NO_OF_ORDERS
FROM SALES.SALESORDERHEADER AS SOH
GROUP BY SOH.TERRITORYID;

-- Total revenue per territory 

SELECT SOH.TERRITORYID, SUM(SOH.TOTALDUE) AS TOTAL_REVENUE 
FROM SALES.SALESORDERHEADER AS SOH GROUP BY SOH.TERRITORYID;

-- Average order value ( AVG(soh.TotalDue) ). Combine all and creating table, for observing territory performance.alter

SELECT ST.TERRITORYID, 
		ST.NAME AS TERRITORY_NAME,
		COUNT(DISTINCT SC.CUSTOMERID) AS NO_OF_CUSTOMERS,
		COUNT(DISTINCT SOH.SALESORDERID) AS NO_OF_ORDERS,
		SUM(SOH.TOTALDUE) AS TOTAL_REVENUE, 
		avg(SOH.TOTALDUE) AS AVERAGE_ORDER_VALUE
	FROM SALES.SALESTERRITORY AS ST
    JOIN SALES.CUSTOMER AS SC ON st.TerritoryID = SC.TerritoryID
    JOIN Sales.SalesOrderHeader AS SOH ON SC.CustomerID = SOH.CustomerID 
    GROUP BY ST.TERRITORYID, ST.NAME 
    ORDER BY TOTAL_REVENUE DESC;

-- Challenge: Identify the best-performing territory.
-- (A.) TERRITORY ID - 4 & SOUTHWEST IS BEST PERFORMING TERRITORY.
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Task 13: Customer Order Report
-- Objective: Create a customer order report.

-- Customer name 
-- Sales order number
-- Order date
-- Territory
-- Total order value      -- Challenge: Use the appropriate JOINs.

-- STEP 1 ( Selecting customer ID & customer name )

SELECT SC.CUSTOMERID, 
		CONCAT(PP.FIRSTNAME," ",PP.LASTNAME) AS CUSTOMER_NAME 
        FROM PERSON.PERSON AS PP
        JOIN SALES.CUSTOMER AS SC 
        ON SC.PERSONID = PP.BUSINESSENTITYID;

-- STEP 2 ( Selecting Sales Orders by joining SalesOrderHeader ) 

SELECT SC.CUSTOMERID, 
		CONCAT(PP.FIRSTNAME," ",PP.LASTNAME) AS CUSTOMER_NAME,
        SOH.SALESORDERNUMBER,
        SOH.ORDERDATE,
        SOH.TOTALDUE
        FROM PERSON.PERSON AS PP
        JOIN SALES.CUSTOMER AS SC 
			ON SC.PERSONID = PP.BUSINESSENTITYID
        JOIN SALES.SALESORDERHEADER AS SOH
			ON SC.CUSTOMERID = SOH.CUSTOMERID;

-- STEP 3 (Add Territory FROM SalesTerritory:)

SELECT SC.CUSTOMERID AS CUSTOMER_ID, 
		CONCAT(PP.FIRSTNAME," ",PP.LASTNAME) AS CUSTOMER_NAME,
        SOH.SALESORDERNUMBER AS SALES_ORDER_NUMBER,
        SOH.ORDERDATE AS ORDER_DATE,
        SOH.TOTALDUE AS TOTAL_ORDER_REVENUE,
        ST.Name AS Territory_NAME
        FROM PERSON.PERSON AS PP
        JOIN SALES.CUSTOMER AS SC 
			ON SC.PERSONID = PP.BUSINESSENTITYID
        JOIN SALES.SALESORDERHEADER AS SOH
			ON SC.CUSTOMERID = SOH.CUSTOMERID
		JOIN Sales.SalesTerritory AS ST
			ON SOH.TERRITORYID = ST.TERRITORYID;
-- CHALLENGE: JOINED ALL TABLES USING PROPER JOINS.

-- --------------------------------------------------------------------------------------------------------------------
-- Task 14: Product Sales Report
-- Objective: Create a product sales report.
-- Product name
-- Product category
-- Product subcategory
-- Quantity sold
-- Revenue
-- Challenge: Use at least three related tables.

-- STEP 1 ( SELECTING Product name AND ProductSubcategoryID ) 

SELECT PP.ProductID, PP.Name AS ProductName, PP.ProductSubcategoryID FROM Production.Product AS PP ;

-- STEP 2 ( SELECTING Subcategory BY Join Production.ProductSubcategory)

SELECT PP.ProductID, 
		PP.Name AS Product_Name, 
        PSC.ProductSubcategoryID,
        PSC.Name AS ProductSubcategory
	FROM Production.Product AS PP 
	JOIN Production.ProductSubcategory AS PSC
	ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID;

-- STEP 3 ( ADD PRODUCT CATEGORY NAME ) 

SELECT PP.ProductID, 
		PP.Name AS Product_Name, 
        PSC.ProductSubcategoryID,
        PSC.Name AS ProductSubcategory,
        PC.NAME AS PRODUCT_CATEGORY
	FROM Production.Product AS PP 
	JOIN Production.ProductSubcategory AS PSC
		ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
	JOIN Production.ProductCategory AS PC
		ON PSC.ProductCategoryID = PC.ProductCategoryID;
        
-- STEP 4 ( ADDING QUANTITY SOLD FROM Sales.SalesOrderDetail.OrderQty ) 

SELECT PP.ProductID, 
		PP.Name AS Product_Name, 
        PSC.Name AS ProductSubcategory,
        PC.NAME AS PRODUCT_CATEGORY,
        SUM(SOD.OrderQty) AS QuantitySold
	FROM Sales.SalesOrderDetail AS SOD
	JOIN Production.Product AS PP 
		ON SOD.ProductID = PP.ProductID
	JOIN Production.ProductSubcategory AS PSC
		ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
	JOIN Production.ProductCategory AS PC
		ON PSC.ProductCategoryID = PC.ProductCategoryID
	GROUP BY PP.ProductID, PP.Name, PC.Name, PSC.Name;
    
-- STEP 5 ( ADD REVENUE AND FINAL ANSWER) 

SELECT PP.ProductID, 
		PP.Name AS Product_Name, 
        PSC.Name AS ProductSubcategory,
        PC.NAME AS PRODUCT_CATEGORY,
        SUM(SOD.OrderQty) AS QuantitySold,
        SUM(SOD.LINETOTAL) AS REVENUE       # SUM OF TOTAL
	FROM Sales.SalesOrderDetail AS SOD
	JOIN Production.Product AS PP 
		ON SOD.ProductID = PP.ProductID
	JOIN Production.ProductSubcategory AS PSC
		ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
	JOIN Production.ProductCategory AS PC
		ON PSC.ProductCategoryID = PC.ProductCategoryID
	GROUP BY PP.ProductID, PP.Name, PC.Name, PSC.Name
	ORDER BY REVENUE DESC;

-- Challenge: Use at least three related tables. 
-- (A.) Joined 3 tables:- Sales.SalesOrderDetail <-> Production.Product <-> Production.ProductCategory

-- ------------------------------------------------------------------------------------------------------------------------
-- Task 15: Employee/Salesperson Performance
-- Objective: Analyze salesperson performance.

-- STEP 1 ( SALES PERSON )

SELECT SP.BUSINESSENTITYID,
		CONCAT(PP.FIRSTNAME," ",PP.LASTNAME) AS FULL_NAME 
        FROM SALES.SALESPERSON AS SP
        JOIN PERSON.PERSON AS PP 
			ON SP.BUSINESSENTITYID = PP.BUSINESSENTITYID;

-- STEP - 2 (ADDING TERRITORY) 

SELECT SP.BUSINESSENTITYID,
		CONCAT(PP.FIRSTNAME," ",PP.LASTNAME) AS FULL_NAME,
        ST.NAME AS TERRITORY_NAME
        FROM SALES.SALESPERSON AS SP
        JOIN PERSON.PERSON AS PP 
			ON SP.BUSINESSENTITYID = PP.BUSINESSENTITYID
		JOIN SALES.SALESTERRITORY AS ST
			ON SP.TERRITORYID = ST.TERRITORYID;
            
-- STEP - 3 (ADD SALES ORDERS) 

SELECT SP.BUSINESSENTITYID,
		CONCAT(PP.FIRSTNAME," ",PP.LASTNAME) AS FULL_NAME,
        ST.NAME AS TERRITORY_NAME,
        SOH.SALESORDERID,
        SOH.TOTALDUE
        FROM SALES.SALESPERSON AS SP
        JOIN PERSON.PERSON AS PP 
			ON SP.BUSINESSENTITYID = PP.BUSINESSENTITYID
		JOIN SALES.SALESTERRITORY AS ST
			ON SP.TERRITORYID = ST.TERRITORYID
		JOIN SALES.SALESORDERHEADER AS SOH
			ON SP.BUSINESSENTITYID = SOH.SALESPERSONID;

-- Number of orders ( step - 4 ) 
SELECT COUNT(DISTINCT SOH.SalesOrderID) FROM SALES.SALESORDERHEADER AS SOH;

-- Total sales 		( step - 5 )
SELECT SUM(SOH.TotalDue) FROM SALES.SALESORDERHEADER AS SOH;

-- Average order value ( step - 6 )
SELECT AVG(SOH.TotalDue) FROM SALES.SALESORDERHEADER AS SOH;

-- STEP - 7 ( COMBINING EVERY THING, FINAL QUERY ) 

SELECT SP.BUSINESSENTITYID AS SALES_PERSON_ID,
		CONCAT(PP.FIRSTNAME," ",PP.LASTNAME) AS FULL_NAME,
        ST.NAME AS TERRITORY_NAME,
        COUNT(DISTINCT SOH.SALESORDERID),
        SUM(SOH.TOTALDUE) AS TOTALSALES,
        AVG(SOH.TOTALDUE) AS AVERAGE_ORDER_VALUE
        FROM SALES.SALESPERSON AS SP
        JOIN PERSON.PERSON AS PP 
			ON SP.BUSINESSENTITYID = PP.BUSINESSENTITYID
		JOIN SALES.SALESTERRITORY AS ST
			ON SP.TERRITORYID = ST.TERRITORYID
		JOIN SALES.SALESORDERHEADER AS SOH
			ON SP.BUSINESSENTITYID = SOH.SALESPERSONID
		GROUP BY SP.BUSINESSENTITYID, PP.FIRSTNAME, PP.LASTNAME, ST.NAME
        ORDER BY TOTALSALES DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------- 
-- 9. Part F – CASE Statement 
-- Task 16: Customer Segmentation
-- Objective: Classify customers based on total revenue.
-- Premium, Gold, Silver, Standard
-- Challenge: Create CustomerSegment using CASE.

SELECT CustomerID, CustomerName, TotalRevenue, 
	CASE 
		WHEN TotalRevenue >= 10000 THEN "PREMIUM"
		WHEN TotalRevenue > 5000 and TotalRevenue <= 9999 THEN "GOLD" 
		WHEN TotalRevenue > 1000 and TotalRevenue <= 4999 THEN "SILVER" 
		ELSE "STANDARD" 
    END AS "CUSTOMER_REVENUE_SEGMENT"
FROM Analytics.CustomerAnalysis ;
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Task 17: Product Classification
-- Objective: Classify products according to revenue performance.
-- High Performer
-- Medium Performer
-- Low Performer

SELECT  
	PP.PRODUCTID, 
    PP.NAME AS PRODUCT_NAME,
    SUM(SOD.LINETOTAL) AS PRODUCT_REVENUE,
    CASE 
		WHEN SUM(SOD.LINETOTAL) >= 10000 THEN "HIGH PERFORMER"
        WHEN SUM(SOD.LINETOTAL) >= 5000 AND SUM(SOD.LINETOTAL) < 10000 THEN "MEDIUM PERFORMER"
        WHEN SUM(SOD.LINETOTAL) < 5000 THEN "LOW PERFORMER" 
	END AS "PRODUCT_REVENUE_PERFORMANCE"
    FROM SALES.SALESORDERDETAIL AS SOD
    JOIN PRODUCTION.PRODUCT AS PP 
		ON SOD.PRODUCTID = PP.PRODUCTID
    GROUP BY PP.PRODUCTID,PP.NAME ;

-- Challenge: Why might business rules based only on absolute revenue be misleading?
-- (a.) Business rules based only on absolute revenue can be misleading because revenue doesn't consider profitability, product price, quantity sold, costs, discounts, or growth. 
--      A high-revenue product may actually generate less profit than a lower-revenue product.

-- -------------------------------------------------------------------------------------------------------------------------------
-- 10. Part G – CTE Practice
-- Task 18: Customer Revenue CTE
-- Objective: Use a CTE to calculate total revenue for each customer.

-- CTE BUILDING ( FIND TOTAL REVENUE FOR EACH CUSTOMER 

WITH CUSTOMER_TOTAL_REVENUE AS (
	SELECT
        SC.CUSTOMERID,
        CONCAT(PP.FIRSTNAME, ' ', PP.LASTNAME) AS CUSTOMER_FULL_NAME,
        SUM(SOH.TOTALDUE) AS TOTAL_REVENUE
    FROM Sales.Customer AS SC
    JOIN Person.Person AS PP
        ON SC.PersonID = PP.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON SC.CustomerID = SOH.CustomerID
    GROUP BY
        SC.CUSTOMERID,
        PP.FIRSTNAME,
        PP.LASTNAME
)
SELECT * FROM CUSTOMER_TOTAL_REVENUE;

-- Identify the top 10 customers.

WITH CUSTOMER_TOTAL_REVENUE AS (
	SELECT
        SC.CUSTOMERID,
        CONCAT(PP.FIRSTNAME, ' ', PP.LASTNAME) AS CUSTOMER_FULL_NAME,
        SUM(SOH.TOTALDUE) AS TOTAL_REVENUE
    FROM Sales.Customer AS SC
    JOIN Person.Person AS PP
        ON SC.PersonID = PP.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON SC.CustomerID = SOH.CustomerID
    GROUP BY
        SC.CUSTOMERID,
        PP.FIRSTNAME,
        PP.LASTNAME
)

SELECT * FROM CUSTOMER_TOTAL_REVENUE ORDER BY TOTAL_REVENUE LIMIT 10;

-- Identify customers above average revenue.

WITH CUSTOMER_TOTAL_REVENUE AS (
	SELECT
        SC.CUSTOMERID,
        CONCAT(PP.FIRSTNAME, ' ', PP.LASTNAME) AS CUSTOMER_FULL_NAME,
        SUM(SOH.TOTALDUE) AS TOTAL_REVENUE
    FROM Sales.Customer AS SC
    JOIN Person.Person AS PP
        ON SC.PersonID = PP.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON SC.CustomerID = SOH.CustomerID
    GROUP BY
        SC.CUSTOMERID,
        PP.FIRSTNAME,
        PP.LASTNAME
)
SELECT * FROM CUSTOMER_TOTAL_REVENUE WHERE TOTAL_REVENUE > (SELECT AVG(TOTAL_REVENUE) FROM CUSTOMER_TOTAL_REVENUE) ; 

-- Identify customers below average revenue.

WITH CUSTOMER_TOTAL_REVENUE AS (
	SELECT
        SC.CUSTOMERID,
        CONCAT(PP.FIRSTNAME, ' ', PP.LASTNAME) AS CUSTOMER_FULL_NAME,
        SUM(SOH.TOTALDUE) AS TOTAL_REVENUE
    FROM Sales.Customer AS SC
    JOIN Person.Person AS PP
        ON SC.PersonID = PP.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON SC.CustomerID = SOH.CustomerID
    GROUP BY
        SC.CUSTOMERID,
        PP.FIRSTNAME,
        PP.LASTNAME
)
SELECT * FROM CUSTOMER_TOTAL_REVENUE WHERE TOTAL_REVENUE < (SELECT AVG(TOTAL_REVENUE) FROM CUSTOMER_TOTAL_REVENUE) ; 
-- ---------------------------------------------------------------------------------------------------------------------------------------- 
-- Task 19: Product Performance CTE
-- Objective: Use a CTE for product-level analysis.

-- Create a CTE containing Product, Quantity Sold and Revenue.

WITH PRODUCT_PERFORMANCE AS(
	SELECT 
		SOD.PRODUCTID, 
        PP.NAME , 
        SUM(SOD.OrderQty) AS QuantitySold, 
        SUM(SOD.LINETOTAL) AS REVENUE
    FROM SALES.SALESORDERDETAIL AS SOD 
    JOIN PRODUCTION.PRODUCT AS PP 
		ON SOD.PRODUCTID = PP.PRODUCTID
	GROUP BY SOD.PRODUCTID, PP.Name
    )
SELECT * FROM PRODUCT_PERFORMANCE;

-- Use the CTE to identify products contributing more than a specified percentage of total sales.

WITH PRODUCT_PERFORMANCE AS(
	SELECT 
		SOD.PRODUCTID, 
        PP.NAME , 
        SUM(SOD.OrderQty) AS QuantitySold, 
        SUM(SOD.LINETOTAL) AS REVENUE
    FROM SALES.SALESORDERDETAIL AS SOD 
    JOIN PRODUCTION.PRODUCT AS PP 
		ON SOD.PRODUCTID = PP.PRODUCTID
	GROUP BY SOD.PRODUCTID, PP.Name
    )
SELECT ProductID, Name, QuantitySold, Revenue,
    (Revenue / (SELECT SUM(Revenue)
                FROM Product_Performance)) * 100 AS SalesPercentage
FROM Product_Performance
WHERE (Revenue / (SELECT SUM(Revenue) FROM Product_Performance)) * 100 > 5
ORDER BY SalesPercentage DESC;

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 11. Part H – Window Functions 

-- Task 20: ROW_NUMBER()     Objective: Assign a sequential number to customers based on total revenue.

-- Rank customers in descending revenue order.
-- Challenge: Generate the row number separately for each territory using PARTITION BY.

-- STEP - 1 CREATED CUSTOMER REVENUE

WITH CUSTOMER_TOTAL_REVENUE AS (
	SELECT
        SC.CUSTOMERID,
        CONCAT(PP.FIRSTNAME, ' ', PP.LASTNAME) AS CUSTOMER_FULL_NAME,
        SC.TerritoryID,
        SUM(SOH.TOTALDUE) AS TOTAL_REVENUE
    FROM Sales.Customer AS SC
    JOIN Person.Person AS PP
        ON SC.PersonID = PP.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON SC.CustomerID = SOH.CustomerID
    GROUP BY
        SC.CUSTOMERID,
        PP.FIRSTNAME,
        PP.LASTNAME,
        SC.TerritoryID
)
-- step - 2, Now applying ROW() FUNCTION ON CTE 
SELECT
    CUSTOMERID,
    CUSTOMER_FULL_NAME,
    TOTAL_REVENUE,
    ROW_NUMBER() OVER (
        ORDER BY TOTAL_REVENUE DESC
    ) AS RevenueRank
FROM CUSTOMER_TOTAL_REVENUE
ORDER BY TOTAL_REVENUE DESC;

-- ----------------------------------------------------------------------------------------------------------------------------------
-- Task 21: RANK()
-- Objective: Rank products based on total revenue.
-- Use RANK() to handle tied revenue values.

WITH CUSTOMER_TOTAL_REVENUE AS (
	SELECT
        SC.CUSTOMERID,
        CONCAT(PP.FIRSTNAME, ' ', PP.LASTNAME) AS CUSTOMER_FULL_NAME,
        SC.TerritoryID,
        SUM(SOH.TOTALDUE) AS TOTAL_REVENUE
    FROM Sales.Customer AS SC
    JOIN Person.Person AS PP
        ON SC.PersonID = PP.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON SC.CustomerID = SOH.CustomerID
    GROUP BY
        SC.CUSTOMERID,
        PP.FIRSTNAME,
        PP.LASTNAME,
        SC.TerritoryID
)
-- step - 2, Now applying RANK() FUNCTION ON CTE 
SELECT
    CUSTOMERID,
    CUSTOMER_FULL_NAME,
    TOTAL_REVENUE,
    RANK() OVER (
        ORDER BY TOTAL_REVENUE DESC
    ) AS RANK_FOR_REVENUE
FROM CUSTOMER_TOTAL_REVENUE;
-- Challenge: Why can a following rank be skipped when two rows have the same rank?
-- (A.) Internally it count for each entry and updates. When, rank ties, it creates gaps. 
-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Task 22: DENSE_RANK()
-- Objective: Repeat the ranking analysis using DENSE_RANK().

WITH CUSTOMER_TOTAL_REVENUE AS (
	SELECT
        SC.CUSTOMERID,
        CONCAT(PP.FIRSTNAME, ' ', PP.LASTNAME) AS CUSTOMER_FULL_NAME,
        SC.TerritoryID,
        SUM(SOH.TOTALDUE) AS TOTAL_REVENUE
    FROM Sales.Customer AS SC
    JOIN Person.Person AS PP
        ON SC.PersonID = PP.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON SC.CustomerID = SOH.CustomerID
    GROUP BY
        SC.CUSTOMERID,
        PP.FIRSTNAME,
        PP.LASTNAME,
        SC.TerritoryID
)
-- step - 2, Now applying DENSE_RANK() FUNCTION ON CTE.    -- Compare the result with RANK().
SELECT
    CUSTOMERID,
    CUSTOMER_FULL_NAME,
    TOTAL_REVENUE, RANK() OVER (
        ORDER BY TOTAL_REVENUE DESC
    ) AS RANK_FOR_REVENUE ,
    DENSE_RANK() OVER (
        ORDER BY TOTAL_REVENUE DESC
    ) AS DENSE_RANK_FOR_REVENUE
FROM CUSTOMER_TOTAL_REVENUE;

-- Challenge: Explain the difference between RANK() and DENSE_RANK().

-- (A.) RANK() Skips ranks after ties. DENSE_RANK(), Does NOT skip ranks after ties. 
-- ----------------------------------------------------------------------------------------------------------------------------------------- 
-- Task 23: Ranking Within Each Category
-- Objective: Find the top products within every product category.
-- Calculate product revenue.

WITH PRODUCT_REVENUE AS
(
    SELECT
        P.ProductID,
        P.Name AS ProductName,
        PC.ProductCategoryID,
        PC.Name AS ProductCategory,
        SUM(SOD.LineTotal) AS TotalRevenue
    FROM Sales.SalesOrderDetail AS SOD
    JOIN Production.Product AS P
        ON SOD.ProductID = P.ProductID
    JOIN Production.ProductSubcategory AS PSC
        ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory AS PC
        ON PSC.ProductCategoryID = PC.ProductCategoryID
    GROUP BY
        P.ProductID,
        P.Name,
        PC.ProductCategoryID,
        PC.Name
)
SELECT * FROM PRODUCT_REVENUE;

-- Apply a ranking function partitioned by product category.
WITH PRODUCT_REVENUE AS
(
    SELECT
        P.ProductID,
        P.Name AS ProductName,
        PC.ProductCategoryID,
        PC.Name AS ProductCategory,
        SUM(SOD.LineTotal) AS TotalRevenue
    FROM Sales.SalesOrderDetail AS SOD
    JOIN Production.Product AS P
        ON SOD.ProductID = P.ProductID
    JOIN Production.ProductSubcategory AS PSC
        ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory AS PC
        ON PSC.ProductCategoryID = PC.ProductCategoryID
    GROUP BY
        P.ProductID,
        P.Name,
        PC.ProductCategoryID,
        PC.Name
)
SELECT
    ProductID,
    ProductName,
    ProductCategory,
    TotalRevenue,
    RANK() OVER (
        PARTITION BY ProductCategory
        ORDER BY TotalRevenue DESC
    ) AS CategoryRank
FROM PRODUCT_REVENUE
ORDER BY ProductCategory, CategoryRank;

-- Challenge: Identify the best-selling product in every category.

WITH PRODUCT_REVENUE AS
(
    SELECT
        P.ProductID,
        P.Name AS ProductName,
        PC.Name AS ProductCategory,
        SUM(SOD.LineTotal) AS TotalRevenue
    FROM Sales.SalesOrderDetail AS SOD
    JOIN Production.Product AS P
        ON SOD.ProductID = P.ProductID
    JOIN Production.ProductSubcategory AS PSC
        ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory AS PC
        ON PSC.ProductCategoryID = PC.ProductCategoryID
    GROUP BY
        P.ProductID,
        P.Name,
        PC.Name
),
RANKED_PRODUCTS AS
(
    SELECT
        ProductID,
        ProductName,
        ProductCategory,
        TotalRevenue,
        RANK() OVER (
            PARTITION BY ProductCategory
            ORDER BY TotalRevenue DESC
        ) AS CategoryRank
    FROM PRODUCT_REVENUE
)
SELECT
    ProductID,
    ProductName,
    ProductCategory,
    TotalRevenue
FROM RANKED_PRODUCTS
WHERE CategoryRank = 1
ORDER BY ProductCategory;
-- -------------------------------------------------------------------------------------------------------------------------------------------------- 
-- Task 24: Running Total
-- Objective: Calculate cumulative sales over time.

-- Calculate monthly sales.

SELECT YEAR(ORDERDATE) AS SALESYEAR,
		MONTH(ORDERDATE) AS SALESMONTH,
        SUM(TOTALDUE) AS MONTHLY_REVENUE 
	FROM SALES.SALESORDERHEADER
    GROUP BY YEAR(ORDERDATE), MONTH(ORDERDATE)
ORDER BY
    SALESYEAR, SALESMONTH;

-- Calculate cumulative revenue using SUM() OVER().

WITH MONTHLY_SALES AS (
SELECT YEAR(ORDERDATE) AS SALESYEAR,
		MONTH(ORDERDATE) AS SALESMONTH,
        SUM(TOTALDUE) AS MONTHLY_REVENUE 
	FROM SALES.SALESORDERHEADER
    GROUP BY YEAR(ORDERDATE), MONTH(ORDERDATE)
ORDER BY
    SALESYEAR, SALESMONTH
)
SELECT
    SALESYEAR, SALESMONTH, MONTHLY_REVENUE,
    SUM(MONTHLY_REVENUE) OVER (
        ORDER BY SalesYear, SalesMonth
    ) AS CumulativeRevenue
FROM MONTHLY_SALES
ORDER BY
    SalesYear,
    SalesMonth;
    
-- Challenge: How much revenue had the company generated cumulatively by each month?
-- (a.) The cumulative revenue for each month is the sum of all monthly revenues from the beginning of the available sales period through that month.
-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- Task 25: Monthly Sales Comparison
-- Objective: Compare each month's revenue with the previous month.

-- Calculate monthly revenue.

WITH MONTHLY_SALES AS (
SELECT YEAR(ORDERDATE) AS SALESYEAR,
		MONTH(ORDERDATE) AS SALESMONTH,
        SUM(TOTALDUE) AS MONTHLY_REVENUE 
	FROM SALES.SALESORDERHEADER
    GROUP BY YEAR(ORDERDATE), MONTH(ORDERDATE)
ORDER BY
    SALESYEAR, SALESMONTH
)
select * FROM MONTHLY_SALES;

-- Use LAG() to retrieve previous-month revenue AND Calculate the difference.

WITH MONTHLY_SALES AS (
SELECT YEAR(ORDERDATE) AS SALESYEAR,
		MONTH(ORDERDATE) AS SALESMONTH,
        SUM(TOTALDUE) AS MONTHLY_REVENUE 
	FROM SALES.SALESORDERHEADER
    GROUP BY YEAR(ORDERDATE), MONTH(ORDERDATE)
ORDER BY
    SALESYEAR, SALESMONTH
) 
SELECT
    SALESYEAR,
    SALESMONTH,
    MONTHLY_REVENUE,
    LAG(MONTHLY_REVENUE) OVER (
        ORDER BY SALESYEAR, SALESMONTH
    ) AS PreviousMonthRevenue,
    MONTHLY_REVENUE -
        LAG(MONTHLY_REVENUE) OVER (
            ORDER BY SALESYEAR, SALESMONTH
        ) AS RevenueDifference
FROM MONTHLY_SALES
ORDER BY
    SALESYEAR, SALESMONTH;

-- Challenge: Explain why the first month has no previous-month value. 
-- (A.) Because there is no month before the first available month in the dataset.

-- --------------------------------------------------------------------------------------------------------------------------------
-- Task 26: Month-over-Month Growth
-- Objective: Calculate MoM Growth %.
-- Use the formula: (Current Month Revenue - Previous Month Revenue) / Previous Month Revenue × 100.

WITH MONTHLY_SALES AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        MONTH(OrderDate) AS SalesMonth,
        SUM(TotalDue) AS MonthlyRevenue
    FROM Sales.SalesOrderHeader
    GROUP BY
        YEAR(OrderDate),
        MONTH(OrderDate)
),
MONTHLY_COMPARISON AS
(
    SELECT
        SalesYear,
        SalesMonth,
        MonthlyRevenue,
        LAG(MonthlyRevenue) OVER (
            ORDER BY SalesYear, SalesMonth
        ) AS PreviousMonthRevenue
    FROM MONTHLY_SALES
)
SELECT
    SalesYear,
    SalesMonth,
    MonthlyRevenue,
    PreviousMonthRevenue,
    MonthlyRevenue - PreviousMonthRevenue AS RevenueDifference,
    ((MonthlyRevenue - PreviousMonthRevenue)
        / PreviousMonthRevenue) * 100 AS MoM_Growth_Percentage
FROM MONTHLY_COMPARISON
ORDER BY
    SalesYear,
    SalesMonth;

-- Challenge: Identify the month with the highest growth and the month with the biggest decline.

WITH MONTHLY_SALES AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        MONTH(OrderDate) AS SalesMonth,
        SUM(TotalDue) AS MonthlyRevenue
    FROM Sales.SalesOrderHeader
    GROUP BY
        YEAR(OrderDate),
        MONTH(OrderDate)
),
MONTHLY_COMPARISON AS
(
    SELECT
        SalesYear,
        SalesMonth,
        MonthlyRevenue,
        LAG(MonthlyRevenue) OVER (
            ORDER BY SalesYear, SalesMonth
        ) AS PreviousMonthRevenue
    FROM MONTHLY_SALES
),
MOM_GROWTH AS
(
    SELECT
        SalesYear,
        SalesMonth,
        MonthlyRevenue,
        PreviousMonthRevenue,
        ((MonthlyRevenue - PreviousMonthRevenue)
            / NULLIF(PreviousMonthRevenue, 0)) * 100
            AS MoM_Growth_Percentage
    FROM MONTHLY_COMPARISON
)
SELECT
    SalesYear,
    SalesMonth,
    MonthlyRevenue,
    PreviousMonthRevenue,
    MoM_Growth_Percentage
FROM MOM_GROWTH
WHERE MoM_Growth_Percentage IS NOT NULL
ORDER BY MoM_Growth_Percentage DESC;
-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Task 27: LEAD()
-- Objective: Compare the current month's revenue with the next month's revenue.

WITH MONTHLY_SALES AS (
SELECT YEAR(ORDERDATE) AS SALESYEAR,
		MONTH(ORDERDATE) AS SALESMONTH,
        SUM(TOTALDUE) AS MONTHLY_REVENUE 
	FROM SALES.SALESORDERHEADER
    GROUP BY YEAR(ORDERDATE), MONTH(ORDERDATE)
ORDER BY
    SALESYEAR, SALESMONTH
)
select * FROM MONTHLY_SALES;

-- Use LEAD() to retrieve the next month's revenue.

WITH MONTHLY_SALES AS (
SELECT YEAR(ORDERDATE) AS SALESYEAR,
		MONTH(ORDERDATE) AS SALESMONTH,
        SUM(TOTALDUE) AS MONTHLY_REVENUE 
	FROM SALES.SALESORDERHEADER
    GROUP BY YEAR(ORDERDATE), MONTH(ORDERDATE)
ORDER BY
    SALESYEAR, SALESMONTH
)
SELECT
    SALESYEAR,
    SALESMONTH,
    MONTHLY_REVENUE,
    LEAD(MONTHLY_REVENUE) OVER (
        ORDER BY SALESYEAR, SALESMONTH
    ) AS NextMonthRevenue
FROM MONTHLY_SALES
ORDER BY
    SALESYEAR,
    SALESMONTH;

-- Challenge: Based on the current month, what was the revenue of the following month?
-- (A.) For each current month, LEAD() retrieves the revenue of the next available month.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- Task 28: Customer Purchase History
-- Objective: Analyze each customer's order history.
-- Customer, Order date, Order amount, Previous order amount
-- Difference from previous order

-- STEP - 1 ( select customer order )
SELECT
    SC.CustomerID,
    CONCAT(PP.FirstName, ' ', PP.LastName) AS CustomerName,
    SOH.OrderDate,
    SOH.TotalDue AS OrderAmount
FROM Sales.Customer AS SC
JOIN Person.Person AS PP
    ON SC.PersonID = PP.BusinessEntityID
JOIN Sales.SalesOrderHeader AS SOH
    ON SC.CustomerID = SOH.CustomerID
ORDER BY
    SC.CustomerID,
    SOH.OrderDate;
    
-- STEP - 2           LAG() 
LAG(OrderAmount) OVER (
    PARTITION BY CustomerID
    ORDER BY OrderDate
) 
-- STEP - 3  

WITH CUSTOMER_ORDERS AS
(
    SELECT
        SC.CustomerID,
        CONCAT(PP.FirstName, ' ', PP.LastName) AS CustomerName,
        SOH.OrderDate,
        SOH.TotalDue AS OrderAmount
    FROM Sales.Customer AS SC
    JOIN Person.Person AS PP
        ON SC.PersonID = PP.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON SC.CustomerID = SOH.CustomerID
),
ORDER_HISTORY AS
(
    SELECT
        CustomerID,
        CustomerName,
        OrderDate,
        OrderAmount,
        LAG(OrderAmount) OVER (
            PARTITION BY CustomerID
            ORDER BY OrderDate
        ) AS PreviousOrderAmount
    FROM CUSTOMER_ORDERS
)
SELECT
    CustomerID,
    CustomerName,
    OrderDate,
    OrderAmount,
    PreviousOrderAmount,
    OrderAmount - PreviousOrderAmount AS DifferenceFromPreviousOrder
FROM ORDER_HISTORY
ORDER BY
    CustomerID,
    OrderDate;
    
-- Challenge: Use LAG() to identify customers whose latest purchase value is significantly higher than their previous purchase. 

WITH CUSTOMER_ORDERS AS
(
    SELECT
        SC.CustomerID,
        CONCAT(PP.FirstName, ' ', PP.LastName) AS CustomerName,
        SOH.OrderDate,
        SOH.TotalDue AS OrderAmount
    FROM Sales.Customer AS SC
    JOIN Person.Person AS PP
        ON SC.PersonID = PP.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON SC.CustomerID = SOH.CustomerID
),
ORDER_HISTORY AS
(
    SELECT
        CustomerID,
        CustomerName,
        OrderDate,
        OrderAmount,
        LAG(OrderAmount) OVER (
            PARTITION BY CustomerID
            ORDER BY OrderDate
        ) AS PreviousOrderAmount
    FROM CUSTOMER_ORDERS
)
SELECT
    CustomerID,
    CustomerName,
    OrderDate,
    OrderAmount,
    PreviousOrderAmount,
    OrderAmount - PreviousOrderAmount AS DifferenceFromPreviousOrder,
    ((OrderAmount - PreviousOrderAmount) / NULLIF(PreviousOrderAmount, 0)) * 100
        AS IncreasePercentage
FROM ORDER_HISTORY
WHERE
    ((OrderAmount - PreviousOrderAmount) / NULLIF(PreviousOrderAmount, 0)) * 100 > 50
ORDER BY IncreasePercentage DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------
-- Task 29: Customer Running Revenue
-- Objective: Calculate cumulative revenue for each customer's order history.
-- Challenge: Use SUM() OVER() with an appropriate PARTITION BY and ORDER BY.

WITH CUSTOMER_ORDERS AS
(
    SELECT
        SC.CustomerID,
        CONCAT(PP.FirstName, ' ', PP.LastName) AS CustomerName,
        SOH.OrderDate,
        SOH.TotalDue AS OrderValue
    FROM Sales.Customer AS SC
    JOIN Person.Person AS PP
        ON SC.PersonID = PP.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON SC.CustomerID = SOH.CustomerID
)
SELECT
    CustomerID,
    CustomerName,
    OrderDate,
    OrderValue,
    SUM(OrderValue) OVER (
        PARTITION BY CustomerID
        ORDER BY OrderDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningRevenue
FROM CUSTOMER_ORDERS
ORDER BY
    CustomerID,
    OrderDate;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Task 30: NTILE()
-- Objective: Divide customers into four revenue groups. 

WITH CUSTOMER_REVENUE AS
(
    SELECT
        SC.CustomerID,
        CONCAT(PP.FirstName, ' ', PP.LastName) AS CustomerName,
        SUM(SOH.TotalDue) AS TotalRevenue
    FROM Sales.Customer AS SC
    JOIN Person.Person AS PP
        ON SC.PersonID = PP.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON SC.CustomerID = SOH.CustomerID
    GROUP BY
        SC.CustomerID,
        PP.FirstName,
        PP.LastName
),
CUSTOMER_GROUPS AS
(
    SELECT
        CustomerID,
        CustomerName,
        TotalRevenue,
        NTILE(4) OVER (
            ORDER BY TotalRevenue DESC
        ) AS RevenueGroup
    FROM CUSTOMER_REVENUE
)
SELECT
    CustomerID,
    CustomerName,
    TotalRevenue
FROM CUSTOMER_GROUPS
WHERE RevenueGroup = 1
ORDER BY TotalRevenue DESC;
-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 12. Part I – Advanced Business Problems

-- Task 1: Top 3 Products Per Category
-- Objective: Find the top three products by revenue within every category.
-- Use a window function.
-- Do not use TOP 3 alone.

WITH PRODUCT_REVENUE AS                 -- CTE for PRODUCT REVENGE 
(
    SELECT
        P.ProductID,
        P.Name AS ProductName,
        PC.ProductCategoryID,
        PC.Name AS ProductCategory,
        SUM(SOD.LineTotal) AS TotalRevenue
    FROM Sales.SalesOrderDetail AS SOD
    JOIN Production.Product AS P
        ON SOD.ProductID = P.ProductID
    JOIN Production.ProductSubcategory AS PSC
        ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory AS PC
        ON PSC.ProductCategoryID = PC.ProductCategoryID
    GROUP BY
        P.ProductID,
        P.Name,
        PC.ProductCategoryID,
        PC.Name
),
RANKED_PRODUCTS AS
(
    SELECT ProductID, ProductName, ProductCategory, TotalRevenue,
        RANK() OVER
        (
            PARTITION BY ProductCategoryID                          # PARTITIONING USING ID OF PRODUCT
            ORDER BY TotalRevenue DESC								# ORDER BY REVENUE FROM TOP TO BOTTOM 
        ) AS CategoryRank
    FROM PRODUCT_REVENUE
)
SELECT
    ProductID, ProductName, ProductCategory, TotalRevenue, CategoryRank
FROM RANKED_PRODUCTS
WHERE CategoryRank <= 3
ORDER BY ProductCategory, CategoryRank;
-- ---------------------------------------------------------------------------------------------------------------------------------- 
-- Task 2: Top Customer Per Territory
-- Objective: Find the highest-revenue customer from every territory. 

WITH CUSTOMER_REVENUE AS
(
    SELECT
        C.CustomerID,
        CONCAT(P.FirstName, ' ', P.LastName) AS CustomerName,
        C.TerritoryID,
        ST.Name AS Territory,
        SUM(SOH.TotalDue) AS TotalRevenue
    FROM Sales.Customer AS C
    JOIN Person.Person AS P
        ON C.PersonID = P.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON C.CustomerID = SOH.CustomerID
    JOIN Sales.SalesTerritory AS ST
        ON C.TerritoryID = ST.TerritoryID
    GROUP BY
        C.CustomerID,
        P.FirstName,
        P.LastName,
        C.TerritoryID,
        ST.Name
),
RANKED_CUSTOMERS AS                       -- RANK() WIND FUNCTION
(
    SELECT
        CustomerID,
        CustomerName,
        Territory,
        TotalRevenue,
        RANK() OVER
        (
            PARTITION BY TerritoryID
            ORDER BY TotalRevenue DESC
        ) AS TerritoryRank
    FROM CUSTOMER_REVENUE
)
SELECT
    CustomerID, CustomerName, Territory, TotalRevenue, TerritoryRank
FROM RANKED_CUSTOMERS
WHERE TerritoryRank = 1                  # Highest ranked territory
ORDER BY Territory;
-- -----------------------------------------------------------------------------------------------------------------------------------
-- Task 3: Second Highest Customer
-- Solve using RANK().

WITH CUSTOMER_REVENUE AS
(
    SELECT
        C.CustomerID,
        CONCAT(P.FirstName, ' ', P.LastName) AS CustomerName,
        SUM(SOH.TotalDue) AS TotalRevenue
    FROM Sales.Customer AS C
    JOIN Person.Person AS P
        ON C.PersonID = P.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON C.CustomerID = SOH.CustomerID
    GROUP BY
        C.CustomerID,
        P.FirstName,
        P.LastName
),
RANKED_CUSTOMERS AS
(
    SELECT
        CustomerID,
        CustomerName,
        TotalRevenue,
        RANK() OVER (
            ORDER BY TotalRevenue DESC
        ) AS RevenueRank
    FROM CUSTOMER_REVENUE
)
SELECT
    CustomerID,
    CustomerName,
    TotalRevenue
FROM RANKED_CUSTOMERS
WHERE RevenueRank = 2;

-- Solve using DENSE_RANK().
WITH CUSTOMER_REVENUE AS
(
    SELECT
        C.CustomerID,
        CONCAT(P.FirstName, ' ', P.LastName) AS CustomerName,
        SUM(SOH.TotalDue) AS TotalRevenue
    FROM Sales.Customer AS C
    JOIN Person.Person AS P
        ON C.PersonID = P.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON C.CustomerID = SOH.CustomerID
    GROUP BY
        C.CustomerID,
        P.FirstName,
        P.LastName
),
RANKED_CUSTOMERS AS
(
    SELECT
        CustomerID,
        CustomerName,
        TotalRevenue,
        DENSE_RANK() OVER (
            ORDER BY TotalRevenue DESC
        ) AS RevenueRank
    FROM CUSTOMER_REVENUE
)
SELECT
    CustomerID,
    CustomerName,
    TotalRevenue
FROM RANKED_CUSTOMERS
WHERE RevenueRank = 2;

-- Solve using a subquery or CTE.
WITH CUSTOMER_REVENUE AS
(
    SELECT
        C.CustomerID,
        CONCAT(P.FirstName, ' ', P.LastName) AS CustomerName,
        SUM(SOH.TotalDue) AS TotalRevenue
    FROM Sales.Customer AS C
    JOIN Person.Person AS P
        ON C.PersonID = P.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON C.CustomerID = SOH.CustomerID
    GROUP BY
        C.CustomerID,
        P.FirstName,
        P.LastName
)
SELECT
    CustomerID,
    CustomerName,
    TotalRevenue
FROM CUSTOMER_REVENUE
WHERE TotalRevenue =
(
    SELECT MAX(TotalRevenue)
    FROM CUSTOMER_REVENUE
    WHERE TotalRevenue <
    (
        SELECT MAX(TotalRevenue)
        FROM CUSTOMER_REVENUE
    )
);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
-- Task 4: Customers Above Territory Average
-- Objective: Identify customers whose revenue is greater than the average revenue of customers in their own territory.

WITH CUSTOMER_REVENUE AS
(
    SELECT
        C.CustomerID,
        CONCAT(P.FirstName, ' ', P.LastName) AS CustomerName,
        C.TerritoryID,
        ST.Name AS Territory,
        SUM(SOH.TotalDue) AS TotalRevenue
    FROM Sales.Customer AS C
    JOIN Person.Person AS P
        ON C.PersonID = P.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS SOH
        ON C.CustomerID = SOH.CustomerID
    JOIN Sales.SalesTerritory AS ST
        ON C.TerritoryID = ST.TerritoryID
    GROUP BY
        C.CustomerID,
        P.FirstName,
        P.LastName,
        C.TerritoryID,
        ST.Name
),
TERRITORY_ANALYSIS AS
(
    SELECT
        CustomerID,
        CustomerName,
        TerritoryID,
        Territory,
        TotalRevenue,
        AVG(TotalRevenue) OVER (
            PARTITION BY TerritoryID
        ) AS TerritoryAverageRevenue
    FROM CUSTOMER_REVENUE
)
SELECT
    CustomerID,
    CustomerName,
    Territory,
    TotalRevenue,
    TerritoryAverageRevenue
FROM TERRITORY_ANALYSIS
WHERE TotalRevenue > TerritoryAverageRevenue
ORDER BY
    Territory,
    TotalRevenue DESC;
-- ----------------------------------------------------------------------------------------------------------------------------------------
-- Task 5: Product Contribution
-- Objective: Calculate each product's percentage contribution to total company revenue.
-- Return Product, Revenue and % of Total Revenue.

WITH PRODUCT_REVENUE AS
(
    SELECT
        P.ProductID,
        P.Name AS ProductName,
        SUM(SOD.LineTotal) AS Revenue
    FROM Sales.SalesOrderDetail AS SOD
    JOIN Production.Product AS P
        ON SOD.ProductID = P.ProductID
    GROUP BY
        P.ProductID,
        P.Name
)
SELECT
    ProductID,
    ProductName,
    Revenue,
    (Revenue / SUM(Revenue) OVER ()) * 100
        AS PercentageOfTotalRevenue
FROM PRODUCT_REVENUE
ORDER BY
    PercentageOfTotalRevenue DESC;
-- ----------------------------------------------------------------------------------------------------------------------------------------
-- Part J — 5 Management Questions
-- (1.) Who are the company's top 10 customers?

SELECT
    C.CustomerID,
    CONCAT(P.FirstName, ' ', P.LastName) AS CustomerName,
    SUM(SOH.TotalDue) AS TotalRevenue
FROM Sales.Customer AS C
JOIN Person.Person AS P
    ON C.PersonID = P.BusinessEntityID
JOIN Sales.SalesOrderHeader AS SOH
    ON C.CustomerID = SOH.CustomerID
GROUP BY
    C.CustomerID,
    P.FirstName,
    P.LastName
ORDER BY
    TotalRevenue DESC
LIMIT 10;
-- -----------------------------------------------------------------------------------------------------------------------------
-- (2.) Which 10 products generate the highest revenue?

SELECT
    P.ProductID,
    P.Name AS ProductName,
    SUM(SOD.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail AS SOD
JOIN Production.Product AS P
    ON SOD.ProductID = P.ProductID
GROUP BY
    P.ProductID,
    P.Name
ORDER BY
    TotalRevenue DESC
LIMIT 10;
-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- (3.) Which territory generates the highest sales?

SELECT
    ST.TerritoryID,
    ST.Name AS Territory,
    SUM(SOH.TotalDue) AS TotalSales
FROM Sales.SalesTerritory AS ST
JOIN Sales.SalesOrderHeader AS SOH
    ON ST.TerritoryID = SOH.TerritoryID
GROUP BY
    ST.TerritoryID,
    ST.Name
ORDER BY
    TotalSales DESC
LIMIT 1;
-- ----------------------------------------------------------------------------------------------------
-- (4) Which products are the top 3 performers in each category?

WITH PRODUCT_REVENUE AS
(
    SELECT
        P.ProductID,
        P.Name AS ProductName,
        PC.ProductCategoryID,
        PC.Name AS ProductCategory,
        SUM(SOD.LineTotal) AS TotalRevenue
    FROM Sales.SalesOrderDetail AS SOD
    JOIN Production.Product AS P
        ON SOD.ProductID = P.ProductID
    JOIN Production.ProductSubcategory AS PSC
        ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory AS PC
        ON PSC.ProductCategoryID = PC.ProductCategoryID
    GROUP BY
        P.ProductID,
        P.Name,
        PC.ProductCategoryID,
        PC.Name
),
RANKED_PRODUCTS AS
(
    SELECT
        ProductID,
        ProductName,
        ProductCategory,
        TotalRevenue,
        RANK() OVER
        (
            PARTITION BY ProductCategoryID
            ORDER BY TotalRevenue DESC
        ) AS CategoryRank
    FROM PRODUCT_REVENUE
)
SELECT
    ProductID,
    ProductName,
    ProductCategory,
    TotalRevenue,
    CategoryRank
FROM RANKED_PRODUCTS
WHERE CategoryRank <= 3
ORDER BY
    ProductCategory,
    CategoryRank;
-- ----------------------------------------------------------------------------------------------------
-- (5.) Which months experienced declining sales? 

WITH MONTHLY_SALES AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        MONTH(OrderDate) AS SalesMonth,
        SUM(TotalDue) AS MonthlyRevenue
    FROM Sales.SalesOrderHeader
    GROUP BY
        YEAR(OrderDate),
        MONTH(OrderDate)
),
MONTHLY_COMPARISON AS
(
    SELECT
        SalesYear,
        SalesMonth,
        MonthlyRevenue,
        LAG(MonthlyRevenue) OVER
        (
            ORDER BY SalesYear, SalesMonth
        ) AS PreviousMonthRevenue
    FROM MONTHLY_SALES
)
SELECT
    SalesYear,
    SalesMonth,
    MonthlyRevenue,
    PreviousMonthRevenue,
    MonthlyRevenue - PreviousMonthRevenue AS RevenueDifference
FROM MONTHLY_COMPARISON
WHERE MonthlyRevenue < PreviousMonthRevenue
ORDER BY
    SalesYear,
    SalesMonth;
    
-- ---------------------------------------------------------------------------------------------------------------------