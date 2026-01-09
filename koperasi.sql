-- ==========================================================
-- DATABASE RETAIL MINIMARKET (FIFO, FEFO, & PRICE HISTORY)
-- ==========================================================

-- 1. Tabel Kategori
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
) ENGINE=InnoDB;

-- 2. Tabel Master Produk
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT,
    barcode VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    product_detail VARCHAR(150) DEFAULT NULL,
    current_selling_price DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    min_stock INT DEFAULT 5,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) 
) ENGINE=InnoDB;

-- 3. Tabel Batch Stok (Jantung FIFO/FEFO)
CREATE TABLE stock_batches (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    purchase_price DECIMAL(12,2) NOT NULL, -- Modal per item
    initial_qty INT NOT NULL,
    remaining_qty INT NOT NULL,
    expiry_date DATE,
    received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX (expiry_date), -- Index untuk mempercepat FEFO
    INDEX (received_at)  -- Index untuk mempercepat FIFO
) ENGINE=InnoDB;

-- 4. Tabel Log Perubahan Harga
CREATE TABLE price_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    old_price DECIMAL(12,2),
    new_price DECIMAL(12,2),
    change_type ENUM('SELLING_PRICE', 'PURCHASE_PRICE') NOT NULL,
    reason VARCHAR(255),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

-- 5. Tabel Transaksi (Header)
CREATE TABLE sales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    total_bill DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_discount DECIMAL(12,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
) ENGINE=InnoDB;

-- 6. Tabel Detail Transaksi (Mencatat HPP & Laba per Batch)
CREATE TABLE sale_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    batch_id INT NOT NULL,
    qty INT NOT NULL,
    normal_price DECIMAL(12,2) NOT NULL,   -- Harga jual sebelum diskon
    discount_amount DECIMAL(12,2) DEFAULT 0.00,
    final_price DECIMAL(12,2) NOT NULL,    -- Harga jual setelah diskon
    hpp_at_sale DECIMAL(12,2) NOT NULL,    -- Modal (HPP) dari batch terkait
    item_profit DECIMAL(12,2) NOT NULL,    -- (Final Price - HPP) * Qty
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (batch_id) REFERENCES stock_batches(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

-- 7. Tabel Penyesuaian Stok (Stock Opname)
CREATE TABLE stock_adjustments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    batch_id INT NOT NULL,
    adjustment_type ENUM('SHRINKAGE', 'DAMAGE', 'GIFT', 'CORRECTION') NOT NULL,
    qty_change INT NOT NULL, -- Contoh: -2 untuk barang hilang
    loss_value DECIMAL(12,2), -- (Qty_change * HPP Batch)
    adjusted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    note TEXT,
    FOREIGN KEY (batch_id) REFERENCES stock_batches(id)
) ENGINE=InnoDB;


