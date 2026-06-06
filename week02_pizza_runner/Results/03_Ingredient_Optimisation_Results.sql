USE Pizza_Runner;

----------------------------------------------------
-- NHÓM 1: CƠ HỘI TĂNG DOANH THU TỪ TOPPING (UPSELL)
----------------------------------------------------
-- C.1. What was the most commonly added extra?
WITH extras_of_pizza_in_each_order AS (
	SELECT 
			c.order_id,
			c.pizza_id, 
			ex.topping_id AS extras
	FROM destination.customer_orders c
	INNER JOIN destination.customer_orders_extras ex ON c.customer_orders_id = ex.customer_orders_id 
)
, used_extras AS (
	SELECT
		    e.extras ,
			COUNT(e.pizza_id) AS numbers
	FROM extras_of_pizza_in_each_order e
	GROUP BY e.extras 
	-- TRONG CTE, không cho ORDER BY ngoại trừ việc dùng kèm với TOP, OFFSET ,...
)
, rank_extras AS (
	SELECT 
		u.extras,
		u.numbers,
		DENSE_RANK() OVER(ORDER BY u.numbers DESC) AS rank_used_numbers_of_extras
	FROM used_extras u
)
SELECT *
FROM rank_extras
WHERE rank_used_numbers_of_extras = 1
-- NGHĨA LÀ BACON là topping được thêm nhiều nhất 

-- Nhưng cách làm này rườm rà và mù ý nghĩa report do extras chỉ là số id trong hệ thống chứ không phải tên BACON


-- CÁCH 2:
SELECT TOP 1 WITH TIES 
		t.topping_name AS most_common_extra, 
        COUNT(t.topping_id) AS total_added_times
FROM destination.customer_orders_extras ex
INNER JOIN destination.pizza_toppings t ON ex.topping_id = t.topping_id 
GROUP BY t.topping_name 
ORDER BY total_added_times DESC

----------------------------------------------------
-- NHÓM 2: CẮT GIẢM LÃNG PHÍ NGUYÊN
----------------------------------------------------
-- C.2. What was the most common exclusion?

SELECT TOP 1 WITH TIES
		t.topping_name most_common_exclusions, 
		COUNT(t.topping_id) AS total_excluded_times
FROM	destination.customer_orders_exclusions ex
INNER JOIN destination.pizza_toppings t ON ex.topping_id = t.topping_id
GROUP BY t.topping_name
ORDER BY total_excluded_times DESC


----------------------------------------------------
-- NHÓM 3: CHUẨN HÓA HIỆN THỊ ĐƠN HÀNG CHO NHÀ BẾP
----------------------------------------------------
-- C.3. What are the standard ingredients for each pizza?
-- Vì dữ liệu đã được chuẩn hóa trước khi đưa vào destination nên chỉ cần viết câu lệnh select chứ không cần xử lý chuỗi nữa

SELECT 
		n.pizza_name,
		t.topping_name
FROM destination.pizza_recipes p
INNER JOIN destination.pizza_names n ON p.pizza_id = n.pizza_id
INNER JOIN destination.pizza_toppings t ON p.toppings = t.topping_id
ORDER BY n.pizza_name ASC,
		 t.topping_name ASC
-- KQ:
-- pizza_id = 1 có toppings: 1, 2, 3, 4, 5, 6, 8, 10 
-- pizza_id = 2 có toppings: 4, 6, 7, 9, 11, 12 
  
-- Nghĩa là: 
-- Meatlovers có topping là : Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
-- Vegetarian có topping là : Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce
  


-- C.4.
/*

Generate an order item for each record in the customers_orders table in the format of one of the following:

	"Meat Lovers"

	"Meat Lovers - Exclude Beef"

	"Meat Lovers - Extra Bacon"

	"Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers"
*/

-- Để giải quyết bài toán này, tôi sẽ chia làm 3 chặng: 
-- Chặng 01: Xử lý topping bỏ đi (exclusions)
-- Chặng 02: Xử lý topping thêm vào (extras)
-- Chặng 03: Tổng hợp lại
---- Nếu ở bước xử lý dữ liệu, chuẩn hóa vào destination ta đã STRING_SPLIT để xử lý vấn đề đa trị, nhưng khi làm báo cáo 
---- cần tổng hợp lại, thì dùng STRING_AGG 
----  LEFT JOIN , lấy orders ở customer_orders rồi LEFT JOIN vs exclusions, extras. Lý do là vì để giữ lại những pizza khách đặt mà không thựuc hiện tùy chỉnh 

