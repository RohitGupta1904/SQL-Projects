--SQL Advance Case Study


--Q1--BEGIN 
SELECT T2.State FROM FACT_TRANSACTIONS as T1 INNER JOIN
DIM_LOCATION AS T2 ON T1.IDLocation = T2.IDLocation
WHERE YEAR(T1.Date)>=2005
GROUP BY T2.State

--Q1--END

--Q2--BEGIN
SELECT TOP 1 T4.State, SUM(T1.Quantity) AS QTY FROM FACT_TRANSACTIONS as T1 INNER JOIN
DIM_MODEL AS T2 ON T1.IDModel=T2.IDModel
INNER JOIN DIM_MANUFACTURER AS T3 ON
T2.IDManufacturer=T3.IDManufacturer INNER JOIN
DIM_LOCATION AS T4 ON T1.IDLocation=T4.IDLocation
WHERE T4.Country='US' AND T3.Manufacturer_Name='Samsung'
GROUP BY T4.State
	
--Q2--END
SELECT * FROM DIM_CUSTOMER
SELECT * FROM DIM_Date
SELECT * FROM DIM_LOCATION
SELECT * FROM DIM_MANUFACTURER
SELECT * FROM DIM_MODEL
SELECT * FROM FACT_TRANSACTIONS
--Q3--BEGIN      
SELECT T3.State, T3.ZipCode, T2.Model_Name, COUNT(T1.IDCustomer) AS QTY FROM FACT_TRANSACTIONS as T1 INNER JOIN
DIM_MODEL AS T2 ON T1.IDModel=T2.IDModel INNER JOIN 
DIM_LOCATION AS T3 ON T1.IDLocation=T3.IDLocation
GROUP BY T3.State, T3.ZipCode, T2.Model_Name
ORDER BY T3.STATE ASC

--Q3--END

--Q4--BEGIN
SELECT TOP 1 Model_Name, Unit_price
FROM DIM_MODEL 
ORDER BY Unit_price ASC

--Q4--END

--Q5--BEGIN
SELECT TOP 5 T3.Manufacturer_Name, T2.Model_Name, ROUND(AVG(T1.TotalPrice), 2) AS AVG_PRICE, SUM(T1.Quantity) AS SALE_QTY
FROM FACT_TRANSACTIONS AS T1 INNER JOIN DIM_MODEL AS T2
ON T1.IDModel = T2.IDModel INNER JOIN DIM_MANUFACTURER AS T3 
ON T2.IDManufacturer=T3.IDManufacturer
GROUP BY T3.Manufacturer_Name, T2.Model_Name
ORDER BY AVG(T2.Unit_price) DESC

--Q5--END

--Q6--BEGIN
SELECT T2.Customer_Name, ROUND(AVG(T1.TotalPrice), 2) AS AVG_SPEND
FROM FACT_TRANSACTIONS AS T1 INNER JOIN DIM_CUSTOMER AS T2
ON T1.IDCustomer = T2.IDCustomer 
WHERE YEAR(Date)='2009'
GROUP BY T2.Customer_Name
HAVING ROUND(AVG(T1.TotalPrice), 2) > 500

--Q6--END
	
--Q7--BEGIN  
SELECT * FROM (SELECT TOP 5 T2.Model_Name FROM FACT_TRANSACTIONS as T1 INNER JOIN
DIM_MODEL AS T2 ON T1.IDModel=T2.IDModel
WHERE YEAR(T1.Date) = '2008'
GROUP BY T2.Model_Name
ORDER BY SUM(T1.Quantity) DESC
INTERSECT
SELECT TOP 5 T2.Model_Name FROM FACT_TRANSACTIONS as T1 INNER JOIN
DIM_MODEL AS T2 ON T1.IDModel=T2.IDModel
WHERE YEAR(T1.Date) = '2009'
GROUP BY T2.Model_Name
ORDER BY SUM(T1.Quantity) DESC
INTERSECT
SELECT TOP 5 T2.Model_Name FROM FACT_TRANSACTIONS as T1 INNER JOIN
DIM_MODEL AS T2 ON T1.IDModel=T2.IDModel
WHERE YEAR(T1.Date) = '2010'
GROUP BY T2.Model_Name
ORDER BY SUM(T1.Quantity) DESC) AS TBL

