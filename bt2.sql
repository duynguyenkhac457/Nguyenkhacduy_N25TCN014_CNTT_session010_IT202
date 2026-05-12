-- ==========================================
-- BƯỚC 1: KHỞI TẠO DATABASE VÀ BẢNG
-- ==========================================
CREATE DATABASE HospitalDB;
USE HospitalDB;

CREATE TABLE Patients (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Full_Name VARCHAR(100),
    Phone VARCHAR(20),
    Age INT,
    Address VARCHAR(255)
);

-- ==========================================
-- BƯỚC 2: TẠO PROCEDURE VÀ NẠP 500.000 DỮ LIỆU
-- ==========================================
DELIMITER //
CREATE PROCEDURE SeedPatients()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 500000 DO
        INSERT INTO Patients (Full_Name, Phone, Age, Address)
        VALUES (CONCAT('Patient ', i), CONCAT('090', i), FLOOR(RAND()*100), 'Ho Chi Minh City');
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- GỌI LỆNH NÀY ĐỂ BƠM DỮ LIỆU (Đợi khoảng 1 - 3 phút để hệ thống chạy xong)
CALL SeedPatients();

-- ==========================================
-- BƯỚC 3: TEST TỐC ĐỘ ĐỌC / GHI TRƯỚC KHI CÓ INDEX
-- ==========================================
-- Đo tốc độ đọc (Ghi lại thời gian Duration):
SELECT * FROM Patients WHERE Phone = '090250000';

-- Xem cách DB quét toàn bảng (type sẽ là ALL, rows ~ 500000):
EXPLAIN SELECT * FROM Patients WHERE Phone = '090250000';

-- Tạo procedure nạp 1000 dòng để test ghi:
DELIMITER //
CREATE PROCEDURE Insert1000Patients()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 1000 DO
        INSERT INTO Patients (Full_Name, Phone, Age, Address)
        VALUES ('New Patient', CONCAT('091', FLOOR(RAND()*1000000)), 30, 'Hanoi');
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Đo tốc độ ghi (Ghi lại thời gian Duration):
CALL Insert1000Patients();

-- ==========================================
-- BƯỚC 4: ĐÁNH INDEX VÀ ĐO LƯỜNG LẠI SỰ CHÊNH LỆCH
-- ==========================================
-- Bắt đầu đánh Index cho cột Phone
CREATE INDEX idx_phone ON Patients(Phone);

-- Đo tốc độ đọc lại (Thời gian sẽ về mốc siêu tốc ~0.000 sec):
SELECT * FROM Patients WHERE Phone = '090250000';

-- Xem cách DB lấy dữ liệu (type sẽ là ref, rows giảm còn 1):
EXPLAIN SELECT * FROM Patients WHERE Phone = '090250000';

-- Đo tốc độ ghi lại (Thời gian chạy sẽ lâu hơn Bước 3 một chút do phải sắp xếp lại Index):
CALL Insert1000Patients();