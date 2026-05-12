-- ==========================================
-- BƯỚC 1: KHỞI TẠO BẢNG VÀ DỮ LIỆU MẪU
-- ==========================================
-- Bảng Khoa
CREATE TABLE Departments (
    Dept_ID INT PRIMARY KEY,
    Dept_Name VARCHAR(100)
);

-- Bảng Hóa đơn (Kết nối bệnh nhân và khoa)
CREATE TABLE Invoices (
    Invoice_ID INT PRIMARY KEY,
    Patient_ID INT,
    Dept_ID INT,
    Amount DECIMAL(10, 2)
);

-- Chèn dữ liệu mẫu
INSERT INTO Departments VALUES (1, 'Nội'), (2, 'Ngoại');
INSERT INTO Invoices VALUES 
(101, 1, 1, 500.00), 
(102, 2, 1, 300.00), 
(103, 3, 2, 1000.00);

-- ==========================================
-- BƯỚC 2: TẠO VIEW BÁO CÁO DOANH THU
-- ==========================================
-- View này dùng GROUP BY để gom nhóm theo Khoa, 
-- dùng COUNT(DISTINCT) để đếm số bệnh nhân (tránh trùng lặp nếu 1 người có nhiều hóa đơn)
-- dùng SUM() để tính tổng tiền.
CREATE VIEW Department_Revenue_View AS
SELECT 
    d.Dept_Name AS 'Ten_Khoa',
    COUNT(DISTINCT i.Patient_ID) AS 'Tong_So_Benh_Nhan',
    SUM(i.Amount) AS 'Tong_Doanh_Thu'
FROM Departments d
JOIN Invoices i ON d.Dept_ID = i.Dept_ID
GROUP BY d.Dept_ID, d.Dept_Name;

-- ==========================================
-- BƯỚC 3: KIỂM THỬ (TESTING)
-- ==========================================
-- 3.1: Truy vấn để xem kết quả tính toán
-- Kế toán chạy lệnh này sẽ chỉ thấy số tổng, không thấy ai đang khám bệnh gì
SELECT * FROM Department_Revenue_View;

-- 3.2: Giả lập hành vi cố tình chỉnh sửa doanh thu trực tiếp trên View
-- Lệnh UPDATE dưới đây sẽ BỊ HỆ THỐNG TỪ CHỐI và báo lỗi: 
-- "Error Code: 1288. The target table Department_Revenue_View of the UPDATE is not updatable"
UPDATE Department_Revenue_View 
SET Tong_Doanh_Thu = 5000.00 
WHERE Ten_Khoa = 'Nội';