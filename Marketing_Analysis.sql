-- 1. Count of Each Transaction

select campaign_name, count(transaction_id) as no_of_transactions
from transactions t
join marketing_campaigns m on t.purchase_date between m.start_date and m.end_date
	and t.product_id = m.product_id
group by campaign_name;

/* 2. Product has highest Sales Quality */

select s.product_name, sum(t.quantity) as quantity_sold
from sustainable_clothing s
inner join transactions t 
on s.product_id = t.product_id
group by s.product_name
order by quantity_sold desc
limit 1; 

-- 3. Total revenue generated 
select c.campaign_name, round(sum(t.quantity * s.price), 2) as total_price
from transactions t
inner join sustainable_clothing s
on  t.product_id = s.product_id
inner join marketing_campaigns c
on t.purchase_date between c.start_date and end_date
	and t.product_id = c.product_id
group by c.campaign_name;

-- 4. Top selling product 
select s.category, round(sum(t.quantity * s.price), 2) as total_price
from transactions t
inner join sustainable_clothing s
on  t.product_id = s.product_id
group by s.category
order by total_price desc
limit 1;

-- 5. product has higher than average
select t.product_id, product_name, quantity
from transactions t
join sustainable_clothing s on t.product_id = s.product_id
where quantity > (select avg(quantity) from transactions);  

-- 6. Average revenue generated per day during the marketing campaigns
select t.purchase_date, round(avg(t.quantity * s.price), 2) as avg_price
from transactions t
inner join sustainable_clothing s
on  t.product_id = s.product_id
inner join marketing_campaigns c
on t.purchase_date between c.start_date and end_date
	and t.product_id = c.product_id
group by t.purchase_date;

-- 7. Percentage contribution of each product to the total revenue
with cte as
(select round(sum(quantity*price),2) as total_revenue
from transactions t
join sustainable_clothing s on t.product_id=s.product_id),

cte2 as
(select product_name, round(sum(quantity*price),2) as total_prod_revenue
from transactions t
join sustainable_clothing s on t.product_id=s.product_id
group by product_name)

select product_name, 
	round((total_prod_revenue*100)/total_revenue ,2) as pct_contri
from cte, cte2;

-- 8.  Average quantity sold during marketing campaigns to outside the marketing campaigns
with cte as
(select avg(t.quantity) as total_avg_qty
from transactions t
inner join sustainable_clothing s
on t.product_id=s.product_id),

cte2 as
(select avg(t.quantity) as avg_qty_during_campaign
from transactions t
inner join marketing_campaigns c
on t.purchase_date between c.start_date and end_date
	and t.product_id = c.product_id)
    
select total_avg_qty, avg_qty_during_campaign, 
	total_avg_qty-avg_qty_during_campaign as avg_qty_outside_campaign
from cte, cte2;

-- 9. Compare the revenue generated by products inside the marketing campaigns to outside the campaigns
with cte as
(select round(sum(t.quantity * s.price), 2) as revenue_market_campaign
from transactions t
inner join sustainable_clothing s
on  t.product_id = s.product_id
inner join marketing_campaigns c
on t.purchase_date between c.start_date and end_date
	and t.product_id = c.product_id), 

cte2 as
(select round(sum(t.quantity * s.price), 2) as revenue_outside_campaign
from transactions t
inner join sustainable_clothing s
on  t.product_id = s.product_id)

select revenue_market_campaign, revenue_outside_campaign, 
	revenue_outside_campaign-revenue_market_campaign as qty_outside_campaign
from cte, cte2;

-- 10. Rank the products by their average daily quantity sold
with cte as
(select product_name, avg(quantity) as avg_sold_qty 
from transactions t
join sustainable_clothing s on t.product_id=s.product_id 
group by 1)

select product_name, avg_sold_qty, 
	dense_rank() over(order by avg_sold_qty) as rank_avg 
from cte;