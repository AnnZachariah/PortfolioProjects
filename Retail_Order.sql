select * from master..df_orders

--find top 10 highest reveue generating products 
select top 10 product_id, sum(sale_price) as revenue
from master..df_orders
group by product_id
order by revenue desc

--find top 5 highest selling products in each region
with cte as (
select product_id, sum(sale_price) as sales, region
from master..df_orders
group by product_id, region
)

select* from (
select *, ROW_NUMBER() over (partition by region order by sales desc) as rank
from cte) A
where rank<=5

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as (
select distinct year(order_date) as year, month(order_date) as month, sum(sale_price) as sales from master..df_orders
group by year(order_date), month(order_date)
--order by year(order_date), month(order_date)
)

select month,
sum(case when year='2022' then sales else 0 end) as sales_2022,
sum(case when year='2023' then sales else 0 end) as sales_2023
from cte
group by month
order by month

--for each category which month had highest sales 
with cte as (
select category, month(order_date) as order_month, sum(sale_price) as sales
from master..df_orders
group by category, sale_price, month(order_date)
--order by order_month desc
)

select * from (
select *,
row_number() over (partition by category order by sales desc) as rn
from cte) a
where rn = 1
