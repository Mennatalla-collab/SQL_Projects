

--UPDATE IN DBO SALES
UPDATE dbo.sales
SET unit_price = ROUND(unit_price, 2),
    discount = ROUND(discount, 2),
    total_amount = ROUND(total_amount, 2),
    profit = ROUND(profit, 2);

-- TOTAL REVENUE!?
select format(round(sum(total_amount),2),'N0') as 'total revenue' from dbo.sales; 

-- TOTAL QUANTITY SOLD?
select format(round(sum(quantity),2),'N0') as 'total quantity sold' from dbo.sales; 
 
 -- REVENUE BY CHANNEL?
 Select channel,format(round(sum(total_amount),2),'N0') as 'total sales' from dbo.sales
 group by channel  order by sum(total_amount) desc;

 --SALES BY CATEGORY?
 select p.category,format(round(sum(s.total_amount),2),'N0') as 'total sales' from dbo.products p
 join sales s
 on p.product_id=s.product_id
 group by category 
 order by sum(s.total_amount) desc;

 --SALES BY TOP 10 FROM PRODUCT NAME?
 select top 10 p.product_name,format(round(sum(s.quantity),2),'N0') as ' total sales' from dbo.products p
 join sales s
 on p.product_id=s.product_id
 group by product_name
 order by sum(s.quantity) desc;

 --HOW MANY CUSTOMERS MADE A PURCHASE?
 select count(distinct customer_id) as 'purchasing customers' from dbo.sales;

 --AVERAGE TRANSACTION VALUE?
 select format(round(AVG(total_amount),2),'N0') as 'transaction value'from dbo.sales;

 --TOP 10 CUSTOMER NAME BY SALES?
 SELECT TOP 10 c.customer_name, FORMAT(ROUND(SUM(s.total_amount), 2), 'N0') AS 'total sales'
FROM dbo.[customers ] c
JOIN sales s 
ON c.customer_id = s.customer_id 
GROUP BY c.customer_name 
ORDER BY SUM(s.total_amount) DESC;

--SALES BY COUNTRY?
select c.country, format(round(sum(total_amount),2),'N0') as 'total revenue' from dbo.[customers ] c
join sales s
on c.customer_id = s.customer_id
group by country
order by sum(total_amount) desc;
--UPDATE 
update dbo.[customers ]
set gender ='no name'
where gender is null;

--SALES BY GENDER?
select c.gender ,format(round(sum(total_amount),2),'N0') as 'total revenue'from dbo.[customers ] c
join sales s
on c.customer_id=s.customer_id
group by gender
order by  sum(total_amount) desc;

--SALES BY AGE-RANGE?
select c.age_range ,format(round(sum(s.total_amount),2),'N0') as 'total revenue'from dbo.[customers ] c
join sales s
on c.customer_id=s.customer_id
group by age_range
order by  sum(total_amount) desc;

--SALES BY BRANDS?
select P.brand ,format(round(sum(s.total_amount),2),'N0') as 'total revenue'from dbo.products p
join sales s
on p.product_id=s.product_id
group by brand
order by  sum(total_amount) desc;

--SALES BY GENDER?
select c.gender ,format(round(sum(total_amount),2),'N0') as 'total revenue'from dbo.[customers ] c
join sales s
on c.customer_id=s.customer_id
group by gender
order by  sum(total_amount) desc;

--add column profit
alter table dbo.sales
add profit decimal(10,2);
select*from dbo.sales;

UPDATE dbo.sales
SET profit = s.total_amount - (s.quantity * p.cost_price)
FROM sales s
JOIN products p
    ON s.product_id = p.product_id;

select * from dbo.sales;

--CATEGORY BY PROFIT?
select p.category,format(round(sum(s.profit),2),'N0') as 'total profit' from dbo.products p
join sales s
on p.product_id = s.product_id
group by category
order by sum(s.profit) desc;

--add column profit margin
alter table dbo.sales
add profit_margin decimal(10,2);
select*from dbo.sales;
 --UPDATE
UPDATE dbo.sales
SET profit_margin = (pro_fit / total_amount) * 100;

SELECT * FROM dbo.sales;

--PROFIT MERGIN BY PRODUCTS NAME?
SELECT top 10 p.product_name, 
       FORMAT(ROUND(SUM(s.profit_margin), 2), 'N0') AS 'total profit margin' 
FROM dbo.products p
JOIN sales s 
ON p.product_id = s.product_id 
GROUP BY p.product_name 
ORDER BY SUM(s.profit_margin) DESC;

--DISCOUNT Affect profit?
SELECT 
    CASE 
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.05 THEN 'Low'
        WHEN discount <= 0.10 THEN 'Medium'
        ELSE 'High'
    END AS discount_level,
    FORMAT(ROUND(AVG(profit), 2),'n0') AS average_profit
FROM sales
GROUP BY 
    CASE 
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.05 THEN 'Low'
        WHEN discount <= 0.10 THEN 'Medium'
        ELSE 'High'
    END
order by AVG(profit) desc;

