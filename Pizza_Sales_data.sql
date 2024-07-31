-- create database and tables 
-- two table direct import

create database pizzasales;

use pizzasales;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);


-- Q1: The total number of order place

use pizzasales;

select count(order_id) from orders;


-- Q2: The total revenue generated from pizza sales

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    

-- Q3: The highest priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Q4: The most common pizza size ordered.

SELECT 
    pizzas.size,
    count(order_details.order_details_id) as count_pizza
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
order by count_pizza desc;


-- Q5: The top 5 most ordered pizza types along their quantities.

SELECT 
    pizza_types.name,
    count(order_details.quantity) AS tot_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY tot_quantity DESC
LIMIT 5;


-- Q6: The quantity of each pizza categories ordered.

SELECT 
    pizza_types.category,
    COUNT(order_details.order_details_id) AS tot_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY tot_quantity DESC;


-- Q7: The distribution of orders by hours of the day.

SELECT 
    HOUR(orders.order_time) AS hour,
    COUNT(orders.order_id) AS count_order
FROM
    orders
GROUP BY HOUR(orders.order_time);


-- Q8: The category-wise distribution of pizzas.

	-- Name wise distribution

SELECT 
    pizza_types.name, (pizza_types.category)
FROM
    pizza_types;
    
	-- count name wise distribution

SELECT 
    pizza_types.category, COUNT(pizza_types.name) AS Tot_name
FROM
    pizza_types
GROUP BY pizza_types.category;


-- Q9: The average number of pizzas ordered per day.

select * from orders;

SELECT 
    ROUND(AVG(quantity), 2) as Average_order_day
FROM
    (SELECT 
        orders.order_date, COUNT(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS a;
    
    
-- Q10: Top 3 most ordered pizza type base on revenue.

SELECT 
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Top_name
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Top_name DESC
LIMIT 3;


-- Q11: The percentage contribution of each pizza type to revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS tot_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS Percentage
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;


-- Q12: The cumulative revenue generated over time.

select order_date,
sum(Tot_revenue) over(order by order_date) Comulative 
from
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as Tot_revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as total;


-- Q13: The top 3 most ordered pizza type based on revenue for each pizza category.

select category,name,revenue from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as corr_order 
from
(select pizza_types.category,pizza_types.name,
round(sum(order_details.quantity * pizzas.price),2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b 
where corr_order <= 3;