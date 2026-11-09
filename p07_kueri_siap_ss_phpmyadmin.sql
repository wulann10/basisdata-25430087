-- ============================================================================
-- PANDUAN KUERI SIAP SALIN UNTUK TANGKAPAN LAYAR (SCREENSHOT) PHPMYADMIN
-- Praktikum Basis Data: Modul 07 (SELECT & Fungsi Skalar)
-- 
-- Mahasiswa : Wulan Maghfiroh (NIM 25430087)
-- Basis Data: kopma_087
-- Total SS  : Cukup 10 Screenshot (1.png sampai 10.png)
-- Lokasi SS : Simpan langsung ke folder: laporan\img7\
-- 
-- Petunjuk Praktis:
-- 1. Buka phpMyAdmin di browser: http://localhost/phpmyadmin
-- 2. Klik nama basis data `kopma_087` di panel sebelah kiri.
-- 3. Masuk ke tab "SQL" di bagian atas.
-- 4. Salin salah satu kueri di bawah ini (Kueri 01 s.d 10).
-- 5. Klik tombol "Kirim" / "Go" di kanan bawah.
-- 6. Tekan tombol Windows: Win + Shift + S untuk menangkap layar (screenshot).
--    Pastikan teks kueri dan tabel hasil yang keluar ikut tertangkap.
-- 7. Simpan file gambar ke folder `laporan\img7\` dengan nama:
--    1.png, 2.png, 3.png, ... sampai 10.png.
-- ============================================================================

USE kopma_087;

-- ----------------------------------------------------------------------------
-- [1.png] Kueri 01 (KI-03): Peringatan Restock Barang Kritis di Bawah Batas Minimum
-- Deskripsi       : Menampilkan barang yang stok fisiknya <= batas stok minimum
-- Hasil phpMyAdmin: 1 baris (MKN-005, Cokelat Silverqueen, stok 3, min 5, defisit 2)
-- ----------------------------------------------------------------------------
SELECT kode_barang, 
       nama_barang, 
       kategori_barang, 
       stok_barang, 
       stok_min_barang, 
       (stok_min_barang - stok_barang) AS defisit_stok
FROM barang
WHERE stok_barang <= stok_min_barang
ORDER BY defisit_stok DESC;


-- ----------------------------------------------------------------------------
-- [2.png] Kueri 02 (KI-03): Filter Himpunan IN Kategori & Format Harga Rupiah
-- Deskripsi       : Menyaring kategori ATK dan Minuman berharga > Rp4.000 dengan format Rp
-- Hasil phpMyAdmin: 6 baris produk (Tip-Ex, Buku Tulis, Penggaris, Kopi, Susu, Teh Pucuk)
-- ----------------------------------------------------------------------------
SELECT kode_barang, 
       nama_barang, 
       kategori_barang, 
       CONCAT('Rp', FORMAT(harga_jual_barang, 0, 'id_ID')) AS harga_jual_format, 
       stok_barang
FROM barang
WHERE kategori_barang IN ('ATK', 'minuman') 
  AND harga_jual_barang > 4000
ORDER BY kategori_barang ASC, harga_jual_barang DESC;


-- ----------------------------------------------------------------------------
-- [3.png] Kueri 03 (KI-01): Pencarian Pola LIKE & Penggabungan Label CONCAT
-- Deskripsi       : Mencari anggota berawalan huruf 'A' atau mengandung kata 'Dewi'
-- Hasil phpMyAdmin: 2 baris anggota (Ahmad Fauzi & Citra Dewi Lestari)
-- ----------------------------------------------------------------------------
SELECT nim_anggota, 
       UPPER(nama_anggota) AS nama_anggota_kapital, 
       CONCAT('Anggota-', nim_anggota) AS label_anggota, 
       telepon_anggota, 
       status_anggota
FROM anggota
WHERE nama_anggota LIKE 'A%' 
   OR nama_anggota LIKE '%Dewi%'
ORDER BY nama_anggota ASC;


-- ----------------------------------------------------------------------------
-- [4.png] Kueri 04 (KI-01): Deteksi Kontak Kosong IS NULL & Substitusi IFNULL
-- Deskripsi       : Menemukan anggota tanpa nomor telepon dan diganti teks 'BELUM MENGISI'
-- Hasil phpMyAdmin: 1 baris anggota (Rizky Pratama, NIM 25430012, status_kontak 'BELUM MENGISI')
-- ----------------------------------------------------------------------------
SELECT nim_anggota, 
       nama_anggota, 
       alamat_anggota, 
       IFNULL(telepon_anggota, 'BELUM MENGISI') AS status_kontak, 
       status_anggota
FROM anggota
WHERE telepon_anggota IS NULL;


-- ----------------------------------------------------------------------------
-- [5.png] Kueri 05 (KI-02): Transaksi Shift Harian BETWEEN & Hitung Kembalian
-- Deskripsi       : Menampilkan transaksi operasional shift tanggal 24 September 2026
-- Hasil phpMyAdmin: 10 baris transaksi dengan format waktu dd/mm/yyyy hh:mm & uang kembali
-- ----------------------------------------------------------------------------
SELECT no_nota_penjualan, 
       DATE_FORMAT(tgl_penjualan, '%d/%m/%Y %H:%i') AS waktu_transaksi, 
       total_belanja, 
       bayar_penjualan, 
       (bayar_penjualan - total_belanja) AS uang_kembali
FROM penjualan
WHERE tgl_penjualan BETWEEN '2026-09-24 00:00:00' AND '2026-09-24 23:59:59'
ORDER BY tgl_penjualan ASC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- [6.png] Kueri 06 (KI-02): Segmentasi Pelanggan Umum IS NULL Belanja > 30rb
-- Deskripsi       : Mengidentifikasi transaksi belanja pembeli umum (non-anggota) bernilai besar
-- Hasil phpMyAdmin: 7 baris transaksi dengan label 'Pelanggan Umum'
-- ----------------------------------------------------------------------------
SELECT no_nota_penjualan, 
       tgl_penjualan, 
       id_petugas, 
       total_belanja, 
       bayar_penjualan, 
       IF(id_anggota IS NULL, 'Pelanggan Umum', 'Anggota') AS tipe_pelanggan
FROM penjualan
WHERE id_anggota IS NULL 
  AND total_belanja > 30000
ORDER BY total_belanja DESC;


-- ----------------------------------------------------------------------------
-- [7.png] Kueri 07 (KI-02): Klasifikasi Skala Nilai Belanja dengan CASE WHEN
-- Deskripsi       : Mengelompokkan transaksi ke skala 'Belanja Besar', 'Sedang', atau 'Ringan'
-- Hasil phpMyAdmin: 10 baris nota kasir teratas dengan label kategori belanja dinamis
-- ----------------------------------------------------------------------------
SELECT no_nota_penjualan, 
       total_belanja, 
       poin_didapat, 
       CASE 
           WHEN total_belanja >= 30000 THEN 'Belanja Besar'
           WHEN total_belanja >= 15000 THEN 'Belanja Sedang'
           ELSE 'Belanja Ringan'
       END AS kategori_transaksi
FROM penjualan
ORDER BY total_belanja DESC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- [8.png] Kueri 08 (KI-01): Analisis Usia Anggota DATEDIFF & Pengelompokan Senioritas
-- Deskripsi       : Menghitung umur bergabung anggota dalam satuan hari dan label senioritas
-- Hasil phpMyAdmin: 11 baris anggota koperasi dari masa keanggotaan terlama ke termuda
-- ----------------------------------------------------------------------------
SELECT nim_anggota, 
       nama_anggota, 
       tgl_daftar, 
       DATEDIFF(CURDATE(), tgl_daftar) AS masa_gabung_hari, 
       CASE 
           WHEN DATEDIFF(CURDATE(), tgl_daftar) >= 780 THEN 'Senior'
           WHEN DATEDIFF(CURDATE(), tgl_daftar) >= 365 THEN 'Menengah'
           ELSE 'Junior'
       END AS status_senioritas
FROM anggota
ORDER BY masa_gabung_hari DESC;


-- ----------------------------------------------------------------------------
-- [9.png] Kueri 09 (KI-04): Audit Mutasi Poin Loyalitas BETWEEN 2-5
-- Deskripsi       : Menyaring catatan audit mutasi poin perolehan belanja bernilai 2 s.d 5
-- Hasil phpMyAdmin: 10 baris log mutasi poin perolehan dengan waktu format dd Mon yyyy hh:mm
-- ----------------------------------------------------------------------------
SELECT id_riwayat_poin, 
       id_anggota, 
       DATE_FORMAT(tgl_transaksi_poin, '%d %b %Y %H:%i') AS waktu_mutasi, 
       jenis_mutasi, 
       jumlah_poin, 
       keterangan
FROM riwayat_poin
WHERE jenis_mutasi = 'Perolehan' 
  AND jumlah_poin BETWEEN 2 AND 5
ORDER BY jumlah_poin DESC, tgl_transaksi_poin ASC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- [10.png] Kueri 10 (KI-02): Identifikasi Transaksi Dibayar Uang Pas
-- Deskripsi       : Menemukan nota kasir di mana pembeli membayar dengan uang pas (kembalian 0)
-- Hasil phpMyAdmin: 3 baris transaksi penjualan dengan selisih_kembalian bernilai 0.00
-- ----------------------------------------------------------------------------
SELECT no_nota_penjualan, 
       tgl_penjualan, 
       total_belanja, 
       bayar_penjualan, 
       (bayar_penjualan - total_belanja) AS selisih_kembalian
FROM penjualan
WHERE bayar_penjualan = total_belanja
ORDER BY total_belanja DESC
LIMIT 10;

-- ============================================================================
-- AKHIR DARI PANDUAN KUERI 10 SCREENSHOT (1.png s.d 10.png)
-- ============================================================================