-- Chặng 01: Xử lý topping bỏ đi (exclusions)
WITH ExclusionsCTE AS (
		SELECT
				exc.customer_orders_id ,
				'Exclude ' + STRING_AGG(p.topping_name, ', ') AS exclusiion_text 
		FROM  destination.customer_orders_exclusions exc
		INNER JOIN destination.pizza_toppings p ON exc.topping_id = p.topping_id 
		-- Mức độ chi tiết của bảng là mỗi hàng là một cái bánh pizza 
		GROUP BY exc.customer_orders_id 
), 
-- Chặng 02: Xử lý topping thêm vào (extras)
ExtrasCTE AS (
		SELECT 
				ext.customer_orders_id,
				'Extra ' + STRING_AGG(p.topping_name, ', ') AS extra_text
		FROM destination.customer_orders_extras ext 
		INNER JOIN destination.pizza_toppings p ON ext.topping_id = p.topping_id  
		GROUP BY ext.customer_orders_id

)
-- Chặng 03: Tổng hợp lại
SELECT
		co.customer_orders_id,
		co.order_id,
		pn.pizza_name + 
		ISNULL(' - ' + exc.exclusiion_text, '') +
		ISNULL(' - ' + ext.extra_text, '') AS order_item
FROM destination.customer_orders co
JOIN destination.pizza_names pn ON co.pizza_id = pn.pizza_id
LEFT JOIN ExclusionsCTE exc	ON co.customer_orders_id = exc.customer_orders_id
LEFT JOIN ExtrasCTE ext ON co.customer_orders_id = ext.customer_orders_id 


-- C.5.
/*
Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients

(e.g. "Meat Lovers: 2xBacon, Beef, ... , Salami")

*/


;WITH total_available_toppings AS(
	SELECT 
			 co.order_id , 
			 co.customer_orders_id , 
			 co.pizza_id ,
			 tp.topping_id AS total_topping_id,
			 tp.topping_name
	FROM destination.customer_orders co
	CROSS JOIN destination.pizza_toppings tp
), specific_toppings_for_pizza AS (
	SELECT 
			tap.order_id,
			tap.customer_orders_id,
			tap.pizza_id,
			tap.total_topping_id,
			tap.topping_name,
			rp.toppings AS topping_id_for_specific_pizza,
			CASE
				WHEN rp.toppings IS NOT NULL THEN 1
				ELSE 0
			END AS base_topping,
			extras.topping_id AS extras_topping_id_for_specific_pizza,
			CASE
				WHEN extras.topping_id IS NOT NULL THEN 1
				ELSE 0
			END AS count_extras_tp,
			exclusions.topping_id AS exclusions_topping_id_for_specific_pizza,
			CASE
				WHEN exclusions.topping_id IS NOT NULL THEN 1
				ELSE 0
			END AS count_exclusion_tp
	FROM total_available_toppings tap 
	LEFT JOIN destination.pizza_recipes rp ON ( tap.pizza_id = rp.pizza_id )
										   AND (tap.total_topping_id = rp.toppings) 
	LEFT JOIN destination.customer_orders_extras extras ON  ( tap.customer_orders_id = extras.customer_orders_id )
														AND	(tap.total_topping_id = extras.topping_id)
	LEFT JOIN destination.customer_orders_exclusions exclusions ON  ( tap.customer_orders_id = exclusions.customer_orders_id )
														AND	(tap.total_topping_id = exclusions.topping_id)
)
, final_CTE AS (
	SELECT 
			s.order_id,
			s.customer_orders_id,
			s.pizza_id,
			s.total_topping_id,
			s.topping_id_for_specific_pizza,
			s.base_topping,
			s.extras_topping_id_for_specific_pizza,
			s.count_extras_tp,
			s.exclusions_topping_id_for_specific_pizza,
			s.count_exclusion_tp,
			(s.base_topping + s.count_extras_tp - s.count_exclusion_tp) AS final_count,
			s.topping_name
	FROM specific_toppings_for_pizza s
) 
SELECT
			f.order_id,
			f.customer_orders_id,
			-- Nguyên liệu làm từng chiếc bánh trong mỗi đơn hàng 
			STRING_AGG(
			-- Nếu ở tiền xử lý dùng STRING_SPLIT để giải quyết đa trị
			-- Còn để trình bày dashboard đệp, thì dùng STRING_AGG(), AGG trong aggregate, là từ nhiều hàng thành 1 
			CASE
				-- Nếu hệ số là 1, thì chỉ ghi topping_name, không cần ghi hệ số trước
				-- Còn nêú > 1 , ví dụ như 2, 3 thì chuyển 2, 3 thành VARCHAR rồi nối với 'x' 
				-- sql xuống WHERE rồi lên SELECT là sau cùng, nên trường hợp final_count = 0 đến đây không còn nữa 
				WHEN f.final_count > 1 THEN CAST(f.final_count AS NVARCHAR ) + 'x' + f.topping_name
				ELSE f.topping_name
			END ,
			-- những hàng thành 1 hàng được nối với nhau bằng dấu cộng thể hiện cách ghi công thức cho từng cái bánh được đặt đẹp 
			'+ '
			) WITHIN GROUP (ORDER BY f.topping_name ASC) 
			-- Để cho thứ tự xuất hiện công thức của từng chiếc bánh đồng nhất 
			AS specific_recipe_for_each_pizza
