-- ============================================================================
-- PANDUAN KUERI SIAP SALIN UNTUK TANGKAPAN LAYAR (SCREENSHOT) PHPMYADMIN
-- Praktikum Basis Data: Modul 07 (SELECT & Fungsi Skalar)
-- 
-- Mahasiswa : Wulan Maghfiroh (NIM 25430087)
-- Basis Data: kopma_087
-- Petunjuk  : 
-- 1. Buka phpMyAdmin di browser (http://localhost/phpmyadmin).
-- 2. Klik basis data `kopma_087` di panel sebelah kiri.
-- 3. Masuk ke tab "SQL".
-- 4. Salin kueri di bawah ini satu per satu sesuai nomor screenshot (1 s.d 23).
-- 5. Jalankan (klik tombol "Kirim" / "Go").
-- 6. Tangkap layar (Win + Shift + S) seluruh hasil query + pesan status.
-- 7. Simpan file gambar ke dalam folder `img7/` (dan `laporan/img7/`) dengan nama:
--    1.png, 2.png, 3.png, ... sampai 23.png.
-- ============================================================================

USE kopma_087;

-- ============================================================================
-- BAGIAN 1: LANGKAH PERCOBAAN D & LATIHAN E (1.png s.d 11.png)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- [1.png] D.1 Kueri KI-03: Peringatan Barang di Bawah Stok Minimum
-- Deskripsi: Menampilkan barang yang perlu dipesan ulang beserta defisitnya
-- Hasil phpMyAdmin: 1 baris (MKN-005, Cokelat Silverqueen, stok 3, min 5, kurang 2)
-- ----------------------------------------------------------------------------
SELECT kode_barang, 
       nama_barang, 
       stok_barang, 
       stok_min_barang, 
       stok_min_barang - stok_barang AS kurang
FROM barang
WHERE stok_barang < stok_min_barang
ORDER BY kurang DESC;


-- ----------------------------------------------------------------------------
-- [2.png] D.1 Kueri Penyaringan IN: Kategori ATK dan Minuman
-- Deskripsi: Menyaring himpunan nilai diskrit khusus kategori ATK dan minuman
-- Hasil phpMyAdmin: 10 baris produk (6 ATK dan 4 minuman)
-- ----------------------------------------------------------------------------
SELECT kode_barang, 
       nama_barang, 
       kategori_barang, 
       harga_jual_barang, 
       stok_barang
FROM barang
WHERE kategori_barang IN ('ATK', 'minuman')
ORDER BY kategori_barang ASC, nama_barang ASC;


-- ----------------------------------------------------------------------------
-- [3.png] D.1 Kueri Penyaringan BETWEEN: Transaksi Kasir 24 September 2026
-- Deskripsi: Menyaring rentang waktu transaksi shift harian
-- Hasil phpMyAdmin: 10 baris pertama transaksi nota pada tanggal 24-09-2026
-- ----------------------------------------------------------------------------
SELECT no_nota_penjualan, 
       tgl_penjualan, 
       total_belanja, 
       bayar_penjualan
FROM penjualan
WHERE tgl_penjualan BETWEEN '2026-09-24 00:00:00' AND '2026-09-24 23:59:59'
ORDER BY tgl_penjualan ASC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- [4.png] D.1 Kueri Penyaringan IS NULL: Anggota Tanpa Nomor Kontak HP
-- Deskripsi: Menemukan anggota yang data nomor teleponnya bernilai NULL
-- Hasil phpMyAdmin: 1 baris anggota (Rizky Pratama, NIM 25430012, telepon NULL)
-- ----------------------------------------------------------------------------
SELECT nim_anggota, 
       nama_anggota, 
       jenis_kelamin, 
       status_anggota, 
       telepon_anggota
FROM anggota
WHERE telepon_anggota IS NULL;


-- ----------------------------------------------------------------------------
-- [5.png] Titik Analisis 1: Demonstrasi Galat ERROR 1054 Alias di WHERE
-- Deskripsi: Kueri ini SENGAJA memicu galat untuk membuktikan urutan evaluasi logis SQL
-- Hasil phpMyAdmin: Kotak pesan merah galat: #1054 - Unknown column 'kurang' in 'where clause'
-- ----------------------------------------------------------------------------
SELECT kode_barang, 
       nama_barang, 
       stok_barang, 
       stok_min_barang, 
       stok_min_barang - stok_barang AS kurang
FROM barang
WHERE kurang > 0;


-- ----------------------------------------------------------------------------
-- [6.png] D.2 Pola Teks LIKE, CONCAT, IFNULL, dan CASE
-- Deskripsi: Menguji fungsi penggabungan nama, tanggal Indonesia, IFNULL, & CASE diskon
-- Hasil phpMyAdmin: 5 baris anggota teratas yang namanya memuat huruf 'a'
-- ----------------------------------------------------------------------------
SELECT CONCAT(nama_anggota, ' (', nim_anggota, ')') AS anggota,
       DATE_FORMAT(tgl_daftar, '%d-%m-%Y') AS tgl_daftar_anggota,
       IFNULL(telepon_anggota, '-') AS hp,
       CASE status_anggota 
           WHEN 'aktif' THEN 'Diskon 5%'
           ELSE 'Tanpa diskon' 
       END AS keterangan
FROM anggota
WHERE nama_anggota LIKE '%a%'
ORDER BY tgl_daftar DESC
LIMIT 5;


-- ----------------------------------------------------------------------------
-- [7.png] Titik Analisis 2: Pembuktian Three-Valued Logic (WHERE col = NULL)
-- Deskripsi: SENGAJA menguji pembanding '= NULL' yang menghasilkan status UNKNOWN
-- Hasil phpMyAdmin: Kotak hijau 'MySQL menyatakan set hasil kosong (misal 0 baris)'
-- ----------------------------------------------------------------------------
SELECT nim_anggota, 
       nama_anggota, 
       telepon_anggota
FROM anggota
WHERE telepon_anggota = NULL;


-- ----------------------------------------------------------------------------
-- [8.png] D.3 Perhitungan Tanggal: Umur Keanggotaan DATEDIFF & Status Baru/Lama
-- Deskripsi: Menghitung selisih hari pendaftaran hingga saat ini dan label status
-- Hasil phpMyAdmin: 11 baris anggota dengan kolom lama_hari dan status 'Lama'
-- ----------------------------------------------------------------------------
SELECT nim_anggota, 
       nama_anggota, 
       tgl_daftar, 
       DATEDIFF(CURDATE(), tgl_daftar) AS lama_hari,
       CASE 
           WHEN DATEDIFF(CURDATE(), tgl_daftar) < 180 THEN 'Baru'
           ELSE 'Lama'
       END AS status_keanggotaan
FROM anggota
ORDER BY tgl_daftar DESC;


-- ----------------------------------------------------------------------------
-- [9.png] D.3 Perhitungan per Baris: Rincian Subtotal Item Nota PJ-2609-0142
-- Deskripsi: Perkalian skalar (qty * harga_satuan) yang cocok dengan fisik nota Modul 2
-- Hasil phpMyAdmin: 3 baris item belanja (subtotal Rp12.000, Rp13.000, Rp4.000)
-- ----------------------------------------------------------------------------
SELECT d.id_penjualan, 
       d.id_barang, 
       d.qty_detail_penjualan AS qty, 
       d.harga_satuan_detail_penjualan AS harga_satuan, 
       (d.qty_detail_penjualan * d.harga_satuan_detail_penjualan) AS subtotal
FROM detail_penjualan d
WHERE d.id_penjualan = (
    SELECT id_penjualan 
    FROM penjualan 
    WHERE no_nota_penjualan = 'PJ-2609-0142'
);


-- ----------------------------------------------------------------------------
-- [10.png] Latihan E.1: Format Teks Huruf Kapital & Format Rupiah Indonesia
-- Deskripsi: Menggunakan fungsi UPPER() dan FORMAT(harga, 0, 'id_ID')
-- Hasil phpMyAdmin: 10 baris katalog barang dengan tampilan huruf besar dan format Rp
-- ----------------------------------------------------------------------------
SELECT UPPER(nama_barang) AS nama_barang_kapital,
       CONCAT('Rp', FORMAT(harga_jual_barang, 0, 'id_ID')) AS harga_jual_format,
       stok_barang
FROM barang
ORDER BY nama_barang ASC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- [11.png] Latihan E.2: Analisis Kesalahan Semantik Operator Logika OR vs AND
-- Deskripsi: Menunjukkan kesalahan semantik akibat ketiadaan tanda kurung presedensi
-- Hasil phpMyAdmin: 7 baris barang (Tip-Ex dan Penggaris salah lolos karena AND > OR)
-- ----------------------------------------------------------------------------
SELECT kode_barang, 
       nama_barang, 
       kategori_barang, 
       stok_barang
FROM barang
WHERE kategori_barang = 'ATK' OR kategori_barang = 'makanan' AND stok_barang > 50;


-- ============================================================================
-- BAGIAN 2: TUGAS MANDIRI MILESTONE PROYEK 7 (12.png s.d 23.png)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- [12.png] Milestone Proyek 7 [Kueri 01 - KI-03]: Peringatan Restock Barang Kritis
-- Deskripsi: Menampilkan barang dengan stok fisik <= stok minimum
-- Hasil phpMyAdmin: 1 baris (MKN-005, Cokelat Silverqueen, defisit_stok 2)
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
-- [13.png] Milestone Proyek 7 [Kueri 02 - KI-03]: Filter IN Kategori & Format Harga Rupiah
-- Deskripsi: Saring kategori ATK/minuman berharga > 4000 dengan format mata uang
-- Hasil phpMyAdmin: 6 baris produk berformat 'Rp7.500', 'Rp6.500', dst.
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
-- [14.png] Milestone Proyek 7 [Kueri 03 - KI-01]: Pencarian Pola LIKE & CONCAT Label
-- Deskripsi: Cari anggota dengan nama berawalan 'A' atau mengandung 'Dewi'
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
-- [15.png] Milestone Proyek 7 [Kueri 04 - KI-01]: Deteksi Kontak Kosong IS NULL & IFNULL
-- Deskripsi: Anggota yang belum mengisi nomor kontak disubstitusi teks 'BELUM MENGISI'
-- Hasil phpMyAdmin: 1 baris anggota (Rizky Pratama, status_kontak 'BELUM MENGISI')
-- ----------------------------------------------------------------------------
SELECT nim_anggota, 
       nama_anggota, 
       alamat_anggota, 
       IFNULL(telepon_anggota, 'BELUM MENGISI') AS status_kontak, 
       status_anggota
FROM anggota
WHERE telepon_anggota IS NULL;


-- ----------------------------------------------------------------------------
-- [16.png] Milestone Proyek 7 [Kueri 05 - KI-02]: Filter Transaksi BETWEEN & Kembalian
-- Deskripsi: Rekapitulasi transaksi 24 September 2026 dan perhitungan selisih kembalian
-- Hasil phpMyAdmin: 10 baris transaksi dengan waktu format dd/mm/yyyy hh:mm
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
-- [17.png] Milestone Proyek 7 [Kueri 06 - KI-02]: Segmentasi Pelanggan Umum IS NULL Belanja > 30rb
-- Deskripsi: Mengidentifikasi pembeli non-anggota (id_anggota NULL) bernilai belanja besar
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
-- [18.png] Milestone Proyek 7 [Kueri 07 - KI-02]: Klasifikasi Skala Nilai Belanja CASE WHEN
-- Deskripsi: Mengelompokkan transaksi menjadi 'Belanja Besar', 'Sedang', atau 'Ringan'
-- Hasil phpMyAdmin: 10 baris transaksi teratas dengan kolom kategori_transaksi
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
-- [19.png] Milestone Proyek 7 [Kueri 08 - KI-01]: Analisis Usia DATEDIFF & Pengelompokan Senioritas
-- Deskripsi: Menghitung umur keanggotaan dalam hari dan label 'Senior' / 'Menengah'
-- Hasil phpMyAdmin: 11 baris anggota koperasi berurutan dari masa gabung terlama
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
-- [20.png] Milestone Proyek 7 [Kueri 09 - KI-04]: Audit Mutasi Poin Loyalitas BETWEEN 2-5
-- Deskripsi: Menyaring mutasi perolehan poin loyalitas yang bernilai antara 2 hingga 5
-- Hasil phpMyAdmin: 10 baris mutasi perolehan poin teratas
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
-- [21.png] Milestone Proyek 7 [Kueri 10 - KI-02]: Identifikasi Transaksi Dibayar Uang Pas
-- Deskripsi: Menemukan nota kasir di mana pembeli membayar dengan uang pas (kembalian 0)
-- Hasil phpMyAdmin: 3 baris transaksi nota dengan selisih_kembalian 0.00
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
-- [22.png] Milestone Proyek 7 [Kueri 11 - KI-05]: Filter Mitra Rekanan Luar Surabaya NOT LIKE
-- Deskripsi: Menyaring pemasok yang alamatnya berada di luar kota Surabaya
-- Hasil phpMyAdmin: 3 baris mitra pemasok (Gresik, Sidoarjo, dan Pasuruan)
-- ----------------------------------------------------------------------------
SELECT id_pemasok, 
       nama_pemasok, 
       telepon_pemasok, 
       alamat_pemasok
FROM pemasok
WHERE alamat_pemasok NOT LIKE '%Surabaya%'
ORDER BY nama_pemasok ASC;


-- ----------------------------------------------------------------------------
-- [23.png] Milestone Proyek 7 [Kueri 12 - KI-03 / KI-02]: Subtotal Item Belanja >= 15rb
-- Deskripsi: Menghitung rincian per baris item belanja dengan subtotal >= Rp15.000
-- Hasil phpMyAdmin: 10 baris item belanja bernilai tinggi teratas
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
-- AKHIR DARI PANDUAN KUERI p07_kueri_siap_ss_phpmyadmin.sql
-- ============================================================================
