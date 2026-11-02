-- ============================================================================
-- SKRIP DML PENGISIAN DATA KOPMA - LANGKAH PERCOBAAN D (MODUL 06)
-- Nama       : Wulan Maghfiroh
-- NIM        : 25430087
-- Kelas      : Basis Data Praktikum (Semester 3) / Kelas D
-- Dosen      : Dedi Irawan, S.Kom., M.T.I.
-- Berkas     : p06_data_kopma_25430087.sql
-- Basis Data : kopma_087
-- ============================================================================

USE kopma_087;

-- ----------------------------------------------------------------------------
-- D.1 MENGISI DATA INDUK (MASTER DATA)
-- ----------------------------------------------------------------------------

-- 1. Mengisi Data Petugas Kasir dan Staf (INSERT Banyak Baris)
INSERT INTO petugas (kode_petugas, nama_petugas, peran_petugas) VALUES
 ('K01', 'Dimas', 'kasir'),
 ('K02', 'Sari', 'kasir'),
 ('K03', 'Rina', 'kasir'),
 ('G01', 'Joko', 'gudang'),
 ('P01', 'Ketua Kopma', 'ketua');

-- 2. Mengisi Data Katalog Barang Koperasi (INSERT Banyak Baris)
INSERT INTO barang (kode_barang, nama_barang, kategori_barang, harga_jual_barang, stok_barang, stok_min_barang) VALUES
 ('ATK-001', 'Pulpen Gel 0.5', 'ATK', 4000.00, 120, 20),
 ('ATK-002', 'Buku Tulis 58', 'ATK', 6500.00, 80, 20),
 ('MNM-001', 'Air Mineral 600', 'minuman', 4000.00, 48, 24),
 ('MKN-001', 'Roti Cokelat', 'makanan', 5000.00, 6, 10);

-- 3. Mengisi Data Anggota (Minimal 3 orang, 1 berstatus nonaktif)
INSERT INTO anggota (nim_anggota, nama_anggota, jenis_kelamin, telepon_anggota, alamat_anggota, status_anggota, tgl_daftar) VALUES
 ('25430087', 'Wulan Maghfiroh', 'P', '081234567087', 'Asrama Mahasiswi Putri No. 87', 'aktif', '2024-09-01'),
 ('25430001', 'Ahmad Fauzi', 'L', '081234567001', 'Jl. Merpati No. 10 Surabaya', 'aktif', '2024-09-05'),
 ('25430002', 'Budi Santoso', 'L', '081234567002', 'Jl. Kenanga No. 15 Sidoarjo', 'nonaktif', '2023-11-10');

-- 4. Mengisi Data Pemasok (Minimal 2 distributor rekanan)
INSERT INTO pemasok (nama_pemasok, telepon_pemasok, alamat_pemasok) VALUES
 ('CV Grafika Mandiri', '081122334455', 'Kawasan Industri Rungkut Blok A-3 Surabaya'),
 ('PT Sumber Pangan Sejahtera', '081199887766', 'Jl. Pahlawan No. 45 Surabaya');

-- ----------------------------------------------------------------------------
-- D.2 MENCATAT NOTA PENJUALAN CONTOH MODUL 2 (PJ-2609-0142)
-- ----------------------------------------------------------------------------

-- 5. Catat Nota Transaksi Penjualan Kepala
INSERT INTO penjualan (no_nota_penjualan, tgl_penjualan, id_petugas, id_anggota, bayar_penjualan)
VALUES ('PJ-2609-0142', '2026-09-24 10:15:00', 3, 1, 30000.00);

-- 6. Catat Detail Penjualan Menggunakan INSERT ... SELECT (Harga Satuan Historis)
-- Item 1: Pulpen Gel 0.5 (Qty 3)
INSERT INTO detail_penjualan (id_penjualan, id_barang, qty_detail_penjualan, harga_satuan_detail_penjualan)
SELECT 1, id_barang, 3, harga_jual_barang 
FROM barang 
WHERE kode_barang = 'ATK-001';

-- Item 2: Buku Tulis 58 (Qty 2)
INSERT INTO detail_penjualan (id_penjualan, id_barang, qty_detail_penjualan, harga_satuan_detail_penjualan)
SELECT 1, id_barang, 2, harga_jual_barang 
FROM barang 
WHERE kode_barang = 'ATK-002';

-- Item 3: Air Mineral 600 (Qty 1)
INSERT INTO detail_penjualan (id_penjualan, id_barang, qty_detail_penjualan, harga_satuan_detail_penjualan)
SELECT 1, id_barang, 1, harga_jual_barang 
FROM barang 
WHERE kode_barang = 'MNM-001';

-- 7. Pengurangan Stok Fisik Barang Sesuai Qty Terjual
UPDATE barang SET stok_barang = stok_barang - 3 WHERE kode_barang = 'ATK-001';
UPDATE barang SET stok_barang = stok_barang - 2 WHERE kode_barang = 'ATK-002';
UPDATE barang SET stok_barang = stok_barang - 1 WHERE kode_barang = 'MNM-001';

-- Update Total Belanja dan Poin Didapat pada Nota 1
UPDATE penjualan 
SET total_belanja = (SELECT SUM(qty_detail_penjualan * harga_satuan_detail_penjualan) FROM detail_penjualan WHERE id_penjualan = 1),
    poin_didapat = FLOOR((SELECT SUM(qty_detail_penjualan * harga_satuan_detail_penjualan) FROM detail_penjualan WHERE id_penjualan = 1) / 10000)
WHERE id_penjualan = 1;

-- Catat Riwayat Perolehan Poin Anggota Wulan Maghfiroh (AB-03)
INSERT INTO riwayat_poin (id_anggota, id_penjualan, tgl_transaksi_poin, jenis_mutasi, jumlah_poin, keterangan)
VALUES (1, 1, '2026-09-24 10:15:00', 'Perolehan', 2, 'Poin transaksi nota PJ-2609-0142');

-- ============================================================================
-- AKHIR DARI SKRIP p06_data_kopma_25430087.sql
-- ============================================================================