FROM final_CTE f
INNER JOIN destination.pizza_names pn ON f.pizza_id = pn.pizza_id 
-- Nếu hệ số là 0, không ghi vào công thức của mỗi chiếc bánh  (có thể được tinh chỉnh bởi khách)
WHERE f.final_count > 0
GROUP BY 
		f.order_id, 
		f.customer_orders_id  
ORDER BY f.order_id ASC, 
		 f.customer_orders_id ASC

----------------------------------------------------
-- NHÓM 4: TÍNH GIÁ VỐN HÀNG BÁN THỰC TẾ
----------------------------------------------------
-- C.6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
;WITH total_available_toppings AS(
	SELECT 
			 co.order_id , 
			 co.customer_orders_id , 
			 co.pizza_id ,
			 tp.topping_id AS total_topping_id,
			 tp.topping_name
	FROM destination.customer_orders co
	CROSS JOIN destination.pizza_toppings tp
), specific_toppings_for_pizza AS (
	SELECT 
			tap.order_id,
			tap.customer_orders_id,
			tap.pizza_id,
			tap.total_topping_id,
			tap.topping_name,
			rp.toppings AS topping_id_for_specific_pizza,
			CASE
				WHEN rp.toppings IS NOT NULL THEN 1
				ELSE 0
			END AS base_topping,
			extras.topping_id AS extras_topping_id_for_specific_pizza,
			CASE
				WHEN extras.topping_id IS NOT NULL THEN 1
				ELSE 0
			END AS count_extras_tp,
			exclusions.topping_id AS exclusions_topping_id_for_specific_pizza,
			CASE
				WHEN exclusions.topping_id IS NOT NULL THEN 1
				ELSE 0
			END AS count_exclusion_tp
	FROM total_available_toppings tap 
	LEFT JOIN destination.pizza_recipes rp ON ( tap.pizza_id = rp.pizza_id )
										   AND (tap.total_topping_id = rp.toppings) 
	LEFT JOIN destination.customer_orders_extras extras ON  ( tap.customer_orders_id = extras.customer_orders_id )
														AND	(tap.total_topping_id = extras.topping_id)
	LEFT JOIN destination.customer_orders_exclusions exclusions ON  ( tap.customer_orders_id = exclusions.customer_orders_id )
														AND	(tap.total_topping_id = exclusions.topping_id)
)
, final_CTE AS (
	SELECT 
			s.order_id,
			s.customer_orders_id,
			s.pizza_id,
			s.total_topping_id,
			s.topping_id_for_specific_pizza,
			s.base_topping,
			s.extras_topping_id_for_specific_pizza,
			s.count_extras_tp,
			s.exclusions_topping_id_for_specific_pizza,
			s.count_exclusion_tp,
			(s.base_topping + s.count_extras_tp - s.count_exclusion_tp) AS final_count,
			s.topping_name
	FROM specific_toppings_for_pizza s
) 
SELECT  
		f.topping_name,
		SUM(f.final_count) AS used_quantiies
FROM	final_CTE f
INNER JOIN destination.runner_orders ro ON f.order_id = ro.order_id
WHERE ro.cancellation IS NULL 
GROUP BY f.topping_name
ORDER BY used_quantiies DESC


----------------------------------------------------
-- TỐI ƯU C.5, C.6 BẰNG CÁCH TẠO VIEW 
----------------------------------------------------

