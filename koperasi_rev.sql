-- ==========================================================
-- DATABASE RETAIL MINIMARKET (FIFO, FEFO, & PRICE HISTORY)
-- ==========================================================

-- 1. TABEL user
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
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


-- 2. Tabel Categories --> contoh Makanan, Non Makanan
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- 3. Tabel Unit --> menyimpan satuan ukuran
CREATE TABLE `units` (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `unit_name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 4. TABEL TRANSAKSI & PRODUK (Dibuat Setelah Master)
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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) 
) ENGINE=InnoDB;

-- 5. Tabel stock batches --> untuk simpan stock saat operator kulakan berdasarkan batches
CREATE TABLE stock_batches (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    purchase_price DECIMAL(12,2) NOT NULL,
    initial_qty INT NOT NULL,
    remaining_qty INT NOT NULL,
    expiry_date DATE,
    received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX (expiry_date),
    INDEX (received_at)
) ENGINE=InnoDB;

-- 6. Tabel Price Logs --> untuk simpan history perubahan data harga
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

-- 7. Tabel sales --> untuk simpan data transaksi dengan invoicenya
CREATE TABLE sales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    total_bill DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_discount DECIMAL(12,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 8. Tabel sale_items --> untuk simpan data keluar masuk barang berdasarkan transaksi di sales
CREATE TABLE sale_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    batch_id INT NOT NULL,
    qty INT NOT NULL,
    normal_price DECIMAL(12,2) NOT NULL,
    discount_amount DECIMAL(12,2) DEFAULT 0.00,
    final_price DECIMAL(12,2) NOT NULL,
    hpp_at_sale DECIMAL(12,2) NOT NULL,
    item_profit DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (batch_id) REFERENCES stock_batches(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

-- 9. Tabel stock adjustment --> untuk adjust jumlah stock terakhir
CREATE TABLE stock_adjustments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    batch_id INT NOT NULL,
    adjustment_type ENUM('SHRINKAGE', 'DAMAGE', 'GIFT', 'CORRECTION') NOT NULL,
    qty_change INT NOT NULL,
    loss_value DECIMAL(12,2),
    adjusted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    note TEXT,
    FOREIGN KEY (batch_id) REFERENCES stock_batches(id)
) ENGINE=InnoDB;

-- 10. Tabel activity_logs 
CREATE TABLE `activity_logs` (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `message_text` varchar(255) NOT NULL,
  `message_summary` varchar(255) NOT NULL,
  `role` enum('admin','operator','user') NOT NULL,
  `user_id` int NOT NULL,
  `message_icon` varchar(50) NOT NULL,  
  `message_date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 11. Tabel submission --> untuk simpan history peminjaman uang
CREATE TABLE `submissions` (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `loan_type` text NOT NULL,
  `load_date` text,
  `loan_amount` text NOT NULL,
  `loan_duration` text NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` varchar(255) DEFAULT NULL,
  `submission_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `user_id` int NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;