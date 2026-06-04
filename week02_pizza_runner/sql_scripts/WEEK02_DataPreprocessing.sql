
-- PHẦN 1: CÁC VẤN ĐỀ TRONG DỮ LIỆU HIỆN CÓ 
---------------------------------------------------
-- PHẦN 1.1: ĐỔ DỮ LIỆU THÔ VÀO VÙNG TẠM (STAGING) 
---------------------------------------------------
-- PHẦN 1.1.1: TẠO BẢNG TẠM
CREATE DATABASE Pizza_Runner;
USE Pizza_Runner;


-- Tạo schema (chạy riêng lần lượt)
CREATE SCHEMA staging;
CREATE SCHEMA destination;

-- Tạo bảng tạm runners
CREATE TABLE [staging].runners (
		runner_id				INT,
		registration_date		DATE
)

-- Tạo bảng tạm customer_orders
CREATE TABLE [staging].customer_orders(
		order_id INT,
		customer_id INT,
		pizza_id INT,
		exclusions VARCHAR(4),
		extras VARCHAR(4),
		order_time DATETIME 
)

-- Tạo bảng tạm runner_orders
CREATE TABLE [staging].runner_orders (
		order_id INT,
		runner_id INT,
		pickup_time VARCHAR(19),
		distance VARCHAR(7),
		duration VARCHAR(10),
		cancellation VARCHAR(23)
)

-- Tạo bảng tạm pizza_names 
CREATE TABLE [staging].pizza_names (
		pizza_id INT,
		pizza_name NVARCHAR(50)
)

-- Tạo bảng tạm pizza_recipes
CREATE TABLE [staging].pizza_recipes (
		pizza_id INT,
		toppings NVARCHAR(50)
)

-- Tạo bảng tạm pizza_toppings
CREATE TABLE [staging].pizza_toppings (
		topping_id INT,
		topping_name NVARCHAR(50)
)


---------------------------------------------------
-- PHẦN 1.1.2: INSERT DỮ LIỆU VÀO CÁC BẢNG TẠM
-- Insert dữ liệu vào bảng tạm runners 
INSERT INTO staging.runners 
			(runner_id, registration_date)
VALUES 
			(1, '2021-01-01'),
			(2, '2021-01-03'),
			(3, '2021-01-08'),
			(4, '2021-01-15');

-- Insert dữ liệu vào bảng tạm customer_orders
INSERT INTO [staging].customer_orders
			(order_id ,customer_id ,pizza_id, exclusions, extras, order_time)