CREATE TABLE `users` (
  `id` int NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `username` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `satker` varchar(255) NOT NULL,
  `password` varchar(100) NOT NULL,
  `role` enum('user','operator','admin') NOT NULL,
  `limit` int DEFAULT '0',
  `limit_total` int DEFAULT '0',
  `profile_picture` varchar(255) DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `activity_logs` (
  `id` int NOT NULL,
  `message_text` varchar(255) NOT NULL,
  `message_summary` varchar(255) NOT NULL,
  `role` enum('admin','operator','user') NOT NULL,
  `user_id` int NOT NULL,
  `message_icon` varchar(50) NOT NULL,  
  `message_date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `submissions` (
  `id` int NOT NULL,
  `loan_type` text NOT NULL,
  `loan_date` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `loan_amount` INT NOT NULL,
  `loan_duration` INT NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(255) DEFAULT NULL,
  `submission_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `user_id` int NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tb_pengajuan`
--

INSERT INTO `submissions` (`id`, `loan_type`, `loan_date`, `loan_amount`, `loan_duration`, `is_read`, `created_at`, `status`, `submission_date`, `user_id`) VALUES
(79, 'Konsumtif', '2024-10-18', '12000', '4', 0, '2024-10-18 02:24:58', 'Menunggu Persetujuan', '2024-10-18 09:24:58', 1),
(80, 'Produktif', '2024-10-25', '5676', '3', 0, '2024-10-25 01:40:33', 'Telah Disetujui oleh Admin', '2024-10-25 08:40:33', 2),
(81, 'Konsumtif', '2024-10-25', '7586657', '6', 0, '2024-10-25 01:40:43', 'Telah Disetujui oleh Admin', '2024-10-25 08:40:43', 9),
(82, 'Konsumtif', '2024-10-25', '757', '12', 0, '2024-10-25 01:46:08', 'Dibatalkan oleh Admin', '2024-10-25 08:46:08', 110),
(83, 'Konsumtif', '2024-10-25', '68688', '6', 0, '2024-10-25 01:46:18', 'Dibatalkan oleh Admin', '2024-10-25 08:46:18', 110),
(84, 'Konsumtif', '2024-10-30', '757', '12', 0, '2024-10-30 02:32:15', 'Telah Disetujui oleh Admin', '2024-10-30 09:32:15', 2),
(85, 'Konsumtif', '2024-10-30', '757', '7', 0, '2024-10-30 02:32:21', 'Menunggu Persetujuan', '2024-10-30 09:32:21', 4),
(86, 'Konsumtif', '2024-10-30', '57', '12', 0, '2024-10-30 02:32:29', 'Menunggu Persetujuan', '2024-10-30 09:32:29', 3),
(87, 'Produktif', '2024-10-30', '77', '7', 0, '2024-10-30 02:32:36', 'Menunggu Persetujuan', '2024-10-30 09:32:36', 4),
(88, 'Produktif', '2024-10-30', '5676', '5', 0, '2024-10-30 02:32:44', 'Menunggu Persetujuan', '2024-10-30 09:32:44', 10),
(89, 'Produktif', '2024-10-30', '57', '7', 0, '2024-10-30 02:32:53', 'Menunggu Persetujuan', '2024-10-30 09:32:53', 4),
(90, 'Konsumtif', '2024-11-01', '12000', '2', 0, '2024-11-01 02:44:04', 'Menunggu Persetujuan', '2024-11-01 09:44:04', 3),
(91, 'Konsumtif', '2024-11-04', '66577', '9', 0, '2024-11-04 06:48:27', 'Menunggu Persetujuan', '2024-11-04 13:48:27', 3),
(92, 'Konsumtif', '2024-11-04', '54', '5', 0, '2024-11-04 07:00:50', 'Menunggu Persetujuan', '2024-11-04 14:00:50', 2),
(93, 'Konsumtif', '2024-11-04', '7567', '12', 0, '2024-11-04 07:08:15', 'Menunggu Persetujuan', '2024-11-04 14:08:15', 5);


INSERT INTO `users` (`id`, `full_name`, `username`, `email`, `satker`, `password`, `role`, `limit`, `limit_total`, `profile_picture`, `updated_at`, `created_at`) VALUES
(1, 'Abdullah Hakim', 'abd.hakim', 'abd.hakim@bps.go.id', '3500', '25d55ad283aa400af464c76d713c07ad', 'user', 0, 1500000, 'default.png', '2024-10-02 09:04:59', '2024-10-02 07:41:09'),
(2, 'Abdus Salam', 'abdussalam', 'abdussalam@bps.go.id', '3500', '25d55ad283aa400af464c76d713c07ad', 'user', 0, 1500000, 'default.png', '2024-10-14 08:09:56', '2024-10-02 07:41:09'),
(3, 'Achmad Aziz Effendy', 'achmad.effendy', 'achmad.effendy@bps.go.id', '3500', '25d55ad283aa400af464c76d713c07ad', 'user', 0, 1500000, 'default.png', '2024-10-02 08:10:24', '2024-10-02 07:41:09');


CREATE TABLE `units` (
  `id` int NOT NULL,
  `unit_name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



INSERT INTO `units` (`id`, `unit_name`, `created_at`, `updated_at`) VALUES
(4, 'Unit', '2024-07-30 08:32:12', '2024-07-30 08:32:12'),
(5, 'Karton/boks', '2024-07-30 08:32:12', '2024-07-30 08:32:12'),
(6, 'Dus/paket', '2024-07-30 08:32:12', '2024-07-30 08:32:12'),
(7, 'Palet', '2024-07-30 08:32:12', '2024-07-30 08:32:12'),
(8, 'm²', '2024-07-30 08:32:12', '2024-07-30 08:32:12'),
(9, 'm³', '2024-07-30 08:32:12', '2024-07-30 08:32:12'),
(10, 'Kg', '2024-07-30 08:32:12', '2024-07-30 08:32:12'),
(11, 'Pon', '2024-07-30 08:32:12', '2024-07-30 08:32:12'),
(12, 'Kemasan', '2024-07-30 08:32:12', '2024-07-30 08:32:12'),
(13, 'PCS', '2024-07-30 08:32:12', '2024-07-30 08:32:12'),
(14, 'Buah', '2024-07-30 08:32:12', '2024-07-30 08:32:12'),
(15, 'Biji', '2024-07-30 08:32:12', '2024-09-25 15:47:00');


-- ==========================================================
-- DATA AWAL UNTUK TESTING (SEEDER)
-- ==========================================================

-- Masukkan Kategori
INSERT INTO categories (category_name) VALUES ('Makanan'), ('Minuman');

-- Masukkan Produk
INSERT INTO products (category_id, barcode, product_name, current_selling_price) 
VALUES (2, '89912345', 'Aqua 600ml', 5000.00);

-- Masukkan Stok (Simulasi 2 Batch Berbeda)
-- Batch 1: Masuk tgl 1 Jan, modal 2500, exp Maret
INSERT INTO stock_batches (product_id, purchase_price, initial_qty, remaining_qty, expiry_date, received_at)
VALUES (1, 2500.00, 20, 20, '2026-03-01', '2026-01-01 08:00:00');

-- Batch 2: Masuk tgl 5 Jan, modal 3000 (harga naik), exp Juni
INSERT INTO stock_batches (product_id, purchase_price, initial_qty, remaining_qty, expiry_date, received_at)
VALUES (1, 3000.00, 20, 20, '2026-06-01', '2026-01-05 10:00:00');