-- ĐỂ TRÁNH VIỆC CÂU 5, 6 PHẢI PASTE LẠI MỘT PHẦN CTE KHÁ DÀI, TẠO VIEW CHUNG RỒI TRUY VẤN TỪ VIEW ĐÓ 
CREATE VIEW destination.vw_pizza_ingredient_matrix AS 
WITH total_available_toppings AS(
	SELECT 
			 co.order_id , 
			 co.customer_orders_id , 
			 co.pizza_id ,
			 tp.topping_id AS total_topping_id,
			 tp.topping_name
	FROM destination.customer_orders co
	CROSS JOIN destination.pizza_toppings tp
), specific_toppings_for_pizza AS (
	SELECT 
			tap.order_id,
			tap.customer_orders_id,
			tap.pizza_id,
			tap.total_topping_id,
			tap.topping_name,
			rp.toppings AS topping_id_for_specific_pizza,
			CASE
				WHEN rp.toppings IS NOT NULL THEN 1
				ELSE 0
			END AS base_topping,
			extras.topping_id AS extras_topping_id_for_specific_pizza,
			CASE
				WHEN extras.topping_id IS NOT NULL THEN 1
				ELSE 0
			END AS count_extras_tp,
			exclusions.topping_id AS exclusions_topping_id_for_specific_pizza,
			CASE
				WHEN exclusions.topping_id IS NOT NULL THEN 1
				ELSE 0
			END AS count_exclusion_tp
	FROM total_available_toppings tap 
	LEFT JOIN destination.pizza_recipes rp ON ( tap.pizza_id = rp.pizza_id )
										   AND (tap.total_topping_id = rp.toppings) 
	LEFT JOIN destination.customer_orders_extras extras ON  ( tap.customer_orders_id = extras.customer_orders_id )
														AND	(tap.total_topping_id = extras.topping_id)
	LEFT JOIN destination.customer_orders_exclusions exclusions ON  ( tap.customer_orders_id = exclusions.customer_orders_id )
														AND	(tap.total_topping_id = exclusions.topping_id)
) 
SELECT 
		s.order_id,
		s.customer_orders_id,
		s.pizza_id,
		s.total_topping_id,
		s.topping_id_for_specific_pizza,
		s.base_topping,
		s.extras_topping_id_for_specific_pizza,
		s.count_extras_tp,
		s.exclusions_topping_id_for_specific_pizza,
		s.count_exclusion_tp,
		(s.base_topping + s.count_extras_tp - s.count_exclusion_tp) AS final_count,
		s.topping_name
FROM specific_toppings_for_pizza s


-- CÂU 5
SELECT
			f.order_id,
			f.customer_orders_id,
			-- Nguyên liệu làm từng chiếc bánh trong mỗi đơn hàng 
			STRING_AGG(
			-- Nếu ở tiền xử lý dùng STRING_SPLIT để giải quyết đa trị
			-- Còn để trình bày dashboard đệp, thì dùng STRING_AGG(), AGG trong aggregate, là từ nhiều hàng thành 1 
			CASE
				-- Nếu hệ số là 1, thì chỉ ghi topping_name, không cần ghi hệ số trước
				-- Còn nêú > 1 , ví dụ như 2, 3 thì chuyển 2, 3 thành VARCHAR rồi nối với 'x' 
				-- sql xuống WHERE rồi lên SELECT là sau cùng, nên trường hợp final_count = 0 đến đây không còn nữa 
				WHEN f.final_count > 1 THEN CAST(f.final_count AS NVARCHAR ) + 'x' + f.topping_name
				ELSE f.topping_name
			END ,
			-- những hàng thành 1 hàng được nối với nhau bằng dấu cộng thể hiện cách ghi công thức cho từng cái bánh được đặt đẹp 
			'+ '
			) WITHIN GROUP (ORDER BY f.topping_name ASC) 
			-- Để cho thứ tự xuất hiện công thức của từng chiếc bánh đồng nhất 
			AS specific_recipe_for_each_pizza
FROM destination.vw_pizza_ingredient_matrix f
INNER JOIN destination.pizza_names pn ON f.pizza_id = pn.pizza_id 
-- Nếu hệ số là 0, không ghi vào công thức của mỗi chiếc bánh  (có thể được tinh chỉnh bởi khách)
WHERE f.final_count > 0
GROUP BY 
		f.order_id, 
		f.customer_orders_id  
ORDER BY f.order_id ASC, 
		 f.customer_orders_id ASC



-- CÂU 6
SELECT  
		f.topping_name,
		SUM(f.final_count) AS used_quantiies
FROM	destination.vw_pizza_ingredient_matrix f
INNER JOIN destination.runner_orders ro ON f.order_id = ro.order_id
WHERE ro.cancellation IS NULL 
GROUP BY f.topping_name
ORDER BY used_quantiies DESC