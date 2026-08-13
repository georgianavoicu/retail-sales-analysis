--Project:Retail Sales Analysis
--Script:03.Data_Analysis.sql

--Descriptive analysis

-- table Sales
--how many orders
select
count(order_id) as NumberOfOrders
from Sales;

--number of discounted orders
select
count(order_id) as NumberOfOrders
from Sales
where discount_applied>0;

--total Sales and average Sales
select
sum(quantity*unit_price*(1-discount_applied)) 
as TotalSales,
avg(quantity*unit_price*(1-discount_applied)) as 
AverageSales
from Sales;

--total quantity
select
sum(quantity) as TotalQuantity
from Sales;

--distribution by delivery_status
select 
delivery_status,
count(order_id) delivery_statusDistribution
from Sales
group by delivery_status;

--distribution by payment_method
select
payment_method,
count(order_id) payment_methodDistribution 
from Sales
group by payment_method;

--table Products
--how many products
select
count(product_id) as totalProducts
from Products;

--distribution by category
select
category,
count(*) as categoryDistribution
from Products
group by category;

--the most expensive product
select
	product_id,
	product_name,
	expensiveProduct
from(
select
	product_id,
	base_price,
	product_name,
	max(base_price) over() as expensiveProduct
from Products)t
where base_price=expensiveProduct; 

--the cheapest product
select
	product_id,
	product_name,
	cheapestProduct
from(
select
	product_id,
	base_price,
	product_name,
	min(base_price) over() as cheapestProduct
from Products)t
where base_price=cheapestProduct;

--table Customers
--how many customers
select
count(customer_id) as totalCustomers
from Customers;

--distribution by gender
select
gender,
count(*) as genderDistribution 
from Customers
group by gender;

--distribution by region
select region,
count(*) as regionDistribution 
from Customers 
group by region 
order by regionDistribution desc;

--distribution by loyalty_tier
select loyalty_tier,
count(*) as loyalty_tierDistribution
from Customers
group by loyalty_tier
order by loyalty_tierDistribution desc;

--Comparative analysis

--customer with highest sales value
select top 1
customer_id,
sum(quantity*unit_price*(1-discount_applied)) as SalesValue
from Sales
group by customer_id
order by 
sum(quantity*unit_price*(1-discount_applied)) desc;

--sales performance by customer signup year
select
year(c.signup_date) as signupYear,
count(distinct c.customer_id) as totalCustomers,
count(s.order_id) as totalOrders,
sum(quantity*unit_price*(1-discount_applied)) as totalSales
from Customers as c
left join Sales as s
on c.customer_id=s.customer_id
group by year(c.signup_date) 
order by signupYear desc;

--region generating the highest sales
select top 1
c.region,
sum(s.quantity*s.unit_price*(1-s.discount_applied)) as SalesValue
from Customers as c
left join Sales as s
on c.customer_id=s.customer_id
group by c.region
order by sum(s.quantity*s.unit_price*(1-s.discount_applied)) desc;

--payment method generating the highest sales value
select top 1
payment_method,
sum(quantity*unit_price*(1-discount_applied)) as SalesValue
from Sales
group by payment_method
order by sum(quantity*unit_price*(1-discount_applied)) desc;

--product generating the highest sales value
select top 1
product_id,
sum(quantity*unit_price*(1-discount_applied)) totalSales
from Sales
group by product_id
order by totalSales desc;

--best selling product 
select top 1
product_id,
sum(quantity) UnitsSold
from Sales
group by product_id
order by UnitsSold desc;

--product generating the lowest sales value
select top 1
product_id,
sum(quantity*unit_price*(1-discount_applied)) totalSales
from Sales
group by product_id
order by totalSales asc;

--lowest-selling product
select top 1
product_id,
sum(quantity) UnitsSold
from Sales
group by product_id
order by UnitsSold asc;

--product performance based on launch_year
select
year(p.launch_date) as LaunchYear,
count(p.product_id) as TotalProducts,
sum(s.quantity) as TotalUnitsSold,
sum(quantity*unit_price*(1-discount_applied)) totalSales
from Products as p
left join Sales as s
on p.product_id=s.product_id
group by year(p.launch_date)
order by year(p.launch_date) desc;

--category generating the highest sales
select top 1 
p.category,
sum(s.quantity*s.unit_price*(1-s.discount_applied)) as TotalSales
from Products as p
left join Sales as s
on p.product_id=s.product_id
group by p.category
order by sum(s.quantity*s.unit_price*(1-s.discount_applied)) desc;

--Business insights

--products with high order volume but low revenue
with cte_metrics as
(select
product_id,
count(product_id) as totalOrders,
sum(quantity*unit_price*(1-discount_applied)) as totalSales
from Sales
group by product_id)

select*
from(
select 
product_id,
totalOrders,
totalSales ,
rank() over(order by totalSales asc) as RankSales,
rank() over(order by totalOrders desc) as RankOrders
from cte_metrics)t
where RankSales<=15 and RankOrders<=15;

--products frequently purchased with discounts
select top 5
product_id,
count(discount_applied) as numberOfDiscounts
from Sales
where discount_applied>0
group by product_id
order by count(discount_applied) desc; 

--discount contribution to sales value
with cte_metricsSales as
(select 
sum(quantity*unit_price) as SalesWithoutDiscounts,
sum(quantity*unit_price*(1-discount_applied)) SalesWithDiscounts,
sum(quantity*unit_price*discount_applied) as discountsImpact
from Sales )

select
round((discountsImpact/SalesWithoutDiscounts)*100,1)as discountPercentage
from cte_metricsSales;

--the favorite product of each loyalty_tier
select*
from(
select
p.product_id,
p.product_name,
c.loyalty_tier,
sum(quantity*unit_price*(1-discount_applied)) totalSales,
row_number() over(partition by c.loyalty_tier order by
sum(quantity*unit_price*(1-discount_applied)) desc ) ranking
from Sales as s 
left join Products as p
on p.product_id=s.product_id
left join Customers as c
on c.customer_id=s.customer_id
group by 
	c.loyalty_tier,
	p.product_id,
	p.product_name
)t
where ranking=1;

--performance of categories by region
select*
from(
select
c.region,
p.category,
sum(quantity*unit_price*(1-discount_applied)) totalSales
from Sales as s
left join Products as p
on p.product_id=s.product_id
left join Customers as c
on c.customer_id=s.customer_id
group by c.region,
         p.category)t
order by t.region,t.totalSales desc;

--estimated profitability analysis
select
p.product_id,
p.base_price,
sum(quantity*unit_price*(1-discount_applied)) totalSales,
sum(quantity*p.base_price) as costTotal,
sum(quantity*unit_price*(1-discount_applied)) -
sum(quantity*p.base_price) as profit,
((sum(quantity*unit_price*(1-discount_applied)) -
sum(quantity*p.base_price))/
sum(quantity*unit_price*(1-discount_applied)))*100 
as profitMargin
from Sales as s
left join Products as p
on p.product_id=s.product_id
group by p.product_id;

         
