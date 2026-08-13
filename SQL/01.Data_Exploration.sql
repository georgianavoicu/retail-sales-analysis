--Project:Retail Sales Analysis
--Script:01.Data_Exploration.sql

--View all tables
select* from Customers;
select* from Products;
select* from Sales;

--number of rows
select count(*) as NumberOfCustomers from Customers;
select count(*) as NumberOfProducts from Products;
select count(*) as NumberOfSales from Sales;

--check missing primary keys
select* from Customers where customer_id is null;
select* from Products where product_id is null;
select* from Sales where order_id is null;

--check duplicates in primary keys
select
	customer_id,
	count(*) as duplicate
from Customers
group by customer_id
having count(*)>1;

select
	product_id,
	count(*) as duplicate
from Products
group by product_id
having count(*)>1;

select
	order_id,
	count(*) as duplicate
from Sales
group by order_id
having count(*)>1;

--check null foreign keys
select* from Sales where customer_id is null;
select* from Sales where product_id is null;

--sales where customerID dosen't exist
select s.*
from Sales as s
left join Customers as c
on c.customer_id=s.customer_id
where c.customer_id is null;

--sales where productID dosen't exist
select s.*
from Sales as s
left join Products as p
on s.product_id=p.product_id
where p.product_id is null;