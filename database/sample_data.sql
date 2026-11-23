-- OPSIONAL. Jalankan setelah mendaftar akun pertama (id = 1).
USE finly_db;
INSERT INTO transactions (user_id,type,category,amount,note,trx_date) VALUES
(1,'income','Gaji',8000000,'Gaji bulanan',CURDATE()),
(1,'expense','Makanan & Minuman',1200000,NULL,CURDATE()),
(1,'expense','Transportasi',600000,NULL,CURDATE()),
(1,'expense','Tagihan & Utilitas',450000,NULL,CURDATE()),
(1,'expense','Belanja',500000,NULL,CURDATE());
