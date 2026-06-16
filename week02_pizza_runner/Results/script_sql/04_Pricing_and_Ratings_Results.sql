USE pizza_runner;

-------------------------------------------
-- NHÓM 1: ĐÁNH GIÁ HIỆU QUẢ MÔ HÌNH ĐỊNH GIÁ HIỆN TẠI
-------------------------------------------
-- D.1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 
-- and there were no charges for changes 
-- how much money has Pizza Runner made so far if there are no delivery fees?

WITH money_each_pizza_in_delivered_orders AS(
		SELECT
				co.order_id, 
				co.pizza_id,
				pn.pizza_name,
				co.customer_orders_id, 
				CASE
					WHEN co.pizza_id = 1 THEN 12
					ELSE 10
				END AS money_for_pizza
		FROM destination.customer_orders co
		JOIN destination.pizza_names pn ON co.pizza_id = pn.pizza_id
		WHERE co.order_id NOT IN (SELECT ro.order_id FROM destination.runner_orders ro WHERE ro.cancellation IS NOT NULL)
		GROUP BY co.order_id,  
				 co.pizza_id,
				 pn.pizza_name,
				 co.customer_orders_id
--		ORDER BY co.order_id ASC,
--				 co.pizza_id ASC,
--				 co.customer_orders_id ASC
), 	 total_money_for_specific_pizza  AS(
SELECT
		t.pizza_name,
		SUM(t.money_for_pizza) AS total_money_for_specific_pizza 
FROM money_each_pizza_in_delivered_orders t
GROUP BY t.pizza_name
)
SELECT
		SUM(total_money_for_specific_pizza) AS total_money
FROM total_money_for_specific_pizza t


-------------------------------------------
-- NHÓM 2: ĐO LƯỜNG TIỀM NĂNG TỪ PHÍ TOPPING THÊM
-------------------------------------------
-- D.2. What if there was an additional $1 charge for any pizza extras?
---- Add cheese is $1 extra
;WITH pre_data AS (
		SELECT
				v.order_id,
				v.pizza_id,
				v.customer_orders_id,
				v.total_topping_id,
				v.topping_id_for_specific_pizza,
				v.extras_topping_id_for_specific_pizza ,
				CASE
					WHEN v.extras_topping_id_for_specific_pizza IS NULL THEN 0
					ELSE 1
				END AS extra_money_for_extra_topping 
		FROM destination.vw_pizza_ingredient_matrix v
--		ORDER BY 
--				v.order_id,
--				v.pizza_id,
--				v.customer_orders_id,
--				v.total_topping_id,
--				v.topping_id_for_specific_pizza
)
, pre_calculate AS (
		SELECT 
				p.order_id,
				 p.customer_orders_id,
				 p.pizza_id,
				 CASE
					WHEN p.pizza_id = 1 THEN 12
					ELSE 10
				END AS money_for_pizza,
				SUM(p.extra_money_for_extra_topping) AS extra_money_for_extra_topping
		FROM	pre_data p
		WHERE	p.order_id NOT IN (SELECT ro.order_id FROM destination.runner_orders ro WHERE ro.cancellation IS NOT NULL)
		GROUP BY p.order_id,
				 p.customer_orders_id,
				 p.pizza_id 
--		ORDER BY 
--				 p.order_id,
--				 p.customer_orders_id,
--				 p.pizza_id
)
SELECT 
	  SUM(p.money_for_pizza + p.extra_money_for_extra_topping) AS total_money
FROM pre_calculate p
-------------------------------------------
-- NHÓM 3: XÂY DỰNG HỆ THỐNG PHẢN HỒI VÀ ĐÁNH GIÁ CHẤT LƯỢNG
-------------------------------------------
-- D.3.

/*

The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner

how would you design an additional table for this new dataset

generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

*/

CREATE TABLE destination.runner_ratings (
		rating_id		INT IDENTITY(1,1) PRIMARY KEY,
		order_id		INT NOT NULL FOREIGN KEY REFERENCES destination.runner_orders(order_id),
		rating			INT NOT NULL CONSTRAINT CHK_Rating_Range CHECK (rating BETWEEN 1 AND 5),
		comment			NVARCHAR(255) NULL,
		-- Thêm DEFAULT để hệ thống tự động bắt thời gian nếu khách bấm gửi mà không truyền giờ
		rating_time		DATETIME DEFAULT GETDATE()
)

-- 2 Tạo dữ liệu giả 
INSERT INTO destination.runner_ratings (order_id, rating, comment)
VALUES 
    (1, 5, N'Giao hàng siêu nhanh, bánh còn nóng hổi!'),
    (2, 4, N'Anh shipper thân thiện, lịch sự.'),
    (3, 3, N'Giao hơi muộn một chút nhưng thái độ tốt.'),
    (4, 1, N'Bánh đến nơi bị xô lệch, shipper không cẩn thận!'),
    (5, 5, N'Tuyệt vời, không có gì để chê.'),
    (7, 4, NULL), -- Khách lười không viết bình luận, hệ thống vẫn chấp nhận
    (8, 5, N'Tài xế đi xe rất cẩn thận.'),
    (10, 5, N'Dịch vụ xuất sắc!');



