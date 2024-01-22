use dannys_diner;

-- Q1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) AS total_amount_spent
FROM sales S
JOIN menu M ON S.product_id = M.product_id
GROUP BY customer_id;


-- Q2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) AS days_visited
FROM sales
GROUP BY customer_id;

-- Q3. What was the first item from the menu purchased by each customer?
WITH RNKS AS (
SELECT customer_id, order_date, product_name,
RANK() OVER(partition by customer_id order by order_date ASC) AS RNK,
ROW_NUMBER() OVER(partition by customer_id order by order_date ASC) AS RWN
FROM sales S
JOIN menu M ON S.product_id = M.product_id
)
SELECT
customer_id,
product_name,
order_date
FROM RNKS
where rwn = 1;


-- Q4.  What is the most purchased item on the menu and how many times was 
-- it purchased by all customers? 
SELECT product_name, COUNT(M.product_id) AS total_purchases
FROM sales S
JOIN menu M ON S.product_id = M.product_id
GROUP BY product_name
ORDER BY total_purchases DESC
LIMIT 1;


-- Q5.  Which item was the most popular for each customer?
SELECT customer_id, product_name, COUNT(M.product_id) AS total_purchases
FROM sales S
JOIN menu M ON S.product_id = M.product_id
GROUP BY customer_id, product_name
ORDER BY customer_id, total_purchases DESC;


-- Q6. Which item was purchased first by the customer after they became a member?
WITH RNKS AS (
SELECT MB.customer_id, M.product_name, MB.join_date, S.order_date,
RANK() OVER(partition by customer_id ORDER BY order_date) AS RNK,
ROW_NUMBER() OVER(partition by customer_id ORDER BY order_date) AS RWN
FROM members MB
JOIN sales S ON MB.customer_id = S.customer_id
JOIN menu M ON S.product_id = M.product_id
WHERE S.order_date >= MB.join_date
)
SELECT
CUSTOMER_ID,
product_name,
join_date,
order_date FROM RNKS
WHERE RNK= 1;



-- Q7. Which item was purchased just before the customer became a member?
WITH RNKS AS (
SELECT MB.customer_id, M.product_name, MB.join_date, S.order_date,
RANK() OVER(partition by customer_id ORDER BY order_date) AS RNK,
ROW_NUMBER() OVER(partition by customer_id ORDER BY order_date) AS RWN
FROM members MB
JOIN sales S ON MB.customer_id = S.customer_id
JOIN menu M ON S.product_id = M.product_id
WHERE S.order_date < MB.join_date
)
SELECT
CUSTOMER_ID,
product_name,
join_date,
order_date FROM RNKS
WHERE RNK= 1;


-- Q8. What is the total items and amount spent for each member before they became a member?
SELECT MB.customer_id, MB.join_date, COUNT(s.product_id) AS total_items, 
SUM(M.price) AS total_amount_spent
FROM members MB
LEFT JOIN sales s ON MB.customer_id = s.customer_id
LEFT JOIN menu M ON s.product_id = M.product_id
WHERE s.order_date < MB.join_date OR s.order_date IS NULL
GROUP BY MB.customer_id, MB.join_date
ORDER BY MB.customer_id;

-- Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- - how many points would each customer have?
SELECT customer_id, 
SUM(CASE 
	WHEN M.product_name = 'sushi' THEN PRICE*10*2
	ELSE PRICE*10 
    END) AS total_points
FROM sales S
JOIN menu M ON S.product_id = M.product_id
GROUP BY customer_id;



