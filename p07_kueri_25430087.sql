-- ============================================================================
-- SKRIP KUERI MILESTONE PROYEK 7 - TUGAS MANDIRI SOAL F (MODUL 07)
-- Praktikum Basis Data: Menjawab Pertanyaan dengan SELECT dan Fungsi Skalar
-- 
-- Identitas Mahasiswa:
-- Nama       : Wulan Maghfiroh
-- NIM        : 25430087
-- Kelas      : Basis Data Praktikum (Semester 3) / Kelas D
-- Dosen      : Dedi Irawan, S.Kom., M.T.I.
-- Berkas     : p07_kueri_25430087.sql
-- Basis Data : kopma_087
-- Tanggal    : 09 November 2026
-- Repositori : basisdata-25430087
-- 
-- Ketentuan Pemenuhan Milestone 7:
-- 1. Berisi minimal 10 kueri satu tabel yang mendukung Kebutuhan Informasi (KI) proyek.
-- 2. Setiap kueri memuat 3 elemen wajib:
--    a. Kode Kebutuhan Informasi (KI-xx).
--    b. Pertanyaan dalam bahasa sehari-hari.
--    c. Hasil yang diharapkan sebelum kueri dijalankan (Expected Output).
-- 3. Menggunakan minimal: LIKE, BETWEEN, IN, IS NULL, CASE, fungsi tanggal, dan fungsi string.
-- 4. Memuat tanda dan analisis formal terhadap KI yang belum dapat dijawab dengan satu tabel 
--    (akan diselesaikan menggunakan JOIN dan Agregasi di Pertemuan 9–12).
-- ============================================================================

USE kopma_087;

-- ============================================================================
-- BAGIAN 1: KUERI SATU TABEL PENDUKUNG KEBUTUHAN INFORMASI (KI) PROYEK
-- ============================================================================

-- ----------------------------------------------------------------------------
-- KUERI 01: Peringatan Pengadaan Ulang Barang di Bawah Stok Minimum
-- ----------------------------------------------------------------------------
-- Kode KI               : KI-03 (Laporan persediaan barang kritis / peringatan restock)
-- Pertanyaan Sehari-hari: "Barang apa saja yang stok fisiknya saat ini sudah berada di bawah atau 
--                         sama dengan batas stok minimum, dan berapa unit kekurangannya yang harus dipesan?"
-- Hasil yang Diharapkan : Menampilkan baris data barang yang memenuhi syarat stok_barang <= stok_min_barang. 
--                         Berdasarkan data awal toko, diprediksi produk 'Cokelat Silverqueen 62g' (MKN-005) 
--                         akan muncul dengan defisit sebesar 2 unit (stok 3 unit vs batas minimum 5 unit).
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
-- KUERI 02: Penyaringan Katalog Barang Kategori Tertentu dan Format Mata Uang
-- ----------------------------------------------------------------------------
-- Kode KI               : KI-03 (Katalog persediaan barang & pengelompokan jenis produk)
-- Pertanyaan Sehari-hari: "Barang apa sajakah dari kategori 'ATK' atau 'minuman' yang memiliki harga 
--                         jual di atas Rp4.000,00 beserta label harga resmi berformat mata uang Rupiah?"
-- Hasil yang Diharapkan : Menampilkan daftar barang khusus kategori ATK dan minuman berharga > 4000. 
--                         Kolom harga diformat rapi dengan awalan 'Rp' dan pemisah ribuan titik (id_ID), 
--                         diurutkan secara alfabetis berdasarkan kategori lalu harga termahal.
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
-- KUERI 03: Pencarian Anggota Berdasarkan Pola Nama dan Standarisasi Teks
-- ----------------------------------------------------------------------------
-- Kode KI               : KI-01 (Laporan daftar anggota & pencarian profil identitas)
-- Pertanyaan Sehari-hari: "Siapa saja anggota koperasi yang namanya diawali huruf 'A' atau memuat 
--                         nama 'Dewi', serta bagaimana tampilan nama resmi kapital dan kode label anggotanya?"
-- Hasil yang Diharapkan : Menampilkan anggota bernama seperti 'Ahmad Fauzi' dan 'Citra Dewi Lestari'. 
--                         Nama anggota disajikan dalam huruf kapital (UPPER), disertai label identitas gabungan 
--                         'Anggota-<NIM>' menggunakan fungsi CONCAT.
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
-- KUERI 04: Deteksi Anggota yang Belum Melengkapi Nomor Kontak Darurat
-- ----------------------------------------------------------------------------
-- Kode KI               : KI-01 (Integritas data anggota & kelengkapan administrasi kontak)
-- Pertanyaan Sehari-hari: "Siapa sajakah anggota koperasi yang belum mengisi atau tidak memiliki 
--                         nomor telepon saat pendaftaran (nilai nomor kontak masih kosong/NULL)?"
-- Hasil yang Diharapkan : Menampilkan baris anggota yang kolom telepon_anggota bernilai NULL. 
--                         Kolom kontak yang bernilai kosong otomatis digantikan teks 'BELUM MENGISI' 
--                         menggunakan fungsi IFNULL untuk kenyamanan visual pengurus.
-- ----------------------------------------------------------------------------
SELECT nim_anggota, 
       nama_anggota, 
       alamat_anggota, 
       IFNULL(telepon_anggota, 'BELUM MENGISI') AS status_kontak, 
       status_anggota
