-- 127.0.0.1:3306

set autocommit=0;
SET SQL_SAFE_UPDATES = 0;

select * from global_electronics.customer_records;

select * from global_electronics.exchange_rates;

select * from global_electronics.products_data;

select * from global_electronics.sales_data;

select * from global_electronics.stores_data;

-- 1- Count of Customers by Gender
SELECT Gender, 
       COUNT(*) AS Customer_Count
FROM global_electronics.customer_records
GROUP BY Gender;

-- 2-- Count of customers in country wise
SELECT Country, COUNT(*) AS Customer_Count 
FROM customer_records
GROUP BY Country 
ORDER BY Customer_Count DESC;

-- 3- Count of orders by State and Country
SELECT
    c.State,
    c.Country,
    COUNT(DISTINCT o.Order_Number) AS OrderCount
FROM global_electronics.customer_records c
JOIN global_electronics.sales_data o ON c.CustomerKey = o.CustomerKey
GROUP BY c.State, c.Country
ORDER BY OrderCount DESC
LIMIT 5;

-- 4- Top 10 Customer Cities -----
SELECT 
    City, 
    COUNT(*) AS Customer_Count,
    (SELECT COUNT(CustomerKey) FROM global_electronics.customer_records) AS All_Customers,
    (SELECT count(distinct(City)) FROM global_electronics.customer_records) AS All_Cities,
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM global_electronics.customer_records) AS Percentage
FROM global_electronics.customer_records
GROUP By City
ORDER BY Customer_Count DESC
LIMIT 10;


-- 5- country wise stores 
SELECT Country, COUNT(StoreKey) 
FROM global_electronics.stores_data
GROUP BY Country 
ORDER BY COUNT(StoreKey) desc;


-- 6- Top 10 sale Brands & Products
SELECT p.Product_Name, p.Brand, p.Subcategory,
SUM(s.Quantity) AS Total_Quantity, SUM(s.Quantity * p.Unit_Price_USD) AS Total_Revenue
FROM sales_data s
JOIN products_data p ON s.ProductKey = p.ProductKey
JOIN stores_data st ON s.StoreKey = st.StoreKey
GROUP BY p.Product_Name, p.Brand, p.Subcategory
limit 10;

-- 7- product sales count

select Subcategory ,round(sum(Unit_price_USD*sr.Quantity),2) as TOTAL_SALE_AMOUNT
from global_electronics.products_data pr join global_electronics.sales_data sr on pr.ProductKey=sr.ProductKey
 group by Subcategory order by TOTAL_SALE_AMOUNT desc
 limit 10;
 
-- 8- brand profit yearly
select year(Order_Date), sr.Brand,round(SUM(Unit_price_USD*pr.Quantity),2) as year_sales FROM global_electronics.products_data sr
join global_electronics.sales_data pr on sr.ProductKey=pr.ProductKey group by year(Order_Date), sr.Brand
;



-- 9-yearly sales
 select year(Order_Date) as year,
 SUM((Unit_Price_USD - Unit_Cost_USD) * sr.Quantity) as profit 
from global_electronics.sales_data sr join global_electronics.products_data pr 
on sr.ProductKey = pr.ProductKey
group by year(Order_Date);



-- 10- Products with Zero Sales -----
SELECT *
	FROM Products_data
	WHERE ProductKey NOT IN (SELECT ProductKey FROM Sales_data);
    
    
-- 11-Top 10 Sales Revenue from Stores 
WITH SalesData AS (
    SELECT s.StoreKey, SUM(p.Unit_Price_USD * s.Quantity) AS TotalRevenue
    FROM sales_data s
    JOIN products_data p ON s.ProductKey = p.ProductKey
    GROUP BY s.StoreKey
)
SELECT sd.StoreKey, sd.TotalRevenue
FROM SalesData sd
JOIN stores_data st ON sd.StoreKey = st.StoreKey
ORDER BY sd.TotalRevenue DESC
LIMIT 10;

-- 12- comparing current_year and previous_year sales
select YEAR(Order_Date) as year ,round(sum(pd.Unit_Price_USD*sd.Quantity),2) as sales, LAG(sum(pd.Unit_Price_USD*sd.Quantity))
OVER(order by YEAR(Order_Date)) AS Previous_Year_Sales from sales_data sd join products_data pd 
on sd.ProductKey=pd.ProductKey GROUP BY YEAR(Order_Date);
