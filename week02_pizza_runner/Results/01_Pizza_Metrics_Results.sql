
USE Pizza_Runner

----------------------------------------------------------------------
-- NHÓM 1: ĐO LƯỜNG TỔNG CẦU VÀ XU HƯỚNG HÀNH ĐỘNG
----------------------------------------------------------------------
-- A.1. How many pizzas were ordered?
SELECT 
		COUNT(pizza_id) AS total_pizzas_ordered
FROM destination.customer_orders 

-- A.2. How many unique customer orders were made?
SELECT 
	-- không cần UNIQUE vì mỗi dòng trong bảng orders là đại diện cho một đơn hàng được đặt 
	 COUNT(order_id) AS total_orders
FROM destination.orders

-- A.9. What was the total volume of pizzas ordered for each hour of the day?

;WITH AllHours AS (
	SELECT 0 AS hour_of_day 
	UNION ALL 
	SELECT hour_of_day + 1 FROM AllHours WHERE hour_of_day < 23
)
SELECT
		ah.hour_of_day,
		ISNULL(COUNT(c.pizza_id), 0) AS total_pizzas
FROM Allhours ah
LEFT JOIN	destination.orders o ON ah.hour_of_day = DATEPART(HOUR, o.order_time)
LEFT JOIN   destination.customer_orders c ON o.order_id = c.order_id
GROUP BY ah.hour_of_day
ORDER BY ah.hour_of_day

-- A.10. What was the volume of orders for each day of the week?
SELECT   
    DATENAME(WEEKDAY, o.order_time) AS day_of_week, 
    COUNT(1) AS total_orders 
FROM destination.orders o
GROUP BY 
    DATENAME(WEEKDAY, o.order_time), 
    DATEPART(WEEKDAY, o.order_time)  
ORDER BY 
    DATEPART(WEEKDAY, o.order_time) ASC;  

----------------------------------------------------------------------
-- NHÓM 2: CƠ CẤU SẢN PHẨM VÀ SỞ THÍCH KHÁCH HÀNG
----------------------------------------------------------------------
-- A.4. How many of each type of pizza was delivered ?
SELECT 
		c.pizza_id,
		COUNT(customer_orders_id) AS delivered_pizzas
FROM destination.runner_orders r
INNER JOIN destination.orders o ON r.order_id = o.order_id
INNER JOIN destination.customer_orders c ON r.order_id = c.order_id 
WHERE r.cancellation IS NULL
GROUP BY c.pizza_id

-- A.5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
		 o.customer_id,
		 p.pizza_name,
		 COUNT(c.customer_orders_id) AS ordered_pizzas
FROM destination.customer_orders c 
INNER JOIN destination.pizza_names p ON c.pizza_id = p.pizza_id
INNER JOIN destination.orders o ON c.order_id = o.order_id
GROUP BY  o.customer_id,
		  p.pizza_name
ORDER BY o.customer_id ASC

----------------------------------------------------------------------
-- NHÓM 3: MỨC ĐỘ TÙY CHỈNH VÀ HÀNH VI CÁ NHÂN
----------------------------------------------------------------------
-- A.7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

WITH DeliveredPizzas AS (
		SELECT  
				c.customer_orders_id,
				o.customer_id,
				c.order_id,
				c.pizza_id,
				ex.topping_id AS extras,
				ec.topping_id AS exclusions
		FROM destination.customer_orders c
		LEFT JOIN destination.orders o ON c.order_id = o.order_id
		LEFT JOIN destination.runner_orders r ON o.order_id = r.order_id
		LEFT JOIN destination.customer_orders_extras ex ON c.customer_orders_id = ex.customer_orders_id
		LEFT JOIN destination.customer_orders_exclusions ec ON c.customer_orders_id = ec.customer_orders_id
		WHERE r.cancellation IS NULL -- đây là điều kiện để lấy đơn hàng đã giao, không lấy những đơn hàng đã đặt nhưng chưa giao do bị hủy 
)
, Change_Or_Not_Changes AS (
SELECT 
	 d.customer_orders_id ,
	 d.customer_id,
	 d.order_id,
	 d.pizza_id,
	 -- Sử dụng MAX để kiểm tra: chỉ cần có 1 dòng extras/exclusions là cả pizza đó được tính là 'có thay đổi'
	 MAX(
	 CASE 
		WHEN (d.extras IS NOT NULL) OR (d.exclusions IS NOT NULL) THEN 1
		ELSE 0
	 END) AS has_change
FROM DeliveredPizzas d
GROUP BY d.customer_orders_id,
		 d.customer_id,
		 d.order_id,
		 d.pizza_id
)
SELECT
	     c.customer_id,
		 SUM(has_change) AS count_pizza_with_changes,
		 SUM(CASE WHEN has_change = 0 THEN 1 ELSE 0 END) AS count_pizza_no_changes
