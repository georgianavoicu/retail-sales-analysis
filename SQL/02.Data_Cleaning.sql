--Project:Retail Sales Analysis
--Script:02.Data_Cleaning.sql

--table Customers:
--remove records with missing primary key
delete from Customers
where customer_id is null;

--set customer_id as not null and primary key
alter table Customers
alter column customer_id nvarchar(50) not null;

alter table Customers
add constraint pk_customers primary key(customer_id);

--convert signup_date from nvarchar to date
alter table Customers
add signup_date_new date;

update Customers
set signup_date_new= convert(date,signup_date,5);

alter table Customers
drop column signup_date;

exec sp_rename 'Customers.signup_date_new','signup_date','column';

--Table Products:
--convert launch_date from nvarchar to date
alter table Products
add launch_date_new date;

update Products
set launch_date_new=convert(date,launch_date,5);

alter table Products
drop column launch_date;

exec sp_rename 'Products.launch_date_new','launch_date','column';

--Table Sales:
--delete records with missing primary key
delete from Sales
where order_id is null;

--set order_id as not null
alter table Sales
alter column order_id nvarchar(50) not null;

--remove duplicate orders
with cte_duplicate as
(
select order_id,
row_number() over(partition by order_id order by order_id asc) rowsNumber
from Sales
) delete from cte_duplicate
where rowsNumber>1;

--set order_id as primary key
alter table Sales
add constraint pk_Sales primary key(order_id);

--remove sales records with invalid customer_id
delete s
from Sales as s
left join Customers as c
on s.customer_id=c.customer_id
where c.customer_id is null;

--set customer_id not null and create foreign key
alter table Sales
alter column customer_id nvarchar(50) not null;

alter table Sales
add constraint fk_Sales_Customers
foreign key (customer_id) references Customers(customer_id);

--set product_id not null and create foreign key
delete from Sales
where product_id is null;

alter table Sales
alter column product_id nvarchar(50) not null;

alter table Sales
add constraint fk_Sales_Products
foreign key(product_id) references Products(product_id);

--convert quantity value to int
update Sales
set quantity=5
where quantity='five';
update Sales
set quantity=3
where quantity='three';

alter table Sales
alter column quantity int;

--convert order_date to date
alter table Sales
add order_date_new date;

update Sales
set order_date_new=convert(date,order_date,5);

alter table Sales
drop column order_date;

exec sp_rename 'Sales.order_date_new','order_date','column';

--data standardization
--table Customers 

--column email
select *
from Customers
where email is null;

update Customers
set email='unknown'
where email is null;

--column gender
select distinct
gender
from Customers;

update Customers
set gender= case
when gender in('Female','femle') then 'female'
when gender in('Male') then 'male'
else 'other'
end;

--column region
select distinct region
from Customers;

update Customers
set region=lower(coalesce(region,'unknown'));

--column loyalty_tier
select distinct 
loyalty_tier
from Customers;

update Customers
set loyalty_tier= case
when loyalty_tier in('brnze','bronze') then 'bronze'
when loyalty_tier in('gld','GOLD') then 'gold'
when loyalty_tier in('Silver','silver') then 'silver'
else 'none'
end;

--table Sales
--column quantity
select distinct
count(*),
quantity
from Sales
group by quantity;

update Sales
set quantity=0
where quantity is null;

--column unit_price
select distinct
unit_price,
count(*)
from Sales
group by unit_price;

delete from Sales
where unit_price is null;

--column delivery_status
select distinct
delivery_status,
count(*)
from Sales
group by delivery_status;

update Sales
set delivery_status = case
when delivery_status in('delrd','Delivered') then 'Delivered'
when delivery_status in('delyd','Delayed') then 'Delayed'
when delivery_status in('Cancelled') then 'Cancelled'
else 'Unknown'
end;

--column payment_method
select distinct
count(*),
payment_method
from Sales
group by payment_method;

update Sales
set payment_method = case
when payment_method in('Bank Transfer','bank transfr') then 'Bank Transfer'
when payment_method in('Credit Card') then 'Credit Card'
when payment_method in('PayPal') then 'PayPal'
else 'unknown'
end;

--column region
select distinct
region 
from Sales;

update Sales
set region='North'
where region in('North','nrth');

--column discount_applied
select distinct
count(*),
discount_applied
from Sales
group by discount_applied;

update Sales
set discount_applied=0.00
where discount_applied is null;



