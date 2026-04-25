create database sql_challenge
use sql_challenge

-- LINK 01 : https://www.youtube.com/watch?v=cXhv4kmIzFw
-- LINK 02: https://youtu.be/OdnxoJitdAg?si=Mnyt5e6ViZYPI9K5
-- LINK 03: 

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

-- CHÚ Ý THỰC TIỄN:
-- Khách có thể mua sắm nhiều lần cùng một ngày
-- Nên nên để DATETIME thay vì DATE 
-- Thay vì dùng tổ hợp làm khóa chính , thì tham khảo surrogate key, natural key , auto increment ID 


------------------------------------------------
-- 5. Case Study Questions
------------------------------------------------
-- 5.1. Tổng số tiền mỗi khách hàng đã chi tiêu tại nhà hàng là bao nhiêu?

-- CÁCH 1 cho bài 5.1:
-- Bước 1: Tạo CTE với output customer_id, order_date, total_amount_by_orderdate
-- để ghép bảng lấy giá 
WITH sales_with_price  AS (
	SELECT 
			s.customer_id,
			s.order_date,
			m.product_id,
			m.price
	FROM dannys_diner.sales s
	INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id
	
	) 
-- Bước 2: Viết query từ bảng CTE đã tạo 
SELECT 
		sp.customer_id,
		SUM(sp.price) AS total_amount_by_customers
FROM sales_with_price sp
GROUP BY sp.customer_id
ORDER BY total_amount_by_customers ASC

-- CÁCH 2 cho bài 5.1:
SELECT
		s.customer_id,
		SUM(m.price) AS total_amount_by_customers
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_amount_by_customers DESC 

------------------------------------------------
-- 5.2. Mỗi khách hàng đã ghé thăm nhà hàng bao nhiêu ngày?

-- Hiểu logic nghiệp vụ của dữ liệu 
-- order_date bảng sales là ngày khách hàng đến thăm , ngày đến để mua hàng
-- join_date ở members là ngày đăng ký thẻ thành viên

-- Xem dữ liệu 
SELECT *
FROM dannys_diner.sales s
-- A	2021-01-01	1
-- A	2021-01-01	2
-- Nhận xét: vào cùng một ngày, mua sp có product_id =1 và 2
-- việc hiển thị chi tiết pro_id trong đơn hàng làm order_date bị lặp lại nhiều lần
-- nên khi đếm ngày khách hàng đến mua hàng phải dùng COUNT(DISTINCT .. )

-- Viết câu lệnh truy xuất thông tin
SELECT
		s.customer_id,
		COUNT(DISTINCT s.order_date) AS visited_days
FROM dannys_diner.sales s
GROUP BY s.customer_id
ORDER BY visited_days DESC

------------------------------------------------
-- 5.3. Món đầu tiên trong thực đơn mà mỗi khách hàng đã mua là gì?

-- Một khách hàng sẽ có nhiều ngày mua hàng, một ngày mua hàng có thể mua nhiều sản phẩm
-- Khi tính tiền, thời gian theo lúc tạo hóa đơn chứ không theo lúc quét mã vạch từng sản phẩm 

-- Vậy sản phầm đầu tiên sẽ là ?  
-- Tất cả sản phẩm trong giỏ hàng của ngày đầu tiên khách hàng mua

-- Để giải bài toán này
-- Không thể dùng TOP 1 vì nó chỉ dành cho 1 cột
-- groupby theo nhiều cấp, lấy thứ hạng của cấp 2, 3,... --> ?
-- Dùng Rank Functions
-- Dùng DENSE_RANK để giải quyết vì: nó cho phép đồng hạng, phù hợp để lấy ra ngày mua hàng sớm nhất của khách hàng 

-- Bước 1: Dùng CTE để xếp hạng ngày mua hàng của từng khách hàng 
;WITH ranked_sales AS (
		SELECT
				s.customer_id,
				s.order_date,
				
				-- Hàm DENSE_RANK():
				-- PARTITION BY: Chia nhóm theo từng khách hàng
				-- ORDER BY: Sắp xếp ngày mua tăng dần (cũ nhất lên đầu)
				DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS [rank],

				m.product_name 
		FROM dannys_diner.sales s 
		INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id 
		GROUP BY s.customer_id,
				 s.order_date,
				 m.product_name 
)		
-- Bước 2: Lọc ra đơn hàng có ngày đầu tiên
SELECT *
FROM ranked_sales r
WHERE r.[rank] = 1


