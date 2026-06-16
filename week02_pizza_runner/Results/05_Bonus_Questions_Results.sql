USE Pizza_Runner;

-- NÂNG CAO ĐỘ LINH HOẠT, GIẢM THAO TÁC THỰC THI, TAO HÀM THỦ TỤC ĐỂ MỖI KHI THÊM LOẠI PIZZA CHỈ CẦN KHAI BÁO 3 THỨ
-- I. TỪ BÀI TOÁN QUẢN TRỊ ĐẾN GIẢI PHÁP KỸ THUẬT


 -- PizzaID, PizzaName, Toppings (cho chọn từ 1 đến 12, cách nhau bởi ký hiệu ', '
 /*
 
 Khi Pizza Runner bước vào giai đoạn tăng trưởng, Danny nhận ra một nhu cầu thiết yếu:  thực đơn không thể đứng yên.
 Khách hàng ngày càng đòi hỏi sự mới lạ, và việc thêm một chiếc pizza mới – dù chỉ là biến thể từ các nguyên liệu sẵn có 
 – cũng phải được thực hiện một cách nhanh chóng, chính xác và an toàn

 Nếu mỗi lần thêm món, nhân viên phải thao tác thủ công trên nhiều bảng (pizza_names, pizza_recipes), 
 rủi ro sai sót là rất lớn: nhập sai ID, chọn nhầm topping, thậm chí làm hỏng dữ liệu hiện c

 Giải pháp được đưa ra là tạo một thủ tục lưu trữ (stored procedure) – sp_AddCustomPizza
 Thủ tục này đóng vai trò như một “trợ lý bếp thông minh”: chỉ cần cung cấp ba tham số (mã pizza, tên món, danh sách topping), toàn bộ quá trình kiểm tra và ghi nhận sẽ được tự động hóa.
  Nhờ đó, Danny có thể ủy quyền việc cập nhật thực đơn cho quản lý ca mà không lo lắng về tính toàn vẹn dữ liệu.

  Logic nghiệp vụ của sp_AddCustomPizza:
  - 1. Kiểm tra đầu vào: Đảm bảo tất cả mã topping được liệt kê đều nằm trong khoảng 1–12. Nếu có mã không hợp lệ, lập tức thông báo lỗi và dừng xử lý.

  - 2. Thêm tên món vào danh mục: Chèn một dòng mới vào bảng pizza_names với pizza_id và pizza_name được cung cấp

  - 3. Thêm công thức vào kho bếp: Tách chuỗi topping (phân cách bằng dấu phẩy) và chèn từng topping tương ứng vào bảng pizza_recipes, mỗi topping một dòng.

  - 4. Xử lý lỗi: Bắt các tình huống như trùng mã pizza, to
  pping ngoài phạm vi, hoặc lỗi hệ thống, và trả về thông báo phù hợp.
 
 */


 -- II. NỘI DUNG THỦ TỤC VÀ KIỂM THỬ
 -- Toàn bộ mã nguồn dưới đây được viết bằng T‑SQL và chạy trên SQL Server

 -- 1. Khai báo thủ tục

CREATE  PROCEDURE destination.sp_AddCustomPizza
		@PizzaID INT,
		@PizzaName NVARCHAR(100),
		@Toppings NVARCHAR(MAX)
AS
BEGIN
		SET NOCOUNT ON;

		BEGIN TRY
				-- 1. BẪY CHỦ ĐỘNG: Kiểm tra xem có topping nào bị ngoài khoảng 1-12 không
				-- Nếu phát hiện, ta tự kích hoạt lệnh THROW để đá luồng chạy xuống khối CATCH
				IF EXISTS (
						SELECT 1 
						FROM STRING_SPLIT(@Toppings, ',') 
						WHERE CAST(TRIM(value) AS INT) NOT BETWEEN 1 AND 12
				)
				BEGIN
						-- Khai báo mã lỗi tự định nghĩa (50001) và thông báo lỗi
						;THROW 50001, N'Có Topping nằm ngoài phạm vi hợp lệ (chỉ được chọn từ 1 đến 12)!', 1;
				END;

				-- 2. Nếu topping hợp lệ, tiến hành chèn ID và tên bánh
				INSERT INTO destination.pizza_names (pizza_id, pizza_name)
				VALUES (@PizzaID, @PizzaName);

				-- 3. Tách chuỗi và chèn nguyên liệu vào bếp
				INSERT INTO destination.pizza_recipes (pizza_id, toppings)
				SELECT 
						@PizzaID,
						CAST(TRIM(value) AS INT)
				FROM	STRING_SPLIT(@Toppings, ',');

				-- Nếu mọi thứ mượt mà, in thông báo thành công
				PRINT N'🎉 THÀNH CÔNG: Đã thêm bánh ' + @PizzaName + N' (ID = ' + CAST(@PizzaID AS NVARCHAR(10)) + N')!';

		END TRY
		BEGIN CATCH
				-- KHỐI PHÂN TÍCH VÀ XỬ LÝ LỖI
				DECLARE @ErrorNum INT = ERROR_NUMBER();

				-- Trường hợp A: Trùng khóa chính Primary Key (Mã lỗi 2627 hoặc 2601)
				IF @ErrorNum IN (2627, 2601)
				BEGIN
						PRINT N'❌ THẤT BẠI (Lỗi Trùng ID): PizzaID ' + CAST(@PizzaID AS NVARCHAR(10)) + N' đã tồn tại trong hệ thống. Vui lòng chọn ID khác!';
				END
				
				-- Trường hợp B: Topping bị sai khoảng (Mã lỗi 50001 do ta tự ném ra ở trên)
				ELSE IF @ErrorNum = 50001
				BEGIN
						PRINT N'❌ THẤT BẠI (Lỗi Topping): ' + ERROR_MESSAGE();
				END
				
				-- Trường hợp C: Các lỗi hệ thống không lường trước được (lỗi bộ nhớ, sai kiểu dữ liệu...)
				ELSE
				BEGIN
						PRINT N'❌ THẤT BẠI (Lỗi Hệ Thống): ' + ERROR_MESSAGE();
				END
		END CATCH
END;

-- 2. Kiểm thử với các trường hợp thực tế

-- Trường hợp 1: Thêm món hợp lệ
EXEC destination.sp_AddCustomPizza 
    @PizzaID = 6, 
    @PizzaName = N'Tomato only', 
    @Toppings = '1, 3, 7, 11'; -- Khai báo số lượng và loại tùy ý


-- Trường hợp 2: Trùng mã pizza
EXEC destination.sp_AddCustomPizza 
    @PizzaID = 3, 
    @PizzaName = N'Supreme', 
    @Toppings = '1, 3, 7, 11';

-- Trường hợp 3: Topping không hợp lệ
EXEC destination.sp_AddCustomPizza  
    @PizzaID = 5,  
    @PizzaName = N'Pizza Lỗi Topping',  
    @Toppings = '1, 3, 15, 7';
	 

-- 3. Xác minh kết quả
-- Xem toàn bộ danh mục pizza
SELECT * FROM destination.pizza_names;

-- 2. Kiểm tra kho công thức bếp của chiếc bánh số 4
-- Hệ thống phải tự động sinh ra đúng 4 dòng nguyên liệu tương ứng thay vì 12 dòng như trước
SELECT * FROM destination.pizza_recipes 
WHERE pizza_id = 4
ORDER BY toppings ASC;


-- III. GIÁ TRỊ KINH DOANH VÀ  ĐỀ XUẤT MỞ RỘNG
/*

Việc triển khai sp_AddCustomPizza mang lại ba lợi ích trực tiếp cho Pizza Runner:

- 1. Tiết kiệm thời gian
 Thao tác thêm món giảm từ vài phút (thủ công) xuống chỉ còn một dòng lệnh.

- 2. Đảm bảo toàn vẹn dữ liệu
Các ràng buộc kiểm tra topping và khóa chính được thực thi tự động, không thể bỏ sót.

- 3. Trao quyền an toàn
Nhân viên không cần biết cấu trúc bảng vẫn có thể cập nhật thực đơn dưới sự giám sát của thủ tục.


Trong tương lai, Danny có thể mở rộng thủ tục này để cập nhật giá bán, mô tả món, hoặc tự động ghi log mỗi lần thay đổi
– từng bước xây dựng một hệ thống quản trị thực đơn chuyên nghiệp ngay trên nền tảng cơ sở dữ liệu hiện có.

*/