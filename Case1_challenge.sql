use [z-SQL_Training_Movies_WR]
go
/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
select customer_id, SUM(price) AS Total_Spent
from tblsales
join tblmenu
on tblsales.product_id = tblmenu.product_id
group by customer_id

-- 2. How many days has each customer visited the restaurant?
select customer_id, COUNT(distinct order_date) AS Total_Visits
from tblsales
group by customer_id

-- 3. What was the first item from the menu purchased by each customer?
With CTE AS (
	select customer_id, product_name, order_date, RANK() OVER ( PARTITION BY customer_id ORDER BY order_date) as rnk
	from tblsales s
	join tblmenu m
	on s.product_id = m.product_id)
select customer_id, product_name
from CTE
where rnk=1 

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select Top 1 m.product_name, count(s.product_id) AS total_purchased
from tblsales s
join tblmenu m
on s.product_id = m.product_id
group by m.product_name
order by total_purchased desc

-- 5. Which item was the most popular for each customer?
WITH cte AS (
	select customer_id, product_name, COUNT(order_date) as orders,
	RANK() OVER (PARTITION BY customer_id order by COUNT(order_date) desc) as rnk
	from tblsales s
	join tblmenu m
	on s.product_id= m.product_id
	GROUP BY product_name, customer_id) 
select customer_id, product_name, orders
from cte
where rnk= 1

-- 6. Which item was purchased first by the customer after they became a member?
WITH cte AS(
	select s.customer_id, product_name, order_date,
	RANK() OVER (PARTITION BY s.customer_id order by order_date) as rnk
	from tblsales s
	join tblmembers m on s.customer_id= m.customer_id
	join tblmenu u on s.product_id= u.product_id
	where order_date >= join_date)
select customer_id, product_name
from cte
where rnk=1

-- 7. Which item was purchased just before the customer became a member?
WITH cte AS(	
	select s.customer_id, product_name, order_date,
	RANK() OVER (PARTITION BY s.customer_id order by order_date desc) as rnk
	from tblsales s
	join tblmembers m on s.customer_id= m.customer_id
	join tblmenu u on s.product_id= u.product_id
	where order_date < join_date)
select customer_id, product_name
from cte
where rnk=1

-- 8. What is the total items and amount spent for each member before they became a member?
 WITH cte AS( 
    select s.customer_id, product_name, order_date, price
	from tblsales s
	join tblmembers m on s.customer_id= m.customer_id
	join tblmenu u on s.product_id= u.product_id
	where order_date < join_date)
select customer_id, COUNT(product_name) as Total_Items, SUM(price) AS Total_Spent
from cte
group by customer_id
order by Total_Items desc

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select customer_id, 
SUM(CASE WHEN product_name= 'sushi' THEN price * 10 * 2
ELSE price*10
end) AS Points
from tblsales s
join tblmenu m on s.product_id= m.product_id
GROUP BY customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT s.customer_id,
SUM(CASE 
WHEN order_date between join_date and DATEADD(DAY, 6, join_date) THEN price*10*2
WHEN product_name= 'sushi' THEN price*10*2
else price*10
end) as new_points
from tblsales s
inner join tblmembers m on s.customer_id= m.customer_id 
inner join tblmenu u on s.product_id= u.product_id
where order_date <= '2021-01-31'
group by s.customer_id

-- Bonus Questions
-- Join all things
select s.customer_id, order_date, product_name,price,
case
WHEN order_date >= join_date THEN 'Y'
ELSE 'N'
END as member
from tblsales s
left join tblmenu u on s.product_id= u.product_id
left join tblmembers m on s.customer_id= m.customer_id
order by s.customer_id, order_date, price desc

-- Ranking all Things
WITH CTE AS (
	select s.customer_id, order_date, product_name,price,
	case
	WHEN order_date >= join_date THEN 'Y'
	ELSE 'N'
	END as member
	from tblsales s
	left join tblmenu u on s.product_id= u.product_id
	left join tblmembers m on s.customer_id= m.customer_id
)
SELECT *, 
case
when member = 'Y' then rank() OVER (PARTITION BY customer_id, member order by order_date)
else null 
end as ranking
FROM CTE