FROM anggota
WHERE telepon_anggota IS NULL;


-- ----------------------------------------------------------------------------
-- KUERI 05: Monitoring Transaksi Penjualan pada Rentang Tanggal Tertentu
-- ----------------------------------------------------------------------------
-- Kode KI               : KI-02 (Rekapitulasi transaksi penjualan harian dan shift kerja)
-- Pertanyaan Sehari-hari: "Nota penjualan kasir mana sajakah yang tercatat pada operasional hari pertama 
--                         tanggal 24 September 2026, beserta perhitungan uang kembalian pembelinya?"
-- Hasil yang Diharapkan : Menampilkan daftar transaksi yang terjadi di antara pukul 00:00:00 hingga 23:59:59 
--                         pada tanggal 2026-09-24. Waktu transaksi diformat 'HH:MM DD/MM/YYYY' dan selisih 
--                         (bayar - total) dihitung sebagai kembalian pelanggan. Dibatasi 10 baris pertama.
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
-- KUERI 06: Identifikasi Transaksi Belanja Pembeli Umum (Non-Anggota)
-- ----------------------------------------------------------------------------
-- Kode KI               : KI-02 (Analisis segmentasi pelanggan transaksi kasir)
-- Pertanyaan Sehari-hari: "Transaksi mana sajakah yang dilakukan oleh pelanggan umum (bukan anggota, 
--                         kolom id_anggota bernilai NULL) dengan nilai belanja signifikan di atas Rp30.000?"
-- Hasil yang Diharapkan : Menampilkan nota penjualan pembeli umum yang memiliki total_belanja > 30000. 
--                         Kolom tipe pembeli dilabeli 'Pelanggan Umum' melalui fungsi logika IF(), 
--                         diurutkan dari transaksi belanja terbesar.
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
-- KUERI 07: Klasifikasi Skala Nilai Transaksi Menggunakan CASE Kontrol
-- ----------------------------------------------------------------------------
-- Kode KI               : KI-02 (Segmentasi nilai transaksi & kebijakan apresiasi belanja)
-- Pertanyaan Sehari-hari: "Bagaimana kategorisasi skala belanja pada setiap nota kasir, apakah tergolong 
--                         'Belanja Besar' (>= Rp30.000), 'Belanja Sedang' (Rp15.000 - Rp29.999), 
--                         atau 'Belanja Ringan' (< Rp15.000)?"
-- Hasil yang Diharapkan : Menampilkan nomor nota, total belanja, poin perolehan, dan label kategori 
--                         skala transaksi yang dievaluasi melalui konstruksi kondisional CASE WHEN.
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
-- KUERI 08: Analisis Masa Keanggotaan dan Pengelompokan Senioritas
-- ----------------------------------------------------------------------------
-- Kode KI               : KI-01 (Laporan riwayat keanggotaan & loyalitas anggota)
-- Pertanyaan Sehari-hari: "Berapa hari usia keanggotaan setiap anggota sejak awal mendaftar hingga hari ini, 
--                         dan bagaimana status senioritasnya ('Senior' >= 780 hari, 'Menengah' >= 365 hari, 
--                         atau 'Junior' < 365 hari)?"
-- Hasil yang Diharapkan : Menghitung selisih hari antara CURDATE() dan tgl_daftar menggunakan DATEDIFF(), 
--                         kemudian menetapkan label senioritas berdasarkan umur keanggotaan anggota.
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
-- KUERI 09: Audit Mutasi Perolehan Poin Loyalitas Bernilai Signifikan
-- ----------------------------------------------------------------------------
-- Kode KI               : KI-04 (Laporan mutasi dan audit perolehan poin loyalitas anggota)
-- Pertanyaan Sehari-hari: "Catatan transaksi audit mutasi poin mana sajakah yang menghasilkan perolehan 
--                         poin loyalitas menengah ke atas (antara 2 hingga 5 poin)?"
-- Hasil yang Diharapkan : Menampilkan baris riwayat poin dengan jenis_mutasi = 'Perolehan' dan 
--                         jumlah_poin bernilai antara 2 sampai 5 (memakai BETWEEN), dengan format 
--                         tanggal mutasi yang terbaca jelas (DATE_FORMAT).
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
-- KUERI 10: Deteksi Transaksi yang Dibayar Pelanggan dengan Uang Pas
-- ----------------------------------------------------------------------------
-- Kode KI               : KI-02 (Efisiensi kasir dan rekonsiliasi uang kembalian)
-- Pertanyaan Sehari-hari: "Nota penjualan kasir mana sajakah yang dibayar dengan uang pas oleh pembeli 
--                         sehingga kasir tidak perlu mengeluarkan uang kembalian (bayar = total belanja)?"
-- Hasil yang Diharapkan : Menampilkan nota penjualan yang nilai bayar_penjualan sama persis dengan total_belanja. 
--                         Nilai selisih kembalian diproyeksikan dan dipastikan bernilai 0.00.
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