------------------------------------------------
-- 5.4. Món được mua nhiều nhất trong thực đơn là gì và nó đã được tất cả khách hàng mua bao nhiêu lần?
-- CÁCH 1 cho 5.4:
;WITH sales_table  AS(
		SELECT m.product_id,
			   m.product_name,
			   COUNT(s.order_date) AS saled_amt,
			   DENSE_RANK() OVER(ORDER BY COUNT(s.order_date) DESC) AS rank_saled_amnt
		FROM dannys_diner.sales s 
		INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id
		GROUP BY m.product_id,
				 m.product_name
		
)
SELECT  
	  s.product_id AS best_sell_product_id,
	  s.product_name AS best_sell_product_name,
	  s.saled_amt AS saled_amnt
FROM  sales_table s
WHERE s.rank_saled_amnt = 1

-- CÁCH 2 cho 5.4:
SELECT TOP 1 WITH TIES
    m.product_id AS best_sell_product_id,
    m.product_name AS best_sell_product_name,
    COUNT(1) AS saled_amnt
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY 
    m.product_id,
    m.product_name
ORDER BY saled_amnt DESC;


------------------------------------------------
-- 5.5. Món nào phổ biến nhất đối với mỗi khách hàng?

-- nhóm cấp 1: khách hàng
-- nhóm cấp 2: product_id 
WITH rank_purchae_times AS(
	SELECT 
			s.customer_id,
			m.product_id,
			m.product_name,
			COUNT(s.order_date) AS times,
			DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.order_date) DESC ) AS rank_purchase_times
	FROM dannys_diner.sales s
	INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id
	GROUP BY    s.customer_id,
				m.product_id,
				m.product_name
	
)

SELECT
		r.customer_id,
		r.product_name	AS best_seller,
		r.times
FROM	rank_purchae_times r
WHERE r.rank_purchase_times = 1
ORDER BY   r.customer_id ASC


------------------------------------------------
-- 5.6. Món nào được khách hàng mua đầu tiên sau khi họ trở thành thành viên?

-- khách hàng có thể là khách tại quán, sau một thời gian sử dụng thì đk thẻ thành viên
-- vậy ngày mua hàng sau khi đăng ký thẻ chưa chắc là ngày mua hàng sớm nhất trong cột order_date bảng sales 

WITH rank_date_by_cust  AS(
	SELECT 
			s.customer_id,
			m.product_id,
			m.product_name,
			s.order_date,
			b.join_date,
			DENSE_RANK() OVER(PARTITION BY  s.customer_id ORDER BY s.order_date ASC) AS rank_date 
	FROM dannys_diner.sales s
	INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id
	INNER JOIN dannys_diner.members b ON s.customer_id = b.customer_id
	WHERE  b.join_date <= s.order_date
	GROUP BY    s.customer_id,
				m.product_id,
				m.product_name,
				s.order_date,
				b.join_date
)
SELECT
		rd.customer_id,
		rd.product_name AS first_purchased_items_by_every_cust,
		rd.order_date,
		rd.join_date
FROM	rank_date_by_cust rd
WHERE	rd.rank_date = 1


-- dùng WHERE hay HAVING
-- sau khi JOIN, dùng where để lọc record nào không thỏa đk 
-- HAVING cũng để lọc, nhưng kết hợp với các hàm tổng hợp nhưu COUNT, SUM, AVG
-- để đảm bảo hiệu suất, như trường hợp này, dùng WHERE chứ không dùng HAVING 

------------------------------------------------
-- 5.7. Món nào được mua ngay trước khi khách hàng trở thành thành viên?
-- Ý nghĩa kinh doanh:
-- Xác định sản phẩm cuối cùng mà khách hàng mua trước khi họ quyết định đăng ký thành viên
-- Điều này giúp hiểu "động cơ chuyển đổi": món ăn nào đã thuyết phục khách gắn bó lâu dài?
-- Dữ liệu này có thể dùng để tạo ưu đãi đặc biệt cho những món đó nhằm thúc đẩy đăng ký thành viên.

WITH motivating_items AS (
SELECT
		s.customer_id,
		s.order_date,
		m.join_date,
		DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC ) AS rank_date ,
		s.product_id,
		mn.product_name
