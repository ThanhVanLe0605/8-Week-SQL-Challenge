USE Pizza_Runner;

----------------------------------------------------
-- NHÓM 1: TUYỂN DỤNG VÀ NĂNG LỰC ĐỘI NGŨ GIAO HÀNG
----------------------------------------------------
-- B.1. How many runners signed up for each 1 week period?

SELECT @@DATEFIRST AS system_first_day_of_week; 
-- system_first_day_of_week; = 7 nghĩa là lấy ngày CN bắt đầu tuần mới 
-- - Trong Databricks SQL, tuần mặc định bắt đầu từ thứ Hai (Monday), còn mssql thì là Chủ nhật 


-- Trong phân tích dữ liệu trường hợp này, không tính tuần theo cách tính hệ thống 
-- mà sẽ lấy cụm 7 ngày là 1 tuần
-- tức là tính từ ngày đầu tiên của tháng được tính là ngày thứ 1 của tuần thứ 1, thứ của ngày này sẽ được làm mốc để tính ngày bắt đầu cho các tuần sau của tháng 
-- cứ hết 7 ngày sẽ bắt đầu tuần mới 
SELECT 
		-- Tính ngày bắt đầu của tuần 
		DATEADD(DAY, (DATEDIFF(DAY, '2021-01-01', registration_date) / 7) * 7, '2021-01-01') AS week_start_date,
		-- Đánh số tuần 
		(DATEDIFF(DAY, '2021-01-01', r.registration_date) / 7) + 1 AS registration_week,
		-- Đếm số lượng runner 
		COUNT(r.runner_id) AS total_runners_signed_up
FROM destination.runners r
GROUP BY 
		DATEADD(DAY, (DATEDIFF(DAY, '2021-01-01', registration_date) / 7) * 7, '2021-01-01'),
		(DATEDIFF(DAY, '2021-01-01', r.registration_date) / 7) + 1 
ORDER BY 
		registration_week


----------------------------------------------------
-- NHÓM 2: HIỆU SUẤT KHÂU BẾP VÀ ẢNH HƯỞNG ĐẾN GIAO HÀNG
----------------------------------------------------
-- B.2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- CÁCH VIẾT CƠ BẢN 

SELECT
		r.runner_id,
		AVG(DATEDIFF(MINUTE, o.order_time, r.pickup_time))	AS avg_pickup_minutes
FROM destination.orders o
INNER JOIN destination.runner_orders r ON o.order_id = r.order_id 
WHERE r.pickup_time IS NOT NULL 
GROUP BY r.runner_id 
 

-- CÁCH 2
-- VIẾT NÂNG CAO HƠN 
-- nên thêm một dấu chấm phẩy ngay sát trước chữ WITH để chặn đứng mọi lỗi tiềm ẩn từ các câu lệnh bên trên
;WITH PickupTime_CTE AS (
		SELECT
				r.runner_id,
				o.order_id,
				o.order_time ,
				r.pickup_time,
				-- Tính số phút chênh lệch cho từng đơn
				DATEDIFF(MINUTE, o.order_time, r.pickup_time) AS pickup_minutes
		FROM destination.orders o
		JOIN destination.runner_orders r ON o.order_id = r.order_id
		WHERE r.pickup_time IS NOT NULL 
			  AND r.cancellation IS NULL 
)
SELECT 
		p.runner_id ,
		ROUND(AVG(CAST(p.pickup_minutes AS FLOAT)),2) AS avg_pickup_minutes
FROM	PickupTime_CTE p
-- Có thể thêm điều kiện lọc nhiễu: WHERE pickup_minutes >= 0 (đề phòng lỗi log time ngược)
WHERE p.pickup_minutes >= 0
GROUP BY p.runner_id 
ORDER BY p.runner_id 


