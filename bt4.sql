-- ==========================================
-- BƯỚC 1: KHỞI TẠO BẢNG DỮ LIỆU
-- ==========================================
CREATE DATABASE HospitalPharmacy;
USE HospitalPharmacy;

CREATE TABLE Pharmacy_Inventory (
    Inventory_ID INT AUTO_INCREMENT PRIMARY KEY,
    Drug_Name VARCHAR(255),
    Batch_Number VARCHAR(50),
    Expiry_Date DATE,
    Quantity INT
);

-- Bơm một vài dữ liệu giả lập để test (Trong thực tế là >2 triệu dòng)
INSERT INTO Pharmacy_Inventory (Drug_Name, Batch_Number, Expiry_Date, Quantity) VALUES
('Paracetamol 500mg', 'B001', '2024-12-31', 1000),
('Amoxicillin 250mg', 'B002', '2024-10-15', 500),
('Paracetamol 500mg', 'B003', '2025-01-20', 2000),
('Vitamin C 1000mg', 'B004', '2026-05-10', 3000);

-- ==========================================
-- BƯỚC 2: SO SÁNH SINGLE INDEX VÀ COMPOSITE INDEX
-- ==========================================
-- 2.1 THỬ NGHIỆM VỚI 2 INDEX ĐƠN LẺ
CREATE INDEX idx_drug_name ON Pharmacy_Inventory(Drug_Name);
CREATE INDEX idx_expiry_date ON Pharmacy_Inventory(Expiry_Date);

-- Phân tích: MySQL thường chỉ chọn 1 Index tốt nhất (ví dụ idx_drug_name) để lọc trước, 
-- sau đó phải quét qua các kết quả đó để lọc tiếp ngày hết hạn (hoặc dùng Index Merge nhưng tốn chi phí gom).
EXPLAIN SELECT * FROM Pharmacy_Inventory 
WHERE Drug_Name = 'Paracetamol 500mg' AND Expiry_Date = '2024-12-31';

-- 2.2 XÓA INDEX ĐƠN VÀ THAY BẰNG COMPOSITE INDEX
DROP INDEX idx_drug_name ON Pharmacy_Inventory;
DROP INDEX idx_expiry_date ON Pharmacy_Inventory;

-- Tạo Chỉ mục kết hợp (Quy tắc Left-Most Prefix: Cột nào hay dùng điều kiện '=' hoặc độ phân tán cao thì để trước)
CREATE INDEX idx_composite_drug_expiry ON Pharmacy_Inventory(Drug_Name, Expiry_Date);

-- Phân tích: Database sẽ lọc đồng thời cả Tên thuốc và Ngày hết hạn ngay trên cấu trúc cây B-Tree.
-- Hiệu năng tăng vọt, cột "key" sẽ hiển thị sử dụng đúng idx_composite_drug_expiry.
EXPLAIN SELECT * FROM Pharmacy_Inventory 
WHERE Drug_Name = 'Paracetamol 500mg' AND Expiry_Date = '2024-12-31';


-- ==========================================
-- BƯỚC 3: XỬ LÝ VẤN ĐỀ TÌM KIẾM VỚI TOÁN TỬ LIKE
-- ==========================================

-- TÌNH HUỐNG LỖI HIỆU NĂNG:
-- Phân tích bằng EXPLAIN, bạn sẽ thấy cột 'type' là 'ALL' (Full Table Scan). Index bị vô hiệu hóa hoàn toàn.
EXPLAIN SELECT * FROM Pharmacy_Inventory WHERE Drug_Name LIKE '%Paracetamol%';

-- GIẢI PHÁP 1: Tối ưu lại cấu trúc LIKE (Chỉ dùng ký tự % ở cuối)
-- Khi bỏ % ở đầu, B-Tree Index vẫn có thể hoạt động để tìm các chuỗi BẮT ĐẦU bằng từ khóa (Range Scan).
EXPLAIN SELECT * FROM Pharmacy_Inventory WHERE Drug_Name LIKE 'Paracetamol%';

-- GIẢI PHÁP 2: Sử dụng FULL-TEXT SEARCH (Tối ưu nhất cho tìm kiếm chuỗi bất kỳ)
-- Thêm Full-text Index cho cột Drug_Name
ALTER TABLE Pharmacy_Inventory ADD FULLTEXT ft_idx_drug_name(Drug_Name);

-- Truy vấn sử dụng MATCH ... AGAINST tốc độ sẽ nhanh như chớp mắtt dù dữ liệu lớn
EXPLAIN SELECT * FROM Pharmacy_Inventory 
WHERE MATCH(Drug_Name) AGAINST('Paracetamol' IN NATURAL LANGUAGE MODE);