FROM dannys_diner.sales s
INNER JOIN dannys_diner.members m ON s.customer_id = m.customer_id
INNER JOIN dannys_diner.menu mn ON   s.product_id  = mn.product_id 
WHERE s.order_date < m.join_date
)
SELECT 
		m.customer_id AS Customer,
		m.order_date AS Date_before_becoming_member,
		m.join_date AS Join_date,
		m.product_name AS motivating_items
FROM motivating_items m
WHERE m.rank_date = 1
ORDER BY m.customer_id ASC
		,m.order_date DESC

------------------------------------------------
-- 5.8. Tổng số món và số tiền đã chi tiêu của mỗi thành viên trước khi họ trở thành thành viên là bao nhiêu ?

-- Ý nghĩa kinh doanh:
-- Đo lường giá trị (revenue) và tần suất (số lượng món) mà mỗi khách hàng đã đóng góp trong giai đoạn "dùng thử" trước khi cam kết.
-- Từ đó phân nhóm khách hàng tiềm năng: những ai chi tiêu nhiều trước khi đăng ký có thể là khách hàng giá trị cao, cần được chăm sóc đặc biệt
-- So sánh với giai đoạn sau khi đăng ký để đánh giá hiệu quả của chương trình thành viên.

-- Trích xuất các bản ghi trước ngày đăng ký, 
-- GROUP BY  khách hàng, 
--		   tính : 
--					1. tiền khách đã bỏ ra để mua hàng trước khi đăng ký
--					2. số mặt hàng khách hàng đã mua -> có thể lập lại Count distinct  

SELECT
	s.customer_id ,
	-- tính các metrics
	-- tổng tiền đã mua trước đk thành viên
	SUM( mn.price) AS sum_price_before_member ,
	-- tổng loại sp đã mua trước đk thành viên --> cho biết khách có sự đa dạng trong hành vi mua hay không 
	COUNT(DISTINCT mn.product_name) AS toatal_type_item_before_member,
	-- tổng số lượng sp đã mua trước đk thành viên --> cho biết mức tiêu thụ thực tế
	COUNT( mn.product_name) AS toatal_items_before_member
FROM	dannys_diner.sales s
INNER JOIN dannys_diner.members m	ON s.customer_id = m.customer_id
INNER JOIN dannys_diner.menu mn    ON s.product_id  = mn.product_id 
-- Lọc ngày để đảm bảo điều kiện trước ngày đăng ký thành viên 
WHERE s.order_date < m.join_date 
-- Nhóm theo khách hàng để tính các metrics theo khách hàng 
GROUP BY s.customer_id 
-- Ưu tiên khách bỏ nhiều tiền nhất lên đầu danh sách 
ORDER BY sum_price_before_member DESC


------------------------------------------------
-- 5.9. Nếu mỗi 1 đô la chi tiêu tương đương 10 điểm và sushi có hệ số nhân điểm gấp đôi - thì mỗi khách hàng sẽ có bao nhiêu điểm?

-- Ý nghĩa kinh doanh:
-- Mô phỏng chương trình tích điểm để khuyến khích chi tiêu, đặc biệt thúc đẩy món sushi (có thể là món có lợi nhuận cao hoặc cần push).
-- Kết quả cho thấy khách hàng nào mang lại nhiều điểm (giá trị tương đương) – từ đó có thể thiết kế các cấp độ thành viên (VIP, vàng, bạc) dựa trên điểm.

WITH points_by_item_by_cust AS (
		SELECT
				s.customer_id,
				s.order_date,
				m.product_name,
				m.price ,
				-- Tạo cột tính điểm 
				CASE 
					WHEN m.product_name = 'sushi' THEN ( m.price * 20 )
					ELSE ( m.price * 10 )
				END AS points_by_item
		FROM dannys_diner.sales s
		INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id 
)
SELECT
		p.customer_id,
		SUM(p.points_by_item) AS points_by_cust
FROM  points_by_item_by_cust p
GROUP BY p.customer_id
ORDER BY points_by_cust DESC


------------------------------------------------
-- 5.10. 
-- Trong tuần đầu tiên sau khi khách hàng tham gia chương trình (bao gồm ngày tham gia)
-- họ kiếm được điểm gấp đôi cho tất cả các món, không chỉ sushi
-- vậy vào cuối tháng 1, khách hàng A và B có bao nhiêu điểm?

-- Ý nghĩa kinh doanh:
--- Đây là chương trình chào mừng thành viên mới – tạo động lực chi tiêu ngay trong tuần đầu để khách hàng hình thành thói quen
--- Tính đến cuối tháng 1 giúp đo lường hiệu quả của chương trình trong "tháng đầu tiên" (thường dùng để đánh giá retention sớm)
--- So sánh điểm của tuần đầu với các tuần sau để biết mức độ hưởng ứng.

