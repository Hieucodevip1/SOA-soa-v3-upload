-- =============================================================================
-- HỆ THỐNG QUẢN LÝ ĐÀO TẠO & ĐỒ ÁN TỐT NGHIỆP QNU (KIẾN TRÚC SOA)
-- FILE TỔNG HỢP TOÀN BỘ CSDL VÀ DỮ LIỆU MẪU (DATABASE INITIALIZATION & SEED)
-- =============================================================================
-- Kiến trúc Database-per-Service: Mỗi microservice sở hữu 1 database độc lập.
-- Bao gồm 5 CSDL:
--   1. soa_auth         -> Quản lý tài khoản, vai trò và phân quyền JWT
--   2. soa_student      -> Quản lý hồ sơ sinh viên, thông tin lớp và chuyên ngành
--   3. soa_topic        -> Quản lý đề tài / lớp học phần, phân công giảng viên và chỉ tiêu
--   4. soa_registration -> Quản lý đăng ký học phần, xét duyệt, điểm số
--   5. soa_notification -> Quản lý thông báo theo sự kiện bất đồng bộ
--
-- Hướng dẫn thực thi:
--   Cách 1 (MySQL CLI):   mysql -u root -p < database/init_all_databases.sql
--   Cách 2 (Workbench):   Mở file database/init_all_databases.sql và nhấn Execute (Ctrl + Shift + Enter)
--   Cách 3 (phpMyAdmin):  Vào tab "Import" -> Chọn file database/init_all_databases.sql -> Go
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================================
-- 1. DỊCH VỤ XÁC THỰC & PHÂN QUYỀN (Auth Service) - DATABASE: soa_auth
-- =============================================================================
CREATE DATABASE IF NOT EXISTS `soa_auth` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `soa_auth`;