FROM Change_Or_Not_Changes c
GROUP BY c.customer_id
ORDER BY c.customer_id
 

-- CÁCH 2: CÓ TỒN TẠI HAY KHÔNG -> CASE WHEN + EXISTS 
WITH Change_pizzas AS(
SELECT 
	co.customer_orders_id,
	o.customer_id,
	o.order_id,
	co.pizza_id,
	-- Lấy customer_orders_id ở extras
	CASE
		WHEN EXISTS(SELECT ex.customer_orders_id FROM destination.customer_orders_extras ex WHERE ex.customer_orders_id = co.customer_orders_id) 
	-- Lấy customer_orders_id ở exclusions 
			OR EXISTS(SELECT ec.customer_orders_id FROM destination.customer_orders_exclusions ec WHERE ec.customer_orders_id = co.customer_orders_id) THEN 1
		ELSE 0
	END AS has_changed
FROM destination.customer_orders co
JOIN destination.orders o ON co.order_id = o.order_id
JOIN destination.runner_orders ro ON o.order_id = ro.order_id
WHERE ro.cancellation IS NULL
)
SELECT
		c.customer_id,
		SUM(c.has_changed) AS changed_pizzas,
		SUM(CASE WHEN c.has_changed = 0 THEN 1 ELSE 0 END) AS no_change
FROM Change_pizzas c
GROUP BY c.customer_id 
ORDER BY c.customer_id ASC


-- A.8. How many pizzas were delivered that had both exclusions and extras?
 -- Câu này sẽ dùng 1 phần câu 7 

-- CÁCH 1
-- nhưng đổi 1 chút ở case when 

WITH DeliveredPizzas AS (
		SELECT  
				c.customer_orders_id,
				o.customer_id,
				c.order_id,
				c.pizza_id,
				ex.topping_id AS extras,
				ec.topping_id AS exclusions
		FROM destination.customer_orders c
		LEFT JOIN destination.orders o ON c.order_id = o.order_id
		LEFT JOIN destination.runner_orders r ON o.order_id = r.order_id
		LEFT JOIN destination.customer_orders_extras ex ON c.customer_orders_id = ex.customer_orders_id
		LEFT JOIN destination.customer_orders_exclusions ec ON c.customer_orders_id = ec.customer_orders_id
		WHERE r.cancellation IS NULL -- đây là điều kiện để lấy đơn hàng đã giao, không lấy những đơn hàng đã đặt nhưng chưa giao do bị hủy 
)
, Change_Both AS (
SELECT 
	 d.customer_orders_id ,
	 d.customer_id,
	 d.order_id,
	 d.pizza_id,
	 -- Sử dụng MAX để kiểm tra: chỉ cần có 1 dòng extras/exclusions là cả pizza đó được tính là 'có thay đổi'
	 MAX(CASE 
		WHEN (d.extras IS NOT NULL) AND (d.exclusions IS NOT NULL) THEN 1
		ELSE 0
	 END) AS has_change_both 
FROM DeliveredPizzas d
GROUP BY d.customer_orders_id,
		 d.customer_id,
		 d.order_id,
		 d.pizza_id
)
SELECT 
		COUNT(b.customer_orders_id) AS count_pizzas_that_has_both_exclu_extras
FROM Change_Both b
WHERE b.has_change_both = 1

