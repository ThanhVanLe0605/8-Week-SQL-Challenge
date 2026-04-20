create database sql_challenge
use sql_challenge

--  week 01: Case Study #1 - Danny's Diner Danny 

-- 1. TẠO SCHEMA
------------------------------------------------
-- TẠO SCHEMA : staging area
CREATE SCHEMA staging_dannys_diner;
-- TẠO SCHEMA : dữ liệu đã được làm sạch 
CREATE SCHEMA dannys_diner;
------------------------------------------------

-- 2. TẠO BẢNG 
------------------------------------------------
-- 2. 1. TẠO BẢNG TẠM 
------------------------------------------------
CREATE TABLE staging_dannys_diner.menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);
------------------------------------------------
CREATE TABLE staging_dannys_diner.members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);
------------------------------------------------
CREATE TABLE staging_dannys_diner.sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);
------------------------------------------------
-- 2.2. TẠO BẢNG ĐÍCH  + RÀNG BUỘC KHÓA 
------------------------------------------------
CREATE TABLE dannys_diner.menu (
  "product_id" INTEGER NOT NULL,
  "product_name" VARCHAR(5) NULL,
  "price" INTEGER NULL 

  -- Định nghĩa khóa chính 
  CONSTRAINT PK_menu PRIMARY KEY (product_id)
);
------------------------------------------------

CREATE TABLE dannys_diner.members (
  "customer_id" VARCHAR(1) NOT NULL,
  "join_date" DATE NULL
  -- Định nghĩa khóa chính 
  CONSTRAINT PK_members PRIMARY KEY(customer_id)
);
------------------------------------------------
CREATE TABLE dannys_diner.sales (
  "customer_id" VARCHAR(1) NOT NULL ,
  "order_date" DATE NOT NULL,
  "product_id" INTEGER NOT NULL
  -- Định nghĩa khóa ngoại
  -- Khóa ngoại 1: 
  CONSTRAINT FK_sales_members FOREIGN KEY (customer_id) REFERENCES  dannys_diner.members(customer_id),
  -- Khóa ngoại 2:
  CONSTRAINT FK_sales_menu FOREIGN KEY(product_id) REFERENCES  dannys_diner.menu(product_id),
  -- Định nghĩa khóa chính 
  CONSTRAINT PK_sales PRIMARY KEY(customer_id, order_date, product_id)
);
------------------------------------------------


-- 3. INSERT DỮ LIỆU VÀO BẢNG 
------------------------------------------------
--3.1. INSERT DỮ LIỆU VÀO BẢNG TẠM
------------------------------------------------
INSERT INTO staging_dannys_diner.menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
------------------------------------------------
INSERT INTO staging_dannys_diner.members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
------------------------------------------------
INSERT INTO staging_dannys_diner.sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
------------------------------------------------
--3.2. INSERT DỮ LIỆU VÀO CSDL CHÍNH 
------------------------------------------------
-- LOẠI BỎ NHỮNG DÒNG DỮ LIỆU TRÙNG (NẾU CÓ)
INSERT INTO dannys_diner.menu 
  ("product_id", "product_name", "price")
SELECT DISTINCT		-- loại bỏ trùng lắp
	m.product_id,
	m.product_name,
	m.price
FROM staging_dannys_diner.menu m
------------------------------------------------
INSERT INTO dannys_diner.members
  ("customer_id", "join_date")
SELECT DISTINCT		-- loại bỏ trùng lắp
  b.customer_id,
  b.join_date 
FROM staging_dannys_diner.members b
------------------------------------------------
INSERT INTO dannys_diner.sales
 ("customer_id", "order_date", "product_id")
SELECT DISTINCT
	s.customer_id,
	s.order_date,
	s.product_id
FROM staging_dannys_diner.sales s
-- Đảm bảo ràng buộc khóa ngoại: customer_id PHẢI tồn tại trong bảng members
INNER JOIN staging_dannys_diner.members m ON s.customer_id = m.customer_id
-- Đảm bảo ràng buộc khóa ngoại: product_id PHẢI tồn tại trong bảng menu
INNER JOIN staging_dannys_diner.menu n ON s.product_id = n.product_id 
-- Chỉ lấy những bản ghi chưa tồn tại trong bảng sales (để tránh trùng)
WHERE NOT EXISTS (
	SELECT 1
	FROM dannys_diner.sales sales 
	WHERE sales.customer_id = s.customer_id
		AND		sales.product_id = s.product_id
		AND		sales.order_date = s.order_date 
)


------------------------------------------------
-- trường hợp thiết kế sai, xóa để làm lại , cách xóa như sau:
-- DROP SCHEMA [dannys_diner]
-- DROP SCHEMA [staging_dannys_diner]

-- DROP TABLE  sales
-- DROP TABLE	menu
-- DROP TABLE  members
------------------------------------------------
-- DATA CLEANING NOTES (cho dự án nhỏ)
-- Lý do: Dữ liệu đầu vào có kích thước nhỏ,
--        dễ dàng phát hiện các vấn đề bằng mắt thường.
-- Phạm vi xử lý: 
--   1. Xử lý TRÙNG LẶP (dùng DISTINCT)
--   2. Đảm bảo RÀNG BUỘC KHÓA NGOẠI (chỉ insert nếu tham chiếu hợp lệ)
--   3. Chỉ thêm bản ghi nếu CHƯA TỒN TẠI trong bảng đích
-- Các bước khác (NULL, kiểu dữ liệu, business rule, ...)
-- được bỏ qua vì đã kiểm tra thủ công và đảm bảo sạch.


-- Ghi chú mở rộng: Nếu dữ liệu lớn hoặc nguồn không tin cậy,
-- cần bổ sung: NULL check, kiểm tra kiểu dữ liệu, 
-- business rule (price>0, order_date <= hiện tại), 
-- và ghi log lỗi vào bảng rejected_records.

------------------------------------------------
-- 4. KIỂM TRA 
SELECT *
FROM dannys_diner.sales s
INNER JOIN dannys_diner.members m ON s.customer_id = m.customer_id
INNER JOIN dannys_diner.menu n ON s.product_id = n.product_id

------------------------------------------------
-- 5. Case Study Questions
------------------------------------------------
-- 5.1. What is the total amount each customer spent at the restaurant?
------------------------------------------------
-- 5.2. How many days has each customer visited the restaurant?
------------------------------------------------
-- 5.3. What was the first item from the menu purchased by each customer?
------------------------------------------------
-- 5.4. What is the most purchased item on the menu and how many times was it purchased by all customers?
------------------------------------------------
-- 5.5. Which item was the most popular for each customer?
------------------------------------------------
-- 5.6. Which item was purchased first by the customer after they became a member?
------------------------------------------------
-- 5.7. Which item was purchased just before the customer became a member?
------------------------------------------------
-- 5.8. What is the total items and amount spent for each member before they became a member?
------------------------------------------------
-- 5.9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
------------------------------------------------
-- 5.10. 
-- In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi
-- how many points do customer A and B have at the end of January?

------------------------------------------------
-- 6. Bonus Questions
------------------------------------------------
-- 6.1. Join All The Things
------------------------------------------------
-- 6.2. Rank All The Things
------------------------------------------------
------------------------------------------------
------------------------------------------------