-- bảng : sales, members (join_date tính tuần đầu ), menu lấy price
-- nhóm theo khách hàng để tính điểm cho mỗi khách 
-- đk: phạm vi dữ liệu là cuối tháng 1 
-- tuần đầu (1 đô = 20 điểm ) , còn lại (sau tuần đầu, trước khi đk thành viên ) tính bình thường (shshi thì 1 đô là 20 điểm, còn lại 1 đô là 10 điểm )
WITH calculate_point_table AS(
	SELECT
			s.customer_id, 
			s.order_date,
			b.join_date,
			DATEDIFF(day, b.join_date, s.order_date) AS days_from_member,
			-- Tạo cột xem có phải tuần đầu tiên hay không 
			CASE
				WHEN DATEDIFF(day, b.join_date, s.order_date) BETWEEN 0 AND 6 THEN 1
				ELSE 0
			END AS First_Week, 
			-- Tính điểm cho khách 
			CASE
				WHEN DATEDIFF(day, b.join_date, s.order_date) BETWEEN 0 AND 6 THEN ( m.price * 20 ) 
				ELSE   (
							CASE
								WHEN m.product_name ='sushi' THEN (m.price * 20) 
								ELSE (m.price * 10)
							END 
						) 
			END AS points_by_item_for_week 
	FROM dannys_diner.sales s
	INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id
	INNER JOIN dannys_diner.members b ON s.customer_id = b.customer_id
	WHERE s.order_date <= '2021-01-31'
)
SELECT
		c.customer_id,
		SUM(c.points_by_item_for_week) AS total_points_january
FROM  calculate_point_table c
GROUP BY c.customer_id
ORDER BY c.customer_id ASC,
		 SUM(c.points_by_item_for_week)  DESC


------------------------------------------------
-- 6. Câu hỏi thưởng
------------------------------------------------
-- 6.1. Kết hợp tất cả các dữ liệu
-- Ý nghĩa kinh doanh:
----- Tạo một báo cáo 360 độ cho mỗi giao dịch, bao gồm: 
----- thông tin khách hàng (thành viên hay không), chi tiết món ăn, giá, điểm thưởng, và các cột đánh dấu (ví dụ: "trước/sau khi thành viên", "tuần đầu chào mừng")
-----  Bảng này là nguồn cho các dashboard và phân tích tiếp theo.

SELECT
		s.customer_id,
		s.order_date,
		n.product_name,
		n.price,
		-- Tạo cột chỉ trạng thái thành viên
		CASE
			WHEN  s.order_date >=  m.join_date THEN 'Y'
			ELSE 'N'
		END AS status_member
FROM dannys_diner.sales s
LEFT OUTER JOIN dannys_diner.members m ON s.customer_id = m.customer_id 
LEFT OUTER JOIN dannys_diner.menu n	ON s.product_id = n.product_id 
 

------------------------------------------------
-- 6.2. Xếp hạng tất cả các dữ liệu
------------------------------------------------

----- Ý nghĩa kinh doanh:
----- Xếp hạng (ranking) giúp so sánh hiệu suất giữa các khách hàng, sản phẩm hoặc thời gian. Ví dụ:
 
 WITH rank_data AS(
	   SELECT
				s.customer_id,
				s.order_date,
				n.product_name,
				n.price,

				-- Tạo cột chỉ trạng thái thành viên
				CASE
					WHEN  s.order_date >=  m.join_date THEN 'Y'
					ELSE 'N'
				END AS status_member, 

				-- Tạo cột tính điểm (không áp dụng chương trinhd dành cho tuần đầu)
				CASE 
					WHEN n.product_name = 'sushi' THEN ( n.price * 20 )
					ELSE ( n.price * 10 )
				END AS points_by_item

		FROM dannys_diner.sales s
		LEFT OUTER JOIN dannys_diner.members m ON s.customer_id = m.customer_id 
		LEFT OUTER JOIN dannys_diner.menu n	ON s.product_id = n.product_id 
 )
 SELECT
		*,
		CASE
			WHEN r.status_member = 'N' THEN NULL
			ELSE RANK() OVER (PARTITION BY r.customer_id, r.status_member ORDER BY r.points_by_item DESC)
		END AS ranking
 FROM	rank_data  r