-- CÁCH 2: CÓ TỒN TẠI CẢ EXTRAS VÀ EXCLUSIONS HAY KHÔNG -> CASE WHEN + EXISTS 
WITH Change_pizzas AS(
		SELECT 
			co.customer_orders_id,
			o.customer_id,
			o.order_id,
			co.pizza_id,
			-- Lấy customer_orders_id ở extras
			CASE
				WHEN EXISTS(SELECT ex.customer_orders_id FROM destination.customer_orders_extras ex WHERE ex.customer_orders_id = co.customer_orders_id) 
			-- Lấy customer_orders_id ở exclusions 
					AND EXISTS(SELECT ec.customer_orders_id FROM destination.customer_orders_exclusions ec WHERE ec.customer_orders_id = co.customer_orders_id) THEN 1
				ELSE 0
			END AS has_both_changed
		FROM destination.customer_orders co
		JOIN destination.orders o ON co.order_id = o.order_id
		JOIN destination.runner_orders ro ON o.order_id = ro.order_id
		WHERE ro.cancellation IS NULL
)
SELECT
		c.customer_orders_id,
		-- HOW MANY -> DÙNG COUNT 
		COUNT(c.has_both_changed) AS has_both_changed
FROM Change_pizzas c
WHERE c.has_both_changed = 1
GROUP BY c.customer_orders_id

-- CÁCH 3: 
SELECT 
    COUNT(co.customer_orders_id) AS count_pizzas_both_changed
FROM destination.customer_orders co
JOIN destination.orders o ON co.order_id = o.order_id
JOIN destination.runner_orders ro ON o.order_id = ro.order_id
WHERE ro.cancellation IS NULL -- Chỉ lấy đơn đã giao
  AND EXISTS (SELECT 1 FROM destination.customer_orders_extras ex 
              WHERE ex.customer_orders_id = co.customer_orders_id) -- Có Extras
  AND EXISTS (SELECT 1 FROM destination.customer_orders_exclusions ec 
              WHERE ec.customer_orders_id = co.customer_orders_id); -- Và có Exclusions
 

----------------------------------------------------------------------
-- NHÓM 4: NĂNG LỰC PHỤC VỤ VÀ CHẤT LƯỢNG GIAO HÀNG
----------------------------------------------------------------------
-- A.6. What was the maximum number of pizzas delivered in a single order?

-- CÁCH 1
WITH DeliveredOrders AS (
	-- Bước 1: Chỉ lấy các đơn hàng đã giao thành công và đếm số lượng pizza
	SELECT 
			c.order_id,
			COUNT(c.pizza_id) AS pizza_count 
	FROM destination.customer_orders c
	INNER JOIN destination.runner_orders r ON c.order_id = r.order_id
	WHERE r.cancellation IS NULL -- không lấy những đơn hàng bị hủy 
	GROUP BY c.order_id
),
RankedOrders AS(
	-- Bước 2: Xếp hạng các đơn hàng dựa trên số lượng pizza
	SELECT 
		  order_id,
		  pizza_count,
		  -- DÙNG DENSE_RANK vì cho phép đồng hạng 
		  DENSE_RANK() OVER(ORDER BY pizza_count DESC) AS rank_num
	FROM  DeliveredOrders
)
-- Bước 3: Chỉ lấy ra đơn hàng top 1
SELECT
		order_id,
		pizza_count AS max_pizzas_delivered 
FROM RankedOrders
WHERE rank_num = 1



-- CÁCH 2

-- CÓ THỂ DÙNG TOP 1 WITH TIES ĐỂ CODE GỌN HƠN
SELECT TOP 1 WITH TIES
    c.order_id,
    COUNT(c.pizza_id) AS max_pizzas_delivered
FROM destination.customer_orders c
INNER JOIN destination.runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.order_id
ORDER BY COUNT(c.pizza_id) DESC;

-- A.3. How many successful orders were delivered by each runner?

SELECT 
    runner_id,
    COUNT(order_id) AS successful_orders
FROM destination.runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;
----------------------------------------------------------------------