--Q7--END

--Q8--BEGIN

SELECT Manufacturer_Name, YEAR_SALES FROM
(SELECT TOP 2 T3.Manufacturer_Name,YEAR(T1.Date) AS YEAR_SALES, DENSE_RANK() OVER (ORDER BY SUM(T1.TotalPrice) DESC) AS RANK_1
FROM FACT_TRANSACTIONS AS T1 INNER JOIN DIM_MODEL AS T2
ON T1.IDModel = T2.IDModel INNER JOIN DIM_MANUFACTURER AS T3 
ON T2.IDManufacturer=T3.IDManufacturer
WHERE YEAR(T1.Date) = '2009'
GROUP BY T3.Manufacturer_Name, YEAR(T1.Date)
ORDER BY DENSE_RANK() OVER (ORDER BY SUM(T1.TotalPrice) DESC) ASC
UNION ALL
SELECT TOP 2 T3.Manufacturer_Name, YEAR(T1.Date) AS YEAR_SALES,  DENSE_RANK() OVER (ORDER BY SUM(T1.TotalPrice) DESC) AS RANK_1
FROM FACT_TRANSACTIONS AS T1 INNER JOIN DIM_MODEL AS T2
ON T1.IDModel = T2.IDModel INNER JOIN DIM_MANUFACTURER AS T3 
ON T2.IDManufacturer=T3.IDManufacturer
WHERE YEAR(T1.Date) = '2010'
GROUP BY T3.Manufacturer_Name, YEAR(T1.Date)
ORDER BY DENSE_RANK() OVER (ORDER BY SUM(T1.TotalPrice)  DESC) ASC
) TBL 
WHERE RANK_1 = '2'

--Q8--END

--Q9--BEGIN
SELECT Manufacturer_Name FROM 
(SELECT T3.Manufacturer_Name
FROM FACT_TRANSACTIONS AS T1 INNER JOIN DIM_MODEL AS T2
ON T1.IDModel = T2.IDModel INNER JOIN DIM_MANUFACTURER AS T3 
ON T2.IDManufacturer=T3.IDManufacturer
WHERE YEAR(T1.Date) = 2010
GROUP BY T3.Manufacturer_Name
EXCEPT
SELECT T3.Manufacturer_Name
FROM FACT_TRANSACTIONS AS T1 INNER JOIN DIM_MODEL AS T2
ON T1.IDModel = T2.IDModel INNER JOIN DIM_MANUFACTURER AS T3 
ON T2.IDManufacturer=T3.IDManufacturer
WHERE YEAR(T1.Date) = 2009
GROUP BY T3.Manufacturer_Name
) AS TBL


--Q9--END

--Q10--BEGIN
WITH TOP_CUST AS
(SELECT TOP 100 Customer_Name, T1.IDCustomer, SUM(TotalPrice) as TOT_SPEND FROM FACT_TRANSACTIONS AS T1 INNER JOIN DIM_CUSTOMER AS T2
ON T1.IDCustomer=T2.IDCustomer
GROUP BY Customer_Name, T1.IDCustomer
ORDER BY TOT_SPEND DESC),
AVERAGE AS
(SELECT Customer_Name, T3.IDCUSTOMER, YEAR(T3.DATE) AS YEAR1,
AVG(T3.Quantity) AS AVG_QTY, AVG(T3.TotalPrice) AS AVG_SPEND
FROM FACT_TRANSACTIONS T3 INNER  JOIN TOP_CUST AS T4 
ON T4.IDCustomer = T3.IDCustomer
GROUP BY  Customer_Name, T3.IDCustomer, T3.Date)
SELECT Customer_Name, YEAR1, AVG_QTY, AVG_SPEND,
((AVG_SPEND-LAG(AVG_SPEND,1) OVER (PARTITION BY IDCustomer 
ORDER BY YEAR1))/AVG_SPEND)*100 AS PER_CHANGE FROM AVERAGE

--Q10--END
	