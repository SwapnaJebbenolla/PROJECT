create table  zepto(
sku_id serial primary key,
category varchar(120),
name varchar(150)not null,
mrp numeric(8,2),
discountpercant numeric(5,2),
availablequantity integer,
discountedsellingprice numeric(8,2),
weightingms integer,
outofstock boolean,
quantity integer
);


--DATA EXPLORATION
select COUNT(*) from zepto;
select * from zepto;

--Q1.DATA NULL VALUES
SELECT * FROM ZEPTO
WHERE category = null 
and
name = null 
and
discountpercant = null 
and
availablequantity = null 
and
discountedsellingprice = null 
and
weightingms= null 
and
outofstock = null 
and
quantity= null 
and
mrp = null;
--Detects missing values. Null data can lead to incorrect insights or pricing errors. 
--Cleaning such data improves overall data integrity and decision-making.



--Q2.different product category
select category
from zepto
group by category
order by category;
--Helps understand product variety offered by Zepto.
-- Useful for segmenting inventory and targeting category-specific promotions.



--Q3.counts of outofstock
select outofstock , count(sku_id)
from zepto
group by rollup(outofstock)
order by outofstock;
--Highlights availability issues. 
--A high number of out-of-stock items can directly affect sales and customer satisfaction. 
--Helps plan restocking.



--Q4. product repeatation
select name , count(sku_id)
from zepto
group by name
order by count(sku_id) desc;
--Detects repeated listings. May indicate duplicates or bundled SKUs.
-- Helps clean inventory data and avoid redundancy.



--Q5. product might be zero
select *
from zepto
where mrp = 0 and discountpercant = 0;
--Zero-priced products indicate data entry errors or placeholder entries.
-- Removing them prevents misleading financial reports.



--Q6.delete data where prices are zero
delete
from zepto
where mrp = 0 and discountpercant = 0;
--Cleans dataset for more accurate pricing and profitability analysis.
--Improves data hygiene and trust in analytics.



-- Q7.mrp convert into paise to rupees
update zepto
set mrp = mrp/100.0,
discountedsellingprice= discountedsellingprice/100.0;
--Standardizes pricing data. Essential for accurate comparisons, reporting, and user display.



--Q8.find the product which having high discount percent but yet not avaliable.
select *
from zepto
where outofstock = 'false'
order by discountpercant desc;
--Identifies potential lost revenue from heavily discounted but unavailable products.
-- Helps prioritize restocking based on profit potential.



--Q9. how much loss gain by zepto after product is in outofstock.
select name ,sum(discountedsellingprice*availablequantity)as revenue_loss, false as outofstock
from zepto
where outofstock = 'false'
group by rollup(name)
order by revenue_loss desc;
--Quantifies missed revenue due to stockouts. 
--Supports decisions on demand forecasting and supply chain management.



-- Q10 .Find the top 10 best-value product based on the discount percantage.
select distinct name , mrp , discountpercant
from zepto
order by discountpercant desc
limit 10;
--Helps identify products that offer the most value to customers. 
--Useful for promotions and featured listings.



--Q11.what are the product with high mrp but out of stock
select distinct name,outofstock,mrp
from zepto
where outofstock = 'false'
order by mrp desc;
--Highlights premium products that are unavailable. 
--High priority restocking items, as their margins are likely better.



--Q11.calculate the estimate revenue for each category
select coalesce(category,'total') , sum(discountedsellingprice*availablequantity) as total_revenue
from zepto
group by ROLLUP(category)
order by total_revenue desc;
--Evaluates which categories contribute most to revenue. 
--Helps allocate marketing budgets and stock space accordingly.



--Q12. find all products where mrp is greater then 500 and discount is less than 10%
select distinct name, mrp ,discountpercant 
from zepto
where mrp > 500 and discountpercant < 10;
--Identifies luxury products with minimal discounts.
-- Useful for analyzing customer sensitivity to pricing in premium segments.



--Q13.identify the top 5 category offering the highest average discount percantage
select category , round(avg(discountpercant),2)as avg_percant
from zepto
group by category
order by avg_percant desc
limit 5;
--Helps understand which categories are most discounted. 
--Informs pricing strategy and profitability analysis.



--Q14.find the price per gram for product above 100g and sort_by best value
select name , weightingms , round(discountedsellingprice/weightingms,3) as price_per_gram
from zepto
where weightingms > 100;
--Calculates product value by weight. 
--Helps optimize pricing and compare cost-effectiveness across products.



-- Q15.Group the product into category like low , medium, bulk based on there weight
select max(weightingms)
from zepto;

select weightingms , name, category,
case
when weightingms <1000 then 'low'
when weightingms < 5000 then 'medium'
else 'bulk'
end as weight_category
from zepto;
--Segments products by package size. 
--Useful for logistics, delivery optimization, and bulk order promotions.



--Q16.what is the total inventory weight per category
select category, availablequantity, sum(weightingms*availablequantity)as available_weight
from zepto
group by category,availablequantity;
--Analyzes how much weight is in stock per category. 
--Useful for warehouse space planning and distribution strategy.



--Q17. how do you retrieve only duplicate records from table.
select sku_id,category,name,mrp,discountpercant,
availablequantity,discountedsellingprice,
weightingms,outofstock,quantity, count(*)
from zepto
group by sku_id,category,name,mrp,discountpercant,
availablequantity,discountedsellingprice,
weightingms,outofstock,quantity
having count(*)>1;
--Checks for duplicate entries. Clean, non-redundant data ensures accuracy in stock, pricing, and analysis.



