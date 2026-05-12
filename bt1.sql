-- 1. TẠO VIEW BẢO MẬT CÓ RÀNG BUỘC=
CREATE VIEW Reception_Patient_View AS
SELECT 
    Patient_ID, 
    Full_Name, 
    Age, 
    Room_Number
FROM Patients
WHERE Age >= 0
WITH CHECK OPTION; -- "Người gác cổng" bảo vệ dữ liệu
-- 2. KIỂM THỬ (TESTING)

-- A. Kiểm thử bảo mật (Xem View)
-- Kết quả: Chỉ thấy ID, Tên, Tuổi, Phòng. Thông tin nhạy cảm đã bị giấu.
SELECT * FROM Reception_Patient_View;

-- B. Kiểm thử dữ liệu hợp lệ (Sẽ cập nhật thành công)
UPDATE Reception_Patient_View 
SET Age = 39 
WHERE Patient_ID = 1;

-- C. Kiểm thử dữ liệu lỗi (Sẽ bị từ chối)
-- Cố ý nhập tuổi âm -> Hệ thống báo lỗi "CHECK OPTION failed" để bảo vệ Database gốc
UPDATE Reception_Patient_View 
SET Age = -5 
WHERE Patient_ID = 2;