-- D.4.
/*
Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?

	customer_id
	order_id
	runner_id
	rating
	order_time
	pickup_time
	Time between order and pickup
	Delivery duration
	Average speed
	Total number of pizzas

*/

CREATE VIEW destination.vw_efficiency_for_each_order AS
WITH pre_data AS (
		SELECT 
				-- Nhóm đơn hàng 
				o.order_id,
				o.customer_id,
				o.order_time,

				-- Nhóm giao vận 
				ro.runner_order_id,
				ro.runner_id,
				ro.pickup_time,
				ro.distance,
				ro.duration,
				ro.cancellation,

				-- Nhóm chất lượng dịch vụ 
				rr.rating_id,
				rr.rating,
				rr.comment,
				rr.rating_time
		-- orders có order_id từ 1 đến 10
		FROM  destination.orders o 
		-- runner_orders ro có order_id từ 1 đến 10 NÊN dùng JOIN vẫn còn order_id từ 1 -> 10 
		JOIN destination.runner_orders ro	ON o.order_id = ro.order_id 
		-- runner_ratings thiếu order_id = 6 và 9 cũng là những đơn hàng bị hủy và không giao , nên muốn giữ từ 1-> 10 thì phải LEFT JOIN 
		LEFT JOIN destination.runner_ratings rr ON ro.order_id = rr.order_id 
-- ORDER BY o.order_id ASC 
),
count_number_of_pizza_in_each_order AS (
		SELECT
				co.order_id ,
				COUNT(co.customer_orders_id) AS number_of_pizzas
		FROM destination.customer_orders co
		GROUP BY co.order_id 
)
SELECT
		p.customer_id,
		p.order_id,
		c.number_of_pizzas,
		p.runner_id,
		p.rating,
		p.order_time,
		p.pickup_time,
		p.distance,

		-- Thời gian từ lúc đặt hàng order_time đến lúc shipper nhận hàng đi giao (phút)
		DATEDIFF(MINUTE, p.order_time, p.pickup_time) AS preparation_time,
		-- Thời gian giao hàng 
		p.duration,
		-- Tốc độ trung bình của runner
		-- v = s/t = s860/ t (km/h)
		ROUND((p.distance * 60.0 ) / p.duration ,2) AS speed
		-- Tổng pizza giao 
FROM pre_data p 
JOIN count_number_of_pizza_in_each_order c ON p.order_id = c.order_id


SELECT *
FROM destination.vw_efficiency_for_each_order


-- Average speed for each runner
SELECT
		v.runner_id,
		AVG(v.speed) AS avg_speed_for_each_runner 
FROM destination.vw_efficiency_for_each_order v
GROUP BY v.runner_id
ORDER BY avg_speed_for_each_runner DESC
-------------------------------------------
-- NHÓM 4: TÍNH TOÁN LỢI NHUẬN RÒNG SAU CHI PHÍ VẬN HÀNH
-------------------------------------------
-- D.5.
-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices 
-- with no cost for extras and each runner is paid $0.30 per kilometre traveled 
-- how much money does Pizza Runner have left over after these deliveries?
;WITH pre_data AS(
		SELECT 
				i.order_id, 
				i.customer_orders_id,
				i.pizza_id,
				CASE 
					WHEN i.order_id IN (SELECT ro.order_id FROM destination.runner_orders ro WHERE ro.cancellation IS NOT NULL ) THEN 0
					ELSE 
						CASE
							WHEN i.pizza_id = 1 THEN 12 
							ELSE 10
						END
				END AS money_for_each_pizza
		FROM destination.vw_pizza_ingredient_matrix i
		GROUP BY i.order_id,
				 i.customer_orders_id,
				 i.pizza_id
--		ORDER BY i.order_id ASC, 
--				 i.customer_orders_id ASC,
--				 i.pizza_id ASC
), money_for_each_order AS (
		SELECT 
				p.order_id,
				SUM(p.money_for_each_pizza) AS money_for_each_order
		FROM	pre_data p
		GROUP BY p.order_id
), ship_fee AS ( 
		SELECT  
			   v.order_id,
			   ISNULL((v.distance * 0.3),0) AS ship_fee
		FROM destination.vw_efficiency_for_each_order v
)
SELECT 
		s.order_id,
		m.money_for_each_order,
		s.ship_fee,
		(m.money_for_each_order - s.ship_fee) AS net_profit_for_Danny
FROM money_for_each_order m
JOIN ship_fee s ON m.order_id = s.order_id


 