-- B.3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- Để tìm mối liên hệ giữa X (Số lượng Pizza) và Y (Thời gian chuẩn bị), ta bóc tách bài toán làm 3 chặng :
;WITH Chang01_TinhThoiGian AS (
	-- Thời gian chuẩn bị tính từ lúc nhận đơn đến lúc runner_id nhận bánh đi giao 
	SELECT
			r.runner_id,
			o.customer_id,
			o.order_id,
			o.order_time,
			r.pickup_time,
			DATEDIFF(MINUTE, o.order_time, r.pickup_time ) AS Time_for_Prepare 
	FROM destination.orders o
	INNER JOIN destination.runner_orders r ON o.order_id = r.order_id

	-- đây là dự án demo nhỏ, nên nếu cancellation thì pickup_time NULL nên không cần tính 
	-- nhưng nếu dữ liệu lớn hơn, thời gian chuẩn bị cho đơn hảng bị hủy phải xem xét là hủy lúc làm xong hay chưa, nhiều khi xong rồi mà do lỗi trong quy trình nên không giao 
	-- hay những vấn đề khác 
	WHERE r.cancellation IS NULL

)
, Chang02_DemSoLuongBanh AS (
    SELECT
			order_id,
			COUNT(pizza_id) AS count_pizzas 
	FROM destination.customer_orders
	GROUP BY order_id 
)
-- CHẶNG 3: Kết hợp 2 bảng nháp lại để tìm Insight
SELECT
		c2.count_pizzas AS [Quy mô đơn hàng (Số bánh)],
		COUNT(c1.order_id) AS [Tổng số đơn hàng], -- Đếm số lượng đơn để xem mẫu đủ lớn không
		ROUND(AVG(CAST(c1.Time_for_Prepare AS FLOAT)), 2) AS [Thời gian chuẩn bị trung bình (Phút)]
FROM	Chang01_TinhThoiGian c1
INNER JOIN Chang02_DemSoLuongBanh c2 ON c1.order_id = c2.order_id
-- Bước gom nhóm quyết định: Gom theo quy mô đơn hàng (1 bánh, 2 bánh, 3 bánh...)
GROUP BY c2.count_pizzas
ORDER BY c2.count_pizzas;




----------------------------------------------------
-- NHÓM 3: CHI PHÍ VÀ KHOẢNG CÁCH GIAO HÀNG
----------------------------------------------------
-- B.4. What was the average distance travelled for each customer?
SELECT
		o.customer_id,
		ROUND(AVG(CAST(r.distance AS FLOAT)),2) AS avg_distance_by_cust
FROM destination.orders o
INNER JOIN destination.runner_orders r ON o.order_id = r.order_id
WHERE r.cancellation IS NULL 
GROUP BY o.customer_id 
ORDER BY avg_distance_by_cust ASC


----------------------------------------------------
-- NHÓM 4: ĐỘ ỔN ĐINH VÀ CHẤT LƯỢNG GIAO HÀNG
----------------------------------------------------
-- B.5. What was the difference between the longest and shortest delivery times for all orders?
SELECT
		MAX(r.duration) AS the_longest_delivery_times,
		MIN(r.duration) AS the_shortest_delivery_times,
		MAX(r.duration) - MIN(r.duration) AS difference_time
FROM destination.runner_orders r
WHERE r.cancellation IS NULL 

 
----------------------------------------------------
-- NHÓM 5: HIỆU SUẤT CÁ NHÂN TỪNG RUNNER
----------------------------------------------------
-- B.6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT
		r.runner_id,
		r.order_id,
		ROUND(r.distance, 2) AS distance_km,
		r.duration AS duration_mins , 
		-- s = v * t => v = s/t = km/(míns : 60) = km/ h --> v = s * 60 / mins (km/h)
		ROUND((r.distance * 60.0  / r.duration ),2) AS avg_speed_for_each_runner_for_each_delivery 
FROM destination.runner_orders r
WHERE r.cancellation IS NULL 
ORDER BY r.runner_id ASC,
		 r.order_id ASC 
		  
-- B.7. What is the successful delivery percentage for each runner?
;WITH Runner_Stats AS (
    SELECT 
			r.runner_id,
			SUM(CASE WHEN r.cancellation IS NULL THEN 1 ELSE 0 END ) AS successful_delivery,
			SUM(CASE WHEN r.cancellation IS NOT NULL THEN 1 ELSE 0 END ) AS failed_delivery
	FROM destination.runner_orders r 
	GROUP BY r.runner_id 
)
SELECT 
    runner_id,
    successful_delivery,
    failed_delivery,
    -- Gọi tên 2 cột trên ra để ráp công thức tính % ở đây
	(successful_delivery * 100.0) / (successful_delivery + failed_delivery)  AS  successful_delivery_rate 
FROM Runner_Stats;