-- ----------------------------------------------------------------------------
-- KUERI 11: Pemetaan Mitra Pemasok Rekanan di Luar Kota Surabaya
-- ----------------------------------------------------------------------------
-- Kode KI               : KI-05 (Manajemen kemitraan pemasok dan logistik suplai luar daerah)
-- Pertanyaan Sehari-hari: "Perusahaan mitra rekanan pemasok mana sajakah yang alamat fisiknya berada 
--                         di luar wilayah kota Surabaya (tidak memuat kata 'Surabaya')?"
-- Hasil yang Diharapkan : Menampilkan pemasok dari wilayah penyangga seperti Sidoarjo, Gresik, Pasuruan 
--                         menggunakan klausa saring NOT LIKE '%Surabaya%'.
-- ----------------------------------------------------------------------------
SELECT id_pemasok, 
       nama_pemasok, 
       telepon_pemasok, 
       alamat_pemasok
FROM pemasok
WHERE alamat_pemasok NOT LIKE '%Surabaya%'
ORDER BY nama_pemasok ASC;


-- ----------------------------------------------------------------------------
-- KUERI 12: Kalkulasi Subtotal Item Belanja Bernilai Signifikan
-- ----------------------------------------------------------------------------
-- Kode KI               : KI-02 / KI-03 (Analisis transaksi item belanja berbobot tinggi)
-- Pertanyaan Sehari-hari: "Rincian item barang belanja mana sajakah yang memiliki nilai subtotal baris 
--                         mencapai Rp15.000,00 atau lebih dalam satu jenis barang yang dibeli?"
-- Hasil yang Diharapkan : Menampilkan baris detail_penjualan yang hasil perkalian skalar 
--                         (qty * harga_satuan) bernilai >= 15000, diurutkan dari subtotal terbesar.
-- ----------------------------------------------------------------------------
SELECT id_penjualan, 
       id_barang, 
       qty_detail_penjualan AS kuantitas, 
       harga_satuan_detail_penjualan AS harga_satuan, 
       (qty_detail_penjualan * harga_satuan_detail_penjualan) AS subtotal_item
FROM detail_penjualan
WHERE (qty_detail_penjualan * harga_satuan_detail_penjualan) >= 15000
ORDER BY subtotal_item DESC
LIMIT 10;