DROP TABLE IF EXISTS `TAIKHOAN`;
CREATE TABLE IF NOT EXISTS `TAIKHOAN` (
    `MaTK` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `TenDangNhap` VARCHAR(50) NOT NULL UNIQUE,
    `MatKhau` VARCHAR(255) NOT NULL,
    `HoTen` VARCHAR(100) NOT NULL,
    `Email` VARCHAR(100) NULL,
    `VaiTro` VARCHAR(20) NOT NULL DEFAULT 'sinhvien',
    `MaSV` VARCHAR(20) NULL,
    `Lop` VARCHAR(50) NULL,
    `Nganh` VARCHAR(100) NULL DEFAULT 'Công nghệ phần mềm',
    `NgayTao` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ghi chú: Mật khẩu mặc định cho toàn bộ tài khoản mẫu là: 123456
-- Chuỗi hash bcrypt (10 rounds): $2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa
INSERT INTO `TAIKHOAN` (`TenDangNhap`, `MatKhau`, `HoTen`, `Email`, `VaiTro`, `MaSV`, `Lop`, `Nganh`) VALUES
('admin', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'Quản trị viên hệ thống', 'admin@qnu.edu.vn', 'admin', NULL, NULL, 'Toàn trường'),
('GV001', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'TS. Nguyễn Thanh Bình', 'binhnt@qnu.edu.vn', 'giangvien', 'GV001', NULL, 'Công nghệ phần mềm'),
('GV002', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'ThS. Trần Thị Mai', 'maitt@qnu.edu.vn', 'giangvien', 'GV002', NULL, 'Hệ thống thông tin'),
('GV003', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'TS. Vũ Thị Phương', 'phuongvt@qnu.edu.vn', 'giangvien', 'GV003', NULL, 'Trí tuệ nhân tạo'),
('GV004', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'PGS.TS. Lê Văn Hoàng', 'hoanglv@qnu.edu.vn', 'giangvien', 'GV004', NULL, 'Khoa học máy tính'),
('GV005', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'ThS. Phạm Quốc Tuấn', 'tuanpq@qnu.edu.vn', 'giangvien', 'GV005', NULL, 'Mạng máy tính & ATTT'),
('GV006', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'TS. Vũ Hải Đăng', 'dangvh@qnu.edu.vn', 'giangvien', 'GV006', NULL, 'Khoa học dữ liệu'),
('GV007', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'TS. Đặng Hoài Phương', 'phuongdh@qnu.edu.vn', 'giangvien', 'GV007', NULL, 'Kỹ thuật phần mềm'),
('GV008', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'ThS. Hoàng Văn Em', 'emhv@qnu.edu.vn', 'giangvien', 'GV008', NULL, 'Công nghệ phần mềm'),
('GV009', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'ThS. Lê Minh Triết', 'trietlm@qnu.edu.vn', 'giangvien', 'GV009', NULL, 'Hệ thống nhúng & IoT'),
('GV010', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'TS. Đỗ Ngọc Hùng', 'hungdn@qnu.edu.vn', 'giangvien', 'GV010', NULL, 'Kỹ thuật dữ liệu'),
('gv01', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'TS. Nguyễn Thanh Bình', 'binhnt@qnu.edu.vn', 'giangvien', 'GV001', NULL, 'Công nghệ phần mềm'),
('gv02', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'ThS. Trần Thị Mai', 'maitt@qnu.edu.vn', 'giangvien', 'GV002', NULL, 'Hệ thống thông tin'),
('SV001', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'Vũ Đức Hiếu', 'hieuvd@qnu.edu.vn', 'sinhvien', 'SV001', 'DHKTPM20', 'Công nghệ phần mềm'),
('SV002', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'Lê Minh Châu', 'chaulm@qnu.edu.vn', 'sinhvien', 'SV002', 'DHKTPM20', 'Công nghệ phần mềm'),
('SV003', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'Trần Quốc Đạt', 'dattq@qnu.edu.vn', 'sinhvien', 'SV003', 'DHHTTT20', 'Hệ thống thông tin'),
('SV004', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'Nguyễn Thị Bích', 'bichnt@qnu.edu.vn', 'sinhvien', 'SV004', 'DHKTPM21', 'Công nghệ phần mềm'),
('SV005', '$2b$10$H82KtOyjcpuh0vv3VKDNAOxOLeogXFToZz8k5hPUbKQJ6m0vYMBLa', 'Phạm Văn Nam', 'nampv@qnu.edu.vn', 'sinhvien', 'SV005', 'DHKHMT20', 'Khoa học máy tính');

-- =============================================================================
-- 2. DỊCH VỤ SINH VIÊN (Student Service) - DATABASE: soa_student
-- =============================================================================
CREATE DATABASE IF NOT EXISTS `soa_student` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `soa_student`;

DROP TABLE IF EXISTS `SINHVIEN`;
CREATE TABLE IF NOT EXISTS `SINHVIEN` (
    `MaSV` VARCHAR(20) NOT NULL PRIMARY KEY,
    `HoTen` VARCHAR(100) NOT NULL,
    `Email` VARCHAR(100) NULL,
    `Lop` VARCHAR(50) NULL,
    `Nganh` VARCHAR(100) DEFAULT 'Công nghệ phần mềm',
    `SoTCTichLuy` INT DEFAULT 110
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `SINHVIEN` (`MaSV`, `HoTen`, `Email`, `Lop`, `Nganh`, `SoTCTichLuy`) VALUES
('SV001', 'Vũ Đức Hiếu', 'hieuvd@qnu.edu.vn', 'DHKTPM20', 'Công nghệ phần mềm', 122),
('SV002', 'Lê Minh Châu', 'chaulm@qnu.edu.vn', 'DHKTPM20', 'Công nghệ phần mềm', 112),
('SV003', 'Trần Quốc Đạt', 'dattq@qnu.edu.vn', 'DHHTTT20', 'Hệ thống thông tin', 105),
('SV004', 'Nguyễn Thị Bích', 'bichnt@qnu.edu.vn', 'DHKTPM21', 'Công nghệ phần mềm', 65),
('SV005', 'Phạm Văn Nam', 'nampv@qnu.edu.vn', 'DHKHMT20', 'Khoa học máy tính', 118);

-- =============================================================================
-- 3. DỊCH VỤ ĐỀ TÀI / LỚP HỌC PHẦN (Topic Service) - DATABASE: soa_topic
-- =============================================================================
CREATE DATABASE IF NOT EXISTS `soa_topic` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `soa_topic`;

DROP TABLE IF EXISTS `DETAI`;
CREATE TABLE IF NOT EXISTS `DETAI` (
    `MaDT` VARCHAR(20) NOT NULL PRIMARY KEY,
    `TenDT` VARCHAR(255) NOT NULL,
    `MoTa` TEXT NULL,
    `GiangVienHuongDan` VARCHAR(100) NULL,
    `MaGV` VARCHAR(50) NULL,
    `Nganh` VARCHAR(100) DEFAULT 'Công nghệ phần mềm',
    `SoTinChi` INT DEFAULT 10,
    `HocKy` VARCHAR(50) DEFAULT 'Học kỳ 1 (Niên khóa 2022 - 2026)',
    `GioiHanSV` INT DEFAULT 5,
    `TrangThaiMo` TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `DETAI` (`MaDT`, `TenDT`, `MoTa`, `GiangVienHuongDan`, `MaGV`, `Nganh`, `SoTinChi`, `HocKy`, `GioiHanSV`, `TrangThaiMo`) VALUES
('DT001', 'Xây dựng hệ thống quản lý đào tạo & đồ án theo kiến trúc SOA', 'Thiết kế kiến trúc hướng dịch vụ độc lập, loose coupling, event-driven, registry & gateway', 'TS. Nguyễn Thanh Bình', 'GV001', 'Công nghệ phần mềm', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 3, 1),
('DT002', 'Ứng dụng Trí tuệ nhân tạo nhận diện khuôn mặt điểm danh sinh viên', 'Mô hình học sâu kết hợp xử lý thị giác máy tính và camera giám sát trường học', 'TS. Nguyễn Thanh Bình', 'GV001', 'Công nghệ phần mềm', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 4, 1),
('DT003', 'Xây dựng ứng dụng di động hỗ trợ quản lý học tập và rèn luyện sinh viên QNU', 'Ứng dụng Flutter/React Native kết hợp hệ thống API Backend đồng bộ dữ liệu đào tạo', 'ThS. Hoàng Văn Em', 'GV008', 'Công nghệ phần mềm', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 3, 1),
('DT004', 'Phát triển nền tảng học trực tuyến E-learning tích hợp Microservices', 'Hệ thống học tập trực tuyến, livestream bài giảng và chấm điểm trắc nghiệm tự động', 'ThS. Lê Minh Triết', 'GV009', 'Công nghệ phần mềm', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 3, 1),
('DT005', 'Hệ thống kiểm thử tự động CI/CD cho dự án phần mềm doanh nghiệp', 'Tích hợp Docker, Kubernetes, Jenkins và SonarQube kiểm tra chất lượng mã nguồn', 'TS. Nguyễn Thanh Bình', 'GV001', 'Công nghệ phần mềm', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 2, 1),
('DT006', 'Hệ thống hỗ trợ ra quyết định & phân tích dữ liệu học tập sinh viên', 'Kho dữ liệu và phân tích dữ liệu đào tạo trường Đại học', 'ThS. Trần Thị Mai', 'GV002', 'Hệ thống thông tin', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 3, 1),
('DT007', 'Xây dựng cổng thanh toán học phí trực tuyến liên ngân hàng', 'Hệ thống thanh toán bảo mật chuẩn PCI-DSS, kết nối cổng thanh toán VNPay / Momo', 'ThS. Trần Thị Mai', 'GV002', 'Hệ thống thông tin', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 2, 1),
('DT008', 'Hệ thống hoạch định nguồn lực doanh nghiệp ERP cho chuỗi cung ứng', 'Phần mềm ERP quản trị kho vận, đơn hàng, hóa đơn điện tử cho doanh nghiệp sản xuất', 'PGS.TS. Trịnh Xuân Dũng', 'GV012', 'Hệ thống thông tin', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 4, 1),
('DT009', 'Xây dựng hệ thống quản lý thông tin bệnh viện số (Hospital HIS)', 'Quản trị hồ sơ bệnh án điện tử, tiếp nhận bệnh nhân, viện phí và đơn thuốc', 'ThS. Trần Thị Mai', 'GV002', 'Hệ thống thông tin', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 3, 1),
('DT010', 'Nghiên cứu mô hình ngôn ngữ lớn (LLM) hỗ trợ tư vấn tuyển sinh đại học', 'Xây dựng Chatbot RAG dựa trên Llama/GPT tích hợp cơ sở tri thức tuyển sinh QNU', 'TS. Vũ Thị Phương', 'GV003', 'Trí tuệ nhân tạo', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 2, 1),
('DT011', 'Ứng dụng Deep Learning phát hiện sớm bệnh cây trồng qua ảnh lá', 'Mô hình CNN phát hiện sâu bệnh trên cây xoài và lúa tại khu vực Nam Trung Bộ', 'TS. Vũ Thị Phương', 'GV003', 'Trí tuệ nhân tạo', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 3, 1),
('DT012', 'Phát hiện gian lận thi cử trực tuyến sử dụng thị giác máy tính', 'Theo dõi cử chỉ mắt, tư thế ngồi và phát hiện tài liệu lạ trong phòng thi online', 'TS. Vũ Thị Phương', 'GV003', 'Trí tuệ nhân tạo', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 3, 1),
('DT013', 'Tối ưu hóa lập lịch xe buýt đô thị dựa trên thuật toán di truyền', 'Thuật toán Genetic Algorithm giải bài toán định tuyến và phân bổ chuyến xe buýt thông minh', 'PGS.TS. Lê Văn Hoàng', 'GV004', 'Khoa học máy tính', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 2, 1),
('DT014', 'Xây dựng Data Warehouse & Dashboard phân tích hiệu quả kinh doanh', 'Mô hình dữ liệu hình sao (Star Schema), ETL pipeline và trực quan hóa PowerBI', 'TS. Đỗ Ngọc Hùng', 'GV010', 'Kỹ thuật dữ liệu', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 3, 1),
('DT015', 'Hệ thống giám sát và phát hiện xâm nhập mạng nội bộ (IDS/IPS)', 'Phân tích gói tin mạng thời gian thực, phát hiện tấn công DDoS và mã độc', 'ThS. Phạm Quốc Tuấn', 'GV005', 'Mạng máy tính & An toàn thông tin', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 3, 1),
('DT016', 'Ứng dụng công nghệ Blockchain trong xác thực văn bằng và chứng chỉ số', 'Smart Contract Ethereum / Polygon lưu trữ hash văn bằng tốt nghiệp chống làm giả', 'ThS. Phạm Quốc Tuấn', 'GV005', 'Mạng máy tính & An toàn thông tin', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 2, 1),
('DT017', 'Hệ thống IoT quan trắc môi trường và cảnh báo mưa lũ tại Bình Định', 'Cảm biến mực nước, nhiệt độ kết nối mạng truyền thông LoRaWAN gửi dữ liệu đám mây', 'PGS.TS. Lê Văn Hoàng', 'GV004', 'Khoa học máy tính', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 4, 1),
('DT018', 'Phần mềm mô phỏng thí nghiệm vật lý ảo hỗ trợ dạy học trực quan', 'Mô phỏng 3D cơ học và quang học tương tác cho học sinh trung học phổ thông', 'TS. Nguyễn Thị Lan', 'GV011', 'Sư phạm Tin học', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 3, 1),
('DT019', 'Xây dựng mô hình dự báo biến động giá nông sản sử dụng Time Series', 'Mô hình chuỗi thời gian ARIMA kết hợp LSTM dự báo giá lúa và tiêu xuất khẩu', 'TS. Nguyễn Thị Lan', 'GV011', 'Toán ứng dụng', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 2, 1),
('DT020', 'Nền tảng chuyển đổi số du lịch Quy Nhơn tích hợp bản đồ số thực tế ảo (VR 360)', 'Bản đồ số định vị điểm đến, tour du lịch ảo 360 độ và hệ thống đặt vé tham quan', 'ThS. Hoàng Văn Em', 'GV008', 'Công nghệ phần mềm', 10, 'Học kỳ 1 (Niên khóa 2022 - 2026)', 4, 1);

-- =============================================================================
-- 4. DỊCH VỤ ĐĂNG KÝ HỌC PHẦN / ĐỒ ÁN (Registration Service) - DATABASE: soa_registration
-- =============================================================================
CREATE DATABASE IF NOT EXISTS `soa_registration` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `soa_registration`;

DROP TABLE IF EXISTS `DANGKY`;
CREATE TABLE IF NOT EXISTS `DANGKY` (
    `MaDK` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `MaSV` VARCHAR(20) NOT NULL,
    `MaDT` VARCHAR(20) NOT NULL,
    `NgayDangKy` DATE NULL,
    `TrangThai` VARCHAR(50) DEFAULT 'Cho duyet',
    `Diem` DECIMAL(4,2) NULL,
    `NhanXet` TEXT NULL,
    `LyDoTuChoi` VARCHAR(255) NULL,
    KEY `idx_sv` (`MaSV`),
    KEY `idx_dt` (`MaDT`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `DANGKY` (`MaSV`, `MaDT`, `NgayDangKy`, `TrangThai`, `Diem`, `NhanXet`, `LyDoTuChoi`) VALUES
('SV001', 'DT001', '2026-10-15', 'Da duyet', 9.50, 'Đồ án hoàn thành xuất sắc, kiến trúc phân tán chuẩn SOA, báo cáo tự tin.', NULL),
('SV002', 'DT002', '2026-10-18', 'Da duyet', NULL, 'Đạt điều kiện thực hiện đề tài.', NULL),
('SV003', 'DT006', '2026-10-22', 'Cho duyet', NULL, NULL, NULL),
('SV004', 'DT003', '2026-10-23', 'Tu choi', NULL, NULL, 'Chưa đủ điều kiện tham gia lớp học phần'),
('SV005', 'DT013', '2026-10-20', 'Da duyet', 8.50, 'Thuật toán di truyền tối ưu tốt, mô phỏng tuyến đường chính xác.', NULL);

-- =============================================================================
-- 5. DỊCH VỤ THÔNG BÁO (Notification Service) - DATABASE: soa_notification
-- =============================================================================
CREATE DATABASE IF NOT EXISTS `soa_notification` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `soa_notification`;

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `event_id` VARCHAR(64) NOT NULL,
    `topic` VARCHAR(100) NOT NULL,
    `audience` VARCHAR(100) NOT NULL,
    `title` VARCHAR(200) NOT NULL,
    `message` VARCHAR(500) NOT NULL,
    `is_read` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_event_audience` (`event_id`, `audience`),
    KEY `idx_audience` (`audience`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `notifications` (`event_id`, `topic`, `audience`, `title`, `message`, `is_read`) VALUES
('seed-all-1', 'system.announcement', 'all', '📢 Khởi động Đợt Đăng ký Đồ án Tốt nghiệp & Lớp Học phần K20', 'Cổng Đào tạo Trường Đại học Quy Nhơn thông báo mở cổng đăng ký đề tài tốt nghiệp cho sinh viên khóa 2022 - 2026. Thời gian đăng ký từ 15/10 đến 30/11.', 0),
('seed-all-2', 'topic.created', 'all', '📚 Mở đăng ký 20 đề tài & lớp học phần mới', 'Bộ môn và Khoa CNTT đã công bố 20 đề tài tốt nghiệp mới với các hướng Công nghệ phần mềm, Hệ thống thông tin, AI, Khoa học dữ liệu.', 0),
('seed-staff-1', 'registration.created', 'staff', '📝 Sinh viên nộp hồ sơ đăng ký đề tài', 'Sinh viên Vũ Đức Hiếu (SV001) đã đăng ký đề tài [DT001]. Trạng thái: Đã duyệt đăng ký.', 0),
('seed-staff-2', 'registration.created', 'staff', '📝 Sinh viên nộp hồ sơ đăng ký đề tài', 'Sinh viên Lê Minh Châu (SV002) đã đăng ký đề tài [DT002]. Trạng thái: Đã duyệt đăng ký.', 0),
('seed-staff-3', 'registration.created', 'staff', '📝 Sinh viên nộp hồ sơ đăng ký đề tài', 'Sinh viên Trần Quốc Đạt (SV003) vừa đăng ký đề tài [DT006]. Trạng thái: Chờ duyệt.', 0),
('seed-admin-1', 'user.registered', 'admin', '🛡️ Quản trị hệ thống', 'Hệ thống đã đồng bộ toàn bộ dịch vụ SOA (Auth, Student, Topic, Registration, Notification).', 0),
('seed-gv-1a', 'user.registered', 'user:GV001', '🎉 Kích hoạt tài khoản Giảng viên thành công!', 'Xin chào TS. Nguyễn Thanh Bình (GV001). Tài khoản giảng viên hướng dẫn của Quý Thầy/Cô đã được kích hoạt trên Cổng quản trị đào tạo QNU.', 0),
('seed-gv-1b', 'topic.created', 'user:GV001', '📌 Phân công hướng dẫn đề tài tốt nghiệp', 'Quý Thầy/Cô đã được phân công phụ trách đề tài [DT001], [DT002], [DT005] thuộc chuyên ngành Công nghệ phần mềm.', 0),
('seed-gv-1c', 'registration.created', 'user:GV001', '📝 Sinh viên đăng ký lớp học phần của bạn', 'Sinh viên Vũ Đức Hiếu (SV001) đã đăng ký đề tài [DT001]. Bạn đã duyệt và chấm điểm đạt 9.5/10.', 0),
('seed-gv-2a', 'user.registered', 'user:GV002', '🎉 Kích hoạt tài khoản Giảng viên thành công!', 'Xin chào ThS. Trần Thị Mai (GV002). Tài khoản giảng viên hướng dẫn của Quý Thầy/Cô đã được kích hoạt trên Cổng quản trị đào tạo QNU.', 0),
('seed-gv-2b', 'topic.created', 'user:GV002', '📌 Phân công hướng dẫn đề tài tốt nghiệp', 'Quý Thầy/Cô đã được phân công phụ trách đề tài [DT006], [DT007], [DT009] thuộc chuyên ngành Hệ thống thông tin.', 0),
('seed-gv-2c', 'registration.created', 'user:GV002', '📝 Sinh viên đăng ký lớp học phần của bạn', 'Sinh viên Trần Quốc Đạt (SV003) vừa nộp hồ sơ đăng ký đề tài [DT006]. Vui lòng truy cập mục "Duyệt sinh viên đăng ký" để xem xét.', 0),
('seed-gv-3a', 'user.registered', 'user:GV003', '🎉 Kích hoạt tài khoản Giảng viên thành công!', 'Xin chào TS. Vũ Thị Phương (GV003). Tài khoản giảng viên hướng dẫn của Quý Thầy/Cô đã được kích hoạt trên Cổng đào tạo QNU (Bộ môn Trí tuệ nhân tạo).', 0),
('seed-gv-3b', 'topic.created', 'user:GV003', '📌 Phân công hướng dẫn đề tài tốt nghiệp', 'Quý Thầy/Cô đã được phân công phụ trách đề tài [DT010], [DT011], [DT012] thuộc chuyên ngành Trí tuệ nhân tạo.', 0),
('seed-gv-4a', 'user.registered', 'user:GV004', '🎉 Kích hoạt tài khoản Giảng viên thành công!', 'Xin chào PGS.TS. Lê Văn Hoàng (GV004). Tài khoản giảng viên hướng dẫn của Quý Thầy/Cô đã được kích hoạt trên Cổng quản trị đào tạo QNU.', 0),
('seed-gv-4b', 'topic.created', 'user:GV004', '📌 Phân công hướng dẫn đề tài tốt nghiệp', 'Quý Thầy/Cô đã được phân công phụ trách đề tài [DT013], [DT017] thuộc chuyên ngành Khoa học máy tính.', 0),
('seed-gv-5', 'user.registered', 'user:GV005', '🎉 Kích hoạt tài khoản Giảng viên thành công!', 'Xin chào ThS. Phạm Quốc Tuấn (GV005). Bạn được phân công phụ trách đề tài [DT015], [DT016] Mạng máy tính & ATTT.', 0),
('seed-gv-6', 'user.registered', 'user:GV006', '🎉 Kích hoạt tài khoản Giảng viên thành công!', 'Xin chào TS. Vũ Hải Đăng (GV006). Tài khoản giảng viên của Quý Thầy/Cô đã được kích hoạt trên hệ thống đào tạo QNU.', 0),
('seed-sv-1', 'registration.status_changed', 'user:SV001', '🎉 Điểm số đồ án tốt nghiệp chính thức', 'Đề tài [DT001] "Xây dựng hệ thống quản lý đào tạo theo kiến trúc SOA" của bạn đã được giảng viên TS. Nguyễn Thanh Bình chấm 9.5 / 10 điểm.', 0),
('seed-sv-2', 'registration.status_changed', 'user:SV002', '✅ Đã duyệt đăng ký đề tài tốt nghiệp', 'Đăng ký đề tài [DT002] "Ứng dụng AI điểm danh sinh viên" của bạn đã được duyệt thành công.', 0),
('seed-sv-3', 'registration.created', 'user:SV003', '📝 Đã ghi nhận đăng ký đề tài', 'Hồ sơ đăng ký đề tài [DT006] của bạn đã gửi đến ThS. Trần Thị Mai. Vui lòng chờ xét duyệt.', 0);

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- HOÀN TẤT KHỞI TẠO VÀ NẠP DỮ LIỆU TOÀN BỘ 5 DỊCH VỤ SOA QNU!
-- =============================================================================

