-- 1. VẤN ĐỀ
-- 2. XỬ LÝ VẤN ĐỀ
USE Pizza_Runner
---- 2.1. Xóa ràng buộc khóa ngoại đến bảng customer_orders và xóa bảng orders
-- ALTER TABLE destination.customer_orders DROP CONSTRAINT FK_pizza_names_customer_orders
ALTER TABLE destination.customer_orders_exclusions  DROP CONSTRAINT FK_customer_orders_customer_orders_exclusions
ALTER TABLE destination.customer_orders_extras  DROP CONSTRAINT FK_customer_orders_customer_orders_extras 

DROP TABLE destination.customer_orders 

---- 2.2. Tạo bảng Orders
CREATE TABLE destination.orders(
		
		order_id INT PRIMARY KEY,
		customer_id INT NOT NULL,
		order_time DATETIME NOT NULL
)

---- 2.3. Tạo lại bảng customer_orders và khóa ngoại cho bảng 

CREATE TABLE destination.customer_orders(
		customer_orders_id INT IDENTITY(1,1) PRIMARY KEY,
		order_id INT NOT NULL,
		pizza_id INT NOT NULL,

		-- Khóa ngoại trỏ về bảng orders
		CONSTRAINT FK_customer_orders_orders FOREIGN KEY (order_id) REFERENCES destination.orders(order_id),

		-- Khóa ngoại trỏ về danh mục Pizza
		CONSTRAINT FK_customer_orders_pizza_names FOREIGN KEY (pizza_id) REFERENCES destination.pizza_names(pizza_id)
)

---- 2.4. Tạo ràng buộc khóa ngoại và ràng buộc unique 
-- Phải insert dữ liệu vào rồi mới tạo ràng buộc khóa ngoại hợp lệ được 

-- Insert dữ liệu vào bảng destination.orders
-- Loại bỏ cột không dùng, và đảm bảo tính duy nhất của bản ghi (nghĩa là xóa dòng gây duplicates)
INSERT INTO destination.orders
			(order_id ,customer_id , order_time)
VALUES
			('1', '101', '2020-01-01 18:05:02'),
			('2', '101', '2020-01-01 19:00:52'),
			('3', '102', '2020-01-02 23:51:23'),
			('4', '103', '2020-01-04 13:23:46'),
			('5', '104', '2020-01-08 21:00:29'),
			('6', '101', '2020-01-08 21:03:13'),
			('7', '105', '2020-01-08 21:20:29'),
			('8', '102',  '2020-01-09 23:54:33'),
			('9', '103',  '2020-01-10 11:22:59'),
			('10', '104', '2020-01-11 18:34:49')

-- Insert dữ liệu vào bảng destinatiion.customer_orders
INSERT INTO destination.customer_orders
			(order_id ,pizza_id)
VALUES
			('1',  '1'),
			('2',  '1'),
			('3',  '1'),
			('3',  '2'),
			('4',  '1'),
			('4',  '1'),
			('4',  '2'),
			('5',  '1'),
			('6',  '2'),
			('7',  '2'),
			('8',  '1'),
			('9',  '1'),
			('10', '1'),
			('10', '1')

ALTER TABLE destination.runner_orders ADD CONSTRAINT unique_order_id_in_runner UNIQUE (order_id)

ALTER TABLE destination.runner_orders
ADD CONSTRAINT FK_runner_orders_customer_orders
FOREIGN KEY (order_id) REFERENCES destination.orders(order_id)

-- 3. MIÊU TẢ LẠI LƯỢC ĐỒ QUAN HỆ 