--CUSTOMERS WITH MORE THAN 5 PURCHASE?
select c.customer_name,count(s.sale_id) as 'purchase count' from dbo.[customers ] c
join sales s
on c.customer_id=s.customer_id
group by customer_name
having count(s.sale_id) >5;

--CUSTOMERS WITH NO PURCHASE?
Select c.customer_name,s.sale_id from dbo.[customers ] c 
left join sales s
on c.customer_id=s.customer_id
where sale_id is null;

--RANK CUSTOMERS BY SPENDING?
select c.customer_name,format(round(sum(s.total_amount),2),'N0') as  'total revenue',
RANK()over (order by sum(total_amount)DESC) as ' customer rank'
from dbo.[customers ] c
join sales s
on c.customer_id = s.customer_id
group by c.customer_name;

--CATEGORY SALES CONTRIBUTION?
WITH category_sales AS (
    SELECT 
        p.category,
        ROUND(SUM(s.total_amount), 2) AS category_sales
    FROM products p
    JOIN sales s 
        ON p.product_id = s.product_id
    GROUP BY p.category
)
SELECT 
    category,
    FORMAT(category_sales, 'N0') AS category_sales,
    CONCAT(ROUND((category_sales * 100.0 / SUM(category_sales) OVER ()), 2), '%') AS sales_contribution
FROM category_sales
order by (category_sales * 100.0 / SUM(category_sales) OVER ()) desc;
--MONTH SALES?
SELECT
    YEAR(sale_date) AS sales_year,
    MONTH(sale_date) AS sales_month,
    format(round(sum(total_amount),2),'N0')  AS monthly_sales
FROM sales
GROUP BY
    YEAR(sale_date),
    MONTH(sale_date)
ORDER BY
    sales_year,
    sales_month;

    --MONTH OVER MONTH GROWTH?
    with monthly_sales as(
    select 
        YEAR(sale_date) as year,
        MONTH(sale_date) as month,
        SUM(total_amount) as sales
    from dbo.sales
    group by YEAR(sale_date), MONTH(sale_date)
)
select 
    year, 
    month, 
    format(sales, 'N0') as sales,
    format(LAG(sales) OVER(order by year, month), 'N0') as 'previous sales',
    format(sales - LAG(sales) OVER(order by year, month), 'N0') as 'comparsion',
    concat(round((sales - LAG(sales) OVER(order by year, month)) / NULLIF(LAG(sales) OVER(order by year, month), 0) * 100, 2), '%') as 'growth'
from monthly_sales;


--BEST PRODUCT IN EASH CATEGORY?
select p.product_name,p. category ,format(round(sum(s.total_amount),2),'N0') as  'total revenue',
RANK()over (partition by p.category order by sum(s.total_amount)DESC) as ' product rank'
from dbo.products p
join sales s
on p.product_id = s.product_id
group by p.product_name,p.category;

--RUNNING TOTAL SALES?
SELECT
    YEAR(sale_date) AS sales_year,
    MONTH(sale_date) AS sales_month,
    FORMAT(SUM(total_amount), 'N0') AS monthly_sales,
    FORMAT(
        SUM(SUM(total_amount)) OVER (
            ORDER BY YEAR(sale_date), MONTH(sale_date)
        ),
        'N0'
    ) AS running_total_sales
FROM sales
GROUP BY
    YEAR(sale_date),
    MONTH(sale_date)
ORDER BY
    sales_year,
    sales_month;

    --LOW STOCK,HIGH DEMAND PRODUCTS?
    select p.product_name, FORMAT(SUM(total_amount), 'N0')AS 'total sales'
    ,FORMAT(SUM(st.stock_quantity),'N0') as 'total stock'
    from dbo.products p 
    join sales s
    on p.product_id=s.product_id
    join stock st
    on p.product_id=st.product_id
    GROUP BY P.product_name
    order BY SUM(total_amount) desc;

    --PRODUCTS NEVER SOLD?
select p.product_name,p. category ,s.total_amount as  'total revenue'
    from dbo.products p
    left join sales s
    on p.product_id=s.product_id
    where s.product_id is null;

    --LAST PURCHASE DATE PER CUSTOMER?
    SELECT
    c.customer_name,MAX(s.sale_date) AS last_purchase_date
FROM DBO.[customers ] c
JOIN sales s
    ON c.customer_id = s.customer_id
GROUP BY
    c.customer_name
    order by MAX(s.sale_date) asc;

    --Customers Using More Than One Sales Channel?
    SELECT
    c.customer_name,COUNT(DISTINCT s.channel) AS channel_count
FROM DBO.[customers ] C
JOIN sales s
    ON c.customer_id = s.customer_id
GROUP BY c.customer_name
HAVING COUNT(DISTINCT s.channel) > 1;

--Customers Purchasing in More Than One Year?
SELECT
    c.customer_name,
    COUNT(DISTINCT year( s.sale_date)) AS year_count
FROM DBO.[customers ] C
JOIN sales s
    ON c.customer_id = s.customer_id
GROUP BY c.customer_name
HAVING COUNT(DISTINCT year( s.sale_date)) > 1
order by  COUNT(DISTINCT s.sale_date) desc;