-- ============================================================================
-- BAGIAN 2: TANDA DAN ANALISIS KEBUTUHAN INFORMASI (KI) YANG BELUM DAPAT 
--           DIJAWAB DENGAN KUERI SATU TABEL
-- ============================================================================
-- Sesuai dengan instruksi modul, terdapat sejumlah Kebutuhan Informasi (KI) vital 
-- pada sistem informasi koperasi yang belum dapat dijawab secara tuntas hanya 
-- mengandalkan kueri satu tabel (single-table SELECT). Kebutuhan informasi tersebut 
-- secara formal ditandai dan akan dijawab pada Pertemuan 09 s.d 12:
--
-- ----------------------------------------------------------------------------
-- 1. [KI-02] Total Akumulasi Omzet Penjualan Harian dan Bulanan
--    - Kendala Satu Tabel: Tabel 'penjualan' hanya memuat baris transaksi individual. 
--      Untuk memperoleh omzet total per tanggal, sistem membutuhkan fungsi agregasi 
--      SUM(total_belanja) dan klausul pengelompokan baris GROUP BY DATE(tgl_penjualan).
--    - Jadwal Penyelesaian: Modul 09 (Fungsi Agregasi dan GROUP BY).
--
-- 2. [KI-02] Rekapitulasi Performa Penjualan Kasir Disertai Nama Petugas
--    - Kendala Satu Tabel: Tabel 'penjualan' hanya menyimpan 'id_petugas' (foreign key), 
--      sedangkan nama lengkap kasir berada di tabel 'petugas'. Kueri satu tabel tidak 
--      mampu menghubungkan kedua entitas tersebut tanpa operasi penggabungan relasional.
--    - Jadwal Penyelesaian: Modul 10 (Operasi Penggabungan Relasional / INNER JOIN).
--
-- 3. [KI-03] Daftar 5 Produk Paling Laris Berdasarkan Akumulasi Kuantitas Penjualan
--    - Kendala Satu Tabel: Nama produk berada di tabel 'barang', sementara kuantitas belanja 
--      berada di baris transaksi 'detail_penjualan'. Mengetahui produk terlaris memerlukan 
--      penggabungan tabel barang dan detail_penjualan, diikuti agregasi SUM(qty) dan ORDER BY DESC.
--    - Jadwal Penyelesaian: Modul 10 & 11 (JOIN Multi-Tabel dan Agregasi Lanjut).
--
-- 4. [KI-04] Laporan Saldo Akhir Poin Loyalitas Masing-Masing Anggota
--    - Kendala Satu Tabel: Tabel 'riwayat_poin' mencatat setiap baris mutasi (+ perolehan, 
--      - penukaran), sedangkan profil anggota ada di tabel 'anggota'. Untuk menampilkan nama 
--      anggota beserta saldo akhir poinnya, diperlukan JOIN anggota dengan riwayat_poin 
--      serta penjumlahan aljabar SUM(jumlah_poin) GROUP BY id_anggota.
--    - Jadwal Penyelesaian: Modul 09 & 10 (Agregasi Mutasi dan Relasi Anggota).
--
-- 5. [KI-05] Rincian Belanja Faktur Pengadaan Barang Gudang Beserta Nama Pemasok
--    - Kendala Satu Tabel: Tabel 'pembelian' hanya menyimpan id_pemasok, sedangkan alamat 
--      dan nama perusahaan distributor ada di tabel 'pemasok'. Diperlukan JOIN untuk laporan faktur.
--    - Jadwal Penyelesaian: Modul 10 (Kueri Pembelian Multi-Tabel).
--
-- ----------------------------------------------------------------------------
-- CATATAN INTEGRASI PERSIAPAN UTS TAHAP 1 (PERTEMUAN 8):
-- Seluruh artefak DDL (p05), DML Data Induk & Uji (p06), dan Kueri Seleksi Skalar (p07) 
-- telah terintegrasi secara modular, idempoten, dan dapat dibangun ulang dari kondisi 
-- bersih basis data kopma_087.
-- ============================================================================
-- AKHIR DARI SKRIP p07_kueri_25430087.sql
-- ============================================================================