VALUES
			('1', '101', '1', '', '', '2020-01-01 18:05:02'),
			('2', '101', '1', '', '', '2020-01-01 19:00:52'),
			('3', '102', '1', '', '', '2020-01-02 23:51:23'),
			('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
			('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
			('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
			('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
			('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
			('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
			('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
			('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
			('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
			('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
			('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

-- Insert dữ liệu vào bảng tạm runner_orders
INSERT INTO  [staging].runner_orders 
			( order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES 
			('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
			('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
			('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
			('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
			('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
			('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
			('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
			('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
			('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
			('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


-- Insert dữ liệu vào bảng tạm runners 
INSERT INTO [staging].pizza_names 
			(pizza_id ,pizza_name)
VALUES 
			(1, 'Meatlovers'),
			(2, 'Vegetarian');

-- Insert dữ liệu vào bảng tạm pizza_recipes 
INSERT INTO   [staging].pizza_recipes 
			  (pizza_id, toppings)
VALUES		  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
			  (2, '4, 6, 7, 9, 11, 12');

-- Insert dữ liệu vào bảng tạm pizza_toppings
INSERT INTO   [staging].pizza_toppings 
			  (topping_id, topping_name)
VALUES 
			  (1, 'Bacon'),
			  (2, 'BBQ Sauce'),
			  (3, 'Beef'),
			  (4, 'Cheese'),
			  (5, 'Chicken'),
			  (6, 'Mushrooms'),
			  (7, 'Onions'),
			  (8, 'Pepperoni'),
			  (9, 'Peppers'),
			  (10, 'Salami'),
			  (11, 'Tomatoes'),
			  (12, 'Tomato Sauce');

---------------------------------------------------
-- PHẦN 1.2: FRAMEWORK để xem xét vấn đề dữ liệu 
---------------------------------------------------
/*
======== 1. Schema và kiểu dữ liệu
-- Kiểm tra cột có tồn tại đúng tên, đúng thứ tự không.
-- Kiểm tra kiểu dữ liệu có phù hợp với bảng đích không (ngày tháng phải là DATE/DATETIME, số phải là INT/DECIMAL, text đúng độ dài).
-- Xác định khóa chính thực tế (composite key, surrogate key) để đảm bảo mỗi dòng là duy nhất.

======== 2. Tính đầy đủ (Completeness)
-- Xử lý các giá trị thể hiện “thiếu dữ liệu” như NULL, 'null', 'NaN', '' (chuỗi rỗng), ' ' → đồng nhất thành NULL.
-- Kiểm tra các cột bắt buộc (NOT NULL) không được phép thiếu dữ liệu.

======== 3. Tính duy nhất (Uniqueness)
-- Phát hiện bản ghi trùng lặp hoàn toàn hoặc theo business key.
-- Tạo surrogate key (dùng ROW_NUMBER()) cho các bảng thiếu khóa tự nhiên hoặc composite key quá dài.

======== 4. Chuẩn hóa và làm sạch (Standardization & Cleansing)
-- Trích xuất số từ chuỗi có đơn vị (ví dụ '20km' → 20).
-- Tách cột có nhiều giá trị (dạng '1,2,3') thành các dòng riêng (normalize).
-- Chuẩn hóa chữ hoa/thường (ví dụ tên topping).
-- Xử lý các giá trị không hợp lệ (khoảng trắng thừa, ký tự đặc biệt).

======== 5. Tính toàn vẹn tham chiếu (Referential Integrity)
-- Kiểm tra khóa ngoại có tồn tại trong bảng chính (ví dụ pizza_id có trong pizza_names, runner_id có trong runners).

======== 6. Quy tắc nghiệp vụ (Business Rule Validation)
-- Xác định đơn nào được gửi dựa trên logic hủy (cancellation).
-- Kiểm tra giá trị hợp lệ theo ngữ cảnh: distance > 0, duration > 0, order_date <= required_date, v.v.


======== 7. Xử lý lỗi và ghi log
-- Ghi các bản ghi bị từ chối (rejected) vào bảng riêng kèm cột error_reason để theo dõi và sửa sau.
-- Cập nhật cột _valid trong staging (0/1) để phân luồng xử lý.


---------------------------------------------------
-- PHẦN 1.3: CÁC VẤN ĐỀ DỮ LIỆU 
---------------------------------------------------
-- NGUYÊN TẮC:
---- Ưu tiên xử lý bảng ít phụ thuộc trước, bảng nhiều tham chiếu sau. 
---- Nhờ đó, khi xử lý bảng phức tạp, các dữ liệu tham chiếu đã sạch và ổn định, giảm thiểu rủi ro phải sửa lại.


======== Table 1: runners 

-- Cột runner_id là số nguyên , registration_date là date 
-- Không có null hay giá trị bất thường 

-- Nhận xét
-- Dữ liệu sạch, không cần xử lý */

-- Tạ bảng tạm local, #runners_clean 
CREATE TABLE #runners_clean (
		runner_id				INT PRIMARY KEY ,
		registration_date		DATE
)
-- Sao chép toàn bộ dữ liệu từ staging.runners vào #runners_clean
-- Không cần thêm surrogate key vì runner_id đã là khóa tự nhiên duy nhất 

INSERT INTO #runners_clean (runner_id, registration_date) 
SELECT 
		runner_id,
		registration_date
FROM staging.runners 
/*
========  Table 2: pizza_names

-- Vấn đề: không có
-- Dữ liệu: sạch */
-- Tạ bảng tạm local, #runners_clean 
CREATE TABLE #pizza_names_clean (
		pizza_id				INT PRIMARY KEY ,
		pizza_name      		NVARCHAR(50)
)

-- Sao chép toàn bộ dữ liệu từ staging.pizza_names vào #pizza_names_clean
INSERT INTO #pizza_names_clean (pizza_id, pizza_name)
SELECT pizza_id, pizza_name
FROM   staging.pizza_names


/*
======== Table 3: pizza_toppings 
 
-- Dữ liệu sạch, ổn, thống nhất trong cách ghi viết hoa đầu mỗi từ, ngoại trừ trường hợp đặc biệt BBQ 
*/
CREATE TABLE #pizza_toppings_clean(
	   topping_id		INT PRIMARY KEY,
	   topping_name		NVARCHAR(50)
)


INSERT INTO #pizza_toppings_clean(topping_id, topping_name)
SELECT topping_id,
	   topping_name
FROM   staging.pizza_toppings 

/*
======== Table 4: pizza_recipes
-- VI PHẠM QUY TẮC 4: Tách cột nhiều giá trị (normalize)
-- Cột toppings: giá trị bị gộp dạng '1, 2, 3, 4, 5, 6, 8, 10' (có dấu cách sau dấu phẩy)
-- Cần tách thành các dòng riêng (normalize) để phân tích nhiều-nhiều.
*/

SELECT *
FROM   staging.pizza_recipes

-- Cách xử lý
---- Xóa khoảng trắng thừa trong chuỗi (quan trọng: có dấu cách sau dấu phẩy).
---- Dùng STRING_SPLIT để tách thành các dòng.
---- Ép kiểu token về INT

-- Tạo bảng tạm #pizza_recipes_clean
CREATE TABLE #pizza_recipes_clean(
	pizza_recipes_id INT IDENTITY(1,1) PRIMARY KEY,
	pizza_id INT ,
	toppings INT
)

-- Xử lý và Insert trực tiếp 
---- thử chỉ với STRING_SPLIT để hiểu bước này ra cái gì
SELECT *
FROM staging.pizza_recipes 
CROSS APPLY STRING_SPLIT(toppings, ',')
-- Vậy dùng STRING_SPLIT ra :
-- pizza_id sẽ lặp lại nhiều lần, số lần lặp lại bằng số dòng mà giá trị tại côt đem đi split đã split ra
-- toppings giữ nguyên và lặp lại
-- value là kết quả đã được split 

SELECT 
	 pizza_id,
	 -- Dùng TRIM để xóa khoảng trắng thừa trên cột value do STRING_SPLIT tạo ra
	CAST(TRIM(value) AS INT) AS toppings
FROM staging.pizza_recipes 
-- Cắt chuỗi ra thành nhiều dòng bằng dấu ','
CROSS APPLY STRING_SPLIT(toppings, ',')
-- Khi kiểm tra câu lệnh SELECT đã ổn thì mới INSERT 

-- Thực hiện INSERT vào clean
INSERT INTO #pizza_recipes_clean (pizza_id, toppings)
SELECT 
	 pizza_id,
	 -- Dùng TRIM để xóa khoảng trắng thừa trên cột value do STRING_SPLIT tạo ra
	CAST(TRIM(value) AS INT) AS toppings
FROM staging.pizza_recipes 
-- Cắt chuỗi ra thành nhiều dòng bằng dấu ','
CROSS APPLY STRING_SPLIT(toppings, ',')

-- Xem bảng clean
SELECT *
FROM #pizza_recipes_clean
-- QUAN SÁT BẰNG MẮT, NHẬN THẤY CÁC GIÁ TRỊ Ở ĐÂY ĐỀU ĐẢM BẢO RÀNG BUỘC THAM CHIẾU KHÓA NGOẠI pizza_id, topping_id 

/*
======== Table 6: runner_orders

-- VI PHẠM QUY TẮC 1: Xác định khóa chính 
-- Khóa chính: cần composite key hoặc surrogate key 

-- VI PHẠM QUY TẮC 2 - Chuẩn hóa thiếu dữ liệu + - VI PHẠM QUY TẮC 1: kiểu dữ liệu 
-- Cột pickup_time : có giá trị 'null', datetime

-- VI PHẠM QUY TẮC 4: Trích xuất số từ chuỗi, VI PHẠM QUY TẮC 2: Chuẩn hóa null 
-- Cột distance : dạng '20km', '13.4km'. '23.4', '10',  '23.4 km', 'null'. Cần trích xuất số, bỏ đơn vị km, chuẩn hóa 'null' thành NULL, quy định số thập phân sau dấu phẩy cố định 

-- VI PHẠM QUY TẮC 4: Trích xuất số từ chuỗi, VI PHẠM QUY TẮC 2: Chuẩn hóa null 
-- Cột duration: dạng '32 minutes', '20 mins', 40, '15 minute' '10minutes', 'null' . Cần trích xuất số , chuẩn hóa null thành NULL 

-- VI PHẠM QUY TẮC 2: Chuẩn hóa thiếu dữ liệu, VI PHẠM QUY TẮC 6: Quy tắc nghiệp vụ (hủy đơn)
-- Cột cancellation:  có 'Restaurant Cancellation', 'Customer Cancellation', 'null', '' . Cần chuẩn hóa 'NaN', 'null', '' thành NULL , giữ nguyên text nếu có hủy 
*/

SELECT *
FROM staging.runner_orders


-- tại bảng clean
CREATE TABLE #runner_orders_clean(
	-- tạo surrogate key cho bảng thay vì dùng composite key
	runner_order_id INT IDENTITY(1,1) PRIMARY KEY,
	-- các cột còn lại như cấu trúc như cũ, nhưng có sự thay đổi về kiểu dữ liệu 
	order_id INT,
	runner_id INT,
	pickup_time DATETIME,
	distance FLOAT,
	duration INT,
	cancellation NVARCHAR(100)
)

-- Xử lý và INSERT vào clean 
INSERT INTO #runner_orders_clean(order_id, runner_id, pickup_time , distance , duration , cancellation )
SELECT 
	 order_id,
	 runner_id,

	 -- Xử lý cột 'pickup_time': chuyển 'null'(chuỗi) thành NULL (giá trị), ép kiểu DATETIME
	 CASE 
		 WHEN pickup_time = 'null' THEN NULL
		 ELSE CAST(pickup_time AS DATETIME)
	 END AS pickup_time,

	 -- Xử lý cột 'distance': xóa 'km', cắt khoảng trắng thừa, ép kiểu FLOAT để giữ số thập phân 
	 CASE
		WHEN distance = 'null' THEN NULL
		ELSE CAST(TRIM(REPLACE(distance,'km','')) AS FLOAT)
	 END AS distance,

	 -- Xử lý cột 'duration': xóa nhiều biến thể của chữ 'phút' như minutes, minute, mins -> cắt khoảng trắng -> ép kiểu INT 
	 CASE
		WHEN duration = 'null' THEN NULL
		ELSE  CAST(TRIM(REPLACE(REPLACE(REPLACE(duration,'minutes',''),'minute',''),'mins','')) AS INT)
	 END AS duration,

	 -- Xử lý cột 'cancellation': đưa 'null' (chuỗi) và ''(empty string) về chuẩn NULL 
	 CASE
		WHEN cancellation IS NULL OR cancellation = 'null' OR TRIM(cancellation) = '' THEN NULL
		ELSE cancellation 
	 END AS cancellation

FROM staging.runner_orders

-- kiểm tra lại
SELECT * 
FROM #runner_orders_clean

/*
======== Table 7: customer_orders

-- VI PHẠM QUY TẮC 1: Xác định khóa chính 
-- Khóa chính: order_id không đủ để xác định duy nhất một bản ghi ( vì một đơn hàng có thể 
-- có nhiều pizza, mỗi dòng là một mặt hàng ). Cần tổ hợp khóa hoặc dùng surrogate keyy 

-- VI PHẠM QUY TẮC 2 - Chuẩn hóa thiếu dữ liệu, QUY TẮC 4 - tách cột nhiều giá trị 
-- Cột cần tiền xử lý
-- exclusions : danh sách topping bị loại . Có các giá trị như '' ,'null', hoặc số như '4', '2,6' 
-- extra : danh sách topping thêm . Có các giá trị như '', NaN,  '1', 'null', '1, 5', '1, 5'

-- VI PHẠM QUY TẮC 3: Trùng lắp dữ liệu 
-- Dữ liệu trùng lặp: 
-- Có 2 dòng order_id = 4,customer_id = 103, pizza_id = 1, exclusions = 4, extras='', order_time	= 2021-01-04 13:23:46

-- VI PHẠM QUY TẮC 5 - ràng buộc tham chiếu 
-- Tham chiếu : customer_id, pizza_id là khóa ngoại nhưng chưa có ràng buộc trong staging 

-- Nhận xét:
-- Dữ liệu bẩn do biểu diễn thiếu giá trị không chuẩn. Cần xử lý các mục 1, 2, 3, 4, 5.
*/

SELECT *
FROM staging.customer_orders sco

-- Link tham khảo: http://youtube.com/watch?v=hwDa6R7G9sA
 
-- 1. Chuẩn hóa biểu diễn thiếu -> NULL
-- 2. Loại bỏ khoảng trắng sau dấu phẩu ở 2 cột exclusions, extras
-- 3. Không dùng DISTINCT để xử lý trùng lắp, vì lý do trong đơn hàng, có thể tồn tại nhiều pizza giống hệt nhau -> Dùng Row_number() cho toàn bộ dòng customer_orders gốc để tạo order_item_id 
-- 4. Tách giá trị đa trị thành các token riêng 
---- Với mỗi order_item_id, dùng STRING_SPLIT (hoặc công cụ tương tự) để biến exclusion_handled thành các token. Làm tương tự với extras_handled
---- Loại bỏ token rỗng sinh ra do split giá trị NULL hoặc dấu phẩy thừa.
-- 5. Chuẩn hóa và ép kiểu token 
---- Trim khoảng trắng cho từng token.
---- Ép token từ chuỗi sang số nguyên (INT). Token không parse được (không phải số) thì tạm loại khỏi kết quả sạch.
-- 6. Kiểm tra tồn tại topping
---- Đối chiếu từng token số với staging.pizza_toppings. Chỉ giữ token có topping_id hợp lệ.
---- Token không tồn tại -> thực hiện loại bỏ 
-- 7. Loại bỏ trùng lặp nội bộ trong cùng một order‑item
---- Sau khi explode, nếu cùng một order_item_id có một topping_id xuất hiện nhiều lần (do dữ liệu gốc gõ lặp) thì dùng DISTINCT để chỉ giữ một lần.

-- Để xử lý tốt bài toán đa trị ở cột exclusions, extras ta làm như sau:
---- tạo bảng #customer_orders (bỏ cột gây đa trị)
---- tạo bảng trung gian: #customer_orders_exclusions, #customer_orders_extras 
---- và 2 bảng trung gian này sẽ nối bảng toppings đã tạo bằng topping_id 

---- nhưng để làm được điều này, phải tao bảng baseline, sau đó mới phân tách ra thành 3 bảng đích 
------ lý do, bảng staging này ở dòng 5 và 6 bị trùng lắp
------ theo logic business, điều này là hợp lệ vì 1 đơn hàng có thể có nhiều cái pizza giống hệt nhau
------ nhưng về mặt kỹ thuật, nó sẽ là vấn đề vì vi phạm tính duy nhất bảng ghi, khi tham chiếu khóa, nhiều dòng giống ệt biết tham chiếu cái nào
------ nên tạo bảng base, khi khóa tự tăng, nên dù nhiều dòng có giống nhau nhưng tính duy nhất bản ghi vẫn được đảm bảo 


-- Tạo bảng #customer_orders_base 
CREATE TABLE #customer_orders_base(
		customer_orders_id INT IDENTITY(1,1) PRIMARY KEY,

		order_id INT,
		customer_id INT,
		pizza_id INT,

		exclusions NVARCHAR(50),	-- Tạm giữ lại text để bước sau xử lý
		extras NVARCHAR(50),		-- Tạm giữ lại text để bước sau xử lý

		order_time DATETIME 
)
-- Làm sạch dữ liệu và INSERT vào bảng base
INSERT INTO #customer_orders_base (order_id, customer_id, pizza_id, exclusions, extras,order_time)
SELECT
		order_id,
		customer_id,
		pizza_id,

		-- Chuẩn hóa exclusion
		CASE 
			WHEN exclusions IS NULL OR TRIM(exclusions) IN ('null', '') THEN NULL
			ELSE REPLACE(exclusions, ', ',',')
		END AS exclusions,

		-- Chuẩn hóa extras
		CASE
			WHEN extras IS NULL OR TRIM(extras) IN ('null', '') THEN NULL
			ELSE REPLACE(extras, ', ',',')
		END AS extras,

		order_time
FROM staging.customer_orders 
 
-- Tạo bảng chính (không còn cột đa trị)
CREATE TABLE #customer_orders_clean(
	    customer_orders_id INT PRIMARY KEY,

		order_id INT,
		customer_id INT,
		pizza_id INT,
		
		order_time DATETIME 
)
-- chèn dữ liệu từ bảng base vào bảng customer_orders_clean
INSERT INTO #customer_orders_clean(customer_orders_id, order_id, customer_id, pizza_id, order_time)
SELECT
		customer_orders_id , 
		order_id ,
		customer_id ,
		pizza_id , 
		order_time
FROM #customer_orders_base

-- Tạo bảng trung gian (2 bảng)
-- Bảng 1:  #customer_orders_exclusions
CREATE TABLE #customer_orders_exclusions(
		customer_orders_id INT,
		topping_id INT,

		-- Tạo khóa chính tổ hợp 
		PRIMARY KEY(customer_orders_id, topping_id) 
)
INSERT INTO  #customer_orders_exclusions(customer_orders_id,topping_id  )
SELECT DISTINCT 
	 customer_orders_id,
	 TRY_CAST(TRIM(value) AS INT) AS topping_id
FROM #customer_orders_base
CROSS APPLY STRING_SPLIT(exclusions,',')
WHERE 
	value <> ''
	AND TRY_CAST(TRIM(value) AS INT) IS NOT NULL
	AND TRY_CAST(TRIM(value) AS INT) IN (SELECT topping_id FROM staging.pizza_toppings )

-- Bảng 2:  #customer_orders_extras
CREATE TABLE #customer_orders_extras(
		customer_orders_id INT,
		topping_id INT,

		-- Tạo khóa chính tổ hợp 
		PRIMARY KEY(customer_orders_id, topping_id) 
)

INSERT INTO #customer_orders_extras
SELECT DISTINCT
		customer_orders_id INT,
		TRY_CAST(TRIM(value) AS INT) AS topping_id 
FROM	#customer_orders_base
CROSS APPLY STRING_SPLIT(extras, ',')
WHERE 
	value <> ''
	AND TRY_CAST(TRIM(value) AS INT) IS NOT NULL
	AND TRY_CAST(TRIM(value) AS INT) IN (SELECT topping_id FROM staging.pizza_toppings )
	 
---------------------------------------------------
-- PHẦN 1.4: TẠO DESTINATION VÀ LOAD DATA TỪ STAGING ĐÃ ĐƯỢC LÀM SẠCH, SAU ĐÓ TẠO RÀNG BUỘC KHÓA NGOẠI 
---------------------------------------------------


---------------------------------------------------
-- PHẦN 1.4.1: TẠO CẤU TRÚC BẢNG DESTINATION 
--------------------------------------------------- 
-- Tạo bảng destination.runners 
CREATE TABLE destination.runners(
		runner_id				INT PRIMARY KEY ,
		registration_date		DATE
)

-- Tạo bảng destination.pizza_names
CREATE TABLE destination.pizza_names(
		pizza_id				INT PRIMARY KEY ,
		pizza_name      		NVARCHAR(50)
)

-- Tạo bảng destination.pizza_toppings  
CREATE TABLE destination.pizza_toppings(
		topping_id				INT PRIMARY KEY,
		topping_name			NVARCHAR(50)
)
  
-- NHÓM 2: Tạo các bảng phụ thuộc 
-- Tạo bảng destination.runner_orders  
CREATE TABLE destination.runner_orders(
		-- tạo surrogate key cho bảng thay vì dùng composite key
		runner_order_id		   INT IDENTITY(1,1) PRIMARY KEY,
		-- các cột còn lại như cấu trúc như cũ, nhưng có sự thay đổi về kiểu dữ liệu 
		order_id				INT,
		runner_id				INT,
		pickup_time				DATETIME,
		distance				FLOAT,
		duration				INT,
		cancellation			NVARCHAR(100) 

		-- FOREIGN KEY: runner_id -> destination.runners(runner_id)
)

-- Tạo bảng destination.pizza_recipes 

CREATE TABLE destination.pizza_recipes(
		pizza_recipes_id INT IDENTITY(1,1) PRIMARY KEY,
		pizza_id INT ,
		toppings INT

		-- FOREIGN KEY: pizza_id -> destination.pizza_names(pizza_id)
		-- FOREIGN KEY: toppings -> destination.pizza_toppings(topping_id)

)
 
-- Tạo bảng destination.customer_orders
CREATE TABLE destination.customer_orders (
		customer_orders_id		INT PRIMARY KEY, 
		order_id				INT,
		customer_id				INT,
		pizza_id				INT,        
		order_time			    DATETIME

		-- FOREIGN KEY: pizza_id -> destination.pizza_names(pizza_id)

)
-- Tạo bảng destination.customer_orders_exclusions

CREATE TABLE destination.customer_orders_exclusions(
		customer_orders_id	    INT,
		topping_id			    INT,

		-- Tạo khóa chính tổ hợp 
		PRIMARY KEY(customer_orders_id, topping_id)

		-- FOREIGN KEY: customer_orders_id -> destinationcustomer_orders(customer_orders_id)
		-- FOREIGN KEY: topping_id         -> destination.pizza_toppings(topping_id)

)

-- Tạo bảng destination.customer_orders_extras 

CREATE TABLE destination.customer_orders_extras(
		customer_orders_id		INT,
		topping_id				INT,

		-- Tạo khóa chính tổ hợp 
		PRIMARY KEY(customer_orders_id, topping_id)

		-- FOREIGN KEY: customer_orders_id -> destination.customer_orders(customer_orders_id)
		-- FOREIGN KEY: topping_id         -> destination.pizza_toppings(topping_id)


) 

-- Lý do chưa tạo ràng buộc khóa ngoại vì muốn tăng tốc độ khi load data vào destination

---------------------------------------------------
-- PHẦN 1.4.2: LOAD DỮ LIỆU TỪ STAGING ĐÃ LÀM SẠCH VÀO DESTINATION 
---------------------------------------------------
-- TIPS: Những bảng đích bây giờ là bảng tróng
-- Dùng TRUNCATE bảng trước khi INSERT để tránh việc khi đã chạy INSERT rồi mà quên chạy thêm nhiều lần nữa gây trùng dữ liệu 

-- Insert data vào bảng destination.runners
TRUNCATE TABLE destination.runners
INSERT INTO destination.runners (runner_id, registration_date)
SELECT runner_id, registration_date
FROM #runners_clean 

-- Insert data vào bảng destination.pizza_names
TRUNCATE TABLE destination.pizza_names
INSERT INTO destination.pizza_names (pizza_id, pizza_name)
SELECT pizza_id, pizza_name
FROM #pizza_names_clean

-- Insert data vào bảng destination.pizza_toppings  
TRUNCATE TABLE destination.pizza_toppings  
INSERT INTO destination.pizza_toppings (topping_id, topping_name)
SELECT topping_id, topping_name
FROM  #pizza_toppings_clean

-- Insert data vào bảng destination.runner_orders  
TRUNCATE TABLE destination.runner_orders  
SET IDENTITY_INSERT destination.runner_orders ON
INSERT INTO destination.runner_orders (runner_order_id, order_id, runner_id, pickup_time, distance, duration, cancellation)
SELECT runner_order_id, order_id, runner_id, pickup_time, distance, duration, cancellation
FROM #runner_orders_clean
SET IDENTITY_INSERT destination.runner_orders OFF 

-- Insert data vào bảng destination.pizza_recipes
TRUNCATE TABLE destination.pizza_recipes
--- SET IDENTITY_INSER để lấy id tự tăng từ staging clean 
SET IDENTITY_INSERT destination.pizza_recipes ON 
INSERT INTO destination.pizza_recipes (pizza_recipes_id, pizza_id, toppings)
SELECT pizza_recipes_id, pizza_id, toppings
FROM #pizza_recipes_clean;
SET IDENTITY_INSERT destination.pizza_recipes OFF;


-- Insert data vào bảng destination.customer_orders
TRUNCATE TABLE destination.customer_orders
INSERT INTO destination.customer_orders (customer_orders_id, order_id, customer_id, pizza_id, order_time)
SELECT customer_orders_id, order_id, customer_id, pizza_id, order_time
FROM #customer_orders_clean;

-- Insert data vào bảng destination.customer_orders_exclusions
TRUNCATE TABLE destination.customer_orders_exclusions
INSERT INTO destination.customer_orders_exclusions (customer_orders_id, topping_id)
SELECT customer_orders_id, topping_id
FROM #customer_orders_exclusions

-- Insert data vào bảng destination.customer_orders_extras
TRUNCATE TABLE destination.customer_orders_extras
INSERT INTO destination.customer_orders_extras (customer_orders_id, topping_id)
SELECT customer_orders_id, topping_id
FROM #customer_orders_extras;


---------------------------------------------------
-- PHẦN 1.4.3: TẠO TÀNG BUỘC KHÓA NGOẠI 
---------------------------------------------------


-- Thêm foreign key vào bảng destination.runner_orders  
		-- FOREIGN KEY: runner_id -> destination.runners(runner_id)
ALTER TABLE destination.runner_orders 
ADD CONSTRAINT FK_runners_runner_orders FOREIGN KEY (runner_id)
REFERENCES destination.runners(runner_id)


-- Thêm foreign key vào  bảng destination.pizza_recipes
		-- FOREIGN KEY: pizza_id -> destination.pizza_names(pizza_id)
		-- FOREIGN KEY: toppings -> destination.pizza_toppings(topping_id)
ALTER TABLE destination.pizza_recipes
ADD CONSTRAINT FK_pizza_names_recipes FOREIGN KEY (pizza_id)
REFERENCES destination.pizza_names(pizza_id)


ALTER TABLE destination.pizza_recipes
ADD CONSTRAINT FK_pizza_toppings_recipes FOREIGN KEY (toppings)
REFERENCES destination.pizza_toppings(topping_id)


-- Thêm foreign key vào bảng destination.customer_orders
		-- FOREIGN KEY: pizza_id -> destination.pizza_names(pizza_id)
ALTER TABLE destination.customer_orders
ADD CONSTRAINT FK_pizza_names_customer_orders FOREIGN KEY (pizza_id)
REFERENCES destination.pizza_names(pizza_id)


-- Thêm foreign key vào bảng destination.customer_orders_exclusions
		-- FOREIGN KEY: customer_orders_id -> destination.customer_orders(customer_orders_id)
		-- FOREIGN KEY: topping_id         -> destination.pizza_toppings(topping_id)
ALTER TABLE destination.customer_orders_exclusions
ADD CONSTRAINT FK_customer_orders_customer_orders_exclusions FOREIGN KEY (customer_orders_id)
REFERENCES destination.customer_orders(customer_orders_id)

ALTER TABLE destination.customer_orders_exclusions
ADD CONSTRAINT FK_pizza_toppings_customer_orders_exclusions FOREIGN KEY (topping_id)
REFERENCES destination.pizza_toppings(topping_id)


-- Thêm foreign key vào bảng destination.customer_orders_extras
		-- FOREIGN KEY: customer_orders_id -> destination.customer_orders(customer_orders_id)
		-- FOREIGN KEY: topping_id         -> destination.pizza_toppings(topping_id)
ALTER TABLE destination.customer_orders_extras
ADD CONSTRAINT FK_customer_orders_customer_orders_extras FOREIGN KEY (customer_orders_id)
REFERENCES destination.customer_orders(customer_orders_id)

ALTER TABLE destination.customer_orders_extras 
ADD CONSTRAINT FK_pizza_toppings_customer_orders_extras FOREIGN KEY (topping_id )
REFERENCES destination.pizza_toppings(topping_id)

---------------------------------------------------------------------------------------
-- thiết kế khóa ngoại không chỉ để bảng không mồ côi mà tạo thuận lợi cho việc truy vấn 

---- 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

ALTER TABLE destination.customer_orders_exclusions
ADD CONSTRAINT FK_customer_orders_customer_orders_exclusions FOREIGN KEY (customer_orders_id)
REFERENCES destination.customer_orders(customer_orders_id)

ALTER TABLE destination.customer_orders_extras 
ADD CONSTRAINT FK_customer_orders_customer_orders_extras	FOREIGN KEY (customer_orders_id)
REFERENCES destination.customer_orders(customer_orders_id)



---------------------------------------------------
-- PHẦN 1.4.4: CÁC CÂU LỆNH SELECT XEM BẢNG ĐÍCH ĐÃ SẴN SÀNG HAY CHƯA 
---------------------------------------------------

---------------------------------------------------
-- PHẦN 1.4.4: CÁC CÂU LỆNH SELECT XEM BẢNG ĐÍCH ĐÃ SẴN SÀNG HAY CHƯA
---------------------------------------------------

SELECT * FROM destination.runners;
SELECT * FROM destination.pizza_names;
SELECT * FROM destination.pizza_toppings;
SELECT * FROM destination.pizza_recipes;
SELECT * FROM destination.runner_orders;
SELECT * FROM destination.customer_orders;
SELECT * FROM destination.customer_orders_exclusions;
SELECT * FROM destination.customer_orders_extras;

-- Kiểm tra mối quan hệ (ví dụ: xem đơn hàng kèm tên pizza)
SELECT co.customer_orders_id,
       co.order_id,
       co.customer_id,
       pn.pizza_name,
       co.order_time
FROM destination.customer_orders co
JOIN destination.pizza_names pn ON co.pizza_id = pn.pizza_id;

-- Xem exclusions kèm tên topping
SELECT e.customer_orders_id,
       pt.topping_name AS excluded_topping
FROM destination.customer_orders_exclusions e
JOIN destination.pizza_toppings pt ON e.topping_id = pt.topping_id;

-- Xem extras kèm tên topping
SELECT e.customer_orders_id,
       pt.topping_name AS extra_topping
FROM destination.customer_orders_extras e
JOIN destination.pizza_toppings pt ON e.topping_id = pt.topping_id;
